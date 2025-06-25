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
    # Call the seeding function from the Seeds module
    KumaSanKanji.Seeds.insert_initial_data()
    IO.puts("Database seeding completed")
  end

  def reset_and_seed do
    load_app()
    start_seed_dependencies()

    IO.puts("Starting database reset...")

    # For PostgreSQL, we need to handle table dropping differently
    for repo <- repos() do
      {:ok, _, _} = Ecto.Migrator.with_repo(repo, fn repo ->
        # Get all table names (excluding system tables)
        result = repo.query!("""
          SELECT tablename
          FROM pg_tables
          WHERE schemaname = 'public'
          AND tablename != 'schema_migrations'
        """, [])

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
    KumaSanKanji.Seeds.insert_initial_data()

    IO.puts("Database reset and seeding completed!")
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

    # Start the repository for database access
    for repo <- repos() do
      {:ok, _} = repo.start_link()
    end
  end
end
