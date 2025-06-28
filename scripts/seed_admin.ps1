# Quick admin seeding script for local development
# Usage: .\scripts\seed_admin.ps1 [-AdminEmail "email@example.com"]

param(
    [string]$AdminEmail = "davewil1973@gmail.com"
)

Write-Host "🔧 Setting up admin user for local development..." -ForegroundColor Green

# Set the admin email for local development
$env:ADMIN_EMAIL = $AdminEmail

# Run the seed script
Write-Host "🌱 Running seeds with ADMIN_EMAIL=$AdminEmail" -ForegroundColor Yellow
mix run priv/repo/seeds.exs

Write-Host "✅ Admin seeding complete!" -ForegroundColor Green
Write-Host "👤 Admin user ready: $AdminEmail" -ForegroundColor Cyan
