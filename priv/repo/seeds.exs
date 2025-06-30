defmodule KumaSanKanji.Seeds.AdminSeeds do
  @moduledoc """
  Seed script for creating admin users in KumaSanKanji application.

  Set ADMIN_EMAIL environment variable to specify admin user email.
  """

  require Logger

  def run do
    create_admin_user()
  end

  defp create_admin_user do
    admin_email = System.get_env("ADMIN_EMAIL")

    case admin_email do
      nil ->
        Logger.info("No ADMIN_EMAIL environment variable set. Skipping admin user creation.")

      email when is_binary(email) ->
        Logger.info("Checking for admin user with email: #{email}")

        case find_or_create_admin(email) do
          {:ok, user} ->
            Logger.info("Admin user ready: #{user.email} (admin: #{user.admin})")

          {:error, reason} ->
            Logger.error("Failed to create admin user: #{inspect(reason)}")
        end
    end
  end

  defp find_or_create_admin(email) do
    # First check if user already exists using code interface with authorization bypass
    case KumaSanKanji.Accounts.get_user_by_email(email, authorize?: false) do
      {:ok, %{admin: true} = user} ->
        # User exists and is already admin
        {:ok, user}

      {:ok, user} ->
        # User exists but is not admin - make them admin
        Logger.info("Making existing user #{email} an admin")

        case KumaSanKanji.Accounts.update_user(user, %{admin: true}, authorize?: false) do
          {:ok, updated_user} -> {:ok, updated_user}
          {:error, reason} -> {:error, reason}
        end

      {:error, %Ash.Error.Invalid{errors: [%Ash.Error.Query.NotFound{}]}} ->
        # User doesn't exist - create placeholder for when they sign up
        Logger.info("Creating admin placeholder for #{email}")
        create_admin_placeholder(email)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp create_admin_placeholder(email) do
    # Extract username from email
    username = email |> String.split("@") |> List.first()

    KumaSanKanji.Accounts.create_test_user(%{
      email: email,
      username: username,
      admin: true,
      dev_mode_enabled: true
    }, authorize?: false)
  end
end

# Run all seed data, including admin seeding, in a single place
KumaSanKanji.Seeds.insert_initial_data()
KumaSanKanji.Seeds.AdminSeeds.run()
