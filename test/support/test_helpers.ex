defmodule KumaSanKanji.TestHelpers do
  @moduledoc """
  Test helper functions for creating test data and users.
  """

  import Mimic

  @doc """
  Creates a test user with the given email and username.
  Uses the simple create action (no password needed for tests).
  """
  def create_test_user(email \\ "test@example.com", username \\ nil) do
    username = username || email |> String.split("@") |> List.first() |> String.downcase()

    KumaSanKanji.Accounts.User
    |> Ash.Changeset.for_create(:create_for_test, %{
      email: email,
      username: username
    })
    |> Ash.create!(authorize?: false)
  end

  @doc """
  Creates a simple user for testing.
  """
  def create_simple_test_user(email \\ "test@example.com") do
    create_test_user(email)
  end

  @doc """
  Gets a user by ID for testing, bypassing authorization.
  """
  def get_test_user(user_id) do
    require Ash.Query

    case KumaSanKanji.Accounts.User
         |> Ash.Query.filter(id == ^user_id)
         |> Ash.read_one(authorize?: false) do
      {:ok, nil} -> {:error, :not_found}
      {:ok, user} -> {:ok, user}
      {:error, _} = err -> err
    end
  end

  @doc """
  Creates a session for testing purposes using the test user lookup.
  """
  def create_test_session(_conn, user) do
    {:ok, token, _claims} = AshAuthentication.Jwt.token_for_user(user)

    %{
      "user_id" => user.id,
      "token" => token
    }
  end

  @doc """
  Gets user from session for testing, bypassing authorization.
  """
  def get_test_user_from_session(user_id, token) when is_binary(user_id) and is_binary(token) do
    with {:ok, %{"sub" => subject}, _signer} <-
           AshAuthentication.Jwt.verify(token, KumaSanKanji.Accounts.User),
         true <- String.contains?(subject, user_id),
         {:ok, user} <- get_test_user(user_id) do
      {:ok, user}
    else
      _ -> {:error, :invalid_session}
    end
  end

  def get_test_user_from_session(_user_id, _token), do: {:error, :invalid_session}

  @doc """
  Logs in a user for ConnTest by setting up proper session and assigns.
  Generates a real AshAuthentication JWT so LiveSession on_mount works.
  """
  def log_in_user(conn, user) do
    user = ensure_auth_token(user)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> AshAuthentication.Plug.Helpers.store_in_session(user)
    |> Plug.Conn.assign(:current_user, user)
  end

  defp ensure_auth_token(user) do
    case user.__metadata__ do
      %{token: token} when is_binary(token) ->
        user

      _ ->
        {:ok, token, _claims} = AshAuthentication.Jwt.token_for_user(user)
        Ash.Resource.put_metadata(user, :token, token)
    end
  end

  @doc """
  Sets up authentication mocks for LiveView tests.
  Call this in your test setup to mock the authentication system.
  """
  def setup_auth_mocks(user) do
    stub(KumaSanKanjiWeb.UserLiveAuth, :on_mount, fn
      _hook, _params, _session, socket ->
        socket = Phoenix.Component.assign(socket, :current_user, user)

        socket =
          if socket.assigns[:current_path] do
            socket
          else
            socket
            |> Phoenix.Component.assign(:current_path, "/")
            |> Phoenix.LiveView.attach_hook(:track_current_path, :handle_params, fn
              _params, uri, socket ->
                path = URI.parse(uri).path || "/"
                {:cont, Phoenix.Component.assign(socket, :current_path, path)}
            end)
          end

        {:cont, socket}
    end)

    stub(AshAuthentication.Plug.Helpers, :retrieve_from_session, fn conn, _otp_app, _opts ->
      Plug.Conn.assign(conn, :current_user, user)
    end)

    :ok
  end
end
