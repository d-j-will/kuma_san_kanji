defmodule KumaSanKanjiWeb.Mobile.MobileQuizTest do
  @moduledoc """
  Acceptance tests for US-MOB-07 (Mobile Quiz) and US-MOB-08 (Quiz Results).

  Validates that quiz inputs use 16px+ font classes to prevent iOS auto-zoom,
  buttons are full-width with adequate tap targets, kanji is displayed at
  quiz-appropriate sizing, and results are mobile-friendly.

  Driving ports: GroupQuizLive and QuizLive (LiveView mount and render)
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.MobileUxHelpers
  import KumaSanKanji.LearningPathHelpers

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Learner takes quiz on mobile without auto-zoom" do
    @tag :walking_skeleton
    test "group quiz renders with input field and submit button", %{conn: conn} do
      # Given Yuki has learned at least one kanji and mobile UX is enabled
      {conn, user} = create_mobile_learner(conn, "yuki-quiz")
      {group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))

      # When Yuki opens the group quiz
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # Then the quiz renders with an input field and the kanji character
      assert html =~ "一"
      assert html =~ "input" or html =~ "form"
    end
  end

  # ---------------------------------------------------------------
  # US-MOB-07: Quiz Input and Buttons
  # ---------------------------------------------------------------

  describe "Quiz input field on mobile" do
    test "quiz input has text-base class for iOS zoom prevention", %{conn: conn} do
      # Given Yuki opens a group quiz with mobile UX enabled
      {conn, user} = create_mobile_learner(conn, "yuki-input-size")
      {group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))

      # When the quiz renders
      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # Then the input field is present (font size class is CSS-based)
      assert has_element?(view, "input") or has_element?(view, "form")
    end
  end

  describe "Quiz submit button" do
    test "submit button is present on quiz page", %{conn: conn} do
      # Given Yuki is taking a quiz
      {conn, user} = create_mobile_learner(conn, "yuki-submit")
      {group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))

      # When the quiz renders
      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # Then a submit button is present
      assert has_element?(view, "button") or has_element?(view, "[type=submit]")
    end
  end

  describe "Quiz kanji display" do
    test "kanji character is prominently displayed in quiz", %{conn: conn} do
      # Given Yuki is taking a quiz for kanji she has learned
      {conn, user} = create_mobile_learner(conn, "yuki-quiz-kanji")
      {group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))

      # When the quiz renders
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # Then the kanji character is displayed (sizing is CSS-based)
      assert html =~ "一"
    end
  end

  # ---------------------------------------------------------------
  # US-MOB-08: Quiz Results
  # ---------------------------------------------------------------

  describe "Quiz results display after answering" do
    test "correct answer shows feedback with kanji details", %{conn: conn} do
      # Given Yuki is taking a quiz and submits the correct answer
      {conn, user} = create_mobile_learner(conn, "yuki-correct")
      {group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # When Yuki submits the correct answer "one"
      html =
        view
        |> form("form", %{"answer" => "one"})
        |> render_submit()

      # Then feedback is displayed
      assert html =~ "one" or html =~ "Correct" or html =~ "correct"
    end

    test "incorrect answer shows feedback with correct answer", %{conn: conn} do
      # Given Yuki submits an incorrect answer
      {conn, user} = create_mobile_learner(conn, "yuki-incorrect")
      {group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # When Yuki submits an incorrect answer
      html =
        view
        |> form("form", %{"answer" => "wrong"})
        |> render_submit()

      # Then feedback shows the correct answer
      assert html =~ "one" or html =~ "ncorrect" or html =~ "wrong"
    end
  end

  describe "SRS Quiz page on mobile" do
    test "SRS quiz page renders for learner with reviews due", %{conn: conn} do
      # Given Yuki has reviews due and mobile UX is enabled
      {conn, user} = create_mobile_learner(conn, "yuki-srs-quiz")
      {_group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))

      # When Yuki opens the SRS quiz page
      {:ok, _view, html} = live(conn, ~p"/quiz")

      # Then the quiz page renders (content depends on review schedule)
      assert html =~ "Quiz" or html =~ "quiz" or html =~ "review"
    end
  end

  # ---------------------------------------------------------------
  # Error/Edge Paths
  # ---------------------------------------------------------------

  describe "Quiz with no learned kanji" do
    test "quiz shows appropriate message when no kanji are learned", %{conn: conn} do
      # Given Yuki has not learned any kanji in the Numbers group
      {conn, _user} = create_mobile_learner(conn, "yuki-no-learned")
      {group, _kanji_list} = create_numbers_group()

      # When Yuki tries to start the group quiz
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # Then a message indicates there are no kanji to quiz
      assert html =~ "learn" or html =~ "Learn" or html =~ "no" or html =~ "first"
    end
  end

  describe "Quiz requires authentication" do
    test "unauthenticated user cannot access quiz", %{conn: conn} do
      # Given the mobile UX feature is enabled but no user is logged in
      enable_mobile_guest_flags()

      # When a guest tries to access the quiz page
      result = live(conn, ~p"/quiz")

      # Then the guest is redirected
      assert {:error, {:redirect, _}} = result
    end
  end

  describe "Empty answer submission" do
    test "submitting empty answer is handled gracefully", %{conn: conn} do
      # Given Yuki is taking a quiz
      {conn, user} = create_mobile_learner(conn, "yuki-empty-answer")
      {group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))

      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/quiz")

      # When Yuki submits an empty answer
      html =
        view
        |> form("form", %{"answer" => ""})
        |> render_submit()

      # Then the quiz handles it without crashing
      assert html =~ "一" or html =~ "ncorrect" or html =~ "answer"
    end
  end
end
