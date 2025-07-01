defmodule KumaSanKanji.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  # Force rebuild - cache invalidation

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start telemetry supervisor in all environments
      KumaSanKanjiWeb.Telemetry,
      {Ecto.Migrator,
       repos: Application.fetch_env!(:kuma_san_kanji, :ecto_repos), skip: skip_migrations?()},
      {DNSCluster, query: Application.get_env(:kuma_san_kanji, :dns_cluster_query) || :ignore},
      # Start the Finch HTTP client for sending emails
      {Phoenix.PubSub, name: KumaSanKanji.PubSub},
      {Finch, name: KumaSanKanji.Finch},
      # Start the Ash SQLite repository
      KumaSanKanji.Repo,
      # Start the Quiz Session manager
      KumaSanKanji.Quiz.Session,
      # Start to serve requests, typically the last entry
      KumaSanKanjiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KumaSanKanji.Supervisor]

    case Supervisor.start_link(children, opts) do
      {:ok, pid} = result ->
        result
      error ->
        error
    end
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    KumaSanKanjiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp skip_migrations?() do
    # Skip migrations in test environment and releases
    System.get_env("RELEASE_NAME") != nil or Application.get_env(:kuma_san_kanji, :env) == :test
  end

  defp setup_admin_user_async do
    # Wait a bit for the application to fully start
    Process.sleep(2000)

    admin_email = System.get_env("ADMIN_EMAIL") || "davewil1973@gmail.com"
    IO.puts("Setting up admin user with email: #{admin_email}")

    try do
      case KumaSanKanji.Accounts.get_user_by_email(admin_email, authorize?: false) do
        {:ok, user} ->
          if user.admin do
            IO.puts("✅ User #{user.email} is already an admin")
          else
            IO.puts("Making user #{user.email} an admin...")
            case KumaSanKanji.Accounts.update_user(user, %{admin: true}, authorize?: false) do
              {:ok, updated_user} ->
                IO.puts("✅ Successfully made #{updated_user.email} an admin")
              {:error, reason} ->
                IO.puts("❌ Failed to make user admin: #{inspect(reason)}")
            end
          end

        {:error, _} ->
          # User doesn't exist - create a placeholder admin user
          IO.puts("User not found. Creating admin placeholder for #{admin_email}")
          username = admin_email |> String.split("@") |> List.first()

          case KumaSanKanji.Accounts.create_test_user(%{
            email: admin_email,
            username: username,
            admin: true,
            dev_mode_enabled: true
          }, authorize?: false) do
            {:ok, user} ->
              IO.puts("✅ Created admin placeholder: #{user.email}")
            {:error, reason} ->
              IO.puts("❌ Failed to create admin placeholder: #{inspect(reason)}")
          end
      end
    rescue
      error ->
        IO.puts("❌ Error during admin setup: #{inspect(error)}")
    end
  end
end
