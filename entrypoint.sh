#!/bin/bash
set -e

echo "=== KumaSanKanji Startup ==="

# Check if we need to run migrations
if [ "$RUN_MIGRATIONS" != "false" ]; then
  echo "Running database migrations..."
  /app/bin/kuma_san_kanji eval "KumaSanKanji.Release.migrate()"
  
  echo "Seeding database..."
  /app/bin/kuma_san_kanji eval "KumaSanKanji.Release.seed()"
else
  echo "Database migrations and seeding handled by release command."
fi

echo "=== Starting Phoenix Server ==="
exec /app/bin/kuma_san_kanji start
