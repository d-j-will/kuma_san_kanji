defmodule KumaSanKanji.Repo.Migrations.AddIndexOnKanjisRadicalId do
  use Ecto.Migration

  def change do
  create index(:kanjis, [:radical_id])
  end
end
