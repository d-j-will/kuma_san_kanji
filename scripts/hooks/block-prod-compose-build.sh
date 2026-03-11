#!/bin/sh
# Hook: PreToolUse (Write/Edit)
# Blocks `build:` keys in docker-compose.prod.yml.
#
# Production containers must always use pre-built images pulled from GHCR.
#
# Input: JSON on stdin with { "tool_input": { "file_path": "...", "content": "..." } }
# For Edit: { "tool_input": { "file_path": "...", "new_string": "..." } }

INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | grep -o '"file_path":"[^"]*"' | head -1 | sed 's/"file_path":"//;s/"$//')

# Only check prod compose files
case "$FILE_PATH" in
  *docker-compose.prod*) ;;
  *) exit 0 ;;
esac

CONTENT=$(echo "$INPUT" | grep -o '"content":"[^"]*"' | head -1 | sed 's/"content":"//;s/"$//')
if [ -z "$CONTENT" ]; then
  CONTENT=$(echo "$INPUT" | grep -o '"new_string":"[^"]*"' | head -1 | sed 's/"new_string":"//;s/"$//')
fi

if echo "$CONTENT" | grep -qE '^\s*build\s*:'; then
  echo "BLOCKED: \`build:\` key is not allowed in docker-compose.prod.yml."
  echo ""
  echo "Production always uses pre-built images from GHCR."
  echo "Remove the build: key and reference the GHCR image directly:"
  echo "  image: ghcr.io/davewil/kuma-san-kanji:latest"
  exit 2
fi

exit 0
