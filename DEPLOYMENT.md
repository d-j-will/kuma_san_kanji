# Deployment Guide - PostgreSQL on Fly.io

This guide explains how to deploy KumaSanKanji to Fly.io using PostgreSQL instead of SQLite.

## Prerequisites

1. **Install flyctl**: Visit [https://fly.io/docs/hands-on/install-flyctl/](https://fly.io/docs/hands-on/install-flyctl/)
2. **Login to Fly.io**: Run `fly auth login`
3. **Have PostgreSQL ready**: Either use Fly's managed PostgreSQL or an external provider

## Quick Deployment

### Option 1: Using the Deploy Script (Recommended)

**On Linux/Mac:**
```bash
chmod +x scripts/deploy-fly.sh
./scripts/deploy-fly.sh
```

**On Windows:**
```powershell
.\scripts\deploy-fly.ps1
```

### Option 2: Manual Deployment

1. **Create PostgreSQL Database** (if not already created):
   ```bash
   fly postgres create --name kuma-san-kanji-db --region lhr --vm-size shared-cpu-1x --initial-cluster-size 1
   ```

2. **Get Database Connection String**:
   ```bash
   fly postgres connect --app kuma-san-kanji-db
   ```
   Note the connection details for the next step.

3. **Set Application Secrets**:
   ```bash
   # Replace with your actual database credentials
   fly secrets set DATABASE_URL="postgresql://username:password@hostname:port/database_name"
   
   # Generate and set secret key base
   fly secrets set SECRET_KEY_BASE="$(openssl rand -base64 64)"
   ```

4. **Deploy the Application**:
   ```bash
   fly deploy
   ```

## Configuration Changes Made

### 1. Updated `fly.toml`
- Removed SQLite-specific configuration (`DATABASE_PATH`, mounts)
- Added `release_command` to run migrations and seeding on deploy
- Removed the volume mount (no longer needed for PostgreSQL)

### 2. Updated Release Module (`lib/kuma_san_kanji/release.ex`)
- Changed `reset_and_seed/0` to work with PostgreSQL instead of SQLite
- Uses PostgreSQL-specific queries to drop tables with CASCADE

### 3. Created Release Scripts
- `rel/overlays/bin/migrate_and_seed` - Runs migrations and seeding
- `rel/overlays/bin/migrate_and_seed.bat` - Windows version

### 4. Updated Dockerfile
- Includes entrypoint script that runs migrations and seeding before starting the server
- Copies priv directory for migrations and seeds

## Database Migration Process

When you deploy, the following happens automatically:

1. **Build Phase**: Application is compiled with PostgreSQL configuration
2. **Release Phase**: `migrate_and_seed` script runs:
   - Executes all pending migrations
   - Seeds the database with initial kanji data
3. **Runtime Phase**: Application starts and serves requests

## Environment Variables

The application expects these environment variables in production:

- `DATABASE_URL`: PostgreSQL connection string
- `SECRET_KEY_BASE`: Secret key for encryption (auto-generated)
- `PHX_HOST`: Host name (set to `kuma-san-kanji.fly.dev`)
- `PORT`: Server port (set to `8080`)
- `PHX_SERVER`: Enable Phoenix server (set to `true`)

## Monitoring and Maintenance

### View Logs
```bash
fly logs
```

### SSH into Application
```bash
fly ssh console
```

### Connect to PostgreSQL
```bash
fly postgres connect --app kuma-san-kanji-db
```

### Check Application Status
```bash
fly status
```

### Manual Migration (if needed)
```bash
fly ssh console
# Inside the container:
/app/bin/kuma_san_kanji eval "KumaSanKanji.Release.migrate()"
```

### Manual Seeding (if needed)
```bash
fly ssh console
# Inside the container:
/app/bin/kuma_san_kanji eval "KumaSanKanji.Release.seed()"
```

## Rollback Process

If you need to rollback a deployment:

1. **Rollback Application**:
   ```bash
   fly releases
   fly releases rollback <version>
   ```

2. **Rollback Database** (if schema changes were made):
   ```bash
   fly ssh console
   /app/bin/kuma_san_kanji eval "KumaSanKanji.Release.rollback(KumaSanKanji.Repo, <version>)"
   ```

## Troubleshooting

### Common Issues

1. **Database Connection Errors**:
   - Check `DATABASE_URL` is set correctly: `fly secrets list`
   - Verify PostgreSQL app is running: `fly status --app kuma-san-kanji-db`

2. **Migration Errors**:
   - Check logs: `fly logs`
   - SSH and run migrations manually
   - Verify database schema with: `fly postgres connect --app kuma-san-kanji-db`

3. **Seeding Errors**:
   - Check if data already exists (seeding is idempotent)
   - Run seeding manually: `fly ssh console` then eval the seed function

### Useful Commands

```bash
# View all apps
fly apps list

# View secrets
fly secrets list

# Set a secret
fly secrets set KEY=value

# Remove a secret
fly secrets unset KEY

# View PostgreSQL status
fly status --app kuma-san-kanji-db

# PostgreSQL logs
fly logs --app kuma-san-kanji-db

# Scale application
fly scale count 1

# Update application configuration
fly deploy
```

## Production Considerations

1. **Backup Strategy**: Set up regular PostgreSQL backups
2. **Monitoring**: Consider adding application monitoring
3. **SSL**: PostgreSQL connections use SSL by default
4. **Performance**: Monitor database performance and consider scaling
5. **Security**: Regularly rotate secrets and update dependencies

## Cost Optimization

- **Shared CPU**: Using shared-cpu-1x for cost efficiency
- **Auto-stop**: Machines auto-stop when idle to save costs
- **Min Machines**: Set to 0 for maximum cost savings (cold starts acceptable)

For production workloads, consider:
- Dedicated CPU instances
- Multiple regions for redundancy
- Larger PostgreSQL instances
- Connection pooling (PgBouncer)
