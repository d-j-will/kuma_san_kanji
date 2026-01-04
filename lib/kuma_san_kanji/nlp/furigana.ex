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
    # Create a temp file for input
    tmp_path = Path.join(System.tmp_dir!(), "mecab_input_#{System.unique_integer([:positive])}.txt")
    File.write!(tmp_path, text)

    # MeCab outputs in UTF-8
    # Using temp file avoids pipe issues and shell escaping
    result = case System.cmd("mecab", [tmp_path], stderr_to_stdout: true) do
      {output, 0} ->
        output
        |> String.split("\n", trim: true)
        |> Enum.map(&parse_mecab_line/1)
        |> Enum.join()

      {output, status} ->
        Logger.error("Failed to execute MeCab command (exit #{status}): #{output}")
        text # Return original text on error
    end

    # Cleanup
    File.rm(tmp_path)
    
    result
  end

  # Parses a single line of MeCab output into a furigana HTML string
  defp parse_mecab_line("EOS"), do: ""
  defp parse_mecab_line(line) do
    case String.split(line, "\t") do
      [surface, feature_str] ->
        feature = String.split(feature_str, ",")
        # Reading is the 8th field (index 7)
        case Enum.at(feature, 7) do
          reading when is_binary(reading) and reading != "*" ->
            hiragana_full_reading = to_hiragana(reading)

            # If the surface is pure Kana or reading is identical to surface, return surface
            if hiragana_full_reading == surface do
              surface
            else
              # Attempt partial furigana for mixed Kanji/Kana tokens
              kanji_graphemes = Regex.scan(~r/\p{Han}/u, surface) |> List.flatten()
              
              if length(kanji_graphemes) == 0 do
                # No Kanji in surface, just output surface
                surface
              else
                # Find the longest Kanji prefix of the surface
                kanji_part_surface =
                  surface
                  |> String.graphemes()
                  |> Enum.take_while(&Regex.match?(~r/^[\p{Han}]$/u, &1))
                  |> Enum.join()
                
                # The remaining part of the surface is assumed to be okurigana/kana suffix
                kana_suffix_in_surface = String.replace_prefix(surface, kanji_part_surface, "")

                if kanji_part_surface != "" do
                  # Check if the kana_suffix_in_surface matches the end of the full reading
                  if String.ends_with?(hiragana_full_reading, kana_suffix_in_surface) do
                    # The reading for the kanji part is the full reading minus the matched suffix
                    kanji_reading = String.replace_suffix(hiragana_full_reading, kana_suffix_in_surface, "")
                    
                    if kanji_reading != "" do
                      "<ruby>#{kanji_part_surface}<rt>#{kanji_reading}</rt></ruby>#{kana_suffix_in_surface}"
                    else
                      # Fallback if calculated kanji_reading is empty (e.g., if surface was pure Kanji and reading matched)
                      "<ruby>#{surface}<rt>#{hiragana_full_reading}</rt></ruby>"
                    end
                  else
                    # Fallback to whole word furigana if kana suffix doesn't align
                    "<ruby>#{surface}<rt>#{hiragana_full_reading}</rt></ruby>"
                  end
                else
                  # Fallback to whole word furigana if no Kanji prefix (should not happen if `length(kanji_graphemes) > 0`)
                  "<ruby>#{surface}<rt>#{hiragana_full_reading}</rt></ruby>"
                end
              end
            end
          _ ->
            surface # No reading or other cases, just return surface
        end
      _ ->
        "" # Malformed line
    end
  end

  # Simple Katakana to Hiragana conversion
  defp to_hiragana(text) when is_binary(text) do
    text
    |> String.graphemes() # Use graphemes for proper Unicode character handling
    |> Enum.map(fn cp ->
      case String.to_charlist(cp) do
        [char_code] when char_code >= 0x30A1 and char_code <= 0x30F6 ->
          << (char_code - 0x60) :: utf8 >>
        _ -> cp
      end
    end)
    |> Enum.join("")
  end
end