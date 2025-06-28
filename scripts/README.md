# Scripts Directory

This directory contains PowerShell scripts for development and deployment tasks.

## Development Scripts

### `setup_dev.ps1`
Complete development environment setup including admin user configuration.

```powershell
# Default setup (uses davewil1973@gmail.com as admin)
.\scripts\setup_dev.ps1

# Custom admin email
.\scripts\setup_dev.ps1 -AdminEmail "your@email.com"
```

**What it does:**
- Installs dependencies (`mix deps.get`)
- Sets up database (`mix ecto.setup`)
- Runs seeds with admin user creation

### `seed_admin.ps1`
Quick admin user seeding for existing development environments.

```powershell
# Default admin email
.\scripts\seed_admin.ps1

# Custom admin email
.\scripts\seed_admin.ps1 -AdminEmail "your@email.com"
```

**What it does:**
- Sets `ADMIN_EMAIL` environment variable
- Runs seeds to create/update admin user

## Production Scripts

### `deploy_prod.ps1`
Production deployment with admin user configuration.

```powershell
# Deploy without setting secrets (admin email already configured)
.\scripts\deploy_prod.ps1

# Deploy and set admin email secret
.\scripts\deploy_prod.ps1 -AdminEmail "your@email.com" -SetSecret

# Just set the secret without deploying
.\scripts\deploy_prod.ps1 -AdminEmail "your@email.com" -SetSecret -SkipDeploy
```

**What it does:**
- Optionally sets `ADMIN_EMAIL` as a Fly.io secret
- Deploys the application
- Runs production seeds to create admin user

## Environment Variables

### `ADMIN_EMAIL`
The email address of the user who should have admin privileges.

**Local Development:**
Set automatically by the scripts above.

**Production (Fly.io):**
```powershell
# Set once using Fly CLI
fly secrets set ADMIN_EMAIL=your@email.com

# Or use the deploy script with -SetSecret flag
.\scripts\deploy_prod.ps1 -AdminEmail "your@email.com" -SetSecret
```

## Security Notes

- Admin email is configured via environment variables, never hard-coded
- Local scripts in `.gitignore` pattern `scripts/local_*.ps1` are excluded from git
- Production uses Fly.io secrets for secure configuration
- Seeding is idempotent - safe to run multiple times

## Manual Operations

### Local Development
```powershell
# Set admin email and run seeds manually
$env:ADMIN_EMAIL = "your@email.com"
mix run priv/repo/seeds.exs
```

### Production
```powershell
# Run seeds manually in production
fly ssh console -C "/app/bin/kuma_san_kanji eval 'Code.eval_file(\"/app/priv/repo/seeds.exs\")'"

# Or use the release task
fly ssh console -C "/app/bin/kuma_san_kanji eval 'KumaSanKanji.Release.seed()'"
```
