defmodule KumaSanKanji.Quiz.Core.SessionState do
  @moduledoc """
  Pure Decide-zone logic for the quiz session (Gather → Decide → Act).

  Takes already-gathered results from `KumaSanKanji.SRS.Logic` / `KumaSanKanji.Quiz.Session`
  and returns the LiveView state map. No IO, no Ash, no clock — pure functions only.
  """

  @doc "Build the initial quiz state from gathered stats + due-kanji results."
  def init_state(stats_result, due_result) do
    stats = stats_or_empty(stats_result)

    case due_result do
      {:ok, [progress | _]} ->
        {:ok,
         %{
           current_kanji: progress.kanji,
           current_progress: progress,
           user_stats: stats,
           quiz_error: false
         }}

      {:ok, []} ->
        {:ok, %{current_kanji: nil, user_stats: stats, quiz_error: false}}

      {:error, :not_found} ->
        {:ok, %{current_kanji: nil, user_stats: stats, quiz_error: false}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Build the restored-session state from gathered restore + stats + due results."
  def restored_state({:error, _reason}, _stats_result, _due_result),
    do: {:error, :session_not_found}

  def restored_state({:ok, session_data}, stats_result, due_result) do
    case stats_result do
      {:error, reason} ->
        {:error, reason}

      {:ok, stats} ->
        {:ok,
         %{
           current_kanji: session_data.current_kanji,
           current_progress: current_progress_for(session_data.current_kanji, due_result),
           user_stats: stats,
           quiz_error: false,
           answers_count: session_data.answers_count || 0,
           last_answer_times: session_data.last_answer_times || []
         }}
    end
  end

  defp stats_or_empty({:ok, stats}), do: stats
  defp stats_or_empty({:error, _}), do: %{}

  defp current_progress_for(nil, _due_result), do: nil

  defp current_progress_for(kanji, {:ok, [progress | _]}) when progress.kanji.id == kanji.id,
    do: progress

  defp current_progress_for(_kanji, _due_result), do: nil
end
