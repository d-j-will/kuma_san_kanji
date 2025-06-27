defmodule KumaSanKanjiWeb.UserLiveAuthTest do
  use KumaSanKanjiWeb.ConnCase, async: false

  import KumaSanKanji.TestHelpers

  alias KumaSanKanjiWeb.UserLiveAuth

  describe "on_mount :mount_current_user" do
    setup do
      user = create_test_user("liveauth@example.com")
      %{user: user}
    end

    test "continues with socket when current_user is already assigned", %{user: user} do
      socket = %Phoenix.LiveView.Socket{}
      socket = Phoenix.Component.assign(socket, :current_user, user)

      {:cont, new_socket} = UserLiveAuth.on_mount(:mount_current_user, %{}, %{}, socket)

      assert new_socket.assigns.current_user.id == user.id
    end

    test "continues when current_user is nil" do
      socket = %Phoenix.LiveView.Socket{}

      {:cont, _new_socket} = UserLiveAuth.on_mount(:mount_current_user, %{}, %{}, socket)
    end
  end

  describe "on_mount :live_user_optional" do
    setup do
      user = create_test_user("liveauth2@example.com")
      %{user: user}
    end

    test "continues if user is assigned", %{user: user} do
      socket = %Phoenix.LiveView.Socket{}
      socket = Phoenix.Component.assign(socket, :current_user, user)

      {:cont, new_socket} = UserLiveAuth.on_mount(:live_user_optional, %{}, %{}, socket)

      assert new_socket.assigns.current_user.id == user.id
    end

    test "assigns nil if no user is assigned" do
      socket = %Phoenix.LiveView.Socket{}

      {:cont, new_socket} = UserLiveAuth.on_mount(:live_user_optional, %{}, %{}, socket)

      assert new_socket.assigns.current_user == nil
    end
  end

  describe "on_mount :live_user_required" do
    setup do
      user = create_test_user("liveauth3@example.com")
      %{user: user}
    end

    test "continues if user is authenticated", %{user: user} do
      socket = %Phoenix.LiveView.Socket{}
      socket = Phoenix.Component.assign(socket, :current_user, user)

      {:cont, new_socket} = UserLiveAuth.on_mount(:live_user_required, %{}, %{}, socket)

      assert new_socket.assigns.current_user.id == user.id
    end

    test "halts and redirects if user is not authenticated" do
      socket = %Phoenix.LiveView.Socket{}

      {:halt, result_socket} = UserLiveAuth.on_mount(:live_user_required, %{}, %{}, socket)

      assert %{redirected: {:redirect, %{to: "/sign-in"}}} = result_socket
    end
  end

  describe "on_mount :live_no_user" do
    setup do
      user = create_test_user("liveauth4@example.com")
      %{user: user}
    end

    test "halts and redirects if user is authenticated", %{user: user} do
      socket = %Phoenix.LiveView.Socket{}
      socket = Phoenix.Component.assign(socket, :current_user, user)

      {:halt, result_socket} = UserLiveAuth.on_mount(:live_no_user, %{}, %{}, socket)

      assert %{redirected: {:redirect, %{to: "/"}}} = result_socket
    end

    test "continues and assigns nil if no user is authenticated" do
      socket = %Phoenix.LiveView.Socket{}

      {:cont, new_socket} = UserLiveAuth.on_mount(:live_no_user, %{}, %{}, socket)

      assert new_socket.assigns.current_user == nil
    end
  end
end
