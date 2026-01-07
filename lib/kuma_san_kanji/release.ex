defmodule KumaSanKanji.Release do
  @moduledoc """
  Used for executing DB release tasks when run in production without Mix
  installed.
  """
  @app :kuma_san_kanji

  def migrate do
    load_app()

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end
  end

  def rollback(repo, version) do
    load_app()
    {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))
  end

  def seed do
    load_app()

    # Start necessary applications for seeding
    start_seed_dependencies()

    IO.puts("Running database seeds...")
    # Run the complete seed script which includes both initial data and admin seeding
    Code.eval_file("priv/repo/seeds.exs")

    IO.puts("Database seeding completed")
  end

  def reset_and_seed do
    load_app()
    start_seed_dependencies()

    IO.puts("Starting database reset...")

    # For PostgreSQL, we need to handle table dropping differently
    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, fn repo ->
          # Get all table names (excluding system tables)
          result =
            repo.query!(
              """
                SELECT tablename
                FROM pg_tables
                WHERE schemaname = 'public'
                AND tablename != 'schema_migrations'
              """,
              []
            )

          tables = result.rows |> Enum.map(&List.first/1)

          # Drop all tables with CASCADE to handle foreign key constraints
          Enum.each(tables, fn table ->
            repo.query!("DROP TABLE IF EXISTS #{table} CASCADE", [])
            IO.puts("Dropped table: #{table}")
          end)

          # Clean up the schema_migrations table
          repo.query!("DELETE FROM schema_migrations", [])
          IO.puts("Cleaned schema_migrations table")
        end)
    end

    IO.puts("Dropped all tables, running migrations...")

    # Run all migrations back up
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    IO.puts("Migrations complete, seeding database...")

    # Seed the database
    # Run the complete seed script which includes both initial data and admin seeding
    Code.eval_file("priv/repo/seeds.exs")

    IO.puts("Database reset and seeding completed!")
  end

  def setup_admin_user do
    load_app()
    start_seed_dependencies()

    admin_email =
      System.get_env("ADMIN_EMAIL") || raise "Missing environment variable `ADMIN_EMAIL`!"

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
                raise "Admin setup failed: #{inspect(reason)}"
            end
          end

        {:error, _} ->
          # User doesn't exist - create a placeholder admin user
          IO.puts("User not found. Creating admin placeholder for #{admin_email}")
          username = admin_email |> String.split("@") |> List.first()

          case KumaSanKanji.Accounts.create_test_user(
                 %{
                   email: admin_email,
                   username: username,
                   admin: true,
                   dev_mode_enabled: true
                 },
                 authorize?: false
               ) do
            {:ok, user} ->
              IO.puts("✅ Created admin placeholder: #{user.email}")

            {:error, reason} ->
              IO.puts("❌ Failed to create admin placeholder: #{inspect(reason)}")
              raise "Admin creation failed: #{inspect(reason)}"
          end
      end
    rescue
      error ->
        IO.puts("❌ Error during admin setup: #{inspect(error)}")
        reraise error, __STACKTRACE__
    end
  end

  def seed_with_admin do
    load_app()
    start_seed_dependencies()

    IO.puts("Running database seeds with admin setup...")

    # Run the complete seed script which includes both initial data and admin seeding
    Code.eval_file("priv/repo/seeds.exs")

    # Set up admin user
    setup_admin_user()

    IO.puts("Database seeding with admin setup completed")
  end

  def migrate_and_setup do
    load_app()
    start_seed_dependencies()

    IO.puts("Running migrations...")

    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    IO.puts("Migrations completed")

    IO.puts("Setting up admin user...")
    setup_admin_user()
    IO.puts("Admin setup completed")
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp start_seed_dependencies do
    # Start all required applications for Ash and telemetry
    Application.ensure_all_started(:telemetry)
    Application.ensure_all_started(:ash)

    # Start the repository for database access (handle if already started)
    for repo <- repos() do
      case repo.start_link() do
        {:ok, _} -> :ok
        {:error, {:already_started, _}} -> :ok
        {:error, reason} -> raise "Failed to start #{repo}: #{inspect(reason)}"
      end
    end
  end
end
