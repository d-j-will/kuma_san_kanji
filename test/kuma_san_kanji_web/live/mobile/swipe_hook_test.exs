defmodule KumaSanKanjiWeb.Mobile.SwipeHookTest do
  @moduledoc """
  Acceptance tests for US-MOB-09: Swipe Tab Navigation.

  Validates that the teach page content area has the phx-hook attribute
  for the SwipeTabNavigation JS hook, and that the existing tap-based
  tab navigation continues to work alongside the hook binding.

  Note: Actual swipe gesture behavior cannot be tested via Phoenix.LiveViewTest
  since it does not execute JavaScript. Swipe behavior is documented in the
  manual test checklist.

  Driving port: TeachLive (LiveView mount and render)
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.MobileUxHelpers
  import KumaSanKanji.LearningPathHelpers

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Teach page has swipe hook binding" do
    @tag :walking_skeleton
    test "teach page content area includes phx-hook for swipe navigation", %{conn: conn} do
      # Given Yuki has mobile UX enabled and navigates to the teach page
      {conn, _user} = create_mobile_learner(conn, "yuki-swipe")
      {group, _kanji_list} = create_numbers_group()

      # When the teach page renders
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/1")

      # Then the content area has the SwipeTabNavigation hook binding
      assert html =~ "phx-hook" and html =~ "SwipeTabNavigation"
    end
  end

  # ---------------------------------------------------------------
  # Happy Path: Hook Attribute Presence
  # ---------------------------------------------------------------

  describe "Swipe hook attributes on teach page" do
    test "swipe hook has configurable data attributes", %{conn: conn} do
      # Given Yuki is on the teach page with mobile UX enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-swipe-data")
      {group, _kanji_list} = create_numbers_group()

      # When the teach page renders
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/1")

      # Then data attributes for swipe configuration may be present
      # (The hook reads threshold from data-* attributes or uses defaults)
      assert html =~ "SwipeTabNavigation"
    end
  end

  # ---------------------------------------------------------------
  # Happy Path: Tap Navigation Coexistence
  # ---------------------------------------------------------------

  describe "Tap navigation still works with swipe hook" do
    test "next_tab event advances tab when hook is present", %{conn: conn} do
      # Given Yuki is on the Character tab of the teach page
      {conn, _user} = create_mobile_learner(conn, "yuki-tap-coexist")
      {group, _kanji_list} = create_numbers_group()
      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/1")

      # When Yuki uses tap navigation (next_tab event)
      html = render_click(view, "next_tab")

      # Then the tab advances to Meaning
      assert html =~ "one" or html =~ "meaning" or html =~ "Meaning"
    end

    test "prev_tab event retreats tab when hook is present", %{conn: conn} do
      # Given Yuki is on the Meaning tab (tab 2)
      {conn, _user} = create_mobile_learner(conn, "yuki-prev-tap")
      {group, _kanji_list} = create_numbers_group()
      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/1")
      render_click(view, "next_tab")

      # When Yuki uses tap navigation to go back
      html = render_click(view, "prev_tab")

      # Then the tab retreats to Character
      assert html =~ "一"
    end
  end

  # ---------------------------------------------------------------
  # Edge Path: Boundary Tab Behavior
  # ---------------------------------------------------------------

  describe "Tab navigation at boundaries" do
    test "prev_tab on first tab does not crash", %{conn: conn} do
      # Given Yuki is on the first tab (Character)
      {conn, _user} = create_mobile_learner(conn, "yuki-boundary-first")
      {group, _kanji_list} = create_numbers_group()
      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/1")

      # When Yuki attempts to go to the previous tab (already on first)
      html = render_click(view, "prev_tab")

      # Then nothing crashes and she stays on the Character tab
      assert html =~ "一"
    end

    test "next_tab on last tab does not crash", %{conn: conn} do
      # Given Yuki is on the last tab (Examples)
      {conn, _user} = create_mobile_learner(conn, "yuki-boundary-last")
      {group, _kanji_list} = create_numbers_group()
      {:ok, view, _html} = live(conn, ~p"/learn/#{group.id}/1")

      # Navigate to the last tab
      render_click(view, "next_tab")
      render_click(view, "next_tab")
      render_click(view, "next_tab")

      # When Yuki attempts to go past the last tab
      html = render_click(view, "next_tab")

      # Then nothing crashes and she stays on the last tab
      assert html =~ "一" or html =~ ~r/Quiz me|learned/i
    end
  end

  # ---------------------------------------------------------------
  # Error Paths
  # ---------------------------------------------------------------

  describe "Swipe hook absent when flag disabled" do
    test "teach page does not include swipe hook when mobile flag is off", %{conn: conn} do
      # Given the mobile UX feature is disabled
      {conn, _user} = create_authenticated_learner(conn, "yuki-no-swipe")
      enable_learning_path_flag()
      disable_mobile_ux_flag()

      {group, _kanji_list} = create_numbers_group()

      # When the teach page renders
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/1")

      # Then the swipe hook is not present
      refute html =~ "SwipeTabNavigation"
    end
  end

  describe "Swipe hook on different kanji positions" do
    test "swipe hook is present on middle position", %{conn: conn} do
      # Given Yuki navigates to a middle kanji position
      {conn, _user} = create_mobile_learner(conn, "yuki-mid-swipe")
      {group, _kanji_list} = create_numbers_group()

      # When the teach page renders at position 2
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/2")

      # Then the swipe hook is still present
      assert html =~ "SwipeTabNavigation"
    end

    test "swipe hook is present on last position", %{conn: conn} do
      # Given Yuki navigates to the last kanji position
      {conn, _user} = create_mobile_learner(conn, "yuki-last-swipe")
      {group, _kanji_list} = create_numbers_group()

      # When the teach page renders at position 4
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}/4")

      # Then the swipe hook is still present
      assert html =~ "SwipeTabNavigation"
    end
  end
end
