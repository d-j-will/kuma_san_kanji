defmodule KumaSanKanji.Domain do
  @moduledoc """
  The boundary to the KumaSanKanji system.
  """
  use Ash.Domain, otp_app: :kuma_san_kanji
  require Ash.Query

  resources do
    resource(KumaSanKanji.Accounts.User)

    resource(KumaSanKanji.Kanji.Kanji) do
      define(:read_kanji, action: :read)
      define(:get_kanji_by_id, args: [:id], action: :get_by_id, get?: true)
      define(:create_kanji, action: :create)
      define(:get_kanji_by_offset, args: [:offset], action: :by_offset, get?: true)
      define(:list_kanjis, action: :list_all)
      define(:get_kanji_by_character, args: [:character], action: :get_by_character, get?: true)
    end

    resource(KumaSanKanji.Kanji.Radical) do
      define(:create_radical, action: :create)
      define(:get_radical_by_glyph, action: :get_by_glyph, args: [:glyph], get?: true)

      define(:get_radical_by_kangxi_index,
        action: :get_by_kangxi_index,
        args: [:kangxi_index],
        get?: true
      )

      define(:list_radicals, action: :read)
    end

    resource(KumaSanKanji.Kanji.Meaning) do
      define(:create_meaning, action: :create)
      define(:list_meanings_by_kanji, action: :read)
      define(:get_meaning_by_kanji_and_value, action: :by_kanji_and_value)
    end

    resource(KumaSanKanji.Kanji.Pronunciation) do
      define(:create_pronunciation, action: :create)
      define(:list_pronunciations_by_kanji, action: :read)
      define(:get_pronunciation_by_kanji_and_value, action: :by_kanji_and_value)
    end

    resource(KumaSanKanji.Kanji.ExampleSentence) do
      define(:create_example_sentence, action: :create)
      define(:list_example_sentences_by_kanji, action: :read)
      define(:get_sentence_by_kanji_and_text, action: :by_kanji_and_text)
    end

    resource(KumaSanKanji.SRS.UserKanjiProgress)
  end
end
