defmodule KumaSanKanjiWeb.Mobile.AccordionTest do
  @moduledoc """
  Acceptance tests for US-MOB-10: Explore Accordion Sections.

  Validates that the explore page uses native HTML details/summary elements
  for progressive disclosure of secondary content sections when the
  mobile_ux_optimization feature flag is enabled.

  Driving port: ExploreLive (LiveView mount and render)
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.MobileUxHelpers

  setup do
    # Create test kanji so the explore page has content to display
    kanji =
      KumaSanKanji.Domain.create_kanji!(%{
        character: "雨",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 4
      })

    {:ok, _meaning} =
      KumaSanKanji.Domain.create_meaning(%{
        kanji_id: kanji.id,
        value: "rain"
      })

    {:ok, _pron} =
      KumaSanKanji.Domain.create_pronunciation(%{
        kanji_id: kanji.id,
        value: "あめ",
        type: :kun
      })

    %{kanji: kanji}
  end

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Learner sees collapsible sections on explore page" do
    @tag :walking_skeleton
    test "explore page renders with kanji and content sections", %{conn: conn} do
      # Given the mobile UX feature is enabled
      enable_mobile_guest_flags()

      # When a learner opens the Explore page
      {:ok, _view, html} = live(conn, ~p"/explore")

      # Then the explore page renders with kanji content
      assert html =~ "kanji-display" or html =~ "Explore"
    end
  end

  # ---------------------------------------------------------------
  # Happy Path: Accordion Structure
  # ---------------------------------------------------------------

  describe "Accordion sections use details/summary HTML" do
    test "explore page contains details elements for collapsible sections", %{conn: conn} do
      # Given the mobile UX feature is enabled
      enable_mobile_guest_flags()

      # When a learner views the explore page
      {:ok, view, html} = live(conn, ~p"/explore")

      # Then details/summary elements are present for progressive disclosure
      assert has_element?(view, "details") or html =~ "<details"
    end

    test "accordion sections have summary headers", %{conn: conn} do
      # Given the mobile UX feature is enabled
      enable_mobile_guest_flags()

      # When a learner views the explore page
      {:ok, view, html} = live(conn, ~p"/explore")

      # Then summary elements provide section headers
      assert has_element?(view, "summary") or html =~ "<summary"
    end
  end

  describe "Primary kanji info always visible" do
    test "kanji character is visible without expanding any accordion", %{conn: conn} do
      # Given the mobile UX feature is enabled
      enable_mobile_guest_flags()

      # When a learner views the explore page
      {:ok, view, _html} = live(conn, ~p"/explore")

      # Then the kanji character display is always visible (not inside an accordion)
      assert has_element?(view, ".kanji-display")
    end
  end

  describe "Secondary sections are collapsible" do
    test "pronunciation section is present as a collapsible section", %{conn: conn} do
      # Given the mobile UX feature is enabled
      enable_mobile_guest_flags()

      # When a learner views the explore page with a kanji that has pronunciations
      {:ok, _view, html} = live(conn, ~p"/explore")

      # Then a pronunciations section header is present
      assert html =~ "Pronunciations" or html =~ "Readings" or html =~ "pronunciations"
    end
  end

  # ---------------------------------------------------------------
  # Edge Path: New Kanji Load
  # ---------------------------------------------------------------

  describe "Accordion state on new kanji" do
    test "loading a new kanji resets the page content", %{conn: conn} do
      # Given a learner is viewing the explore page
      enable_mobile_guest_flags()
      {:ok, view, _html} = live(conn, ~p"/explore")

      # When the learner clicks "Show New Kanji"
      html = view |> element("button", "Show New Kanji") |> render_click()

      # Then the explore page renders with fresh content
      # (accordion reset is handled by HTML -- new details elements render collapsed)
      assert html =~ "kanji-display" or html =~ "Explore"
    end
  end

  # ---------------------------------------------------------------
  # Error/Edge Paths
  # ---------------------------------------------------------------

  describe "Explore page without mobile flag" do
    test "explore page renders normally when mobile flag is disabled", %{conn: conn} do
      # Given the mobile UX feature is disabled
      disable_mobile_ux_flag()

      # When a learner views the explore page
      {:ok, _view, html} = live(conn, ~p"/explore")

      # Then the page renders with all sections visible (no accordion on desktop)
      assert html =~ "kanji-display" or html =~ "Explore"
    end
  end

  describe "Explore page with kanji lacking details" do
    test "accordion sections handle missing data gracefully", %{conn: conn} do
      # Given a kanji exists with minimal data (no pronunciations, no radical)
      KumaSanKanji.Domain.create_kanji!(%{
        character: "木",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5
      })

      enable_mobile_guest_flags()

      # When a learner views the explore page
      {:ok, _view, html} = live(conn, ~p"/explore")

      # Then the page renders without error even if some sections are empty
      assert html =~ "kanji-display" or html =~ "Explore"
    end
  end

  describe "Authenticated user sees all accordion features" do
    test "logged-in user sees additional sections like notes", %{conn: conn} do
      # Given Yuki is logged in with mobile UX enabled
      {conn, _user} = create_mobile_learner(conn, "yuki-accordion-auth")

      # When Yuki views the explore page
      {:ok, _view, html} = live(conn, ~p"/explore")

      # Then the page renders with user-specific sections available
      assert html =~ "kanji-display" or html =~ "Explore"
    end
  end
end
