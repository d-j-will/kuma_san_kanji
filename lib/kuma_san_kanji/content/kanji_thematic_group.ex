defmodule KumaSanKanji.Content.KanjiThematicGroup do
  @moduledoc """
  Join table resource between Kanji and ThematicGroup resources.

  This allows many-to-many relationships between kanji and thematic groups,
  with additional metadata like relevance scores and notes.
  """

  use Ash.Resource,
    domain: KumaSanKanji.Content,
    data_layer: AshPostgres.DataLayer

  require Ash.Query

  attributes do
    uuid_primary_key(:id)
    attribute(:kanji_id, :uuid, allow_nil?: false)
    attribute(:relevance_score, :float, default: 1.0)
    attribute(:position, :integer)
    attribute(:notes, :string)
    timestamps()
  end

  relationships do
    belongs_to :thematic_group, KumaSanKanji.Content.ThematicGroup do
      attribute_writable?(true)
      allow_nil?(false)
    end
  end

  identities do
    identity(:unique_kanji_in_group, [:kanji_id, :thematic_group_id])
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:kanji_id, :thematic_group_id, :relevance_score, :position, :notes])
    end

    update :update do
      accept([:relevance_score, :position, :notes])
    end

    read :by_kanji do
      argument(:kanji_id, :uuid, allow_nil?: false)

      prepare(fn query, _context ->
        kanji_id_val = Ash.Query.get_argument(query, :kanji_id)
        Ash.Query.filter(query, kanji_id == ^kanji_id_val)
      end)
    end

    read :by_group do
      argument(:thematic_group_id, :uuid, allow_nil?: false)

      prepare(fn query, _context ->
        group_id_val = Ash.Query.get_argument(query, :thematic_group_id)

        query
        |> Ash.Query.filter(thematic_group_id == ^group_id_val)
        |> Ash.Query.sort([{:position, :asc_nils_last}, {:relevance_score, :desc}])
      end)
    end
  end

  postgres do
    table("kanji_thematic_groups")
    repo(KumaSanKanji.Repo)
  end
end
