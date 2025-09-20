defmodule KumaSanKanji.Kanji.Kanji do
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshPostgres.DataLayer

  require Ash.Query

  attributes do
    uuid_primary_key(:id)
    attribute(:character, :string, allow_nil?: false)
    attribute(:grade, :integer, default: nil)
    attribute(:stroke_count, :integer, default: nil)
    attribute(:jlpt_level, :integer, default: nil)
    timestamps()
  end

  relationships do
    belongs_to :radical, KumaSanKanji.Kanji.Radical,
      allow_nil?: true,
      define_attribute?: true

    has_many(:meanings, KumaSanKanji.Kanji.Meaning, destination_attribute: :kanji_id)
    has_many(:pronunciations, KumaSanKanji.Kanji.Pronunciation, destination_attribute: :kanji_id)

    has_many(:example_sentences, KumaSanKanji.Kanji.ExampleSentence,
      destination_attribute: :kanji_id
    )
  end

  actions do
    defaults([:read, :destroy])

    create :create do
      accept([:character, :grade, :stroke_count, :jlpt_level, :radical_id])
    end

    update :update do
      accept([:character, :grade, :stroke_count, :jlpt_level, :radical_id])
    end

    read :list_all do
      pagination offset?: true, keyset?: true, countable: :by_default
      prepare(fn query, _context ->
        query
        |> Ash.Query.load([:meanings, :pronunciations, :example_sentences, :radical])
        |> Ash.Query.sort(:inserted_at)
      end)
    end

    read :get_by_character do
      get? true
      argument(:character, :string, allow_nil?: false)
      filter expr(character == ^arg(:character))
      prepare(fn query, _context ->
        query |> Ash.Query.load([:meanings, :pronunciations, :example_sentences, :radical])
      end)
    end

    read :get_by_id do
      get? true
      argument(:id, :uuid, allow_nil?: false)
      filter expr(id == ^arg(:id))
      prepare(fn query, _context ->
        query |> Ash.Query.load([:meanings, :pronunciations, :example_sentences, :radical])
      end)
    end

    read :by_offset do
      argument(:offset, :integer, allow_nil?: false)
      get? true

      prepare(fn query, _context ->
        offset = Ash.Query.get_argument(query, :offset)

        query
        |> Ash.Query.sort(:inserted_at)
        |> Ash.Query.offset(offset)
        |> Ash.Query.limit(1)
      end)
    end
  end

  postgres do
    table("kanjis")
    repo(KumaSanKanji.Repo)
  end
end
