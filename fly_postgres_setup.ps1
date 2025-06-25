# Development configuration for connecting to Fly Postgres
# 
# To use Fly Postgres in development:
# 1. Set up WireGuard connection to Fly: fly wireguard create
# 2. Set the DATABASE_URL environment variable with your Fly Postgres connection string
# 3. Run: mix phx.server
#
# Example DATABASE_URL format:
# DATABASE_URL=postgres://username:password@hostname:5432/database_name
#
# Get your connection details from: fly postgres connect -a kuma-san-kanji-db

# Alternative: Use fly proxy to connect to Fly Postgres via local proxy
# Run in a separate terminal: fly proxy 5432 -a kuma-san-kanji-db
# Then use: DATABASE_URL=postgres://postgres:password@localhost:5432/database_name

Write-Host "Fly Postgres Development Setup" -ForegroundColor Green
Write-Host "===============================" -ForegroundColor Green
Write-Host ""
Write-Host "Option 1: Direct connection via WireGuard" -ForegroundColor Yellow
Write-Host "1. Set up WireGuard: fly wireguard create" -ForegroundColor White
Write-Host "2. Get connection string: fly postgres connect -a kuma-san-kanji-db" -ForegroundColor White
Write-Host "3. Set DATABASE_URL environment variable" -ForegroundColor White
Write-Host "4. Run: mix phx.server" -ForegroundColor White
Write-Host ""
Write-Host "Option 2: Proxy connection (recommended)" -ForegroundColor Yellow
Write-Host "1. Start proxy: fly proxy 5432 -a kuma-san-kanji-db" -ForegroundColor White
Write-Host "2. In another terminal, set DATABASE_URL and run server" -ForegroundColor White
Write-Host ""
Write-Host "Example DATABASE_URL:" -ForegroundColor Cyan
Write-Host "DATABASE_URL=postgres://postgres:password@localhost:5432/database_name" -ForegroundColor White
