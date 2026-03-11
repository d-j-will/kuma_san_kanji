defmodule KumaSanKanjiWeb.Live.AnswerChecker do
  @moduledoc "Shared answer checking logic for quiz experiences."

  def check_answer_correctness(kanji, user_answer) do
    normalized_meaning_answer = user_answer |> String.trim() |> String.downcase()
    normalized_reading_answer = user_answer |> String.trim() |> normalize_kana()

    meanings_match =
      kanji.meanings
      |> Enum.any?(fn meaning_record ->
        String.downcase(String.trim(meaning_record.value)) == normalized_meaning_answer
      end)

    readings_match =
      kanji.pronunciations
      |> Enum.any?(fn pronunciation_record ->
        pronunciation_record.value
        |> String.trim()
        |> normalize_kana()
        |> Kernel.==(normalized_reading_answer)
      end)

    meanings_match || readings_match
  end

  def normalize_kana(str) when is_binary(str) do
    str
    |> String.graphemes()
    |> Enum.map(&katakana_to_hiragana/1)
    |> Enum.join()
  end

  defp katakana_to_hiragana(grapheme) when is_binary(grapheme) do
    case String.to_charlist(grapheme) do
      [cp] when cp >= 0x30A1 and cp <= 0x30F6 -> <<cp - 0x60::utf8>>
      _ -> grapheme
    end
  end

  def get_feedback_message(:correct, kanji) do
    meanings = kanji.meanings |> Enum.map(& &1.value) |> Enum.join(", ")
    readings = kanji.pronunciations |> Enum.map(& &1.value) |> Enum.join(", ")
    "Correct! #{kanji.character} means: #{meanings}. Readings: #{readings}"
  end

  def get_feedback_message(:incorrect, kanji) do
    meanings = kanji.meanings |> Enum.map(& &1.value) |> Enum.join(", ")
    readings = kanji.pronunciations |> Enum.map(& &1.value) |> Enum.join(", ")
    "Incorrect. #{kanji.character} means: #{meanings}. Readings: #{readings}"
  end
end
