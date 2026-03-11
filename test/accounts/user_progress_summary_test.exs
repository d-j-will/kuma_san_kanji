defmodule KumaSanKanji.Accounts.UserProgressSummaryTest do
  use KumaSanKanji.DataCase, async: false

  alias KumaSanKanji.Accounts
  alias KumaSanKanji.Accounts.User
  alias KumaSanKanji.SRS.UserKanjiProgress
  alias KumaSanKanji.Kanji

  setup do
    # Create a user
    {:ok, user} =
      User
      |> Ash.Changeset.for_create(:create_for_test, %{email: "u@example.com", username: "tester"})
      |> Ash.create(authorize?: false)

    # Create a kanji (assumes minimal create action exists)
    {:ok, kanji} =
      Kanji.Kanji
      |> Ash.Changeset.for_create(:create, %{character: "日"})
      |> Ash.create(authorize?: false)

    # Initialize progress
    {:ok, progress} =
      UserKanjiProgress
      |> Ash.Changeset.for_create(:initialize, %{user_id: user.id, kanji_id: kanji.id})
      |> Ash.create(actor: user, authorize?: false)

    # Record a correct review
    {:ok, _p2} =
      progress
      |> Ash.Changeset.for_update(:record_review, %{last_result: :correct})
      |> Ash.update(actor: user, authorize?: false)

    %{user: user}
  end

  test "progress_summary loads aggregates & calculation", %{user: user} do
    summary = Accounts.progress_summary!(user.id, actor: user)
    assert summary.kanji_progress_count == 1
    assert summary.total_reviews_sum == 1
    assert summary.correct_reviews_sum == 1
    assert Decimal.equal?(summary.accuracy, Decimal.new("100")) or summary.accuracy == 100
  end
end
