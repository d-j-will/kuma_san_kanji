# Production deployment script with admin seeding
# Usage: .\scripts\deploy_prod.ps1 [-AdminEmail "email@example.com"] [-SetSecret]

param(
    [string]$AdminEmail,
    [switch]$SetSecret = $false
)

Write-Host "🚀 Deploying to production..." -ForegroundColor Green

if ($SetSecret) {
    Write-Host "🔑 Setting admin email secret in Fly.io..." -ForegroundColor Yellow
    fly secrets set ADMIN_EMAIL=$AdminEmail
    Write-Host "✅ Secret set successfully!" -ForegroundColor Green
}

Write-Host "📦 Deploying application..." -ForegroundColor Yellow
fly deploy

Write-Host "🌱 Setting up admin user..." -ForegroundColor Yellow
fly ssh console -C "/app/bin/kuma_san_kanji eval 'KumaSanKanji.Release.setup_admin_user()'"

Write-Host "✅ Production deployment complete!" -ForegroundColor Green
Write-Host "🌐 Application available at: https://kuma-san-kanji.fly.dev" -ForegroundColor Cyan
Write-Host "👤 Admin user configured for: $AdminEmail" -ForegroundColor Cyan
