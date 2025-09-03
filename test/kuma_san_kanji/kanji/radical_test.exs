defmodule KumaSanKanji.Kanji.RadicalTest do
  use KumaSanKanji.DataCase, async: false
  alias KumaSanKanji.Domain

  @valid_attrs %{
    glyph: "亻",
    kangxi_index: 9,
    stroke_count: 2,
    meaning: "person",
    japanese_name: "にんべん",
    alt_forms: ["人"],
    sample_kanji: ["休", "体"],
    notes: "Used on the left side (hen) form of the person radical.",
    mnemonic: "Looks like a leaning person.",
    frequency_rank: 10,
    high_yield: true
  }

  defp create!(attrs \\ %{}) do
    attrs = Map.merge(@valid_attrs, attrs)
    Domain.create_radical!(attrs)
  end

  test "create_radical! persists and returns radical" do
    radical = create!()
    assert radical.id
    assert radical.glyph == @valid_attrs.glyph
    assert radical.kangxi_index == @valid_attrs.kangxi_index
  end

  test "unique constraint on glyph" do
    create!()
    assert_raise Ash.Error.Invalid, fn -> create!(%{meaning: "duplicate glyph"}) end
  end

  test "unique constraint on kangxi_index" do
    create!()
    assert_raise Ash.Error.Invalid, fn -> create!(%{glyph: "化", kangxi_index: @valid_attrs.kangxi_index}) end
  end

  test "get_radical_by_glyph! finds the radical" do
    radical = create!()
    found = Domain.get_radical_by_glyph!(radical.glyph)
    assert found.id == radical.id
  end

  test "get_radical_by_kangxi_index! finds the radical" do
    radical = create!()
    found = Domain.get_radical_by_kangxi_index!(radical.kangxi_index)
    assert found.glyph == radical.glyph
  end

  test "list_radicals! returns list including created radical" do
    radical = create!()
    list = Domain.list_radicals!()
    assert Enum.any?(list, &(&1.id == radical.id))
  end

  test "loading kanjis relationship returns empty list initially" do
    radical = create!()
    loaded = Ash.load!(radical, :kanjis)
    assert loaded.kanjis == []
  end

  test "invalid create missing required fields raises" do
    assert_raise Ash.Error.Invalid, fn ->
      Domain.create_radical!(%{glyph: nil, kangxi_index: nil, stroke_count: nil, meaning: nil})
    end
  end

  test "alt_forms default to empty list" do
    radical = create!(%{alt_forms: [], sample_kanji: []})
    assert radical.alt_forms == []
    assert radical.sample_kanji == []
  end
end
