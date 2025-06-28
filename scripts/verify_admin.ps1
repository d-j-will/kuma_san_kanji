# Verify admin user script
# Usage: .\scripts\verify_admin.ps1 [-AdminEmail "email@example.com"]

param(
    [string]$AdminEmail = "davewil1973@gmail.com"
)

Write-Host "🔍 Checking admin user status..." -ForegroundColor Green

# Use mix task to check user
$elixirCode = @"
case KumaSanKanji.Accounts.get_user_by_email("$AdminEmail", authorize?: false) do
  {:ok, user} -> 
    IO.puts("✅ User found: #{user.email}")
    IO.puts("👤 Username: #{user.username}")
    IO.puts("🔑 Admin: #{user.admin}")
    IO.puts("🛠️  Dev Mode: #{user.dev_mode_enabled}")
  {:error, _} -> 
    IO.puts("❌ User not found: $AdminEmail")
end
"@

mix run -e $elixirCode

Write-Host "Verification complete!" -ForegroundColor Cyan
