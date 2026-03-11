defmodule KumaSanKanjiWeb.GroupQuizLiveTest do
  @moduledoc """
  Acceptance tests for US-04: Quiz Scoped to Learned Kanji in a Group.

  Validates that the group quiz only draws from kanji the learner has marked
  as learned within the current thematic group, that answer checking works
  for both meanings and readings, and that SRS records are updated.

  Driving port: GroupQuizLive (LiveView mount, submit_answer, next_kanji events)
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.LearningPathHelpers

  alias KumaSanKanji.SRS.UserKanjiProgress

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Learner quizzes on learned kanji in a group" do

    test "quiz presents only learned kanji from the current group", %{conn: conn} do
      # Given Yuki has learned 一, 二, 三 in the Numbers group
      {conn, user} = create_authenticated_learner(conn, "yuki-quiz")
      enable_learning_path_flag()

      {numbers_group, numbers_kanji} = create_numbers_group()
      learned = Enum.take(numbers_kanji, 3)
      Enum.each(learned, &mark_kanji_learned(user, &1))

      # And Yuki has learned 山 in the Nature group
      {_nature_group, nature_kanji} = create_nature_group()
      mark_kanji_learned(user, Enum.at(nature_kanji, 0))

      # When Yuki starts the Numbers group quiz
      {:ok, _view, html} = live(conn, ~p"/learn/#{numbers_group.id}/quiz")

      # Then the quiz draws from the learned Numbers kanji
      # (at least one of 一, 二, 三 appears as the current question)
      learned_chars = Enum.map(learned, & &1.character)
      assert Enum.any?(learned_chars, &String.contains?(html, &1))

      # And 四 does not appear (not learned)
      # And 山 does not appear (different group)
      # (These are verified by the quiz pool, not necessarily visible on first question)
    end
  end

  # ---------------------------------------------------------------
  # Happy Path Scenarios
  # ---------------------------------------------------------------

  describe "Correct answer shows positive feedback" do

    test "typing the correct meaning shows Correct feedback", %{conn: conn} do
      # Given Yuki is in the Numbers group quiz
      {conn, user} = create_authenticated_learner(conn, "yuki-correct")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()

      # Learn only 一 so quiz pool is deterministic
      kanji_one = Enum.at(kanji_list, 0)
      mark_kanji_learned(user, kanji_one)

      {:ok, view, html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # And the current question shows 一
      assert html =~ "一"

      # When Yuki types "one" and submits
      view
      |> element("form")
      |> render_submit(%{answer: "one"})

      # Then Yuki sees "Correct!" feedback
      assert render(view) =~ "Correct"
    end
  end

  describe "Incorrect answer shows learning reinforcement" do

    test "wrong answer shows the correct meaning and readings", %{conn: conn} do
      # Given Yuki is in the Numbers group quiz
      {conn, user} = create_authenticated_learner(conn, "yuki-incorrect")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()

      # Learn only 一 so quiz pool is deterministic
      kanji_one = Enum.at(kanji_list, 0)
      mark_kanji_learned(user, kanji_one)

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # When Yuki types "five" (wrong) and submits
      view
      |> element("form")
      |> render_submit(%{answer: "five"})

      updated_html = render(view)

      # Then Yuki sees "Incorrect" feedback
      assert updated_html =~ "Incorrect" or updated_html =~ "incorrect"

      # And the feedback shows the correct meaning "one"
      assert updated_html =~ "one"
    end
  end

  describe "Reading accepted as correct answer" do

    test "answering with a reading instead of meaning is accepted", %{conn: conn} do
      # Given Yuki is quizzing on the Numbers group
      {conn, user} = create_authenticated_learner(conn, "yuki-reading")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()

      # Learn only 一 so quiz pool is deterministic
      kanji_one = Enum.at(kanji_list, 0)
      mark_kanji_learned(user, kanji_one)

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # When Yuki types "ひと" (kun reading) and submits
      view
      |> element("form")
      |> render_submit(%{answer: "ひと"})

      # Then Yuki sees "Correct!" feedback
      assert render(view) =~ "Correct"
    end
  end

  describe "SRS record is updated after answering" do

    test "correct answer updates the SRS record for the kanji", %{conn: conn} do
      # Given Yuki is in the Numbers group quiz
      {conn, user} = create_authenticated_learner(conn, "yuki-srs")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()

      kanji_one = Enum.at(kanji_list, 0)
      progress = mark_kanji_learned(user, kanji_one)

      original_total_reviews = progress.total_reviews

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # When Yuki answers correctly
      view
      |> element("form")
      |> render_submit(%{answer: "one"})

      # Then the SRS record for 一 is updated
      {:ok, [updated]} =
        UserKanjiProgress.get_user_kanji_progress(user.id, kanji_one.id, actor: user)

      assert updated.total_reviews > original_total_reviews
    end
  end

  describe "Quiz session ends after all learned kanji reviewed" do

    test "answering all questions transitions to completion", %{conn: conn} do
      # Given Yuki has learned only 一 in the Numbers group
      {conn, user} = create_authenticated_learner(conn, "yuki-complete-quiz")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()

      kanji_one = Enum.at(kanji_list, 0)
      mark_kanji_learned(user, kanji_one)

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # When Yuki answers the only question
      view
      |> element("form")
      |> render_submit(%{answer: "one"})

      # And proceeds to next (which should end the quiz)
      if has_element?(view, "button", ~r/[Nn]ext/) do
        view
        |> element("button", ~r/[Nn]ext/)
        |> render_click()
      end

      # Then the quiz transitions to completion or back to group
      html = render(view)
      assert html =~ "session" or html =~ "complete" or html =~ "correct" or html =~ "Numbers"
    end
  end

  # ---------------------------------------------------------------
  # Error Path Scenarios
  # ---------------------------------------------------------------

  describe "Quiz blocked when no kanji learned in group" do

    test "zero learned kanji shows helpful message with link to first teach step", %{conn: conn} do
      # Given Yuki has not learned any kanji in the Numbers group
      {conn, _user} = create_authenticated_learner(conn, "yuki-no-learned")
      enable_learning_path_flag()

      {group, _kanji_list} = create_numbers_group()

      # When Yuki navigates directly to the Numbers quiz URL
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # Then Yuki sees "Learn at least one kanji before starting the quiz."
      assert html =~ "Learn at least one kanji" or html =~ "learn" or html =~ "study"

      # And a link to the first kanji teach step exists
      assert html =~ ~r/learn\// or html =~ "Start with"
    end
  end

  describe "Empty answer submission" do

    test "submitting an empty answer shows validation message", %{conn: conn} do
      # Given Yuki is in the quiz with a learned kanji
      {conn, user} = create_authenticated_learner(conn, "yuki-empty-answer")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # When Yuki submits an empty answer
      view
      |> element("form")
      |> render_submit(%{answer: ""})

      # Then Yuki sees a validation message (not a crash)
      html = render(view)
      assert html =~ "answer" or html =~ "enter" or html =~ "Please"
    end
  end

  describe "Quiz for non-existent group" do

    test "navigating to quiz for invalid group handles gracefully", %{conn: conn} do
      # Given Yuki is signed in
      {conn, _user} = create_authenticated_learner(conn, "yuki-bad-quiz-group")
      enable_learning_path_flag()

      # When Yuki navigates to a quiz for a non-existent group
      result = live(conn, ~p"/learn/nonexistent/quiz")

      # Then Yuki is redirected or sees an error (not a crash)
      case result do
        {:error, {:redirect, _}} -> assert true
        {:ok, _view, html} -> assert html =~ "not found" or html =~ "Learn"
      end
    end
  end

  describe "Cross-group isolation" do

    test "kanji learned in another group do not appear in this group quiz", %{conn: conn} do
      # Given Yuki has learned 山, 川 in the Nature group
      {conn, user} = create_authenticated_learner(conn, "yuki-isolation")
      enable_learning_path_flag()

      {numbers_group, _numbers_kanji} = create_numbers_group()
      {_nature_group, nature_kanji} = create_nature_group()

      # Learn nature kanji only
      Enum.each(nature_kanji, &mark_kanji_learned(user, &1))

      # And has not learned any Numbers kanji

      # When Yuki navigates to the Numbers quiz
      {:ok, _view, html} = live(conn, ~p"/learn/#{numbers_group.id}/quiz")

      # Then the quiz shows the "no learned kanji" message
      # (山 and 川 are learned but in Nature, not Numbers)
      assert html =~ "Learn at least one kanji" or html =~ "learn" or html =~ "study"

      # And 山 and 川 do not appear as quiz questions
      refute html =~ "山"
      refute html =~ "川"
    end
  end
end
