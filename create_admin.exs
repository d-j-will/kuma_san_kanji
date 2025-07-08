# Simple admin user creation script for production
admin_email = System.get_env?("ADMIN_EMAIL") || raise "Missing environment variable `ADMIN_EMAIL`!"
username = admin_email |> String.split("@") |> List.first()

IO.puts("Creating admin user with email: #{admin_email}")

# Create test user with admin privileges
case KumaSanKanji.Accounts.create_test_user(%{
  email: admin_email,
  username: username,
  admin: true,
  dev_mode_enabled: true
}, authorize?: false) do
  {:ok, user} ->
    IO.puts("Admin user created successfully: #{user.email} (admin: #{user.admin})")
  {:error, %Ash.Error.Invalid{errors: [%Ash.Error.Changes.InvalidAttribute{field: :email, message: "has already been taken"}]}} ->
    IO.puts("User already exists, updating to admin...")
    # Find and update existing user
    case KumaSanKanji.Accounts.get_user_by_email(admin_email, authorize?: false) do
      {:ok, user} ->
        case KumaSanKanji.Accounts.update_user(user, %{admin: true}, authorize?: false) do
          {:ok, updated_user} ->
            IO.puts("User updated to admin: #{updated_user.email} (admin: #{updated_user.admin})")
          {:error, error} ->
            IO.puts("Failed to update user: #{inspect(error)}")
        end
      {:error, error} ->
        IO.puts("Failed to find user: #{inspect(error)}")
    end
  {:error, error} ->
    IO.puts("Failed to create admin user: #{inspect(error)}")
end
