#!/bin/bash
# Simple admin setup script
cd /app && /app/bin/kuma_san_kanji eval 'Code.eval_file("/app/priv/repo/seeds.exs")'
