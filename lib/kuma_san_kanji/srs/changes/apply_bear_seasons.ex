defmodule KumaSanKanji.SRS.Changes.ApplyBearSeasons do
  @moduledoc """
  Ash change that applies the Bear Seasons stage-based SRS logic.

  On correct: advance stage by 1, set next_review_date from new stage interval.
  On incorrect: penalize stage, set next_review_date from new stage interval.
  On skip: no stage change, halve remaining interval.
  Also dual-writes SM-2 fields for rollback safety.
  """

  use Ash.Resource.Change

  alias Ash.Changeset
  alias KumaSanKanji.SRS.Stage

  @impl true
  def change(changeset, _opts, _context) do
    case Changeset.get_attribute(changeset, :last_result) do
      nil -> changeset
      result -> apply_bear_seasons(changeset, result)
    end
  end

  defp apply_bear_seasons(changeset, result) do
    current_time = DateTime.utc_now()
    current_stage = Changeset.get_attribute(changeset, :srs_stage) || 1
    current_total_reviews = Changeset.get_attribute(changeset, :total_reviews) || 0
    current_correct_reviews = Changeset.get_attribute(changeset, :correct_reviews) || 0

    {new_stage, new_correct_count} =
      case result do
        :correct ->
          {:ok, advanced} = Stage.advance(current_stage)
          {advanced, current_correct_reviews + 1}

        :incorrect ->
          # Penalty with incorrect_count = 1 (single review result)
          {:ok, penalized} = Stage.penalize(current_stage, 1)
          {penalized, current_correct_reviews}

        :skip ->
          {current_stage, current_correct_reviews}
      end

    {:ok, interval_seconds} = Stage.interval(new_stage)

    next_review_date =
      if interval_seconds do
        DateTime.add(current_time, interval_seconds, :second)
      else
        # Hibernated - set far future date
        DateTime.add(current_time, 365 * 24 * 60 * 60, :second)
      end

    # Dual-write: also update SM-2 fields for rollback safety
    interval_days = if interval_seconds, do: max(1, div(interval_seconds, 86_400)), else: 365

    changeset
    |> Changeset.change_attribute(:srs_stage, new_stage)
    |> Changeset.change_attribute(:next_review_date, next_review_date)
    |> Changeset.change_attribute(:last_reviewed_at, current_time)
    |> Changeset.change_attribute(:total_reviews, current_total_reviews + 1)
    |> Changeset.change_attribute(:correct_reviews, new_correct_count)
    # Dual-write SM-2 fields
    |> Changeset.change_attribute(:interval, interval_days)
    |> Changeset.change_attribute(
      :repetitions,
      if(result == :correct,
        do: (Changeset.get_attribute(changeset, :repetitions) || 0) + 1,
        else: 0
      )
    )
    |> maybe_set_first_reviewed_at(current_time)
  end

  defp maybe_set_first_reviewed_at(changeset, current_time) do
    case Changeset.get_attribute(changeset, :first_reviewed_at) do
      nil -> Changeset.change_attribute(changeset, :first_reviewed_at, current_time)
      _ -> changeset
    end
  end
end
