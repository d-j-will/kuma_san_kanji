defmodule KumaSanKanjiWeb.MarkLearnedTest do
  @moduledoc """
  Acceptance tests for US-03: Mark a Kanji as Learned.

  Validates that clicking "I've learned this" creates SRS progress,
  that existing progress is preserved, and that skipping does not
  create a progress record.

  Driving port: TeachLive (LiveView events: mark_learned, skip)
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.TestHelpers
  import KumaSanKanji.LearningPathHelpers

  alias KumaSanKanji.SRS.UserKanjiProgress

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Learner marks kanji as learned and enters quiz" do
    @tag :skip
    test "marking a new kanji as learned creates progress and navigates to quiz", %{conn: conn} do
      # Given Yuki Tanaka is on the teach step for 四
      {conn, user} = create_authenticated_learner(conn, "yuki-mark")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()
      kanji_four = Enum.at(kanji_list, 3)

      # And Yuki has no existing UserKanjiProgress for 四
      assert {:ok, []} =
               UserKanjiProgress.get_user_kanji_progress(user.id, kanji_four.id, actor: user)

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/4")

      # When Yuki clicks "I've learned this -- Quiz me!"
      view
      |> element("button", ~r/learned|Quiz me/i)
      |> render_click()

      # Then a UserKanjiProgress record is created for Yuki and 四
      assert {:ok, [progress]} =
               UserKanjiProgress.get_user_kanji_progress(user.id, kanji_four.id, actor: user)

      # And the record has initial SRS values
      assert progress.interval == 1
      assert progress.repetitions == 0

      # And Yuki is navigated to the group quiz
      {path, _flash} = assert_redirect(view)
      assert path =~ ~r/learn\/.*\/quiz/
    end
  end

  # ---------------------------------------------------------------
  # Happy Path Scenarios
  # ---------------------------------------------------------------

  describe "Marking an already-tracked kanji preserves SRS state" do
    @tag :skip
    test "existing progress is not overwritten when re-marking learned", %{conn: conn} do
      # Given Yuki Tanaka is on the teach step for 三
      {conn, user} = create_authenticated_learner(conn, "yuki-preserve")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()
      kanji_three = Enum.at(kanji_list, 2)

      # And Yuki already has a UserKanjiProgress for 三
      existing_progress = mark_kanji_learned(user, kanji_three)

      # Simulate some SRS history by recording a review
      {:ok, updated} =
        KumaSanKanji.SRS.Logic.record_review(
          existing_progress.id,
          :correct,
          user.id,
          user
        )

      original_interval = updated.interval
      original_repetitions = updated.repetitions

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/3")

      # When Yuki clicks "I've learned this -- Quiz me!"
      view
      |> element("button", ~r/learned|Quiz me/i)
      |> render_click()

      # Then the existing UserKanjiProgress is not modified
      {:ok, [current]} =
        UserKanjiProgress.get_user_kanji_progress(user.id, kanji_three.id, actor: user)

      # The SRS state should be preserved (interval and repetitions from the review)
      assert current.interval == original_interval
      assert current.repetitions == original_repetitions
    end
  end

  # ---------------------------------------------------------------
  # Error/Edge Path Scenarios
  # ---------------------------------------------------------------

  describe "Skipping does not create a progress record" do
    @tag :skip
    test "skip advances to next kanji without creating progress", %{conn: conn} do
      # Given Yuki Tanaka is on the teach step for 四
      {conn, user} = create_authenticated_learner(conn, "yuki-skip")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()
      kanji_four = Enum.at(kanji_list, 3)

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/4")

      # When Yuki clicks "Skip to next"
      view
      |> element("a", ~r/[Ss]kip/i)
      |> render_click()

      # Then no UserKanjiProgress record is created for 四
      assert {:ok, []} =
               UserKanjiProgress.get_user_kanji_progress(user.id, kanji_four.id, actor: user)
    end
  end

  describe "Skip at last position returns to group page" do
    @tag :skip
    test "skipping past the last kanji navigates back to group detail", %{conn: conn} do
      # Given Yuki is on the teach step for the last kanji (position 4 of 4)
      {conn, _user} = create_authenticated_learner(conn, "yuki-skip-last")
      enable_learning_path_flag()

      {group, _kanji_list} = create_numbers_group()

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/4")

      # When Yuki clicks "Skip to next" on the last kanji
      view
      |> element("a", ~r/[Ss]kip/i)
      |> render_click()

      # Then Yuki is navigated back to the group page
      {path, _flash} = assert_redirect(view)
      assert path =~ ~r/learn\//
    end
  end

  describe "Multiple kanji can be marked learned sequentially" do
    @tag :skip
    test "marking learned creates independent progress records", %{conn: conn} do
      # Given Yuki is signed in
      {conn, user} = create_authenticated_learner(conn, "yuki-multi")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()
      kanji_one = Enum.at(kanji_list, 0)
      kanji_two = Enum.at(kanji_list, 1)

      # When Yuki marks 一 as learned from position 1
      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/1")

      view
      |> element("button", ~r/learned|Quiz me/i)
      |> render_click()

      # And then marks 二 as learned from position 2
      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/2")

      view
      |> element("button", ~r/learned|Quiz me/i)
      |> render_click()

      # Then both kanji have progress records
      assert {:ok, [_p1]} =
               UserKanjiProgress.get_user_kanji_progress(user.id, kanji_one.id, actor: user)

      assert {:ok, [_p2]} =
               UserKanjiProgress.get_user_kanji_progress(user.id, kanji_two.id, actor: user)
    end
  end
end
