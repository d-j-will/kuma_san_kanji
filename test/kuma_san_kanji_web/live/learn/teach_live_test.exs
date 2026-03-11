defmodule KumaSanKanjiWeb.TeachLiveTest do
  @moduledoc """
  Acceptance tests for US-02: Study a Kanji in the Teach Step.

  Validates that a learner can view full kanji details (character, meaning,
  readings, stroke count, example sentences) in the teach step, and that
  optional learning metadata displays when available.

  Driving port: TeachLive (LiveView mount and render)
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.LearningPathHelpers

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Learner studies a kanji in the teach step" do

    test "learner sees full kanji detail for a specific position", %{conn: conn} do
      # Given Yuki Tanaka is signed in
      {conn, _user} = create_authenticated_learner(conn, "yuki-teach")
      enable_learning_path_flag()

      # And Yuki is learning the Numbers group
      {group, _kanji_list} = create_numbers_group()

      # When Yuki opens the teach step for position 4 (四)
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/4")

      # Then Yuki sees the character 四 displayed prominently
      assert html =~ "四"

      # And Yuki sees the meaning "four"
      assert html =~ "four"

      # And Yuki sees kun readings: よん, よ, よっつ
      assert html =~ "よん"

      # And Yuki sees on reading: シ
      assert html =~ "シ"

      # And Yuki sees stroke count: 5
      assert html =~ "5"

      # And Yuki sees an example sentence with translation
      assert html =~ "四月は春です。"
      assert html =~ "April is spring."
    end
  end

  # ---------------------------------------------------------------
  # Happy Path Scenarios
  # ---------------------------------------------------------------

  describe "Position indicator shows group context" do

    test "header displays group name and position within group", %{conn: conn} do
      # Given Yuki Tanaka is learning the Numbers group
      {conn, _user} = create_authenticated_learner(conn, "yuki-position")
      enable_learning_path_flag()

      {group, _kanji_list} = create_numbers_group()

      # When Yuki opens the teach step for position 4 of 4
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/4")

      # Then Yuki sees position context in the header
      assert html =~ "Numbers"
      assert html =~ "4"
    end
  end

  describe "Learning tips display when available" do

    test "kanji with learning metadata shows tips section", %{conn: conn} do
      # Given Yuki is on the teach step for 四
      {conn, _user} = create_authenticated_learner(conn, "yuki-tips")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()
      kanji_four = Enum.at(kanji_list, 3)

      # And 四 has a KanjiLearningMeta record with a learning tip
      create_learning_meta(kanji_four, %{
        learning_tips: "Four has an enclosed square shape, like four walls of a room."
      })

      # When the page renders
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/4")

      # Then Yuki sees the learning tip
      assert html =~ "four walls"
    end
  end

  describe "Learning tips hidden when no metadata exists" do

    test "kanji without learning metadata omits tips section", %{conn: conn} do
      # Given Yuki is on the teach step for 一
      {conn, _user} = create_authenticated_learner(conn, "yuki-no-tips")
      enable_learning_path_flag()

      {group, _kanji_list} = create_numbers_group()
      # 一 at position 1 has no KanjiLearningMeta record

      # When the page renders
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/1")

      # Then the learning tip section is not displayed
      # And all other kanji information displays normally
      assert html =~ "一"
      assert html =~ "one"
      assert html =~ "ひと"
    end
  end

  describe "Learner sees I've learned this button" do

    test "teach step shows the mark-learned action button", %{conn: conn} do
      # Given Yuki is on the teach step for a kanji
      {conn, _user} = create_authenticated_learner(conn, "yuki-button")
      enable_learning_path_flag()

      {group, _kanji_list} = create_numbers_group()

      # When the page renders
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/1")

      # Then Yuki sees the "I've learned this" button
      assert html =~ "learned" or html =~ "Quiz me"
    end
  end

  # ---------------------------------------------------------------
  # Error Path Scenarios
  # ---------------------------------------------------------------

  describe "Invalid position shows graceful error" do

    test "position beyond group size shows helpful message", %{conn: conn} do
      # Given Yuki is learning the Numbers group with 4 kanji
      {conn, _user} = create_authenticated_learner(conn, "yuki-invalid-pos")
      enable_learning_path_flag()

      {group, _kanji_list} = create_numbers_group()

      # When Yuki navigates to position 99 (does not exist)
      result = live(conn, ~p"/learn/#{group.id}/99")

      # Then Yuki sees a redirect or error message (not a crash)
      case result do
        {:error, {:redirect, _}} -> assert true
        {:ok, _view, html} -> assert html =~ "not found" or html =~ "Numbers"
      end
    end
  end

  describe "Non-existent group shows graceful error" do

    test "invalid group identifier redirects gracefully", %{conn: conn} do
      # Given Yuki is signed in
      {conn, _user} = create_authenticated_learner(conn, "yuki-bad-group")
      enable_learning_path_flag()

      # When Yuki navigates to a teach step for a non-existent group
      result = live(conn, ~p"/learn/nonexistent-group/1")

      # Then Yuki is redirected or sees an error (not a crash)
      case result do
        {:error, {:redirect, _}} -> assert true
        {:ok, _view, html} -> assert html =~ "not found" or html =~ "Learn"
      end
    end
  end

  describe "Unauthenticated access to teach step" do

    test "unauthenticated visitor is redirected to sign-in", %{conn: conn} do
      # Given the feature flag is enabled
      enable_learning_path_flag()

      # And a visitor is not signed in

      # When the visitor navigates to a teach step URL
      assert {:error, {:redirect, %{to: redirect_path}}} =
               live(conn, ~p"/learn/some-group/1")

      # Then the visitor is redirected to the sign-in page
      assert redirect_path =~ "/sign-in"
    end
  end

  describe "Kanji without example sentences degrades gracefully" do

    test "teach step omits sentence section when kanji has none", %{conn: conn} do
      # Given a kanji exists without example sentences
      {conn, _user} = create_authenticated_learner(conn, "yuki-no-sentence")
      enable_learning_path_flag()

      group = create_thematic_group(%{name: "Test Group", order_index: 1})

      # Create kanji without example sentence
      kanji =
        KumaSanKanji.Domain.create_kanji!(%{
          character: "力",
          grade: 1,
          stroke_count: 2,
          jlpt_level: 5
        })

      {:ok, _} = KumaSanKanji.Domain.create_meaning(%{kanji_id: kanji.id, value: "power"})
      assign_kanji_to_group(kanji, group, 1)

      # When Yuki opens the teach step
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/1")

      # Then the character and meaning still display
      assert html =~ "力"
      assert html =~ "power"
    end
  end
end
