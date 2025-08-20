defmodule KumaSanKanji.Kanji do
  @moduledoc """
  Thin facade for Kanji-related operations expected by tests.

  Delegates to `KumaSanKanji.Domain` code interface functions for the
  `KumaSanKanji.Kanji.Kanji` resource.
  """

  alias KumaSanKanji.Domain

  @doc "Create a kanji (non-raising)."
  def create(attrs), do: Domain.create_kanji(attrs)

  @doc "Create a kanji (raising)."
  def create!(attrs), do: Domain.create_kanji!(attrs)

  @doc "Fetch a kanji by offset; returns {:ok, record} | {:error, reason}."
  def by_offset(offset) when is_integer(offset) and offset >= 0 do
    Domain.get_kanji_by_offset(offset)
  end

  @doc "Count all kanji (raising)."
  def count_all!(), do: Domain.count_all_kanjis!()
end
