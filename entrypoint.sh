#!/bin/bash
set -e

echo "=== KumaSanKanji Startup ==="

# Migrations are handled by the release command in fly.toml
# This script will now only start the server.

echo "=== Starting Phoenix Server ==="
exec /app/bin/kuma_san_kanji start
