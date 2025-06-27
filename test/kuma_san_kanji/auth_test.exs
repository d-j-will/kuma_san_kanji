defmodule KumaSanKanji.AuthTest do
  use KumaSanKanji.DataCase, async: false

  import KumaSanKanji.TestHelpers

  alias KumaSanKanji.Auth

  describe "get_user/1" do
    setup do
      user = create_simple_test_user("test@example.com")
      %{user: user}
    end

    test "returns user when id exists", %{user: user} do
      assert {:ok, found_user} = get_test_user(user.id)
      assert found_user.id == user.id
    end

    test "returns error when id doesn't exist" do
      assert {:error, _} = get_test_user(Ecto.UUID.generate())
    end
  end

  describe "create_session/2" do
    setup do
      user = create_simple_test_user("test3@example.com")
      %{user: user}
    end

    test "creates a session with user id and token", %{user: user} do
      conn = %Plug.Conn{}
      session = create_test_session(conn, user)

      assert is_map(session)
      assert session["user_id"] == user.id
      assert is_binary(session["token"])
    end

    test "generates unique tokens for different users" do
      user1 = create_simple_test_user("user1@example.com")
      user2 = create_simple_test_user("user2@example.com")

      conn = %Plug.Conn{}
      session1 = create_test_session(conn, user1)
      session2 = create_test_session(conn, user2)

      assert session1["token"] != session2["token"]
    end
  end

  describe "session token verification" do
    setup do
      user = create_simple_test_user("test4@example.com")
      %{user: user}
    end

    test "verify_session_token/1 returns user_id for valid token", %{user: user} do
      session = create_test_session(%Plug.Conn{}, user)
      token = session["token"]

      assert {:ok, user_id} = Auth.verify_session_token(token)
      assert user_id == user.id
    end

    test "get_user_from_session/2 returns user for valid session", %{user: user} do
      session = create_test_session(%Plug.Conn{}, user)

      assert {:ok, session_user} = get_test_user_from_session(user.id, session["token"])
      assert session_user.id == user.id
    end

    test "get_user_from_session/2 returns error for invalid token", %{user: user} do
      assert {:error, :invalid_session} = get_test_user_from_session(user.id, "invalid_token")
    end
  end
end
