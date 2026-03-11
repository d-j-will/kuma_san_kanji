defmodule KumaSanKanji.LearningPathHelpers do
  @moduledoc """
  Test helpers for the Grade 1 Thematic Learning Path feature.

  Provides functions to create thematic groups, kanji, group memberships,
  and user progress records needed by acceptance tests.
  """

  import KumaSanKanji.TestHelpers

  @doc """
  Creates a thematic group with the given attributes.

  Returns the created ThematicGroup struct.
  """
  def create_thematic_group(attrs) do
    base_slug =
      attrs[:name]
      |> to_string()
      |> String.downcase()
      |> String.replace(~r/[^a-z0-9]+/, "-")
      |> String.trim("-")

    slug = "#{base_slug}-#{System.unique_integer([:positive])}"

    defaults = %{
      description: "Test group description",
      color_code: "#4A90D9",
      icon_name: "academic-cap",
      slug: slug
    }

    KumaSanKanji.Content.create_thematic_group!(Map.merge(defaults, attrs))
  end

  @doc """
  Creates a kanji with meaning, pronunciation, and example sentence.

  Accepts a map with:
    - :character (required)
    - :meaning (required) - primary English meaning
    - :kun_readings (optional) - list of kun'yomi strings
    - :on_readings (optional) - list of on'yomi strings
    - :stroke_count (optional, default 4)
    - :grade (optional, default 1)
    - :example_japanese (optional) - Japanese sentence text
    - :example_translation (optional) - English translation

  Returns {kanji, meaning, pronunciations, example_sentences}.
  """
  def create_kanji_with_details(attrs) do
    kanji =
      KumaSanKanji.Domain.create_kanji!(%{
        character: attrs.character,
        grade: Map.get(attrs, :grade, 1),
        stroke_count: Map.get(attrs, :stroke_count, 4),
        jlpt_level: Map.get(attrs, :jlpt_level, 5)
      })

    {:ok, meaning} =
      KumaSanKanji.Domain.create_meaning(%{
        kanji_id: kanji.id,
        value: attrs.meaning
      })

    kun_readings =
      for reading <- Map.get(attrs, :kun_readings, []) do
        {:ok, p} =
          KumaSanKanji.Domain.create_pronunciation(%{
            kanji_id: kanji.id,
            value: reading,
            type: :kun
          })

        p
      end

    on_readings =
      for reading <- Map.get(attrs, :on_readings, []) do
        {:ok, p} =
          KumaSanKanji.Domain.create_pronunciation(%{
            kanji_id: kanji.id,
            value: reading,
            type: :on
          })

        p
      end

    example_sentences =
      if Map.has_key?(attrs, :example_japanese) do
        {:ok, sentence} =
          KumaSanKanji.Domain.create_example_sentence(%{
            kanji_id: kanji.id,
            japanese: attrs.example_japanese,
            translation: Map.get(attrs, :example_translation, "Example translation.")
          })

        [sentence]
      else
        []
      end

    {kanji, meaning, kun_readings ++ on_readings, example_sentences}
  end

  @doc """
  Assigns a kanji to a thematic group at the given position.

  Returns the created KanjiThematicGroup join record.
  """
  def assign_kanji_to_group(kanji, group, position) do
    KumaSanKanji.Content.create_kanji_thematic_group!(%{
      kanji_id: kanji.id,
      thematic_group_id: group.id,
      position: position,
      relevance_score: 1.0,
      notes: "position #{position}"
    })
  end

  @doc """
  Marks a kanji as learned for a user by initializing SRS progress.

  Returns the UserKanjiProgress record.
  """
  def mark_kanji_learned(user, kanji) do
    {:ok, progress} = KumaSanKanji.SRS.Logic.initialize_progress(user.id, kanji.id, user)
    progress
  end

  @doc """
  Creates a complete thematic group with kanji for testing.

  Accepts:
    - name: group name (e.g., "Numbers")
    - slug: URL slug (e.g., "numbers") -- stored in notes until slug column exists
    - order_index: display order
    - kanji_data: list of maps with :character, :meaning, and optional details

  Returns {group, kanji_list} where kanji_list is ordered by position.
  """
  def create_group_with_kanji(name, order_index, kanji_data) do
    group = create_thematic_group(%{name: name, order_index: order_index})

    kanji_list =
      kanji_data
      |> Enum.with_index(1)
      |> Enum.map(fn {attrs, position} ->
        {kanji, _meaning, _pronunciations, _sentences} = create_kanji_with_details(attrs)
        _join = assign_kanji_to_group(kanji, group, position)
        kanji
      end)

    {group, kanji_list}
  end

  @doc """
  Creates the standard Numbers group used across many test scenarios.

  Returns {group, kanji_list} with 4 kanji: 一, 二, 三, 四.
  """
  def create_numbers_group do
    create_group_with_kanji("Numbers", 1, [
      %{
        character: "一",
        meaning: "one",
        kun_readings: ["ひと"],
        on_readings: ["イチ"],
        stroke_count: 1,
        example_japanese: "一つください。",
        example_translation: "One, please."
      },
      %{
        character: "二",
        meaning: "two",
        kun_readings: ["ふた"],
        on_readings: ["ニ"],
        stroke_count: 2,
        example_japanese: "二人います。",
        example_translation: "There are two people."
      },
      %{
        character: "三",
        meaning: "three",
        kun_readings: ["み"],
        on_readings: ["サン"],
        stroke_count: 3,
        example_japanese: "三月は春です。",
        example_translation: "March is spring."
      },
      %{
        character: "四",
        meaning: "four",
        kun_readings: ["よん", "よ", "よっつ"],
        on_readings: ["シ"],
        stroke_count: 5,
        example_japanese: "四月は春です。",
        example_translation: "April is spring."
      }
    ])
  end

  @doc """
  Creates a small Nature group for cross-group isolation tests.

  Returns {group, kanji_list} with 2 kanji: 山, 川.
  """
  def create_nature_group do
    create_group_with_kanji("Nature", 3, [
      %{
        character: "山",
        meaning: "mountain",
        kun_readings: ["やま"],
        on_readings: ["サン"],
        stroke_count: 3,
        example_japanese: "あの山は高いです。",
        example_translation: "That mountain is tall."
      },
      %{
        character: "川",
        meaning: "river",
        kun_readings: ["かわ"],
        on_readings: ["セン"],
        stroke_count: 3,
        example_japanese: "川で泳ぎます。",
        example_translation: "I swim in the river."
      }
    ])
  end

  @doc """
  Creates a user authenticated for LiveView tests.

  Returns {conn, user} where conn has auth session set up
  and Mimic stubs are configured.
  """
  def create_authenticated_learner(conn, email_prefix \\ "learner") do
    user =
      create_simple_test_user("#{email_prefix}-#{System.system_time(:millisecond)}@example.com")

    setup_auth_mocks(user)
    conn = log_in_user(conn, user)
    {conn, user}
  end

  @doc """
  Creates learning metadata (tips/mnemonics) for a kanji.
  """
  def create_learning_meta(kanji, attrs \\ %{}) do
    defaults = %{
      kanji_id: kanji.id,
      learning_tips: "Remember this character by its shape.",
      mnemonic_hints: "Think of it as a picture."
    }

    KumaSanKanji.Content.create_kanji_learning_meta!(Map.merge(defaults, attrs))
  end

  @doc """
  Enables the :grade1_learning_path feature flag.
  """
  def enable_learning_path_flag do
    FunWithFlags.enable(:grade1_learning_path)
  end

  @doc """
  Disables the :grade1_learning_path feature flag.
  """
  def disable_learning_path_flag do
    FunWithFlags.disable(:grade1_learning_path)
  end
end
