defmodule KumaSanKanjiWeb.AshAuthenticationTest do
  use KumaSanKanjiWeb.ConnCase, async: false

  import KumaSanKanji.TestHelpers

  alias KumaSanKanji.Auth

  setup %{conn: conn} do
    conn =
      conn
      |> Map.replace!(:secret_key_base, KumaSanKanjiWeb.Endpoint.config(:secret_key_base))
      |> init_test_session(%{})

    user = create_test_user("auth_test@example.com")

    %{conn: conn, user: user}
  end

  describe "session management" do
    test "creates valid session data for user", %{conn: conn, user: user} do
      session_data = create_test_session(conn, user)

      assert is_map(session_data)
      assert session_data["user_id"] == user.id
      assert is_binary(session_data["token"])
    end

    test "verifies valid session tokens", %{conn: conn, user: user} do
      session_data = create_test_session(conn, user)
      token = session_data["token"]

      assert {:ok, user_id} = Auth.verify_session_token(token)
      assert user_id == user.id
    end

    test "rejects invalid session tokens" do
      assert {:error, :invalid} = Auth.verify_session_token("invalid_token")
    end

    test "extracts user from valid session", %{conn: conn, user: user} do
      session_data = create_test_session(conn, user)

      assert {:ok, session_user} = get_test_user_from_session(user.id, session_data["token"])
      assert session_user.id == user.id
    end

    test "rejects invalid session data", %{user: user} do
      assert {:error, :invalid_session} = get_test_user_from_session(user.id, "invalid_token")
      assert {:error, :invalid_session} = get_test_user_from_session("invalid_id", "invalid_token")
    end
  end

  describe "auth helpers" do
    test "gets user by id", %{user: user} do
      assert {:ok, found_user} = get_test_user(user.id)
      assert found_user.id == user.id
      assert to_string(found_user.email) == to_string(user.email)
    end

    test "returns error for non-existent user" do
      assert {:error, :not_found} = get_test_user(Ecto.UUID.generate())
    end
  end
end
