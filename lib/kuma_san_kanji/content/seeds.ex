defmodule KumaSanKanji.Content.Seeds do
  @moduledoc """
  Seeds for the Content domain in Kuma-san Kanji.
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
        name: "Nature",
        description: "Kanji related to natural world",
        color_code: "oklch(70% 0.2 150)",
        icon_name: "tree",
        order_index: 2,
        parent_id: nil
      },
      %{
        name: "People",
        description: "Kanji related to humans and body",
        color_code: "oklch(70% 0.2 60)",
        icon_name: "person",
        order_index: 3,
        parent_id: nil
      },
      %{
        name: "Actions",
        description: "Kanji representing verbs and activities",
        color_code: "oklch(70% 0.2 200)",
        icon_name: "play",
        order_index: 4,
        parent_id: nil
      },
      %{
        name: "Time",
        description: "Kanji related to time concepts",
        color_code: "oklch(70% 0.2 90)",
        icon_name: "clock",
        order_index: 5,
        parent_id: nil
      },
      %{
        name: "Abstract Concepts & Others",
        description:
          "Kanji representing abstract ideas or those not fitting neatly into other categories.",
        color_code: "oklch(0.7 0.1 330)",
        icon_name: "puzzle-piece",
        order_index: 10
      }
    ]

    Enum.map(groups, fn group_attrs ->
      slug =
        group_attrs[:name]
        |> String.downcase()
        |> String.replace(~r/[^a-z0-9]+/, "-")
        |> String.trim("-")

      case Content.get_group_by_slug(slug) do
        {:ok, existing} ->
          existing

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
      case Content.get_educational_context_by_grade(context[:grade_level]) do
        {:ok, existing} ->
          existing

        {:error, _} ->
          {:ok, created} = Content.create_educational_context(context)
          created
      end
    end)
  end

  defp map_kanji_to_content(thematic_groups_list, educational_contexts) do
    kanji_list =
      KumaSanKanji.Domain.list_kanjis!(load: [:meanings, :pronunciations, :example_sentences])

    thematic_groups_map =
      Enum.into(thematic_groups_list, %{}, fn group -> {group.name, group} end)

    kanji_mapping = %{
      "一" => ["Numbers"],
      "七" => ["Numbers"],
      "三" => ["Numbers"],
      "九" => ["Numbers"],
      "二" => ["Numbers"],
      "五" => ["Numbers"],
      "八" => ["Numbers"],
      "六" => ["Numbers"],
      "四" => ["Numbers"],
      "十" => ["Numbers"],
      "木" => ["Nature"],
      "森" => ["Nature"],
      "林" => ["Nature"],
      "山" => ["Nature"],
      "川" => ["Nature"],
      "土" => ["Nature"],
      "空" => ["Nature"],
      "雨" => ["Nature"],
      "日" => ["Nature"],
      "月" => ["Nature"],
      "人" => ["People"],
      "子" => ["People"],
      "女" => ["People"],
      "男" => ["People"],
      "見" => ["Actions"],
      "聞" => ["Actions"],
      "行" => ["Actions"],
      "来" => ["Actions"],
      "年" => ["Time"],
      "時" => ["Time"],
      "分" => ["Time"]
    }

    Enum.each(kanji_list, fn kanji ->
      group_names = Map.get(kanji_mapping, kanji.character, [])

      Enum.each(group_names, fn group_name ->
        group = Map.get(thematic_groups_map, group_name)

        if group do
          case Content.create_kanji_thematic_group(%{
                 kanji_id: kanji.id,
                 thematic_group_id: group.id,
                 relevance_score: 1.0
               }) do
            {:ok, _} -> :ok
            {:error, _} -> :already_exists
          end
        else
          IO.puts(
            "Warning: Thematic group '#{group_name}' not found for kanji '#{kanji.character}'."
          )
        end
      end)

      if kanji.grade do
        contexts = Enum.filter(educational_contexts, &(&1.grade_level == kanji.grade))

        Enum.each(contexts, fn context ->
          case Content.create_kanji_learning_meta(%{
                 kanji_id: kanji.id,
                 educational_context_id: context.id
               }) do
            {:ok, _} -> :ok
            {:error, _} -> :already_exists
          end
        end)
      else
        IO.puts(
          "Warning: Kanji '#{kanji.character}' (ID: #{kanji.id}) has no grade level, skipping KanjiLearningMeta creation."
        )
      end
    end)
  end
end
