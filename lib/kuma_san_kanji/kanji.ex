defmodule KumaSanKanji.Kanji do
  @moduledoc """
  Thin facade for Kanji-related operations expected by tests.

  Delegates to `KumaSanKanji.Domain` code interface functions for the
  `KumaSanKanji.Kanji.Kanji` resource.
  """

  alias KumaSanKanji.Domain

  def create(attrs), do: Domain.create_kanji(attrs)
  def create!(attrs), do: Domain.create_kanji!(attrs)

  def by_offset(offset) when is_integer(offset) and offset >= 0 do
    Domain.get_kanji_by_offset(offset)
  end

  def count_all! do
    Ash.count!(KumaSanKanji.Kanji.Kanji, action: :read)
  end
end
