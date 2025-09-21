defmodule KumaSanKanji.Repo.Migrations.CreateTokens do
  use Ecto.Migration

  def up do
    create_if_not_exists table(:tokens, primary_key: false) do
      add :jti, :text, primary_key: true
      add :subject, :text, null: false
      add :expires_at, :utc_datetime, null: false
      add :purpose, :text, null: false
      add :extra_data, :map
      add :created_at, :utc_datetime, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create_if_not_exists index(:tokens, [:subject])
    create_if_not_exists index(:tokens, [:purpose])
  end

  def down do
    drop table(:tokens)
  end
end
