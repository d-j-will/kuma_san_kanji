defmodule KumaSanKanji.Repo.Migrations.FixMigrationState do
  use Ecto.Migration

  def change do
    # This migration fixes the database state by ensuring the columns exist
    # and cleaning up the migration table
    execute """
    DELETE FROM schema_migrations WHERE version = '20250627180021';
    """, ""

    # Add columns only if they don't exist
    execute """
    DO $$
    BEGIN
        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                      WHERE table_name='users' AND column_name='dev_mode_enabled') THEN
            ALTER TABLE users ADD COLUMN dev_mode_enabled boolean NOT NULL DEFAULT false;
        END IF;

        IF NOT EXISTS (SELECT 1 FROM information_schema.columns
                      WHERE table_name='users' AND column_name='admin') THEN
            ALTER TABLE users ADD COLUMN admin boolean NOT NULL DEFAULT false;
        END IF;
    END $$;
    """, """
    ALTER TABLE users DROP COLUMN IF EXISTS admin;
    ALTER TABLE users DROP COLUMN IF EXISTS dev_mode_enabled;
    """
  end
end
