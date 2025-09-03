defmodule KumaSanKanji.Repo.Migrations.AddIndexesToUserKanjiProgress do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  # Adds performance indexes for SRS lookups
  #  - index on user_id for user-scoped stats
  #  - index on kanji_id for reverse lookups / cascading operations
  #  - composite index (user_id, next_review_date) to accelerate due_for_review queries
  def up do
    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS user_kanji_progress_user_id_idx ON user_kanji_progress (user_id)",
            "DROP INDEX IF EXISTS user_kanji_progress_user_id_idx"

    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS user_kanji_progress_kanji_id_idx ON user_kanji_progress (kanji_id)",
            "DROP INDEX IF EXISTS user_kanji_progress_kanji_id_idx"

    execute "CREATE INDEX CONCURRENTLY IF NOT EXISTS user_kanji_progress_user_next_review_idx ON user_kanji_progress (user_id, next_review_date)",
            "DROP INDEX IF EXISTS user_kanji_progress_user_next_review_idx"
  end

  def down do
    execute "DROP INDEX IF EXISTS user_kanji_progress_user_next_review_idx"
    execute "DROP INDEX IF EXISTS user_kanji_progress_kanji_id_idx"
    execute "DROP INDEX IF EXISTS user_kanji_progress_user_id_idx"
  end
end
