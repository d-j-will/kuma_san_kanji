defmodule KumaSanKanji.Repo.Migrations.DropHashedPasswordFromUsers do
  use Ecto.Migration

  def change do
  execute """
  DO $$
  BEGIN
    IF EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_name='users' AND column_name='hashed_password'
    ) THEN
      ALTER TABLE users DROP COLUMN hashed_password;
    END IF;
  END $$;
  """, """
  ALTER TABLE users ADD COLUMN IF NOT EXISTS hashed_password text;
  UPDATE users SET hashed_password = '' WHERE hashed_password IS NULL;
  ALTER TABLE users ALTER COLUMN hashed_password SET NOT NULL;
  """
  end
end
