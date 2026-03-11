#!/bin/bash
# Setup the .env file on the Docker host for kuma_san_kanji.
# Run this on the Docker host (ssh root@docker-host first).
#
# Usage: bash setup-server-env.sh

set -e

ENV_DIR="/root/kuma_san_kanji"
ENV_FILE="$ENV_DIR/.env"

if [ -f "$ENV_FILE" ]; then
  echo "ERROR: $ENV_FILE already exists. Delete it first if you want to regenerate."
  exit 1
fi

mkdir -p "$ENV_DIR"

# Generate random secrets
POSTGRES_PASSWORD=$(openssl rand -hex 32)
SECRET_KEY_BASE=$(openssl rand -base64 64 | tr -d '\n')
TOKEN_SIGNING_SECRET=$(openssl rand -base64 64 | tr -d '\n')

# Prompt for admin credentials
echo "=== Admin Configuration ==="
read -p "Admin email: " ADMIN_EMAIL
read -sp "Admin password (min 8 chars): " ADMIN_PASSWORD
echo ""

cat > "$ENV_FILE" << EOF
POSTGRES_PASSWORD=$POSTGRES_PASSWORD
SECRET_KEY_BASE=$SECRET_KEY_BASE
TOKEN_SIGNING_SECRET=$TOKEN_SIGNING_SECRET
ADMIN_EMAIL=$ADMIN_EMAIL
ADMIN_PASSWORD=$ADMIN_PASSWORD
EOF

chmod 600 "$ENV_FILE"

echo ""
echo "=== Done ==="
echo "Created $ENV_FILE with generated secrets."
echo "Postgres password and signing keys were auto-generated."
echo ""
echo "Next: push a version tag to trigger the deploy."
