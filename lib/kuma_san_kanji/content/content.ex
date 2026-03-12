defmodule KumaSanKanji.Content.ContentContext do
  @moduledoc """
  Content context for managing kanji thematic groups, educational context, and learning metadata.

  This module provides the high-level business interface for content-related operations,
  abstracting the underlying Ash resources and providing a clean API for the application.
  """

  alias KumaSanKanji.Content
  require Ash.Query

  @doc """
  Gets thematic group information for a kanji character.
  """
  def get_thematic_group_for_kanji(kanji_id) do
    with {:ok, joins} <- Content.get_kanji_group_joins(%{kanji_id: kanji_id}),
         thematic_group_ids = Enum.map(joins, & &1.thematic_group_id),
         query =
           KumaSanKanji.Content.ThematicGroup
           |> Ash.Query.filter(id in ^thematic_group_ids),
         {:ok, groups} <- Ash.read(query, authorize?: false) do
      {:ok, groups, joins}
    else
      {:ok, []} -> {:ok, [], []}
      err -> err
    end
  end

  @doc """
  Gets educational context for a kanji based on its grade level.
  """
  def get_educational_context(grade) when is_integer(grade) do
    Content.get_educational_context_by_grade(%{grade_level: grade})
  end

  @doc """
  Gets usage examples for a kanji.
  """
  def get_usage_examples(kanji_id) do
    Content.get_kanji_usage_examples(%{kanji_id: kanji_id})
  end

  @doc """
  Gets learning metadata for a kanji.
  """
  def get_learning_meta(kanji_id) do
    Content.get_kanji_learning_meta(%{kanji_id: kanji_id})
  end

  @doc """
  Returns all thematic groups in order.
  """
  def get_all_thematic_groups do
    Content.get_ordered_groups()
  end

  @doc """
  Returns all kanji in a specific thematic group, sorted by position.
  """
  def get_kanji_by_thematic_group(thematic_group_id) do
    require Ash.Query

    with {:ok, joins} <- Content.get_group_kanji_joins(%{thematic_group_id: thematic_group_id}),
         kanji_ids = Enum.map(joins, & &1.kanji_id),
         query =
           KumaSanKanji.Kanji.Kanji
           |> Ash.Query.filter(id in ^kanji_ids)
           |> Ash.Query.load([:meanings, :pronunciations, :example_sentences]),
         {:ok, kanji} <- Ash.read(query, authorize?: false) do
      sorted_kanji =
        Enum.sort_by(kanji, fn k ->
          position =
            Enum.find_value(joins, 0, fn j ->
              if j.kanji_id == k.id, do: Map.get(j, :position, 0), else: nil
            end)

          {position, k.character}
        end)

      {:ok, sorted_kanji}
    end
  end

  @doc """
  Gets a thematic group by its slug.
  """
  def get_group_by_slug(slug) do
    Content.get_group_by_slug(%{slug: slug})
  end

  @doc """
  Gets learning progress for a user within a thematic group.

  Returns `{:ok, %{learned: count, total: count}}`.
  """
  def get_group_progress(user_id, group_id) do
    with {:ok, joins} <- Content.get_group_kanji_joins(%{thematic_group_id: group_id}),
         kanji_ids = Enum.map(joins, & &1.kanji_id) do
      if kanji_ids == [] do
        {:ok, %{learned: 0, total: 0}}
      else
        learned_count =
          Enum.count(kanji_ids, fn kanji_id ->
            case KumaSanKanji.SRS.UserKanjiProgress.get_user_kanji_progress(user_id, kanji_id,
                   authorize?: false
                 ) do
              {:ok, [_ | _]} -> true
              _ -> false
            end
          end)

        {:ok, %{learned: learned_count, total: length(kanji_ids)}}
      end
    end
  end

  @doc """
  Gets the kanji at a specific position within a thematic group.
  """
  def get_kanji_at_position(group_id, position) do
    with {:ok, joins} <- Content.get_group_kanji_joins(%{thematic_group_id: group_id}) do
      sorted_joins =
        Enum.sort_by(joins, fn j -> {Map.get(j, :position, 0) || 0, j.kanji_id} end)

      join = Enum.at(sorted_joins, position - 1)

      case join do
        nil -> {:error, :not_found}
        j -> KumaSanKanji.Domain.get_kanji_by_id(j.kanji_id)
      end
    end
  end
end
