defmodule KumaSanKanji.TestHelpers do
  @moduledoc """
  Test helper functions for creating test data and users.
  """

  import Mimic

  @doc """
  Creates a test user with the given email and username.
  Since we're using Auth0, we simulate the OAuth flow by creating
  a user with the appropriate user_info and oauth_tokens.
  For now, using simple approach to bypass AshAuthentication policy issues.
  """
  def create_test_user(email \\ "test@example.com", username \\ nil) do
    _username = username || email |> String.split("@") |> List.first() |> String.downcase()

    # For now, use the simple approach to bypass AshAuthentication policy issues
    create_simple_test_user(email)
  end

  @doc """
  Creates a simple user for testing.
  """
  def create_simple_test_user(email \\ "test@example.com") do
    username = email |> String.split("@") |> List.first() |> String.downcase()

    # Create user using the test action
    KumaSanKanji.Accounts.User
    |> Ash.Changeset.for_create(:create_for_test, %{
      email: email,
      username: username
    })
    |> Ash.create!(authorize?: false)
  end

  @doc """
  Creates a mock session token for a user for testing authentication.
  """
  def create_test_session(user) do
    # Generate a simple test token
    token = "test_token_#{user.id}_#{System.unique_integer([:positive])}"

    %{
      "user_id" => user.id,
      "token" => token
    }
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
  Uses AshAuthentication compatible session format.
  """
  def log_in_user(conn, user) do
    # Try to get token from user metadata first (if it exists)
    token =
      case user.__metadata__ do
        %{token: token} when is_binary(token) ->
          token

        _ ->
          # Fallback: generate a valid JWT using AshAuthentication
          {:ok, token, _claims} = AshAuthentication.Jwt.token_for_user(user)
          token
      end

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:user_token, token)
    |> Plug.Conn.assign(:current_user, user)
  end

  @doc """
  Sets up authentication mocks for LiveView tests.
  Call this in your test setup to mock the authentication system.
  """
  def setup_auth_mocks(user) do
    # Mock the UserLiveAuth.on_mount to always succeed with the test user
    stub(KumaSanKanjiWeb.UserLiveAuth, :on_mount, fn
      :live_user_required, _params, _session, socket ->
        {:cont, Phoenix.Component.assign(socket, :current_user, user)}

      _hook, _params, _session, socket ->
        # For other hooks, just continue with the user assigned
        {:cont, Phoenix.Component.assign(socket, :current_user, user)}
    end)

    # Mock session retrieval to return our test user
    stub(AshAuthentication.Plug.Helpers, :retrieve_from_session, fn conn, _otp_app, _opts ->
      Plug.Conn.assign(conn, :current_user, user)
    end)

    :ok
  end
end
