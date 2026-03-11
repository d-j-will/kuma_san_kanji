defmodule KumaSanKanjiWeb.FeatureFlagTest do
  @moduledoc """
  Acceptance tests for US-05 (cross-cutting): Feature Flag Gate.

  Validates that all learning path routes and navigation are gated behind
  the :grade1_learning_path FunWithFlags flag. This is a cross-cutting
  concern that applies to US-01 through US-05.

  Driving port: All learning path LiveViews (mount behavior) + Navigation component
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.LearningPathHelpers

  # ---------------------------------------------------------------
  # Feature Flag Disabled: All Routes Blocked
  # ---------------------------------------------------------------

  describe "Feature flag disabled blocks all learning path routes" do
    setup %{conn: conn} do
      disable_learning_path_flag()
      {conn, user} = create_authenticated_learner(conn, "kenji-flag")
      %{conn: conn, user: user}
    end


    test "GET /learn redirects to home", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/learn")
    end


    test "GET /learn/:slug redirects to home", %{conn: conn} do
      group = create_thematic_group(%{name: "Numbers", order_index: 1})
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/learn/#{group.id}")
    end


    test "GET /learn/:slug/:position redirects to home", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/learn/some-group/1")
    end


    test "GET /learn/:slug/quiz redirects to home", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/learn/some-group/quiz")
    end
  end

  # ---------------------------------------------------------------
  # Feature Flag Enabled: All Routes Accessible
  # ---------------------------------------------------------------

  describe "Feature flag enabled allows all learning path routes" do
    setup %{conn: conn} do
      enable_learning_path_flag()
      {conn, user} = create_authenticated_learner(conn, "yuki-flag")
      {group, kanji_list} = create_numbers_group()
      mark_kanji_learned(user, Enum.at(kanji_list, 0))
      %{conn: conn, user: user, group: group, kanji_list: kanji_list}
    end


    test "GET /learn renders the Learn page", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/learn")
      assert html =~ "Numbers"
    end


    test "GET /learn/:slug renders the group detail", %{conn: conn, group: group} do
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}")
      assert html =~ "Numbers"
    end


    test "GET /learn/:slug/:position renders the teach step", %{conn: conn, group: group} do
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/1")
      assert html =~ "一"
    end


    test "GET /learn/:slug/quiz renders the group quiz", %{conn: conn, group: group} do
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/quiz")
      # Should show quiz or "learn at least one" message
      assert html =~ "一" or html =~ "quiz" or html =~ "Quiz"
    end
  end

  # ---------------------------------------------------------------
  # Navigation Visibility
  # ---------------------------------------------------------------

  describe "Learn navigation item visibility" do

    test "Learn link appears in navigation when flag is enabled", %{conn: conn} do
      enable_learning_path_flag()
      {conn, _user} = create_authenticated_learner(conn, "yuki-nav-on")

      {:ok, _view, html} = live(conn, ~p"/")

      assert html =~ "Learn"
    end


    test "Learn link is hidden in navigation when flag is disabled", %{conn: conn} do
      disable_learning_path_flag()
      {conn, _user} = create_authenticated_learner(conn, "yuki-nav-off")

      {:ok, _view, html} = live(conn, ~p"/")

      # The word "Learn" should not appear as a navigation link
      # (it might appear in other page content, so check for nav link specifically)
      refute html =~ ~r/<a[^>]*href="\/learn"[^>]*>/
    end
  end

  # ---------------------------------------------------------------
  # Flag Toggle Behavior
  # ---------------------------------------------------------------

  describe "Flag toggle takes effect immediately" do

    test "disabling flag after page load blocks subsequent navigation", %{conn: conn} do
      # Given the flag is enabled and Yuki accesses /learn
      enable_learning_path_flag()
      {conn, _user} = create_authenticated_learner(conn, "yuki-toggle")

      {:ok, _view, _html} = live(conn, ~p"/learn")

      # When the flag is disabled
      disable_learning_path_flag()

      # Then a fresh navigation to /learn is blocked
      assert {:error, {:redirect, %{to: "/"}}} = live(conn, ~p"/learn")
    end
  end
end
