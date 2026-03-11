defmodule KumaSanKanjiWeb.LearnLiveTest do
  @moduledoc """
  Acceptance tests for US-01: Browse Thematic Groups.

  Validates that an authenticated learner can see all thematic groups
  on the Learn page with accurate progress indicators, and that
  access is properly gated behind authentication and feature flag.

  Driving port: LearnLive (LiveView mount and render)
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.LearningPathHelpers

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Learner browses thematic groups" do
    @tag :skip
    test "first-time learner sees all thematic groups with kanji counts", %{conn: conn} do
      # Given Yuki Tanaka is signed in
      {conn, _user} = create_authenticated_learner(conn, "yuki")
      # And the grade1_learning_path feature flag is enabled
      enable_learning_path_flag()

      # And thematic groups are seeded
      {_numbers_group, _numbers_kanji} = create_numbers_group()
      {_nature_group, _nature_kanji} = create_nature_group()

      # When Yuki navigates to the Learn page
      {:ok, view, html} = live(conn, ~p"/learn")

      # Then Yuki sees thematic group cards
      assert html =~ "Numbers"
      assert html =~ "Nature"

      # And each card shows the group name and kanji count
      assert render(view) =~ "4"
      assert render(view) =~ "2"

      # And each card shows "Not started"
      assert render(view) =~ "Not started"
    end
  end

  # ---------------------------------------------------------------
  # Happy Path Scenarios
  # ---------------------------------------------------------------

  describe "Returning learner sees accurate progress" do
    @tag :skip
    test "progress badges reflect learned kanji per group", %{conn: conn} do
      # Given Yuki Tanaka is signed in
      {conn, user} = create_authenticated_learner(conn, "yuki-progress")
      enable_learning_path_flag()

      # And Yuki has learned 3 kanji in the Numbers group
      {_numbers_group, numbers_kanji} = create_numbers_group()
      Enum.take(numbers_kanji, 3) |> Enum.each(&mark_kanji_learned(user, &1))

      # And Yuki has learned 0 kanji in the Nature group
      {_nature_group, _nature_kanji} = create_nature_group()

      # When Yuki navigates to the Learn page
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the Numbers card shows "3/4 learned"
      assert html =~ "3/4"

      # And the Nature card shows "Not started"
      assert html =~ "Not started"

      # And the overall progress shows learned count
      assert html =~ "3"
    end
  end

  describe "Groups are ordered by curriculum sequence" do
    @tag :skip
    test "thematic groups appear in order_index sequence", %{conn: conn} do
      # Given Yuki is signed in
      {conn, _user} = create_authenticated_learner(conn, "yuki-order")
      enable_learning_path_flag()

      # And groups exist with different order indices
      create_thematic_group(%{name: "Nature", order_index: 3})
      create_thematic_group(%{name: "Numbers", order_index: 1})
      create_thematic_group(%{name: "Directions", order_index: 2})

      # When Yuki navigates to /learn
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then groups are ordered: Numbers, Directions, Nature
      numbers_pos = :binary.match(html, "Numbers") |> elem(0)
      directions_pos = :binary.match(html, "Directions") |> elem(0)
      nature_pos = :binary.match(html, "Nature") |> elem(0)

      assert numbers_pos < directions_pos
      assert directions_pos < nature_pos
    end
  end

  describe "Completed group shows completion indicator" do
    @tag :skip
    test "fully learned group displays completion marker", %{conn: conn} do
      # Given Yuki has learned all kanji in a group
      {conn, user} = create_authenticated_learner(conn, "yuki-complete")
      enable_learning_path_flag()

      {_nature_group, nature_kanji} = create_nature_group()
      Enum.each(nature_kanji, &mark_kanji_learned(user, &1))

      # When Yuki navigates to the Learn page
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the Nature card shows "2/2 learned" with a completion indicator
      assert html =~ "2/2"
    end
  end

  # ---------------------------------------------------------------
  # Error Path Scenarios
  # ---------------------------------------------------------------

  describe "Unauthenticated visitor cannot access learning path" do
    @tag :skip
    test "visitor is redirected to sign-in page", %{conn: conn} do
      # Given the grade1_learning_path feature flag is enabled
      enable_learning_path_flag()

      # And a visitor is not signed in
      # (conn has no user session)

      # When the visitor navigates to /learn
      assert {:error, {:redirect, %{to: redirect_path}}} = live(conn, ~p"/learn")

      # Then the visitor is redirected to the sign-in page
      assert redirect_path =~ "/sign-in"
    end
  end

  describe "Feature flag disabled hides learning path" do
    @tag :skip
    test "navigation does not show Learn link when flag is disabled", %{conn: conn} do
      # Given the grade1_learning_path feature flag is disabled
      disable_learning_path_flag()

      # And Kenji Nakamura is signed in
      {conn, _user} = create_authenticated_learner(conn, "kenji")

      # When Kenji loads any page to see the navigation
      {:ok, _view, html} = live(conn, ~p"/")

      # Then there is no "Learn" navigation item
      refute html =~ ~r/<a[^>]*>Learn<\/a>/
    end

    @tag :skip
    test "direct URL access redirects to home when flag is disabled", %{conn: conn} do
      # Given the grade1_learning_path feature flag is disabled
      disable_learning_path_flag()

      # And Kenji Nakamura is signed in
      {conn, _user} = create_authenticated_learner(conn, "kenji-direct")

      # When Kenji navigates directly to /learn
      assert {:error, {:redirect, %{to: redirect_path}}} = live(conn, ~p"/learn")

      # Then Kenji is redirected to the home page
      assert redirect_path == "/"
    end
  end

  describe "Learn page with no groups seeded" do
    @tag :skip
    test "shows helpful empty state when no thematic groups exist", %{conn: conn} do
      # Given Yuki is signed in
      {conn, _user} = create_authenticated_learner(conn, "yuki-empty")
      enable_learning_path_flag()

      # And no thematic groups are seeded

      # When Yuki navigates to /learn
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then Yuki sees an appropriate empty state message
      # (not a crash or blank page)
      assert html =~ "Learn" or html =~ "learn"
    end
  end
end
