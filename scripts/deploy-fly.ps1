# Deploy script for KumaSanKanji to Fly.io with PostgreSQL

$ErrorActionPreference = "Stop"

Write-Host "🚀 Deploying KumaSanKanji to Fly.io with PostgreSQL" -ForegroundColor Green

# Check if flyctl is installed
if (-not (Get-Command fly -ErrorAction SilentlyContinue)) {
    Write-Host "❌ flyctl is not installed. Please install it first:" -ForegroundColor Red
    Write-Host "   Visit https://fly.io/docs/hands-on/install-flyctl/ for installation instructions"
    exit 1
}

# Check if we're logged in to Fly.io
try {
    fly auth whoami | Out-Null
} catch {
    Write-Host "❌ Not logged in to Fly.io. Please run 'fly auth login' first." -ForegroundColor Red
    exit 1
}

Write-Host "📋 Checking existing resources..." -ForegroundColor Blue

# Check if PostgreSQL app already exists
$POSTGRES_APP_NAME = "kuma-san-kanji-db"
$apps = fly apps list
if ($apps -match $POSTGRES_APP_NAME) {
    Write-Host "✅ PostgreSQL database '$POSTGRES_APP_NAME' already exists" -ForegroundColor Green
} else {
    Write-Host "🗄️  Creating PostgreSQL database..." -ForegroundColor Blue
    fly postgres create --name $POSTGRES_APP_NAME --region lhr --vm-size shared-cpu-1x --initial-cluster-size 1
    Write-Host "✅ PostgreSQL database created" -ForegroundColor Green
}

Write-Host "🔑 Setting application secrets..." -ForegroundColor Blue

# Set database URL (user will need to set this manually with the correct credentials)
Write-Host "📝 Please manually set the DATABASE_URL secret:" -ForegroundColor Yellow
Write-Host "   fly secrets set DATABASE_URL=postgresql://username:password@hostname:port/database_name" -ForegroundColor Yellow
Write-Host "   You can get the connection details with: fly postgres connect --app $POSTGRES_APP_NAME" -ForegroundColor Yellow

# Generate secret key base
$SECRET_KEY_BASE = [System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(48))
fly secrets set SECRET_KEY_BASE=$SECRET_KEY_BASE

Write-Host "🏗️  Building and deploying application..." -ForegroundColor Blue
fly deploy

Write-Host ""
Write-Host "🎉 Deployment complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Application status:" -ForegroundColor Blue
fly status

Write-Host ""
Write-Host "🌐 Your application should be available at: https://kuma-san-kanji.fly.dev" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Useful commands:" -ForegroundColor Blue
Write-Host "   fly logs                    - View application logs"
Write-Host "   fly ssh console            - SSH into the application"
Write-Host "   fly postgres connect --app $POSTGRES_APP_NAME - Connect to PostgreSQL"
Write-Host "   fly secrets list           - View application secrets"
