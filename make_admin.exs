# Make user admin script
admin_email = "davewil1973@gmail.com"

case KumaSanKanji.Accounts.get_user_by_email(admin_email, authorize?: false) do
  {:ok, user} -> 
    IO.puts("Making user #{user.email} an admin...")
    case KumaSanKanji.Accounts.update_user(user, %{admin: true}, authorize?: false) do
      {:ok, updated_user} -> 
        IO.puts("✅ Successfully made #{updated_user.email} an admin")
        IO.puts("🔑 Admin: #{updated_user.admin}")
      {:error, reason} -> 
        IO.puts("❌ Failed to make user admin: #{inspect(reason)}")
    end
  {:error, error} -> 
    IO.puts("❌ User not found")
    IO.inspect(error, label: "Error")
end
