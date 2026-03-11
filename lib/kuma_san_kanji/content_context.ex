defmodule KumaSanKanji.ContentContext do
  @moduledoc """
  The Content context for the application.

  This module provides the business interface for content-related operations,
  abstracting the underlying Ash resources and providing a clean API for the application.
  """
  require Ash.Query

  @doc """
  Gets thematic group information for a kanji character.
  """
  def get_thematic_group_for_kanji(kanji_id) do
    case KumaSanKanji.Content.get_kanji_group_joins(%{kanji_id: kanji_id}) do
      {:ok, joins} when joins != [] ->
        thematic_group_ids = Enum.map(joins, & &1.thematic_group_id)

        query =
          KumaSanKanji.Content.ThematicGroup
          |> Ash.Query.filter(id in ^thematic_group_ids)

        case Ash.read(query, authorize?: false) do
          {:ok, groups} -> {:ok, groups, joins}
          err -> err
        end

      {:ok, []} ->
        {:ok, [], []}

      err ->
        err
    end
  end

  @doc """
  Gets educational context for a kanji based on its grade level.
  """
  def get_educational_context(grade) when is_integer(grade) do
    KumaSanKanji.Content.get_educational_context_by_grade(%{grade_level: grade})
  end

  @doc """
  Gets usage examples for a kanji.
  """
  def get_usage_examples(kanji_id) do
    KumaSanKanji.Content.get_kanji_usage_examples(%{kanji_id: kanji_id})
  end

  @doc """
  Gets learning metadata for a kanji.
  """
  def get_learning_meta(kanji_id) do
    KumaSanKanji.Content.get_kanji_learning_meta(%{kanji_id: kanji_id})
  end

  @doc """
  Returns all thematic groups in order.
  """
  def get_all_thematic_groups do
    KumaSanKanji.Content.get_ordered_groups()
  end

  @doc """
  Returns all kanji in a specific thematic group, sorted by position.
  """
  def get_kanji_by_thematic_group(thematic_group_id) do
    with {:ok, joins} <-
           KumaSanKanji.Content.get_group_kanji_joins(%{thematic_group_id: thematic_group_id}),
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
end
