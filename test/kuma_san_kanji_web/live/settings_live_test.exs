defmodule KumaSanKanjiWeb.SettingsLiveTest do
  use KumaSanKanjiWeb.ConnCase
  import Phoenix.LiveViewTest
  import KumaSanKanji.TestHelpers

  describe "Settings Page" do
    setup do
      user = create_simple_test_user("settings_user@example.com")
      %{user: user}
    end

    test "redirects to login if not authenticated", %{conn: conn} do
      {:error, {:redirect, %{to: "/sign-in"}}} = live(conn, ~p"/settings")
    end

    test "renders settings page for authenticated user", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, html} = live(conn, ~p"/settings")

      assert html =~ "Settings"
      assert html =~ "Profile"
      assert html =~ "Appearance"
      assert html =~ "Notifications"
      assert has_element?(view, "input[value='#{user.username}']")
    end

    test "can switch tabs", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/settings")

      # Default tab is profile
      assert has_element?(view, "h2", "Profile Settings")

      # Switch to Appearance
      view
      |> element("a", "Appearance")
      |> render_click()

      assert has_element?(view, "h2", "Appearance")
      assert render(view) =~ "Choose a theme"

      # Switch to Notifications
      view
      |> element("a", "Notifications")
      |> render_click()

      assert has_element?(view, "h2", "Notification Preferences")
      assert has_element?(view, "span", "Study Reminders")
    end

    test "can update profile settings", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/settings")

      new_username = "updated_kuma"

      view
      |> form("form", user_settings: %{username: new_username})
      |> render_submit()

      assert render(view) =~ "Settings updated successfully"
      assert has_element?(view, "input[value='#{new_username}']")

      # Verify persistence
      updated_user = KumaSanKanji.Accounts.User.get_by_id!(user.id, actor: user)
      assert to_string(updated_user.username) == new_username
    end

    test "can update theme", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/settings")

      # Switch to Appearance tab
      view |> element("a", "Appearance") |> render_click()

      # Click a theme button (e.g., 'dark')
      view
      |> element("button[phx-value-theme='dark']")
      |> render_click()

      # Check if event was pushed (for JS hook)
      assert_push_event(view, "theme-changed", %{theme: "dark"})

      # Verify persistence
      updated_user = KumaSanKanji.Accounts.User.get_by_id!(user.id, actor: user)
      assert updated_user.theme == "dark"
    end

    test "can update notification preferences", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/settings")

      # Switch to Notifications tab
      view |> element("a", "Notifications") |> render_click()

      # Toggle settings
      view
      |> form("form", user_settings: %{study_reminders: "false", marketing_emails: "true"})
      |> render_submit()

      assert render(view) =~ "Settings updated successfully"

      # Verify persistence
      updated_user = KumaSanKanji.Accounts.User.get_by_id!(user.id, actor: user)
      assert updated_user.study_reminders == false
      assert updated_user.marketing_emails == true
    end
  end
end
