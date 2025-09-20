defmodule KumaSanKanji.Repo.Migrations.FixRadicalsUniqueGlyphIndex do
  use Ecto.Migration

  def up do
    execute """
    WITH ranked AS (
      SELECT id,
             glyph,
             ROW_NUMBER() OVER (PARTITION BY glyph ORDER BY inserted_at NULLS FIRST, id) AS rn
      FROM radicals
    )
    DELETE FROM radicals r
    USING ranked
    WHERE r.id = ranked.id AND ranked.rn > 1;
    """

    execute "CREATE UNIQUE INDEX IF NOT EXISTS radicals_unique_glyph_index ON radicals (glyph)"
    execute "CREATE UNIQUE INDEX IF NOT EXISTS radicals_unique_kangxi_index_index ON radicals (kangxi_index)"
  end

  def down do
    execute "DROP INDEX IF EXISTS radicals_unique_kangxi_index_index"
    execute "DROP INDEX IF EXISTS radicals_unique_glyph_index"
  end
end
