defmodule KumaSanKanji.Kanji.Radical do
  @moduledoc """
  Radical (部首) resource providing metadata for indexing and instructional use.

  Fields are derived from the extended radicals reference. This is intentionally
  richer than minimal indexing to support mnemonic display & future quizzes.
  """
  use Ash.Resource,
    domain: KumaSanKanji.Domain,
    data_layer: AshPostgres.DataLayer

  attributes do
    uuid_primary_key(:id)

    # Core identifying data
    attribute(:glyph, :string, allow_nil?: false)
    attribute(:kangxi_index, :integer, allow_nil?: false)
    attribute(:stroke_count, :integer, allow_nil?: false)
    attribute(:meaning, :string, allow_nil?: false)
    attribute(:japanese_name, :string)

    # Extended metadata
    attribute(:alt_forms, {:array, :string}, default: [])
    attribute(:sample_kanji, {:array, :string}, default: [])
    attribute(:notes, :string)
    attribute(:mnemonic, :string)
    attribute(:frequency_rank, :integer)
    attribute(:high_yield, :boolean, default: false)

    timestamps()
  end

  relationships do
    has_many(:kanjis, KumaSanKanji.Kanji.Kanji)
  end

  actions do
    defaults([:read, :update, :destroy])

    create :create do
      accept([
        :glyph,
        :kangxi_index,
        :stroke_count,
        :meaning,
        :japanese_name,
        :alt_forms,
        :sample_kanji,
        :notes,
        :mnemonic,
        :frequency_rank,
        :high_yield
      ])
    end

    read :get_by_glyph do
      argument(:glyph, :string, allow_nil?: false)
      filter(expr(glyph == ^arg(:glyph)))
      get?(true)
    end

    read :get_by_kangxi_index do
      argument(:kangxi_index, :integer, allow_nil?: false)
      filter(expr(kangxi_index == ^arg(:kangxi_index)))
      get?(true)
    end

    read :get_with_kanjis do
      argument(:kangxi_index, :integer, allow_nil?: false)
      filter(expr(kangxi_index == ^arg(:kangxi_index)))
      get?(true)

      prepare(fn query, _context ->
        query
        |> Ash.Query.load(kanjis: [limit: 50, sort: [character: :asc]])
      end)
    end
  end

  identities do
    identity(:unique_glyph, [:glyph])
    identity(:unique_kangxi_index, [:kangxi_index])
  end

  code_interface do
    define(:create_radical, action: :create)
    define(:get_radical_by_glyph, action: :get_by_glyph, args: [:glyph])
    define(:get_radical_by_kangxi_index, action: :get_by_kangxi_index, args: [:kangxi_index])
    define(:get_radical_with_kanjis, action: :get_with_kanjis, args: [:kangxi_index])
    define(:list_radicals, action: :read)
  end

  postgres do
    table("radicals")
    repo(KumaSanKanji.Repo)
  end
end
