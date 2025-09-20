defmodule KumaSanKanji.Repo.Migrations.AddCreatedUpdatedToUsers do
  use Ecto.Migration

  def up do
    execute """
    DO $$
    BEGIN
      IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='users' AND column_name='created_at'
      ) THEN
        ALTER TABLE users
          ADD COLUMN created_at timestamp without time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc');
      END IF;

      IF NOT EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='users' AND column_name='updated_at'
      ) THEN
        ALTER TABLE users
          ADD COLUMN updated_at timestamp without time zone NOT NULL DEFAULT (now() AT TIME ZONE 'utc');
      END IF;
    END $$;
    """
  end

  def down do
    execute """
    DO $$
    BEGIN
      IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='users' AND column_name='updated_at'
      ) THEN
        ALTER TABLE users DROP COLUMN updated_at;
      END IF;

      IF EXISTS (
        SELECT 1 FROM information_schema.columns
        WHERE table_name='users' AND column_name='created_at'
      ) THEN
        ALTER TABLE users DROP COLUMN created_at;
      END IF;
    END $$;
    """
  end
end
