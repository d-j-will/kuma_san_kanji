defmodule KumaSanKanji.Content.Seeds do
  @moduledoc """
  Seeds for the Content domain in Kuma-san Kanji.
  Covers all 80 Grade 1 kanji across 11 thematic groups with positions and learning metadata.
  """

  alias KumaSanKanji.Content

  def insert_initial_data do
    thematic_groups = insert_thematic_groups()
    educational_contexts = insert_educational_contexts()
    map_kanji_to_content(thematic_groups, educational_contexts)
  end

  defp insert_thematic_groups do
    groups = [
      %{
        name: "Numbers",
        description:
          "These form the foundation of the Japanese counting system and are among the first kanji taught.",
        color_code: "oklch(0.7 0.15 45)",
        icon_name: "calculator",
        order_index: 1
      },
      %{
        name: "Directions & Positions",
        description: "Essential spatial concepts for basic navigation and describing locations.",
        color_code: "oklch(0.7 0.15 270)",
        icon_name: "compass",
        order_index: 2
      },
      %{
        name: "Nature",
        description:
          "Kanji representing fundamental elements of the natural world that surround children in daily life.",
        color_code: "oklch(70% 0.2 150)",
        icon_name: "tree",
        order_index: 3
      },
      %{
        name: "People",
        description:
          "Characters representing basic social categories and common animals children encounter.",
        color_code: "oklch(70% 0.2 60)",
        icon_name: "person",
        order_index: 4
      },
      %{
        name: "Body Parts",
        description:
          "Learning the kanji for body parts helps children describe themselves and basic health.",
        color_code: "oklch(0.7 0.15 20)",
        icon_name: "hand",
        order_index: 5
      },
      %{
        name: "Actions",
        description: "Basic actions and concepts that appear frequently in elementary texts.",
        color_code: "oklch(70% 0.2 200)",
        icon_name: "play",
        order_index: 6
      },
      %{
        name: "Colors",
        description:
          "The first color kanji taught, representing primary colors children use in art class.",
        color_code: "oklch(0.7 0.2 0)",
        icon_name: "palette",
        order_index: 7
      },
      %{
        name: "Time",
        description: "Kanji that help children understand and express time concepts.",
        color_code: "oklch(70% 0.2 90)",
        icon_name: "clock",
        order_index: 8
      },
      %{
        name: "Places & Community",
        description: "Kanji relating to the child's immediate community and social environment.",
        color_code: "oklch(0.7 0.15 180)",
        icon_name: "building",
        order_index: 9
      },
      %{
        name: "Objects",
        description: "Common objects children interact with or see regularly.",
        color_code: "oklch(0.7 0.15 120)",
        icon_name: "cube",
        order_index: 10
      },
      %{
        name: "Abstract Concepts & Others",
        description:
          "Kanji representing abstract ideas, qualities, and concepts that build vocabulary foundations.",
        color_code: "oklch(0.7 0.1 330)",
        icon_name: "puzzle-piece",
        order_index: 11
      }
    ]

    Enum.map(groups, fn group_attrs ->
      slug =
        group_attrs[:name]
        |> String.downcase()
        |> String.replace(~r/[^a-z0-9]+/, "-")
        |> String.trim("-")

      case Content.get_group_by_slug(%{slug: slug}) do
        {:ok, existing} ->
          # Update description and order_index for existing groups
          update_attrs = Map.take(group_attrs, [:description, :order_index])

          existing
          |> Ash.Changeset.for_update(:update, update_attrs, authorize?: false)
          |> Ash.update!(authorize?: false)

        {:error, _} ->
          params =
            group_attrs
            |> Map.take([:name, :description, :color_code, :icon_name, :order_index, :parent_id])
            |> Map.put(:slug, slug)

          {:ok, created} = Content.create_thematic_group(params)
          created
      end
    end)
  end

  defp insert_educational_contexts do
    contexts = [
      %{
        name: "Grade 1",
        grade_level: 1,
        description: "First grade elementary school kanji (小学校一年生)"
      },
      %{
        name: "Grade 2",
        grade_level: 2,
        description: "Second grade elementary school kanji (小学校二年生)"
      },
      %{
        name: "Grade 3",
        grade_level: 3,
        description: "Third grade elementary school kanji (小学校三年生)"
      },
      %{
        name: "Grade 4",
        grade_level: 4,
        description: "Fourth grade elementary school kanji (小学校四年生)"
      },
      %{
        name: "Grade 5",
        grade_level: 5,
        description: "Fifth grade elementary school kanji (小学校五年生)"
      },
      %{
        name: "Grade 6",
        grade_level: 6,
        description: "Sixth grade elementary school kanji (小学校六年生)"
      }
    ]

    Enum.map(contexts, fn context ->
      case Content.get_educational_context_by_grade(%{grade_level: context[:grade_level]}) do
        {:ok, existing} ->
          existing

        {:error, _} ->
          {:ok, created} = Content.create_educational_context(context)
          created
      end
    end)
  end

  defp map_kanji_to_content(thematic_groups_list, educational_contexts) do
    kanji_page =
      KumaSanKanji.Domain.list_kanjis!(
        load: [:meanings, :pronunciations, :example_sentences],
        page: [limit: 1000]
      )

    kanji_list = kanji_page.results
    kanji_by_char = Enum.into(kanji_list, %{}, fn k -> {k.character, k} end)

    thematic_groups_map =
      Enum.into(thematic_groups_list, %{}, fn group -> {group.name, group} end)

    # Build tips lookup from kanji group data
    tips_data =
      Map.new(kanji_group_data(), fn {char, _, _, tips, mnemonic} ->
        {char, %{learning_tips: tips, mnemonic_hints: mnemonic}}
      end)

    # Map each kanji to its thematic group with position
    Enum.each(kanji_group_data(), fn {char, group_name, position, _tips, _mnemonic} ->
      kanji = Map.get(kanji_by_char, char)
      group = Map.get(thematic_groups_map, group_name)

      cond do
        is_nil(kanji) ->
          IO.puts("Warning: Kanji '#{char}' not found in database — skipping group mapping.")

        is_nil(group) ->
          IO.puts(
            "Warning: Thematic group '#{group_name}' not found for kanji '#{char}' — skipping."
          )

        true ->
          upsert_kanji_group(kanji.id, group.id, position)
      end
    end)

    # Educational context mapping and learning metadata
    Enum.each(kanji_list, fn kanji ->
      if kanji.grade do
        contexts = Enum.filter(educational_contexts, &(&1.grade_level == kanji.grade))
        meta = Map.get(tips_data, kanji.character, %{})

        Enum.each(contexts, fn context ->
          attrs =
            %{kanji_id: kanji.id, educational_context_id: context.id}
            |> maybe_put(:learning_tips, meta[:learning_tips])
            |> maybe_put(:mnemonic_hints, meta[:mnemonic_hints])

          case Content.create_kanji_learning_meta(attrs) do
            {:ok, _} ->
              :ok

            {:error, _} ->
              # Already exists — update with tips if we have them
              if meta[:learning_tips] || meta[:mnemonic_hints] do
                update_learning_meta(kanji.id, meta)
              end
          end
        end)
      end
    end)
  end

  defp upsert_kanji_group(kanji_id, group_id, position) do
    case Content.create_kanji_thematic_group(%{
           kanji_id: kanji_id,
           thematic_group_id: group_id,
           position: position,
           relevance_score: 1.0
         }) do
      {:ok, _} ->
        :ok

      {:error, _} ->
        # Already exists — update position
        with {:ok, joins} <- Content.get_group_kanji_joins(%{thematic_group_id: group_id}) do
          case Enum.find(joins, &(&1.kanji_id == kanji_id)) do
            nil ->
              :ok

            join ->
              join
              |> Ash.Changeset.for_update(:update, %{position: position}, authorize?: false)
              |> Ash.update!(authorize?: false)
          end
        end
    end
  end

  defp update_learning_meta(kanji_id, meta) do
    update_attrs =
      %{}
      |> maybe_put(:learning_tips, meta[:learning_tips])
      |> maybe_put(:mnemonic_hints, meta[:mnemonic_hints])

    if update_attrs != %{} do
      case Content.get_kanji_learning_meta(%{kanji_id: kanji_id}) do
        {:ok, existing} ->
          existing
          |> Ash.Changeset.for_update(:update, update_attrs, authorize?: false)
          |> Ash.update!(authorize?: false)

        {:error, _} ->
          :ok
      end
    end
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  # -- Kanji Group Data --
  # {character, group_name, position_in_group, learning_tips, mnemonic_hints}

  defp kanji_group_data do
    numbers() ++
      directions() ++
      nature() ++
      people() ++
      body_parts() ++
      actions() ++ colors() ++ time_kanji() ++ places() ++ objects() ++ abstract()
  end

  defp numbers do
    [
      {"一", "Numbers", 1,
       "The simplest kanji — just one stroke. All Japanese counting builds on this.",
       "One horizontal line = one."},
      {"二", "Numbers", 2,
       "Two horizontal lines stacked. The top line is shorter than the bottom.",
       "Two lines = two."},
      {"三", "Numbers", 3,
       "Three horizontal lines. The middle line is shortest, bottom is longest.",
       "Three lines = three. After this, the pattern changes!"},
      {"四", "Numbers", 4,
       "Pronounced 'shi' or 'yon'. 'Shi' also means death, so 'yon' is often preferred.",
       "A box with internal divisions — imagine four walls of a room."},
      {"五", "Numbers", 5,
       "The top and bottom lines frame the character, with a cross-like shape in the middle.",
       "A hand with five fingers — central strokes cross like spread fingers."},
      {"六", "Numbers", 6, "Pronounced 'roku'. Top part looks like a hat with two legs below.",
       "A hat (亠) with two spreading legs below it."},
      {"七", "Numbers", 7, "The horizontal stroke cuts through the vertical-then-curved stroke.",
       "Looks like an upside-down 7 — a bent line crossed by a horizontal."},
      {"八", "Numbers", 8, "Two strokes spreading outward from the top. Also relates to 'divide'.",
       "Two lines spreading apart like opening a book."},
      {"九", "Numbers", 9, "Pronounced 'ku' or 'kyuu'. Features a swooping curved stroke.",
       "A person reaching out with a hook — reaching for the last single digit."},
      {"十", "Numbers", 10,
       "A cross shape — the most basic intersection. Also the radical for 'complete'.",
       "A perfect cross: + marks the spot for 10."},
      {"百", "Numbers", 11, "一 (one) on top of 白 (white). One hundred is a milestone number.",
       "One (一) over white (白) — a hundred white things."},
      {"千", "Numbers", 12, "A modified 十 (ten) with an extra stroke on top. Means one thousand.",
       "Like 十 (ten) with a slanted stroke — ten taken to the next level."}
    ]
  end

  defp directions do
    [
      {"上", "Directions & Positions", 1,
       "Can mean 'up', 'above', 'on top of'. Very common in compounds like 上手 (skilled).",
       "A line above a baseline — pointing upward."},
      {"下", "Directions & Positions", 2,
       "Opposite of 上. Means 'down', 'below', 'under'. Used in 下手 (unskilled).",
       "A line below a baseline — pointing downward."},
      {"中", "Directions & Positions", 3,
       "Means 'middle', 'inside', 'during'. Used in 中国 (China) and 中学 (middle school).",
       "A line through the center of a box — right in the middle."},
      {"左", "Directions & Positions", 4,
       "Means 'left'. The left hand (ナ) holds a carpenter's square (工).",
       "Left hand (ナ) + work (工) — the left hand at work."},
      {"右", "Directions & Positions", 5,
       "Means 'right'. The right hand (ナ) holds a mouth/opening (口).",
       "Right hand (ナ) + mouth (口) — eating with the right hand."}
    ]
  end

  defp nature do
    [
      {"水", "Nature", 1,
       "One of the five classical elements. Radical form (氵) appears in hundreds of water-related kanji.",
       "The central stroke is a river, with splashes on either side."},
      {"火", "Nature", 2,
       "Another classical element. Radical form (灬) appears at the bottom of characters like 熱 (heat).",
       "A person (人) with two sparks — flames dancing."},
      {"木", "Nature", 3,
       "One of the most important radicals. 林 (grove) and 森 (forest) build on it.",
       "A tree with branches above and roots below."},
      {"山", "Nature", 4,
       "One of the most pictographic kanji — looks exactly like mountain peaks.",
       "Three peaks of a mountain range."},
      {"川", "Nature", 5, "Three flowing lines representing a river. Very pictographic.",
       "Three parallel flowing lines — water streaming between banks."},
      {"空", "Nature", 6, "穴 (hole/cave) + 工 (work). The sky is the great opening above us.",
       "A cave opening (穴) worked (工) into the vast sky."},
      {"雨", "Nature", 7, "Highly pictographic — a window frame with rain drops falling inside.",
       "Rain drops (dots) falling from a cloud under a roof."},
      {"天", "Nature", 8, "One stroke above 大 (big). What is bigger than big? Heaven and sky.",
       "Above (一) the big (大) — the heavens."},
      {"日", "Nature", 9,
       "Originally a circle with a dot — the sun. Now a rectangle. Also means 'day'.",
       "The sun enclosed in a frame — a window showing daylight."},
      {"月", "Nature", 10,
       "Originally a crescent moon shape. Also means 'month' and is a very common radical.",
       "A crescent moon with two lines inside — the moon's surface."},
      {"地", "Nature", 11, "土 (earth) + 也. The ground on which we stand. Common in 地図 (map).",
       "Earth radical (土) plus a phonetic — the ground beneath our feet."},
      {"石", "Nature", 12, "A cliff (厂) with a mouth/rock (口) below it — a stone at the base.",
       "A rock (口) at the base of a cliff (厂)."},
      {"土", "Nature", 13,
       "A cross with a wider base — a mound of earth. Important radical for ground-related kanji.",
       "A cross planted in the ground — soil piled up."},
      {"花", "Nature", 14,
       "Grass radical (艹) + 化 (to change). Plants that transform into blossoms.",
       "Grass (艹) that changes (化) into something beautiful — flowers."},
      {"草", "Nature", 15,
       "Grass radical (艹) + 早 (early). The first green growth of early spring.",
       "Early (早) growth under grass (艹) — fresh grass."},
      {"竹", "Nature", 16, "Two bamboo stalks side by side. This is also the bamboo radical (⺮).",
       "Two bamboo stems leaning together with leaves."},
      {"林", "Nature", 17, "Two trees (木木) side by side make a grove. Building block from 木.",
       "Two trees (木) together — a small wood or grove."},
      {"森", "Nature", 18, "Three trees (木) — even more than a grove. Dense and full.",
       "Three trees (木) packed together — a thick forest."},
      {"田", "Nature", 19,
       "Looks like rice paddies divided by paths — an aerial view of farmland.",
       "A field divided into four plots by paths — rice paddies from above."}
    ]
  end

  defp people do
    [
      {"人", "People", 1,
       "The most fundamental kanji for person. Changes form as radical: 亻on the left side.",
       "Two strokes leaning on each other — people supporting each other."},
      {"男", "People", 2,
       "田 (rice field) + 力 (power). The one who works with strength in the fields.",
       "Power (力) in the rice field (田) — strength at work."},
      {"女", "People", 3,
       "A pictograph of a person kneeling gracefully. Important radical in many kanji.",
       "A figure in an elegant kneeling position."},
      {"子", "People", 4,
       "A pictograph of a child with arms outstretched. Common in names and compounds.",
       "A baby with arms spread wide, head on top."},
      {"犬", "People", 5, "Like 大 (big) but with an extra dot. A big animal with a spot — a dog!",
       "Big (大) with a dot — a big animal (dog) with a marking."},
      {"虫", "People", 6,
       "Originally a pictograph of a snake or insect. Used for all small creatures.",
       "A creature with a head, body, and legs — a generic bug."}
    ]
  end

  defp body_parts do
    [
      {"口", "Body Parts", 1,
       "A simple square representing a mouth. One of the most common radicals.",
       "An open mouth — a square opening."},
      {"目", "Body Parts", 2,
       "A sideways eye with the pupil visible. Radical form appears in 見 (see) and 眠 (sleep).",
       "An eye turned sideways with lines for the iris."},
      {"耳", "Body Parts", 3, "Originally pictured the outer ear with its ridges and curves.",
       "An ear with its curved ridges visible from the side."},
      {"手", "Body Parts", 4,
       "A hand with fingers spread. Radical form (扌) is very common on the left side of kanji.",
       "Fingers on a hand — the main lines of the palm."},
      {"足", "Body Parts", 5,
       "口 (a knee shape) + a foot below. Means both 'foot' and 'sufficient'.",
       "A kneecap (口) above a stepping foot — leg and foot together."}
    ]
  end

  defp actions do
    [
      {"見", "Actions", 1, "目 (eye) on legs (儿). An eye walking around — looking and seeing.",
       "An eye (目) on legs (儿) — walking around to see things."},
      {"立", "Actions", 2,
       "A person standing on the ground with arms spread wide. Means 'to stand'.",
       "A person standing firmly on a line — planted on the ground."},
      {"生", "Actions", 3,
       "A plant growing from the earth. Means 'life', 'birth', 'raw', and 'student'.",
       "A sprout growing upward from the ground — new life emerging."},
      {"休", "Actions", 4, "亻(person) + 木 (tree). A person leaning against a tree to rest.",
       "A person (亻) resting against a tree (木) — taking a break."},
      {"入", "Actions", 5,
       "Two strokes pointing inward. Often confused with 人 — note the stroke direction!",
       "Two lines converging inward — entering a space. Unlike 人, strokes point in."},
      {"出", "Actions", 6, "Two mountain-like shapes stacked — going out over the mountains.",
       "Two 山-like shapes — climbing out and over."}
    ]
  end

  defp colors do
    [
      {"赤", "Colors", 1, "土 (earth) + fire radical combined. Earth on fire glows red.",
       "Earth (土) plus fire — red-hot glowing earth."},
      {"青", "Colors", 2,
       "Originally showed young plants (生) under moonlight (月). Fresh, blue-green.",
       "Life (生) under the moon (月) — the blue-green of nature at dusk."},
      {"白", "Colors", 3,
       "The sun (日) with a ray of light escaping from the top. Pure white light.",
       "A bright sun with a beam on top — pure white light."}
    ]
  end

  defp time_kanji do
    [
      {"年", "Time", 1,
       "Originally showed a person carrying grain — the harvest marks one year's cycle.",
       "A person carrying the harvest — one full year of growth."},
      {"夕", "Time", 2, "Half of 月 (moon) — the moon just appearing at dusk. Only 3 strokes.",
       "A crescent — half a moon appearing at evening twilight."}
    ]
  end

  defp places do
    [
      {"学", "Places & Community", 1,
       "A child (子) under a roof with hands reaching for knowledge. To study and learn.",
       "A child (子) under a roof reaching upward — studying."},
      {"校", "Places & Community", 2,
       "木 (tree) + 交 (cross/mix). A place where people meet among trees — a school.",
       "Trees (木) where people cross paths (交) — a school campus."},
      {"町", "Places & Community", 3,
       "田 (rice field) + 丁 (block). A block of rice fields forming a town district.",
       "Rice fields (田) divided into blocks (丁) — a town."},
      {"村", "Places & Community", 4,
       "木 (tree) + 寸 (measure). A measured area of trees — a rural village.",
       "Trees (木) measured out (寸) — a small village in the countryside."},
      {"金", "Places & Community", 5,
       "Originally a pictograph of nuggets buried in the earth. Gold, metal, and money.",
       "Metal nuggets under a roof buried in earth — gold and money."}
    ]
  end

  defp objects do
    [
      {"車", "Objects", 1, "A top-down view of a wheeled cart with an axle through the middle.",
       "A cart seen from above — wheels, axle, and frame."},
      {"本", "Objects", 2,
       "木 (tree) with a mark at the root. The root/origin leads to 'book' (a fundamental thing).",
       "A tree (木) with its root marked — the root of knowledge, a book."},
      {"玉", "Objects", 3, "王 (king) with a dot — a jewel that belongs to royalty. Ball or gem.",
       "A king (王) with a precious dot — a royal jewel or ball."},
      {"貝", "Objects", 4,
       "A pictograph of a cowrie shell. Shells were used as money in ancient times.",
       "A shell with legs — cowrie shells once used as currency."},
      {"円", "Objects", 5, "Simplified from 圓. The unit of Japanese currency — the yen.",
       "An enclosed circle — the Japanese yen (¥) currency."}
    ]
  end

  defp abstract do
    [
      {"大", "Abstract Concepts & Others", 1,
       "A person (人) with arms stretched wide — big! Common in 大学 (university).",
       "A person spreading arms wide to show something is BIG."},
      {"小", "Abstract Concepts & Others", 2,
       "A vertical line with two small dots — dividing something into tiny pieces.",
       "A line with two small marks — something divided into small parts."},
      {"名", "Abstract Concepts & Others", 3,
       "夕 (evening) + 口 (mouth). In the dark evening, you call out your name to be known.",
       "In the evening (夕) you speak (口) your name to be recognized."},
      {"力", "Abstract Concepts & Others", 4,
       "A pictograph of a strong arm or a plow. Raw physical power and effort.",
       "A flexed arm showing a bicep — strength and power."},
      {"文", "Abstract Concepts & Others", 5,
       "Originally a pictograph of a tattooed chest — patterns became writing and culture.",
       "Crossed lines forming a pattern — writing and culture."},
      {"正", "Abstract Concepts & Others", 6,
       "一 (one) + 止 (stop). Stopping at the one correct answer — correct and proper.",
       "Stop (止) at the one (一) right answer — correct and proper."},
      {"先", "Abstract Concepts & Others", 7,
       "Top part shows legs walking, bottom is 儿 (person). Someone walking ahead — before.",
       "Legs stepping forward above a person — going ahead, before."},
      {"早", "Abstract Concepts & Others", 8,
       "日 (sun) + 十 (ten). The sun at its first position — early morning.",
       "The sun (日) just rising (十) — early in the morning."},
      {"字", "Abstract Concepts & Others", 9,
       "宀 (roof) + 子 (child). A child under a roof learning to write characters.",
       "A child (子) under a roof (宀) — learning to write characters."},
      {"気", "Abstract Concepts & Others", 10,
       "Simplified from 氣. Steam/vapor rising — spirit, energy, and mood.",
       "Steam rising with swirls — invisible energy and spirit."},
      {"王", "Abstract Concepts & Others", 11,
       "Three horizontal lines (heaven, person, earth) connected by one vertical — the king unites all.",
       "Three realms united by one vertical stroke — the king."},
      {"音", "Abstract Concepts & Others", 12,
       "立 (stand) + 日 (sun/day). A sound that stands out clearly. Used in 音楽 (music).",
       "Standing (立) sound in the day (日) — a sound that carries."},
      {"糸", "Abstract Concepts & Others", 13,
       "A pictograph of twisted silk threads. The radical for fabric and textile kanji.",
       "Twisted threads of silk — a bundle of fine fibers."}
    ]
  end
end
