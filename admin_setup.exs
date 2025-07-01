#!/usr/bin/env elixir

# Admin setup script that finds and updates the admin user
require Logger

# Make sure the required modules are loaded
Code.ensure_loaded?(KumaSanKanji.Accounts)
Code.ensure_loaded?(Ash.Error.Invalid)

admin_email = System.get_env("ADMIN_EMAIL") || "davewil1973@gmail.com"

Logger.info("Setting up admin user with email: #{admin_email}")

case KumaSanKanji.Accounts.get_user_by_email(admin_email, authorize?: false) do
  {:ok, %{admin: true} = user} ->
    Logger.info("✅ User #{user.email} is already an admin")

  {:ok, user} ->
    Logger.info("Making user #{user.email} an admin")
    case KumaSanKanji.Accounts.update_user(user, %{admin: true}, authorize?: false) do
      {:ok, updated_user} ->
        Logger.info("✅ Successfully made #{updated_user.email} an admin")
      {:error, reason} ->
        Logger.error("❌ Failed to make user admin: #{inspect(reason)}")
    end

  {:error, %Ash.Error.Invalid{}} ->
    # User doesn't exist - create placeholder
    Logger.info("Creating admin placeholder for #{admin_email}")
    username = admin_email |> String.split("@") |> List.first()

    case KumaSanKanji.Accounts.create_test_user(%{
      email: admin_email,
      username: username,
      admin: true,
      dev_mode_enabled: true
    }, authorize?: false) do
      {:ok, user} ->
        Logger.info("✅ Created admin placeholder: #{user.email}")
      {:error, reason} ->
        Logger.error("❌ Failed to create admin placeholder: #{inspect(reason)}")
    end

  {:error, reason} ->
    Logger.error("❌ Error finding user: #{inspect(reason)}")
end
