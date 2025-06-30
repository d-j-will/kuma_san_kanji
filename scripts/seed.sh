#!/bin/sh
set -e

echo "=== Running application seeds ==="
/app/bin/kuma_san_kanji eval "if File.exists?('/app/priv/repo/seeds.exs'), do: Code.eval_file('/app/priv/repo/seeds.exs'), else: IO.puts('Seeds file not found')"

echo "=== Setting up admin user ==="
/app/bin/kuma_san_kanji eval "Code.eval_file('/app/admin_setup.exs')"
