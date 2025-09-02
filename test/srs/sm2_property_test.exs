defmodule KumaSanKanji.SRS.SM2PropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties
  import StreamData

  alias KumaSanKanji.SRS.UserKanjiProgress
  alias KumaSanKanji.SRS.UserKanjiProgress, as: Progress


  @moduledoc false

  describe "calculate_sm2_interval/4 invariants" do
    property "ease factor is never below 1.3" do
  check all interval <- positive_integer(),
        repetitions <- integer(0..50),
                # restrict ef to reasonable range
                ef <- float(min: 1.3, max: 3.5),
                quality <- integer(0..5) do
        # Ensure interval at least 1
        interval = max(interval, 1)
        {new_interval, new_ef} = Progress.calculate_sm2_interval(interval, Decimal.from_float(ef), repetitions, quality)
        assert new_interval >= 1
  assert Decimal.compare(new_ef, Decimal.new("1.3")) in [:eq, :gt]
      end
    end

    property "first two correct repetitions produce intervals 1 then 6" do
      check all ef <- float(min: 1.3, max: 3.0) do
        # initial state (before any correct answers)
        interval = 1
        ease_factor = Decimal.from_float(ef)
        # first correct -> repetitions becomes 1
        {i1, ef1} = Progress.calculate_sm2_interval(interval, ease_factor, 1, 5)
        assert i1 == 1
        # second correct -> repetitions becomes 2
        {i2, _ef2} = Progress.calculate_sm2_interval(i1, ef1, 2, 5)
        assert i2 == 6
      end
    end
  end

  describe "update_srs_state/1 invariants" do
    property "sequence of correct answers has non-decreasing intervals after second repetition" do
  check all len <- integer(2..8) do
        base = %UserKanjiProgress{interval: 1, ease_factor: Decimal.new("2.5"), repetitions: 0, last_result: :correct, total_reviews: 0, correct_reviews: 0}
        changeset = Ash.Changeset.new(base)

        intervals =
          Enum.reduce(1..len, {changeset, []}, fn _n, {cs, acc} ->
            cs = Progress.update_srs_state(cs)
            i = Ash.Changeset.get_attribute(cs, :interval)
            # prepare for next iteration: set last_result to :correct again using updated data
            next = cs |> Ash.Changeset.change_attribute(:last_result, :correct)
            {next, acc ++ [i]}
          end)
          |> elem(1)

        # First interval should be 1, second 6
        [first, second | rest] = intervals
        assert first == 1
        assert second == 6
        Enum.reduce(rest, second, fn i, prev ->
          assert i >= prev
          i
        end)
      end
    end

    property "incorrect answer resets interval & repetitions and lowers EF by 0.2 with floor 1.3" do
  check all interval <- integer(1..60),
                reps <- integer(0..10),
                ef <- float(min: 1.3, max: 3.0) do
        progress = %UserKanjiProgress{interval: interval, ease_factor: Decimal.from_float(ef), repetitions: reps, last_result: :incorrect, total_reviews: 5, correct_reviews: 3}
        cs = Ash.Changeset.new(progress)
        updated = Progress.update_srs_state(cs)

        new_interval = Ash.Changeset.get_attribute(updated, :interval)
        new_reps = Ash.Changeset.get_attribute(updated, :repetitions)
        new_ef = Ash.Changeset.get_attribute(updated, :ease_factor)

        assert new_interval == 1
        assert new_reps == 0

        expected_new_ef =
            if Decimal.compare(Decimal.from_float(ef), Decimal.new("1.5")) == :gt do
            Decimal.sub(Decimal.from_float(ef), Decimal.new("0.2"))
          else
            Decimal.new("1.3")
          end

        assert Decimal.equal?(new_ef, expected_new_ef)
        # never below 1.3
  assert Decimal.compare(new_ef, Decimal.new("1.3")) in [:eq, :gt]
      end
    end

    property "skip halves the interval (floor) without changing repetitions or EF" do
  check all interval <- integer(1..60),
                reps <- integer(0..10),
                ef <- float(min: 1.3, max: 3.0) do
        progress = %UserKanjiProgress{interval: interval, ease_factor: Decimal.from_float(ef), repetitions: reps, last_result: :skip, total_reviews: 5, correct_reviews: 3}
        cs = Ash.Changeset.new(progress)
        updated = Progress.update_srs_state(cs)

        new_interval = Ash.Changeset.get_attribute(updated, :interval)
        new_reps = Ash.Changeset.get_attribute(updated, :repetitions)
        new_ef = Ash.Changeset.get_attribute(updated, :ease_factor)
        new_correct = Ash.Changeset.get_attribute(updated, :correct_reviews)

        assert new_interval == max(1, div(interval, 2))
        assert new_reps == reps
        assert Decimal.equal?(new_ef, Decimal.from_float(ef))
        assert new_correct == 3
      end
    end
  end
end
