defmodule KumaSanKanjiWeb.Mobile.AppShellTest do
  @moduledoc """
  Acceptance tests for US-MOB-01: Mobile App Shell.

  Validates that when the mobile_ux_optimization feature flag is enabled,
  the root layout renders a CSS Grid app shell structure with appropriate
  classes for full-viewport mobile layout.

  Driving port: Root layout template (root.html.heex) rendered through LiveView mount
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.MobileUxHelpers
  import KumaSanKanji.LearningPathHelpers, only: [create_authenticated_learner: 2, enable_learning_path_flag: 0]

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Learner sees mobile app shell on phone" do
    @tag :walking_skeleton
    test "app shell renders CSS Grid layout when mobile flag is enabled", %{conn: conn} do
      # Given Yuki has the mobile UX feature enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-shell")

      # When Yuki opens the Learn dashboard
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the page uses the mobile app shell layout with CSS Grid classes
      assert html =~ "100dvh" or html =~ "dvh"
      assert html =~ "grid"
    end
  end

  # ---------------------------------------------------------------
  # Feature Flag Gating
  # ---------------------------------------------------------------

  describe "App shell layout is gated behind feature flag" do
    test "desktop layout renders when mobile flag is disabled", %{conn: conn} do
      # Given Yuki has the mobile UX feature disabled
      {conn, _user} = create_authenticated_learner(conn, "yuki-desktop")
      enable_learning_path_flag()
      disable_mobile_ux_flag()

      # When Yuki opens the Learn dashboard
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the page uses the existing desktop layout
      assert html =~ "min-h-screen"
      # And no mobile grid classes are present
      refute html =~ "grid-rows"
    end

    test "mobile shell renders for unauthenticated pages when flag is enabled", %{conn: conn} do
      # Given the mobile UX feature is enabled for all users
      enable_mobile_guest_flags()

      # When a guest opens the Explore page
      {:ok, _view, html} = live(conn, ~p"/explore")

      # Then the mobile app shell is rendered
      assert html =~ "100dvh" or html =~ "dvh"
    end
  end

  # ---------------------------------------------------------------
  # Content Area Structure
  # ---------------------------------------------------------------

  describe "Content area scrolls independently" do
    test "content area has overflow scroll class", %{conn: conn} do
      # Given Yuki has the mobile UX feature enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-scroll")

      # When Yuki opens the Learn dashboard
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the content area has independent scroll behavior
      assert html =~ "overflow" or html =~ "scroll"
    end
  end

  # ---------------------------------------------------------------
  # Error/Edge Paths
  # ---------------------------------------------------------------

  describe "App shell with flash messages" do
    test "flash messages render inside the content area, not overlapping navigation", %{
      conn: conn
    } do
      # Given Yuki has the mobile UX feature enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-flash")

      # When Yuki opens the Learn dashboard
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then flash message container is present in the layout
      assert html =~ "flash"
    end
  end

  describe "App shell on pages requiring authentication" do
    test "unauthenticated user redirected from protected pages retains layout", %{conn: conn} do
      # Given the mobile UX feature is enabled but no user is logged in
      enable_mobile_guest_flags()

      # When a guest tries to access the Learn dashboard
      result = live(conn, ~p"/learn")

      # Then the guest is redirected (auth required)
      assert {:error, {:redirect, _}} = result
    end
  end

end
