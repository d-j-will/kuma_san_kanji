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

    admin_password = System.get_env("ADMIN_PASSWORD")
    IO.puts("Setting up admin user with email: #{admin_email}")

    try do
      case KumaSanKanji.Accounts.get_user_by_email(admin_email, authorize?: false) do
        {:ok, user} ->
          if user.admin do
            IO.puts("Admin user #{user.email} already exists")
          else
            IO.puts("Making user #{user.email} an admin...")

            case KumaSanKanji.Accounts.update_user(user, %{admin: true}, authorize?: false) do
              {:ok, updated_user} ->
                IO.puts("Successfully made #{updated_user.email} an admin")

              {:error, reason} ->
                raise "Admin setup failed: #{inspect(reason)}"
            end
          end

        {:error, _} ->
          # User doesn't exist - register with password
          password = admin_password || generate_random_password()
          IO.puts("Creating admin user for #{admin_email}")

          user =
            KumaSanKanji.Accounts.User
            |> Ash.Changeset.for_create(:register_with_password, %{
              email: admin_email,
              password: password
            })
            |> Ash.create!(authorize?: false)

          # Make them admin
          KumaSanKanji.Accounts.update_user(user, %{admin: true, dev_mode_enabled: true},
            authorize?: false
          )

          IO.puts("Created admin user: #{admin_email}")
          unless admin_password, do: IO.puts("Generated password: #{password}")
      end
    rescue
      error ->
        IO.puts("Error during admin setup: #{inspect(error)}")
        reraise error, __STACKTRACE__
    end
  end

  defp generate_random_password do
    :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)
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

    if System.get_env("ADMIN_EMAIL") not in [nil, ""] do
      IO.puts("Setting up admin user...")
      setup_admin_user()
      IO.puts("Admin setup completed")
    else
      IO.puts("ADMIN_EMAIL not set, skipping admin setup")
    end
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end

  defp start_seed_dependencies do
    Application.ensure_all_started(@app)
  end
end
