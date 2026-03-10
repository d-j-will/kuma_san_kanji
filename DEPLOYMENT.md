# Deployment Guide

Production runs a single app container behind a shared Caddy reverse proxy on a Docker host (Proxmox VM). The CI/CD pipeline builds a Docker image, pushes to GHCR, SSHes into the server via Tailscale, and deploys with `docker-compose.prod.yml`.

## Prerequisites

- Docker host running on Proxmox with Docker + Docker Compose
- Caddy container running on the host (shared with other apps)
- `proxy` Docker network already created (`docker network create proxy`)
- Tailscale configured on both the Docker host and GitHub Actions

## 1. Cloudflare Setup

1. **Add DNS record** for `kanji.davewil.dev`:
   - Type: `A` (or `CNAME`)
   - Name: `kanji`
   - Content: your server's public IP (or Tailscale IP if using Tailscale Funnel)
   - Proxy status: DNS only (grey cloud) — Caddy handles TLS, not Cloudflare

2. **Create API Token** for Caddy DNS challenge (if not already created for slackex):
   - Go to: Cloudflare Dashboard > My Profile > API Tokens
   - Create Token > Custom Token
   - Permissions: `Zone > DNS > Edit`
   - Zone Resources: `Include > Specific zone > davewil.dev`
   - Copy the token — this becomes the `CADDY_CF_TOKEN` secret

## 2. GitHub Actions Secrets

Go to: GitHub repo > Settings > Secrets and variables > Actions > New repository secret

### Required secrets

| Secret | Description | How to get it |
|--------|-------------|---------------|
| `DEPLOY_SSH_KEY` | Ed25519 private key for SSH to Docker host | `ssh-keygen -t ed25519`, add public key to host's `~/.ssh/authorized_keys` |
| `DEPLOY_HOST` | Tailscale IP or hostname of the Docker host | `tailscale ip -4` on the host (e.g., `100.x.y.z`) |
| `TS_OAUTH_CLIENT_ID` | Tailscale OAuth client ID for CI | Tailscale Admin > Settings > OAuth clients > Generate |
| `TAILSCALE_AUTHKEY` | Tailscale OAuth secret | Same as above (the secret paired with the client ID) |
| `CADDY_CF_TOKEN` | Cloudflare API token for DNS-01 TLS challenge | See Cloudflare setup above |

### Shared with slackex

If deploying to the same host as slackex, these secrets can have the same values:
- `DEPLOY_SSH_KEY`
- `DEPLOY_HOST`
- `TS_OAUTH_CLIENT_ID`
- `TAILSCALE_AUTHKEY`
- `CADDY_CF_TOKEN`

`GITHUB_TOKEN` is provided automatically by GitHub Actions for GHCR access.

## 3. Server Setup (first deploy only)

SSH into the Docker host and run:

```bash
# Create app directory
mkdir -p /root/kuma_san_kanji

# Ensure the shared proxy network exists (skip if slackex already created it)
docker network create proxy 2>/dev/null || true

# Create the .env file with production secrets
cat > /root/kuma_san_kanji/.env << 'EOF'
POSTGRES_PASSWORD=<generate: openssl rand -hex 32>
SECRET_KEY_BASE=<generate: mix phx.gen.secret>
TOKEN_SIGNING_SECRET=<generate: mix phx.gen.secret>
AUTH0_CLIENT_ID=<from Auth0 dashboard>
AUTH0_CLIENT_SECRET=<from Auth0 dashboard>
AUTH0_DOMAIN=<e.g., https://your-tenant.auth0.com>
ADMIN_EMAIL=<your admin email>
EOF

chmod 600 /root/kuma_san_kanji/.env
```

## 4. Auth0 Setup

1. Create a new Application in Auth0 Dashboard (Regular Web Application)
2. Set **Allowed Callback URLs**: `https://kanji.davewil.dev/auth/user/auth0/callback`
3. Set **Allowed Logout URLs**: `https://kanji.davewil.dev`
4. Copy Client ID, Client Secret, and Domain into the server `.env` file

## 5. Deploy Process

Deploys trigger on version tags:

```bash
# Check latest tag
git tag --sort=-creatordate | head -5

# Tag and push
git tag v0.1.0
git push && git push --tags
```

The GitHub Actions workflow will:
1. Run quality checks (compile, format, test, audit)
2. Build Docker image and push to `ghcr.io/davewil/kuma-san-kanji`
3. SSH into the Docker host via Tailscale
4. SCP `docker-compose.prod.yml` to the server
5. Append `kanji.davewil.dev` to Caddy config (first deploy only)
6. Pull image, run migrations, setup admin, recreate containers
7. Restart Caddy and smoke test `/health`

## 6. First Deploy: Seed Data

After the first deploy, seed the database and run KanjiVG ingestion:

```bash
ssh root@<DEPLOY_HOST>
cd /root/kuma_san_kanji

# Run seeds
docker compose -f docker-compose.prod.yml run --rm app \
  bin/kuma_san_kanji eval "KumaSanKanji.Release.seed()"
```

## Docker Compose Rules

- **Always use `docker compose pull`**, never bare `docker pull`
- **Always pass `--force-recreate --no-build --remove-orphans`** to `docker compose up`
- **Never define `build:` in `docker-compose.prod.yml`** — production uses pre-built GHCR images

## Infrastructure

- **Caddy**: Shared with slackex at `/opt/caddy/Caddyfile`. The deploy appends the `kanji.davewil.dev` block on first deploy.
- **Proxy network**: The `proxy` Docker network connects Caddy to app containers across compose stacks. The app joins with alias `kanji-app`.
- **Postgres**: Dedicated container for kuma_san_kanji (not shared with slackex).
- **Observability**: OTEL collector, Prometheus, and Grafana run in the slackex stack. To reuse them, add OTEL env vars to the app service later.
- **Portainer**: Running on port 9443 for Docker management.
