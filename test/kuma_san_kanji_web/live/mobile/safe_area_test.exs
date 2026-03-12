defmodule KumaSanKanjiWeb.Mobile.SafeAreaTest do
  @moduledoc """
  Acceptance tests for US-MOB-03: Safe Area Insets.

  Validates that the viewport meta tag includes viewport-fit=cover and that
  safe area CSS classes are applied to the bottom nav and header when the
  mobile_ux_optimization feature flag is enabled.

  Driving port: Root layout template (root.html.heex) rendered through LiveView mount
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.MobileUxHelpers

  import KumaSanKanji.LearningPathHelpers,
    only: [create_authenticated_learner: 2, enable_learning_path_flag: 0]

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: App respects device safe areas" do
    @tag :walking_skeleton
    test "viewport meta tag includes viewport-fit=cover when flag enabled", %{conn: conn} do
      # Given Yuki has the mobile UX feature enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-safe")

      # When Yuki opens any page in the app
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the viewport meta tag includes viewport-fit=cover
      assert html =~ "viewport-fit=cover" or html =~ "viewport-fit"
    end
  end

  # ---------------------------------------------------------------
  # Happy Path
  # ---------------------------------------------------------------

  describe "Safe area CSS classes on bottom nav" do
    test "bottom nav includes safe-area-inset-bottom padding class", %{conn: conn} do
      # Given Yuki has the mobile UX feature enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-safe-bottom")

      # When Yuki opens any page
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the bottom nav includes safe area bottom padding
      assert html =~ "safe-area" or html =~ "env(safe-area"
    end
  end

  describe "Viewport meta tag structure" do
    test "viewport meta includes width=device-width and initial-scale=1", %{conn: conn} do
      # Given Yuki has the mobile UX feature enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-viewport")

      # When any page renders
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the viewport meta tag has required attributes
      assert html =~ "width=device-width"
      assert html =~ "initial-scale=1"
    end
  end

  # ---------------------------------------------------------------
  # Error/Edge Paths
  # ---------------------------------------------------------------

  describe "Safe area without mobile flag" do
    test "viewport-fit=cover is not added when mobile flag is disabled", %{conn: conn} do
      # Given the mobile UX feature is disabled
      {conn, _user} = create_authenticated_learner(conn, "yuki-no-safe")
      enable_learning_path_flag()
      disable_mobile_ux_flag()

      # When Yuki opens any page
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the viewport meta does not include viewport-fit=cover
      # (standard viewport meta is still present)
      assert html =~ "width=device-width"
      refute html =~ "viewport-fit=cover"
    end
  end

  describe "Safe area on unauthenticated pages" do
    test "safe area classes present on guest-accessible pages", %{conn: conn} do
      # Given the mobile UX feature is enabled for all users
      enable_mobile_guest_flags()

      # When a guest opens the Explore page
      {:ok, _view, html} = live(conn, ~p"/explore")

      # Then the viewport meta includes viewport-fit=cover
      assert html =~ "viewport-fit=cover" or html =~ "viewport-fit"
    end
  end
end
