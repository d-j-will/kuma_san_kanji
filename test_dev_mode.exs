# Test script to verify the dev mode feature toggle system

# Start the application
Application.ensure_all_started(:kuma_san_kanji)

alias KumaSanKanji.Accounts

# Create a test user using the User resource directly with authorization bypass
user_params = %{
  email: "test-#{System.system_time(:second)}@example.com",  # Unique email
  username: "testuser-#{System.system_time(:second)}"  # Unique username
}

case KumaSanKanji.Accounts.User
     |> Ash.Changeset.for_create(:create_for_test, user_params)
     |> Ash.create(authorize?: false) do
  {:ok, user} ->
    IO.puts("✓ Created test user: #{user.email}")
    IO.puts("  Dev mode enabled: #{user.dev_mode_enabled}")
    IO.puts("  Admin: #{user.admin}")

    # Try to toggle dev mode (this should fail since we're not authenticated as an admin)
    case Accounts.toggle_user_dev_mode(user, true) do
      {:ok, updated_user} ->
        IO.puts("✓ Successfully toggled dev mode")
        IO.puts("  Dev mode enabled: #{updated_user.dev_mode_enabled}")
      {:error, error} ->
        IO.puts("✗ Failed to toggle dev mode (expected): #{inspect(error)}")
    end

    # Try to toggle dev mode with authorization bypass
    case KumaSanKanji.Accounts.User
         |> Ash.Changeset.for_update(:toggle_dev_mode, user, %{enabled: true})
         |> Ash.update(authorize?: false) do
      {:ok, updated_user} ->
        IO.puts("✓ Successfully toggled dev mode with authorization bypass")
        IO.puts("  Dev mode enabled: #{updated_user.dev_mode_enabled}")

        # Also make them an admin
        case updated_user
             |> Ash.Changeset.for_update(:update, %{admin: true})
             |> Ash.update(authorize?: false) do
          {:ok, admin_user} ->
            IO.puts("✓ Successfully made user an admin")
            IO.puts("  Admin: #{admin_user.admin}")

            # Now try toggling dev mode WITH admin privileges
            case Accounts.toggle_user_dev_mode(admin_user, false, actor: admin_user) do
              {:ok, final_user} ->
                IO.puts("✓ Admin successfully toggled dev mode")
                IO.puts("  Dev mode enabled: #{final_user.dev_mode_enabled}")
              {:error, error} ->
                IO.puts("✗ Admin failed to toggle dev mode: #{inspect(error)}")
            end

          {:error, error} ->
            IO.puts("✗ Failed to make user admin: #{inspect(error)}")
        end

      {:error, error} ->
        IO.puts("✗ Failed to toggle dev mode even with bypass: #{inspect(error)}")
    end

  {:error, error} ->
    IO.puts("✗ Failed to create test user: #{inspect(error)}")
end

IO.puts("\n=== Testing LiveHelpers ===")

# Test the LiveHelpers
alias KumaSanKanjiWeb.LiveHelpers

# Get the user with authorization bypass
case KumaSanKanji.Accounts.User
     |> Ash.read(authorize?: false) do
  {:ok, [user | _]} ->
    IO.puts("✓ Testing LiveHelpers with user: #{user.email}")
    IO.puts("  dev_mode_enabled?(user): #{LiveHelpers.dev_mode_enabled?(user)}")
    IO.puts("  admin?(user): #{LiveHelpers.admin?(user)}")
  {:error, error} ->
    IO.puts("✗ Failed to get user: #{inspect(error)}")
  {:ok, []} ->
    IO.puts("No users found")
end
