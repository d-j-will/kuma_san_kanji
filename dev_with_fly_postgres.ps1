# PowerShell script to run development server with Fly Postgres
param(
    [string]$DatabaseUrl = "",
    [switch]$Help
)

if ($Help) {
    Write-Host "Kuma San Kanji - Development with Fly Postgres" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor Yellow
    Write-Host "  .\dev_with_fly_postgres.ps1 -DatabaseUrl 'postgres://user:pass@host:port/db'" -ForegroundColor White
    Write-Host ""
    Write-Host "This script will:" -ForegroundColor Yellow
    Write-Host "  1. Start Fly proxy to your Postgres database" -ForegroundColor White
    Write-Host "  2. Set up the development environment" -ForegroundColor White
    Write-Host "  3. Run database migrations" -ForegroundColor White
    Write-Host "  4. Start the Phoenix server" -ForegroundColor White
    Write-Host ""
    Write-Host "Prerequisites:" -ForegroundColor Yellow
    Write-Host "  - Fly CLI installed and authenticated" -ForegroundColor White
    Write-Host "  - Fly Postgres database 'kuma-san-kanji-db' exists" -ForegroundColor White
    Write-Host ""
    Write-Host "To get your database URL:" -ForegroundColor Yellow
    Write-Host "  fly postgres connect -a kuma-san-kanji-db" -ForegroundColor White
    exit
}

Write-Host "🚀 Starting Kuma San Kanji Development with Fly Postgres" -ForegroundColor Green
Write-Host "=========================================================" -ForegroundColor Green

# Start Fly proxy in background
Write-Host "📡 Starting Fly Postgres proxy on port 5433..." -ForegroundColor Yellow
$proxyJob = Start-Job -ScriptBlock {
    fly proxy 5433 -a kuma-san-kanji-db
}

# Wait for proxy to start
Write-Host "⏳ Waiting for proxy to initialize..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Set DATABASE_URL
if ($DatabaseUrl -eq "") {
    Write-Host "⚠️  No DATABASE_URL provided. Using default localhost connection on port 5433." -ForegroundColor Yellow
    Write-Host "   Make sure your Fly Postgres credentials match the default." -ForegroundColor Yellow
    $env:DATABASE_URL = "postgres://postgres:password@localhost:5433/kuma_san_kanji_dev"
} else {
    $env:DATABASE_URL = $DatabaseUrl
    Write-Host "✅ DATABASE_URL set to: $DatabaseUrl" -ForegroundColor Green
}

# Set development environment
$env:MIX_ENV = "dev"
$env:PHX_SERVER = "true"

Write-Host "🔨 Setting up database..." -ForegroundColor Yellow

try {
    # Create and migrate database
    mix ecto.create
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Database created successfully" -ForegroundColor Green
    }
    
    mix ecto.migrate
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Migrations completed successfully" -ForegroundColor Green
    }
    
    # Run seeds if they exist
    if (Test-Path "priv/repo/seeds.exs") {
        Write-Host "🌱 Running database seeds..." -ForegroundColor Yellow
        mix run priv/repo/seeds.exs
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Seeds completed successfully" -ForegroundColor Green
        }
    }
    
    Write-Host ""
    Write-Host "🌟 Starting Phoenix development server..." -ForegroundColor Green
    Write-Host "   Server will be available at: http://localhost:4000" -ForegroundColor Cyan
    Write-Host "   Press Ctrl+C to stop the server and cleanup" -ForegroundColor Yellow
    Write-Host ""
    
    # Start Phoenix server
    mix phx.server
}
catch {
    Write-Host "❌ Error occurred: $_" -ForegroundColor Red
}
finally {
    Write-Host ""
    Write-Host "🧹 Cleaning up..." -ForegroundColor Yellow
    
    # Stop the proxy job
    if ($proxyJob) {
        Stop-Job $proxyJob -ErrorAction SilentlyContinue
        Remove-Job $proxyJob -ErrorAction SilentlyContinue
        Write-Host "✅ Fly proxy stopped" -ForegroundColor Green
    }
    
    Write-Host "👋 Development session ended" -ForegroundColor Green
}
