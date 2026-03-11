defmodule KumaSanKanji.Repo.Migrations.AddSlugAndPositionToContent do
  use Ecto.Migration

  def up do
    # Expand: add slug column to thematic_groups
    alter table(:thematic_groups) do
      add :slug, :string
    end

    # Backfill existing slugs from name (downcase, replace spaces with hyphens)
    execute """
    UPDATE thematic_groups
    SET slug = lower(replace(name, ' ', '-'))
    WHERE slug IS NULL
    """

    # Now make slug NOT NULL after backfill
    alter table(:thematic_groups) do
      modify :slug, :string, null: false
    end

    create unique_index(:thematic_groups, [:slug])

    # Expand: add position column to kanji_thematic_groups
    alter table(:kanji_thematic_groups) do
      add :position, :integer
    end
  end

  def down do
    alter table(:kanji_thematic_groups) do
      remove :position
    end

    drop_if_exists unique_index(:thematic_groups, [:slug])

    alter table(:thematic_groups) do
      remove :slug
    end
  end
end
