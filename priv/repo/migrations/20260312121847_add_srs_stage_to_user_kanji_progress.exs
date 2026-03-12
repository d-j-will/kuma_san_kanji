defmodule KumaSanKanji.Repo.Migrations.AddSrsStageToUserKanjiProgress do
  use Ecto.Migration

  def up do
    alter table(:user_kanji_progress) do
      add(:srs_stage, :integer, default: 1)
    end

    # Index for querying by stage (dashboard counts)
    create(index(:user_kanji_progress, [:user_id, :srs_stage]))
  end

  def down do
    drop_if_exists(index(:user_kanji_progress, [:user_id, :srs_stage]))

    alter table(:user_kanji_progress) do
      remove(:srs_stage)
    end
  end
end
