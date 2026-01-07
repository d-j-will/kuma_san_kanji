defmodule KumaSanKanji.SRS.Changes.ApplySm2 do
  @moduledoc """
  Ash change that applies the SM-2 spaced repetition interval/ease factor updates
  to a `UserKanjiProgress` record based on `:last_result` (:correct, :incorrect, :skip).

  This encapsulates what previously lived in `UserKanjiProgress.update_srs_state/1` so that
  review mutation logic resides in a reusable change module (Ash best practice: avoid large
  inline anonymous functions inside the resource DSL).
  """

  use Ash.Resource.Change

  alias Ash.Changeset
  alias KumaSanKanji.SRS.UserKanjiProgress

  @impl true
  def change(changeset, _opts, _context) do
    # If last_result not set, do nothing (action may have other changes)
    case Changeset.get_attribute(changeset, :last_result) do
      nil -> changeset
      _ -> apply_sm2(changeset)
    end
  end

  # Core logic extracted from the former update_srs_state/1 function.
  defp apply_sm2(changeset) do
    current_time = DateTime.utc_now()
    result = Changeset.get_attribute(changeset, :last_result)

    current_interval = Changeset.get_attribute(changeset, :interval) || 1

    current_ease_factor =
      Changeset.get_attribute(changeset, :ease_factor) || Decimal.new("2.5")

    current_repetitions = Changeset.get_attribute(changeset, :repetitions) || 0
    current_total_reviews = Changeset.get_attribute(changeset, :total_reviews) || 0
    current_correct_reviews = Changeset.get_attribute(changeset, :correct_reviews) || 0

    {new_interval, new_ease_factor, new_repetitions, new_correct_count} =
      case result do
        :correct ->
          new_repetitions = current_repetitions + 1
          new_correct_count = current_correct_reviews + 1

          {new_interval, new_ease_factor} =
            UserKanjiProgress.calculate_sm2_interval(
              current_interval,
              current_ease_factor,
              new_repetitions,
              5
            )

          {new_interval, new_ease_factor, new_repetitions, new_correct_count}

        :incorrect ->
          new_ease_factor =
            Decimal.max(
              Decimal.sub(current_ease_factor, Decimal.new("0.2")),
              Decimal.new("1.3")
            )

          {1, new_ease_factor, 0, current_correct_reviews}

        :skip ->
          {max(1, div(current_interval, 2)), current_ease_factor, current_repetitions,
           current_correct_reviews}
      end

    next_review_date =
      current_time
      |> DateTime.add(new_interval * 24 * 60 * 60, :second)

    changeset
    |> Changeset.change_attribute(:interval, new_interval)
    |> Changeset.change_attribute(:ease_factor, new_ease_factor)
    |> Changeset.change_attribute(:repetitions, new_repetitions)
    |> Changeset.change_attribute(:next_review_date, next_review_date)
    |> Changeset.change_attribute(:last_reviewed_at, current_time)
    |> Changeset.change_attribute(:total_reviews, current_total_reviews + 1)
    |> Changeset.change_attribute(:correct_reviews, new_correct_count)
    |> maybe_set_first_reviewed_at(current_time)
  end

  defp maybe_set_first_reviewed_at(changeset, current_time) do
    case Changeset.get_attribute(changeset, :first_reviewed_at) do
      nil -> Changeset.change_attribute(changeset, :first_reviewed_at, current_time)
      _ -> changeset
    end
  end
end
