defmodule KumaSanKanji.NLP.Furigana do
  @moduledoc """
  Provides functions for generating furigana for Japanese text by shelling out to the `mecab` command.
  """
  require Logger

  @doc """
  Parses a Japanese sentence and returns an HTML string with furigana (ruby tags).

  Uses `System.cmd("mecab")` to get morphological analysis including readings.
  Kanji with common readings (that are part of the dictionary) will have furigana.
  Kana will be left as is.

  ## Examples
      iex> Furigana.parse_sentence("日本語を勉強しています。")
      "<ruby>日本<rt>にほん</rt></ruby><ruby>語<rt>ご</rt></ruby>を<ruby>勉強<rt>べんきょう</rt></ruby>しています。"

      iex> Furigana.parse_sentence("これはペンです。")
      "これはペンです。"
  """
  def parse_sentence(text) when is_binary(text) do
    tmp_path =
      Path.join(System.tmp_dir!(), "mecab_input_#{System.unique_integer([:positive])}.txt")

    File.write!(tmp_path, text)

    result =
      try do
        case System.cmd("mecab", [tmp_path], stderr_to_stdout: true) do
          {output, 0} ->
            output
            |> String.split("\n", trim: true)
            |> Enum.map(&parse_mecab_line/1)
            |> Enum.join()

          {output, status} ->
            Logger.error("Failed to execute MeCab command (exit #{status}): #{output}")
            text
        end
      rescue
        ErlangError ->
          Logger.debug("MeCab not installed, skipping furigana generation")
          text
      end

    File.rm(tmp_path)
    result
  end

  # Processes a single line of MeCab output into a furigana HTML string
  defp parse_mecab_line("EOS"), do: ""

  defp parse_mecab_line(line) do
    case String.split(line, "\t") do
      [surface, feature_str] ->
        feature = String.split(feature_str, ",")
        process_mecab_token(surface, feature)

      _ ->
        # Malformed line (e.g., just a newline or unexpected format)
        Logger.warning("Malformed MeCab output line: #{inspect(line)}")
        ""
    end
  end

  defp process_mecab_token(surface, feature) do
    # Reading is the 8th field (index 7)
    reading = Enum.at(feature, 7)

    cond do
      reading == "*" or not is_binary(reading) ->
        # No reading or reading is a wildcard, just return surface
        surface

      true ->
        hiragana_full_reading = to_hiragana(reading)

        # If the surface is pure Kana (or reading is identical to surface), return surface
        if hiragana_full_reading == surface or not Regex.match?(~r/\p{Han}/u, surface) do
          surface
        else
          # Otherwise, it's Kanji or mixed Kanji/Kana, and reading is different.
          # Apply the partial furigana heuristic.
          apply_partial_furigana_heuristic(surface, hiragana_full_reading)
        end
    end
  end

  # Applies a heuristic to generate partial furigana for mixed Kanji/Kana tokens.
  # This attempts to split the furigana only to the Kanji part, leaving the okurigana as plain text.
  defp apply_partial_furigana_heuristic(surface, hiragana_full_reading) do
    # Find the longest Kanji prefix of the surface
    kanji_part_surface =
      surface
      |> String.graphemes()
      |> Enum.take_while(&Regex.match?(~r/^[\p{Han}]$/u, &1))
      |> Enum.join()

    # The remaining part of the surface is assumed to be okurigana/kana suffix
    kana_suffix_in_surface = String.replace_prefix(surface, kanji_part_surface, "")

    cond do
      kanji_part_surface == "" ->
        # No Kanji prefix, fallback to whole token furigana (e.g. if reading was actually Kanji)
        # This case should ideally not be hit if called correctly, as process_mecab_token checks for Han.
        "<ruby>#{surface}<rt>#{hiragana_full_reading}</rt></ruby>"

      String.ends_with?(hiragana_full_reading, kana_suffix_in_surface) ->
        # The reading for the kanji part is the full reading minus the matched suffix
        kanji_reading = String.replace_suffix(hiragana_full_reading, kana_suffix_in_surface, "")

        if kanji_reading != "" do
          "<ruby>#{kanji_part_surface}<rt>#{kanji_reading}</rt></ruby>#{kana_suffix_in_surface}"
        else
          # Fallback if calculated kanji_reading is empty (e.g., if surface was pure Kanji and reading matched)
          # This happens if surface is '本' (ほん) and reading 'ほん'.
          "<ruby>#{surface}<rt>#{hiragana_full_reading}</rt></ruby>"
        end

      true ->
        # Fallback to whole word furigana if kana suffix doesn't align
        "<ruby>#{surface}<rt>#{hiragana_full_reading}</rt></ruby>"
    end
  end

  # Simple Katakana to Hiragana conversion
  defp to_hiragana(text) when is_binary(text) do
    text
    # Use graphemes for proper Unicode character handling
    |> String.graphemes()
    |> Enum.map(fn cp ->
      case String.to_charlist(cp) do
        [char_code] when char_code >= 0x30A1 and char_code <= 0x30F6 ->
          <<char_code - 0x60::utf8>>

        _ ->
          cp
      end
    end)
    |> Enum.join("")
  end
end
