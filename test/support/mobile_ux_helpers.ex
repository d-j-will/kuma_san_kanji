defmodule KumaSanKanji.MobileUxHelpers do
  @moduledoc """
  Test helpers for the Mobile UX Optimization feature (mobile-ux-optimization).

  Provides functions to enable/disable the mobile_ux_optimization feature flag
  and create test data needed by mobile UX acceptance tests.
  """

  import ExUnit.Assertions
  import KumaSanKanji.LearningPathHelpers

  @doc """
  Enables the :mobile_ux_optimization feature flag.
  """
  def enable_mobile_ux_flag do
    FunWithFlags.enable(:mobile_ux_optimization)
  end

  @doc """
  Disables the :mobile_ux_optimization feature flag.
  """
  def disable_mobile_ux_flag do
    FunWithFlags.disable(:mobile_ux_optimization)
  end

  @doc """
  Creates an authenticated learner with mobile UX flag enabled.

  Returns {conn, user} with a logged-in user and the mobile UX flag turned on.
  Also enables the learning path flag since many mobile pages depend on it.
  """
  def create_mobile_learner(conn, email_prefix \\ "mobile-learner") do
    {conn, user} = create_authenticated_learner(conn, email_prefix)
    enable_mobile_ux_flag()
    enable_learning_path_flag()
    {conn, user}
  end

  @doc """
  Creates an unauthenticated connection with mobile UX flag enabled.

  Returns conn (no user session). Useful for testing guest-visible
  pages like Explore with mobile layout.
  """
  def enable_mobile_guest_flags do
    enable_mobile_ux_flag()
  end

  @doc """
  Asserts that the given HTML contains a bottom navigation bar
  with the expected tab structure.
  """
  def assert_bottom_nav_present(html) do
    assert html =~ "btm-nav"
    assert html =~ "Learn"
    assert html =~ "Explore"
    assert html =~ "Quiz"
    assert html =~ "Profile"
  end

  @doc """
  Asserts that the given HTML does NOT contain a bottom navigation bar.
  """
  def refute_bottom_nav_present(html) do
    refute html =~ "btm-nav"
  end

  @doc """
  Checks whether the given tab name has the active CSS class in the HTML.

  Returns true if the tab appears to be marked active.
  """
  def tab_active?(html, tab_name) do
    # DaisyUI btm-nav uses the "active" class on the active tab button
    # We look for the tab name near an "active" class marker
    html =~ ~r/active[^>]*>.*?#{tab_name}/s or
      html =~ ~r/#{tab_name}.*?active/s
  end
end
