defmodule KumaSanKanji.Repo.Migrations.BackfillSrsStages do
  @moduledoc """
  Backfills srs_stage on existing user_kanji_progress records based on
  their current SM-2 interval values.

  Stage mapping (Bear Seasons):
    interval < 1   → stage 1   (Mezame 1)
    interval = 1   → stage 3   (Mezame 3)
    interval = 2   → stage 4   (Mezame 4)
    interval 3-7   → stage 5   (Sakari 1)
    interval 8-14  → stage 6   (Sakari 2)
    interval 15-60 → stage 7   (Minori)
    interval > 60  → stage 8   (Chikara)

  Never sets stage 9 (Tomin) — users must earn hibernation through the
  new system.

  Idempotent: only updates records still at the default (srs_stage = 1)
  that have a positive interval (reviewed at least once).
  """

  use Ecto.Migration

  def up do
    execute("""
    UPDATE user_kanji_progress
    SET srs_stage = CASE
      WHEN interval < 1 THEN 1
      WHEN interval = 1 THEN 3
      WHEN interval = 2 THEN 4
      WHEN interval BETWEEN 3 AND 7 THEN 5
      WHEN interval BETWEEN 8 AND 14 THEN 6
      WHEN interval BETWEEN 15 AND 60 THEN 7
      WHEN interval > 60 THEN 8
      ELSE 1
    END
    WHERE srs_stage = 1
    AND interval > 0
    """)
  end

  def down do
    execute("UPDATE user_kanji_progress SET srs_stage = 1")
  end
end
