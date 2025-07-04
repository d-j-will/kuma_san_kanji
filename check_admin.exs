# Check admin user script
admin_email = "davewil1973@gmail.com"

case KumaSanKanji.Accounts.get_user_by_email(admin_email, authorize?: false) do
  {:ok, user} ->
    IO.puts("✅ User found: #{user.email}")
    IO.puts("👤 Username: #{user.username}")
    IO.puts("🔑 Admin: #{user.admin}")
    IO.puts("🛠️  Dev Mode: #{user.dev_mode_enabled}")
    IO.puts("📅 Created: #{user.created_at}")
    IO.inspect(user, label: "Full User")
  {:error, error} ->
    IO.puts("❌ User not found")
    IO.inspect(error, label: "Error")
end
