defmodule KumaSanKanji.Content.ThematicGroup do
  @moduledoc """
  Resource for thematic groups.

  Thematic groups organize kanji into meaningful categories like "Numbers",
  "Nature", "People", etc. with support for hierarchical grouping and
  visual customization through colors and icons.
  """
  use Ash.Resource,
    domain: KumaSanKanji.Content,
    data_layer: AshPostgres.DataLayer

  require Ash.Query

  attributes do
    uuid_primary_key(:id)
    attribute(:name, :string, allow_nil?: false)
    attribute(:slug, :string)
    attribute(:description, :string)
    attribute(:color_code, :string)
    attribute(:icon_name, :string)
    attribute(:order_index, :integer)
    timestamps()
  end

  relationships do
    belongs_to :parent, __MODULE__ do
      attribute_writable?(true)
      allow_nil?(true)
    end

    has_many(:children, __MODULE__, destination_attribute: :parent_id)
    has_many(:kanji_associations, KumaSanKanji.Content.KanjiThematicGroup)
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:name, :slug, :description, :color_code, :icon_name, :order_index])
    end

    update :update do
      accept([:name, :slug, :description, :color_code, :icon_name, :order_index])
    end

    read :by_name do
      argument(:name, :string, allow_nil?: false)

      prepare(fn query, _context ->
        name_val = Ash.Query.get_argument(query, :name)
        Ash.Query.filter(query, name == ^name_val)
      end)
    end

    read :by_slug do
      argument(:slug, :string, allow_nil?: false)

      prepare(fn query, _context ->
        slug_val = Ash.Query.get_argument(query, :slug)
        Ash.Query.filter(query, slug == ^slug_val)
      end)
    end

    read :ordered do
      prepare(fn query, _context ->
        Ash.Query.sort(query, order_index: :asc)
      end)
    end

    read :root_groups do
      filter(expr(is_nil(parent_id)))

      prepare(fn query, _context ->
        Ash.Query.sort(query, order_index: :asc)
      end)
    end
  end

  postgres do
    table("thematic_groups")
    repo(KumaSanKanji.Repo)
  end
end
