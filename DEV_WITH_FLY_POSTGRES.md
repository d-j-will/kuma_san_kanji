# Development with Fly Postgres

This project is configured to use Fly Postgres for both development and production environments.

## Setup

### Option 1: Using Fly Proxy (Recommended)

1. **Start the Fly Postgres proxy** in one terminal:

   ```powershell
   fly proxy 5433 -a kuma-san-kanji-db
   ```

2. **Set up your environment** in another terminal:

   ```powershell
   # Navigate to project directory
   cd d:\work\elixir\kuma_san_kanji

   # Set the DATABASE_URL environment variable
   # Replace the connection details with your actual Fly Postgres credentials
   $env:DATABASE_URL = "postgres://postgres:your_password@localhost:5433/your_database_name"

   # Run database setup
   mix ecto.create
   mix ecto.migrate
   mix run priv/repo/seeds.exs

   # Start the development server
   mix phx.server
   ```

### Option 2: Direct Connection via WireGuard

1. **Set up WireGuard connection to Fly**:

   ```powershell
   fly wireguard create
   ```

2. **Get your database connection details**:

   ```powershell
   fly postgres connect -a kuma-san-kanji-db
   ```

3. **Set the DATABASE_URL with the direct connection**:

   ```powershell
   $env:DATABASE_URL = "postgres://username:password@hostname:5432/database_name"
   ```

4. **Run the application**:

   ```powershell
   mix phx.server
   ```

## Docker Development

If you prefer using Docker for development:

1. **Start the Fly proxy** (in host terminal):

   ```powershell
   fly proxy 5433 -a kuma-san-kanji-db
   ```

2. **Set DATABASE_URL environment variable** and run Docker:

   ```powershell
   $env:DATABASE_URL = "postgres://postgres:your_password@host.docker.internal:5433/your_database_name"
   docker-compose up
   ```

## Important Notes

- The local PostgreSQL container has been removed from docker-compose.yml
- Your application now uses Fly Postgres for both development and production
- Make sure to set the correct DATABASE_URL based on your Fly Postgres credentials
- The `dev.exs` config will automatically use DATABASE_URL if present, falling back to local config

## Database Management

- **Connect to database**: `fly postgres connect -a kuma-san-kanji-db`
- **View database info**: `fly postgres list`
- **Create migrations**: `mix ecto.gen.migration migration_name`
- **Run migrations**: `mix ecto.migrate`

## Troubleshooting

- If you get connection errors, ensure the Fly proxy is running
- Check that your DATABASE_URL is correctly formatted
- Verify that your Fly Postgres database is running: `fly status -a kuma-san-kanji-db`
