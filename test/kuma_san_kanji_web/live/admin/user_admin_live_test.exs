defmodule KumaSanKanjiWeb.Admin.UserAdminLiveTest do
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.TestHelpers

  describe "dev mode toggle functionality" do
    setup do
      # Create an admin user who can toggle dev mode
      admin_user = create_admin_user("admin@example.com")

      # Create a regular user whose dev mode we'll toggle
      regular_user = create_regular_user("user@example.com")

      # Set up authentication mocks for LiveView tests
      setup_auth_mocks(admin_user)

      # Create authenticated connection
      conn = log_in_user(build_conn(), admin_user)

      %{admin_user: admin_user, regular_user: regular_user, conn: conn}
    end

    test "admin can access user admin page", %{conn: conn, admin_user: admin_user} do
      {:ok, view, html} = live(conn, ~p"/admin/users")

      # Should display the admin page
      assert html =~ "User Administration"
      assert html =~ "Manage user dev mode settings"

      # Should show the admin user in the table (convert CiString to string)
      assert has_element?(view, "td", to_string(admin_user.email))
    end

    test "dev mode toggle event works with valid data", %{conn: conn, admin_user: _admin_user, regular_user: regular_user} do
      # Verify user starts with dev mode disabled
      refute regular_user.dev_mode_enabled

      {:ok, view, _html} = live(conn, ~p"/admin/users")

      # Simulate the toggle dev mode event
      result = render_hook(view, "toggle_dev_mode", %{
        "user_id" => regular_user.id,
        "enabled" => "true"
      })

      # The hook should process without error
      assert result
    end

    test "dev mode toggle event can be triggered", %{conn: conn, regular_user: regular_user} do
      # Verify user starts with dev mode disabled
      refute regular_user.dev_mode_enabled

      {:ok, view, _html} = live(conn, ~p"/admin/users")

      # Click the toggle button
      view
      |> element("button[phx-click='toggle_dev_mode'][phx-value-user_id='#{regular_user.id}']")
      |> render_click()

      # Check that the database was updated
      {:ok, updated_user} = KumaSanKanji.Accounts.get_user_by_id(regular_user.id, authorize?: false)
      assert updated_user.dev_mode_enabled, "Dev mode should be enabled in the database"

      # The button should now show "Enabled"
      assert has_element?(view, "button[phx-value-user_id='#{regular_user.id}']", "Enabled")
    end

    test "displays user information correctly", %{conn: conn, admin_user: admin_user, regular_user: regular_user} do
      {:ok, view, _html} = live(conn, ~p"/admin/users")

      # Should show admin user information
      assert has_element?(view, "td", to_string(admin_user.email))
      assert has_element?(view, "td", to_string(admin_user.username))

      # Should show regular user information
      assert has_element?(view, "td", to_string(regular_user.email))
      assert has_element?(view, "td", to_string(regular_user.username))
    end

    test "button state reflects actual dev mode status after toggle", %{conn: conn, regular_user: regular_user} do
      {:ok, view, _html} = live(conn, ~p"/admin/users")

      # Initially, user should have dev mode disabled
      assert has_element?(view, "button[phx-value-user_id='#{regular_user.id}']", "Disabled")

      # Click to enable dev mode
      view
      |> element("button[phx-click='toggle_dev_mode'][phx-value-user_id='#{regular_user.id}']")
      |> render_click()

      # After toggle, button should show "Enabled"
      assert has_element?(view, "button[phx-value-user_id='#{regular_user.id}']", "Enabled")

      # Verify database was actually updated
      {:ok, updated_user} = KumaSanKanji.Accounts.get_user_by_id(regular_user.id, authorize?: false)
      assert updated_user.dev_mode_enabled, "Dev mode should be enabled in the database"

      # The button should now show "Enabled"
      assert has_element?(view, "button[phx-value-user_id='#{regular_user.id}']", "Enabled")
    end

    test "button text and styling changes after dev mode toggle", %{conn: conn, regular_user: regular_user} do
      {:ok, view, _html} = live(conn, ~p"/admin/users")

      # The test user should have dev mode disabled initially
      # Since tests run in isolation, we should find this user in the table
      # Check if we can find a button with the user's email in the text content instead
      assert has_element?(view, "td", to_string(regular_user.email))

      # Button should have gray styling for disabled state
      button_selector = "button[phx-value-user_id='#{regular_user.id}']"
      assert has_element?(view, button_selector)
      
      # Check if button has the correct classes (simplified test)
      button_html = view |> element(button_selector) |> render()
      assert button_html =~ "bg-gray-100"
      assert button_html =~ "text-gray-800"

      # Click to enable dev mode
      view
      |> element("button[phx-click='toggle_dev_mode'][phx-value-user_id='#{regular_user.id}']")
      |> render_click()

      # After toggle, button should show "Enabled"
      assert has_element?(view, "button[phx-value-user_id='#{regular_user.id}']", "Enabled")

      # Button should now have green styling for enabled state
      assert has_element?(view, "button[phx-value-user_id='#{regular_user.id}'][class*='bg-green-100'][class*='text-green-800']")

      # The phx-value-enabled should now be "false" (to allow disabling)
      # Wait a bit for the state to update
      Process.sleep(100)
      assert has_element?(view, "button[phx-value-user_id='#{regular_user.id}'][phx-value-enabled='false']")

      # Click again to disable dev mode
      view
      |> element("button[phx-click='toggle_dev_mode'][phx-value-user_id='#{regular_user.id}']")
      |> render_click()

      # Wait for the second state update
      Process.sleep(100)

      # Should be back to "Disabled"
      assert has_element?(view, "button[phx-value-user_id='#{regular_user.id}']", "Disabled")

      # Button should be back to gray styling
      button_html_after = view |> element("button[phx-value-user_id='#{regular_user.id}']") |> render()
      assert button_html_after =~ "bg-gray-100"
      assert button_html_after =~ "text-gray-800"

      # The phx-value-enabled should now be "true" (to allow enabling)
      assert has_element?(view, "button[phx-value-user_id='#{regular_user.id}'][phx-value-enabled='true']")
    end
  end

  describe "accounts domain dev mode functions" do
    setup do
      admin_user = create_admin_user("admin2@example.com")
      regular_user = create_regular_user("user2@example.com")

      setup_auth_mocks(admin_user)

      %{admin_user: admin_user, regular_user: regular_user}
    end

    test "toggle_user_dev_mode enables dev mode", %{admin_user: admin_user, regular_user: regular_user} do
      # User starts with dev mode disabled
      refute regular_user.dev_mode_enabled

      # Toggle to enable dev mode
      {:ok, updated_user} = KumaSanKanji.Accounts.toggle_user_dev_mode(
        regular_user,
        %{enabled: true},
        actor: admin_user
      )

      # Verify dev mode is enabled
      assert updated_user.dev_mode_enabled
    end

    test "toggle_user_dev_mode disables dev mode", %{admin_user: admin_user} do
      # Create a user with dev mode enabled
      user = KumaSanKanji.Accounts.User
      |> Ash.Changeset.for_create(:create_for_test, %{
        email: "devuser@example.com",
        username: "devuser",
        admin: false,
        dev_mode_enabled: true
      })
      |> Ash.create!(authorize?: false)

      # User starts with dev mode enabled
      assert user.dev_mode_enabled

      # Toggle to disable dev mode
      {:ok, updated_user} = KumaSanKanji.Accounts.toggle_user_dev_mode(
        user,
        %{enabled: false},
        actor: admin_user
      )

      # Verify dev mode is disabled
      refute updated_user.dev_mode_enabled
    end

    test "non-admin cannot toggle dev mode", %{regular_user: regular_user} do
      another_user = create_regular_user("another@example.com")

      # Non-admin user should not be able to toggle dev mode
      assert_raise Ash.Error.Forbidden, fn ->
        KumaSanKanji.Accounts.toggle_user_dev_mode!(
          another_user,
          %{enabled: true},
          actor: regular_user
        )
      end
    end

    test "user cannot toggle their own dev mode", %{regular_user: regular_user} do
      # User should not be able to toggle their own dev mode
      assert_raise Ash.Error.Forbidden, fn ->
        KumaSanKanji.Accounts.toggle_user_dev_mode!(
          regular_user,
          %{enabled: true},
          actor: regular_user
        )
      end
    end

    test "toggle_user_dev_mode requires enabled argument", %{admin_user: admin_user, regular_user: regular_user} do
      # Should raise error when enabled argument is missing
      assert_raise Ash.Error.Invalid, fn ->
        KumaSanKanji.Accounts.toggle_user_dev_mode!(
          regular_user,
          %{},
          actor: admin_user
        )
      end
    end

    test "toggle_user_dev_mode validates enabled argument type", %{admin_user: admin_user, regular_user: regular_user} do
      # Should raise error when enabled argument is not a boolean
      assert_raise Ash.Error.Invalid, fn ->
        KumaSanKanji.Accounts.toggle_user_dev_mode!(
          regular_user,
          %{enabled: "invalid"},
          actor: admin_user
        )
      end
    end
  end

  defp create_admin_user(email) do
    KumaSanKanji.Accounts.User
    |> Ash.Changeset.for_create(:create_for_test, %{
      email: email,
      username: email |> String.split("@") |> List.first(),
      admin: true,
      dev_mode_enabled: false
    })
    |> Ash.create!(authorize?: false)
  end

  defp create_regular_user(email) do
    KumaSanKanji.Accounts.User
    |> Ash.Changeset.for_create(:create_for_test, %{
      email: email,
      username: email |> String.split("@") |> List.first(),
      admin: false,
      dev_mode_enabled: false
    })
    |> Ash.create!(authorize?: false)
  end
end
