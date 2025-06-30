defmodule KumaSanKanji.Repo.Migrations.AddDevModeAndAdminToUsers do
  use Ecto.Migration

  def change do
    execute(
      """
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
      """,
      ""
    )
  end
end
