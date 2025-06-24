#!/bin/bash

# Deploy script for KumaSanKanji to Fly.io with PostgreSQL

set -e

echo "🚀 Deploying KumaSanKanji to Fly.io with PostgreSQL"

# Check if flyctl is installed
if ! command -v fly &> /dev/null; then
    echo "❌ flyctl is not installed. Please install it first:"
    echo "   curl -L https://fly.io/install.sh | sh"
    exit 1
fi

# Check if we're logged in to Fly.io
if ! fly auth whoami &> /dev/null; then
    echo "❌ Not logged in to Fly.io. Please run 'fly auth login' first."
    exit 1
fi

echo "📋 Checking existing resources..."

# Check if PostgreSQL app already exists
POSTGRES_APP_NAME="kuma-san-kanji-db"
if fly apps list | grep -q "$POSTGRES_APP_NAME"; then
    echo "✅ PostgreSQL database '$POSTGRES_APP_NAME' already exists"
else
    echo "🗄️  Creating PostgreSQL database..."
    fly postgres create --name "$POSTGRES_APP_NAME" --region lhr --vm-size shared-cpu-1x --initial-cluster-size 1
    echo "✅ PostgreSQL database created"
fi

# Get the database connection string
echo "🔗 Getting database connection string..."
DATABASE_URL=$(fly postgres connect --app "$POSTGRES_APP_NAME" --database kuma_san_kanji --command "SELECT 'postgresql://' || current_user || ':PASSWORD@' || inet_server_addr() || ':' || inet_server_port() || '/' || current_database();" --quiet || true)

if [ -z "$DATABASE_URL" ]; then
    echo "📝 Please manually set the DATABASE_URL secret:"
    echo "   fly secrets set DATABASE_URL=postgresql://username:password@hostname:port/database_name"
    echo "   You can get the connection details with: fly postgres connect --app $POSTGRES_APP_NAME"
else
    echo "🔑 Setting database URL secret..."
    fly secrets set DATABASE_URL="$DATABASE_URL"
fi

# Set other required secrets
echo "🔑 Setting application secrets..."

# Generate secret key base if not already set
SECRET_KEY_BASE=$(openssl rand -base64 64 | tr -d '\n')
fly secrets set SECRET_KEY_BASE="$SECRET_KEY_BASE"

echo "🏗️  Building and deploying application..."
fly deploy

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "📊 Application status:"
fly status

echo ""
echo "🌐 Your application should be available at: https://kuma-san-kanji.fly.dev"
echo ""
echo "📝 Useful commands:"
echo "   fly logs                    - View application logs"
echo "   fly ssh console            - SSH into the application"
echo "   fly postgres connect --app $POSTGRES_APP_NAME - Connect to PostgreSQL"
echo "   fly secrets list           - View application secrets"
