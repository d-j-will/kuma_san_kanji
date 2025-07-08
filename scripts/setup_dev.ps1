# Development setup script for KumaSanKanji
# Usage: .\scripts\setup_dev.ps1 [-AdminEmail "email@example.com"]

param(
    [string]$AdminEmail
)

Write-Host "🚀 Setting up development environment..." -ForegroundColor Green

# Set environment variable
$env:ADMIN_EMAIL = $AdminEmail

Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
mix deps.get

Write-Host "🗄️  Setting up database..." -ForegroundColor Yellow
mix ecto.setup

Write-Host "🌱 Running seeds with admin email: $AdminEmail" -ForegroundColor Yellow
mix run priv/repo/seeds.exs

Write-Host "✅ Development setup complete!" -ForegroundColor Green
Write-Host "👤 Admin user configured for: $AdminEmail" -ForegroundColor Cyan
Write-Host "🚀 Start the server with: mix phx.server" -ForegroundColor Cyan
