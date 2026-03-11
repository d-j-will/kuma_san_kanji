defmodule KumaSanKanji.Accounts.DevModeTest do
  use KumaSanKanji.DataCase, async: false

  alias KumaSanKanji.Accounts

  describe "dev mode toggle functionality" do
    setup do
      # Create an admin user who can toggle dev mode
      admin_user = create_test_admin()

      # Create a regular user whose dev mode we'll toggle
      regular_user = create_test_user()

      %{admin_user: admin_user, regular_user: regular_user}
    end

    test "admin can enable dev mode for a user", %{
      admin_user: admin_user,
      regular_user: regular_user
    } do
      # Verify user starts with dev mode disabled
      refute regular_user.dev_mode_enabled

      # Admin enables dev mode
      {:ok, updated_user} =
        Accounts.toggle_user_dev_mode(
          regular_user,
          %{enabled: true},
          actor: admin_user
        )

      assert updated_user.dev_mode_enabled
      assert updated_user.id == regular_user.id
    end

    test "admin can disable dev mode for a user", %{
      admin_user: admin_user,
      regular_user: regular_user
    } do
      # First enable dev mode
      {:ok, enabled_user} =
        Accounts.toggle_user_dev_mode(
          regular_user,
          %{enabled: true},
          actor: admin_user
        )

      assert enabled_user.dev_mode_enabled

      # Then disable it
      {:ok, disabled_user} =
        Accounts.toggle_user_dev_mode(
          enabled_user,
          %{enabled: false},
          actor: admin_user
        )

      refute disabled_user.dev_mode_enabled
      assert disabled_user.id == regular_user.id
    end

    test "non-admin cannot toggle dev mode for another user", %{regular_user: regular_user} do
      # Create another regular user to try to modify the first
      another_user = create_test_user("another@example.com")

      # Regular user should not be able to toggle dev mode for another user
      assert {:error, %Ash.Error.Forbidden{}} =
               Accounts.toggle_user_dev_mode(
                 regular_user,
                 %{enabled: true},
                 actor: another_user
               )
    end

    test "user cannot toggle their own dev mode", %{regular_user: regular_user} do
      # User should not be able to toggle their own dev mode
      assert {:error, %Ash.Error.Forbidden{}} =
               Accounts.toggle_user_dev_mode(
                 regular_user,
                 %{enabled: true},
                 actor: regular_user
               )
    end

    test "toggle_user_dev_mode requires enabled argument", %{
      admin_user: admin_user,
      regular_user: regular_user
    } do
      # Should fail without the enabled argument
      assert {:error, %Ash.Error.Invalid{}} =
               Accounts.toggle_user_dev_mode(
                 regular_user,
                 %{},
                 actor: admin_user
               )
    end

    test "toggle_user_dev_mode validates enabled argument type", %{
      admin_user: admin_user,
      regular_user: regular_user
    } do
      # Should fail with invalid enabled argument type
      assert {:error, %Ash.Error.Invalid{}} =
               Accounts.toggle_user_dev_mode(
                 regular_user,
                 %{enabled: "not_a_boolean"},
                 actor: admin_user
               )
    end

    test "toggle_user_dev_mode with nil enabled argument", %{
      admin_user: admin_user,
      regular_user: regular_user
    } do
      # Should fail with nil enabled argument
      assert {:error, %Ash.Error.Invalid{}} =
               Accounts.toggle_user_dev_mode(
                 regular_user,
                 %{enabled: nil},
                 actor: admin_user
               )
    end

    test "can toggle dev mode multiple times", %{
      admin_user: admin_user,
      regular_user: regular_user
    } do
      # Enable dev mode
      {:ok, user1} =
        Accounts.toggle_user_dev_mode(
          regular_user,
          %{enabled: true},
          actor: admin_user
        )

      assert user1.dev_mode_enabled

      # Disable dev mode
      {:ok, user2} =
        Accounts.toggle_user_dev_mode(
          user1,
          %{enabled: false},
          actor: admin_user
        )

      refute user2.dev_mode_enabled

      # Enable again
      {:ok, user3} =
        Accounts.toggle_user_dev_mode(
          user2,
          %{enabled: true},
          actor: admin_user
        )

      assert user3.dev_mode_enabled

      # All should be the same user
      assert user1.id == user2.id
      assert user2.id == user3.id
    end

    test "can use bang version successfully", %{
      admin_user: admin_user,
      regular_user: regular_user
    } do
      # Bang version should work for valid operations
      updated_user =
        Accounts.toggle_user_dev_mode!(
          regular_user,
          %{enabled: true},
          actor: admin_user
        )

      assert updated_user.dev_mode_enabled
    end

    test "bang version raises on authorization failure", %{regular_user: regular_user} do
      another_user = create_test_user("another@example.com")

      # Bang version should raise on authorization failure
      assert_raise Ash.Error.Forbidden, fn ->
        Accounts.toggle_user_dev_mode!(
          regular_user,
          %{enabled: true},
          actor: another_user
        )
      end
    end

    test "bang version raises on validation failure", %{
      admin_user: admin_user,
      regular_user: regular_user
    } do
      # Bang version should raise on validation failure
      assert_raise Ash.Error.Invalid, fn ->
        Accounts.toggle_user_dev_mode!(
          regular_user,
          %{enabled: "invalid"},
          actor: admin_user
        )
      end
    end
  end

  describe "can_toggle_user_dev_mode? authorization checks" do
    setup do
      admin_user = create_test_admin()
      regular_user = create_test_user()

      %{admin_user: admin_user, regular_user: regular_user}
    end

    test "admin can toggle user dev mode", %{admin_user: admin_user, regular_user: regular_user} do
      # Admin should be authorized to toggle dev mode
      assert Accounts.can_toggle_user_dev_mode?(admin_user, regular_user, %{enabled: true})
    end

    test "regular user cannot toggle another user's dev mode", %{regular_user: regular_user} do
      another_user = create_test_user("another@example.com")

      # Regular user should not be authorized to toggle another user's dev mode
      refute Accounts.can_toggle_user_dev_mode?(another_user, regular_user, %{enabled: true})
    end

    test "regular user cannot toggle their own dev mode", %{regular_user: regular_user} do
      # User should not be authorized to toggle their own dev mode
      refute Accounts.can_toggle_user_dev_mode?(regular_user, regular_user, %{enabled: true})
    end
  end

  # Helper functions
  defp create_test_admin() do
    KumaSanKanji.Accounts.User
    |> Ash.Changeset.for_create(:create_for_test, %{
      email: "admin#{System.unique_integer()}@example.com",
      username: "admin#{System.unique_integer()}",
      admin: true,
      dev_mode_enabled: false
    })
    |> Ash.create!(authorize?: false)
  end

  defp create_test_user(email \\ nil) do
    unique_id = System.unique_integer()
    email = email || "user#{unique_id}@example.com"
    username = email |> String.split("@") |> List.first()

    KumaSanKanji.Accounts.User
    |> Ash.Changeset.for_create(:create_for_test, %{
      email: email,
      username: username,
      admin: false,
      dev_mode_enabled: false
    })
    |> Ash.create!(authorize?: false)
  end
end
