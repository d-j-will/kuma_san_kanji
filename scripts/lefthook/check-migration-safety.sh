#!/usr/bin/env bash
# Lefthook pre-commit: warn on deploy-unsafe migration patterns in staged migrations.
set -euo pipefail
status=0
for f in "$@"; do
  [ -f "$f" ] || continue
  if grep -nE 'null:\s*false' "$f" | grep -vqE 'default:'; then
    echo "WARN $f: NOT NULL column without a default (unsafe for zero-downtime deploy)"; status=1
  fi
  if grep -nqE '\b(remove|rename|modify)\b' "$f"; then
    echo "WARN $f: column remove/rename/modify detected — confirm expand/contract migration"; status=1
  fi
done
exit "$status"
