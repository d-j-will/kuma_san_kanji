defmodule KumaSanKanji.Repo.Migrations.AddMissingPerformanceIndexes do
  use Ecto.Migration

  @disable_ddl_transaction true
  @disable_migration_lock true

  def up do
    # Index for getting kanji by character (used in Explore and searches)
    create_index("kanjis", [:character], concurrent: true)

    # Missing indexes on foreign keys to kanji_id
    create_index("kanji_pronunciations", [:kanji_id], concurrent: true)
    create_index("kanji_meanings", [:kanji_id], concurrent: true)
    create_index("kanji_example_sentences", [:kanji_id], concurrent: true)

    # Index for thematic groups hierarchy
    create_index("thematic_groups", [:parent_id], concurrent: true)
    
    # Index for kanji thematic groups lookup
    create_index("kanji_thematic_groups", [:kanji_id], concurrent: true)
    create_index("kanji_thematic_groups", [:thematic_group_id], concurrent: true)
  end

  def down do
    drop_index("kanji_thematic_groups", [:thematic_group_id], concurrent: true)
    drop_index("kanji_thematic_groups", [:kanji_id], concurrent: true)
    drop_index("thematic_groups", [:parent_id], concurrent: true)
    drop_index("kanji_example_sentences", [:kanji_id], concurrent: true)
    drop_index("kanji_meanings", [:kanji_id], concurrent: true)
    drop_index("kanji_pronunciations", [:kanji_id], concurrent: true)
    drop_index("kanjis", [:character], concurrent: true)
  end

  defp create_index(table, columns, opts) do
    index_name = "#{table}_#{Enum.join(columns, "_")}_idx"
    concurrent = if opts[:concurrent], do: "CONCURRENTLY", else: ""
    
    execute "CREATE INDEX #{concurrent} IF NOT EXISTS #{index_name} ON #{table} (#{Enum.join(columns, ", ")})",
            "DROP INDEX IF EXISTS #{index_name}"
  end

  defp drop_index(table, columns, opts) do
    index_name = "#{table}_#{Enum.join(columns, "_")}_idx"
    concurrent = if opts[:concurrent], do: "CONCURRENTLY", else: ""
    
    execute "DROP INDEX #{concurrent} IF EXISTS #{index_name}", ""
  end
end