defmodule KumaSanKanji.NLP.FuriganaTest do
  use ExUnit.Case, async: true
  alias KumaSanKanji.NLP.Furigana

  describe "parse_sentence/1" do
    test "parses simple sentence with kanji" do
      input = "日本語を勉強します"
      output = Furigana.parse_sentence(input)
      
      assert output =~ "<ruby>日本語<rt>にほんご</rt></ruby>"
      assert output =~ "を"
      assert output =~ "<ruby>勉強<rt>べんきょう</rt></ruby>"
    end

    test "leaves hiragana as is" do
      input = "こんにちは"
      assert Furigana.parse_sentence(input) == "こんにちは"
    end

    test "leaves katakana as is (or converts?)" do
      # Our logic converts readings to Hiragana for furigana, but surface form stays.
      # If surface is Katakana and reading is Katakana -> no furigana (surface == reading).
      # Wait, to_hiragana(reading) converts reading.
      # If surface is "カメラ", reading is "カメラ".
      # to_hiragana("カメラ") -> "かめら".
      # surface != hiragana_reading ("カメラ" != "かめら").
      # So it might add furigana?
      # Logic: if Regex.match?(~r/[\p{Han}]/u, surface) ...
      # Katakana is NOT Han (Kanji). So it should return surface.
      
      input = "カメラ"
      assert Furigana.parse_sentence(input) == "カメラ"
    end

    test "handles kanji mixed with kana" do
      input = "赤い車"
      output = Furigana.parse_sentence(input)
      assert output == "赤い<ruby>車<rt>くるま</rt></ruby>"
    end
  end
end
