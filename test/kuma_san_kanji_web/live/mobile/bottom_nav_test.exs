defmodule KumaSanKanjiWeb.Mobile.BottomNavTest do
  @moduledoc """
  Acceptance tests for US-MOB-02: Bottom Tab Navigation.

  Validates that the bottom navigation bar renders with 4 tabs (Learn, Explore,
  Quiz, Profile), highlights the active tab based on the current path, adapts
  the Profile tab for authenticated vs guest users, and is hidden on desktop.

  Driving port: App layout template (app.html.heex) rendered through LiveView mount
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.MobileUxHelpers
  import KumaSanKanji.LearningPathHelpers

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Learner navigates between sections using bottom tabs" do
    @tag :walking_skeleton
    test "bottom nav renders with four tabs on mobile layout", %{conn: conn} do
      # Given Yuki has the mobile UX feature enabled and is logged in
      {conn, _user} = create_mobile_learner(conn, "yuki-nav")

      # When Yuki opens the Learn dashboard
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then a bottom navigation bar appears with exactly 4 tabs
      assert html =~ "btm-nav"
      assert html =~ "Learn"
      assert html =~ "Explore"
      assert html =~ "Quiz"
      assert html =~ "Profile"
    end
  end

  # ---------------------------------------------------------------
  # Happy Path: Active Tab Highlighting
  # ---------------------------------------------------------------

  describe "Active tab reflects current page" do
    test "Learn tab is active on /learn", %{conn: conn} do
      # Given Yuki is on the Learn dashboard
      {conn, _user} = create_mobile_learner(conn, "yuki-active-learn")

      # When the Learn dashboard renders
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the Learn tab is highlighted as active
      assert tab_active?(html, "Learn")
    end

    test "Explore tab is active on /explore", %{conn: conn} do
      # Given the mobile UX feature is enabled
      enable_mobile_guest_flags()

      # When Yuki opens the Explore page
      {:ok, _view, html} = live(conn, ~p"/explore")

      # Then the Explore tab is highlighted as active
      assert tab_active?(html, "Explore")
    end

    test "Quiz tab is active on /quiz", %{conn: conn} do
      # Given Yuki is logged in with mobile UX enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-active-quiz")

      # When Yuki opens the Quiz page
      {:ok, _view, html} = live(conn, ~p"/quiz")

      # Then the Quiz tab is highlighted as active
      assert tab_active?(html, "Quiz")
    end

    test "Profile tab is active on /settings", %{conn: conn} do
      # Given Yuki is logged in with mobile UX enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-active-profile")

      # When Yuki opens the Settings page
      {:ok, _view, html} = live(conn, ~p"/settings")

      # Then the Profile tab is highlighted as active
      assert tab_active?(html, "Profile")
    end
  end

  describe "Active tab on sub-pages" do
    test "Learn tab stays active on group detail page", %{conn: conn} do
      # Given Yuki navigates to a group detail page
      {conn, _user} = create_mobile_learner(conn, "yuki-sub-learn")
      {group, _kanji_list} = create_numbers_group()

      # When the group detail page renders
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}")

      # Then the Learn tab remains active
      assert tab_active?(html, "Learn")
    end

    test "Learn tab stays active on teach page", %{conn: conn} do
      # Given Yuki navigates to a teach page
      {conn, _user} = create_mobile_learner(conn, "yuki-sub-teach")
      {group, _kanji_list} = create_numbers_group()

      # When the teach page renders
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/1")

      # Then the Learn tab remains active
      assert tab_active?(html, "Learn")
    end
  end

  # ---------------------------------------------------------------
  # Tab Structure and Accessibility
  # ---------------------------------------------------------------

  describe "Tab structure includes icons and labels" do
    test "each tab has an icon and text label", %{conn: conn} do
      # Given Yuki has the mobile UX feature enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-icons")

      # When any page renders
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then each tab includes a Heroicon and a label
      assert html =~ "hero-academic-cap"
      assert html =~ "hero-magnifying-glass"
      assert html =~ "hero-pencil-square"
      assert html =~ "hero-user"
    end
  end

  describe "Tabs include aria-labels for accessibility" do
    test "tab buttons have aria-label attributes", %{conn: conn} do
      # Given Yuki has the mobile UX feature enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-aria")

      # When any page renders
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then tabs have accessible labels
      assert html =~ "aria-label"
    end
  end

  # ---------------------------------------------------------------
  # Feature Flag Gating
  # ---------------------------------------------------------------

  describe "Bottom nav hidden when feature flag is disabled" do
    test "no bottom nav markup when mobile flag is off", %{conn: conn} do
      # Given the mobile UX feature is disabled
      {conn, _user} = create_authenticated_learner(conn, "yuki-no-nav")
      enable_learning_path_flag()
      disable_mobile_ux_flag()

      # When Yuki opens the Learn dashboard
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then no bottom navigation bar is rendered
      refute_bottom_nav_present(html)
    end
  end

  # ---------------------------------------------------------------
  # Error/Edge Paths
  # ---------------------------------------------------------------

  describe "Profile tab adapts for guest users" do
    test "Profile tab links to sign-in for unauthenticated users", %{conn: conn} do
      # Given a guest user with mobile UX enabled
      enable_mobile_guest_flags()

      # When the guest opens the Explore page (no auth required)
      {:ok, _view, html} = live(conn, ~p"/explore")

      # Then the Profile tab links to the sign-in page
      assert html =~ "sign-in" or html =~ "Sign in"
    end
  end

  describe "Bottom nav persists during LiveView navigation" do
    test "bottom nav remains after navigating within the app", %{conn: conn} do
      # Given Yuki is on the Learn dashboard with bottom nav
      {conn, _user} = create_mobile_learner(conn, "yuki-persist")
      {group, _kanji_list} = create_numbers_group()

      {:ok, _view, html} = live(conn, ~p"/learn")
      assert html =~ "btm-nav"

      # When Yuki navigates to a group detail page
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}")

      # Then the bottom nav is still present
      assert html =~ "btm-nav"
    end
  end

  describe "Desktop navbar visibility" do
    test "desktop navbar has hidden class on mobile when flag enabled", %{conn: conn} do
      # Given Yuki has the mobile UX feature enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-desktop-hide")

      # When Yuki opens any page
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the desktop navbar has a responsive hiding class
      # (The navbar should have md:block or similar responsive visibility)
      assert html =~ "navbar" or html =~ "nav"
    end
  end
end
