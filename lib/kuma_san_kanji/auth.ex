defmodule KumaSanKanji.Auth do
  @moduledoc """
  The Auth context module handles authentication related functions.
  """

  alias KumaSanKanji.Accounts.User

  @doc """
  Gets a user by ID.
  Returns `{:ok, user}` if found, otherwise `{:error, :not_found}`.
  """
  def get_user(user_id) do
    # Use code interface for cleaner access and better error handling
    case User.get_by_id(user_id) do
      {:ok, user} -> {:ok, user}
      {:error, %Ash.Error.Query.NotFound{}} -> {:error, :not_found}
      {:error, _} = err -> err
    end
  end

  @doc """
  Creates a new session for a user.
  Returns the session data to be stored in the session.
  """
  def create_session(_conn, user) do
    # Generate a JWT for the session
    {:ok, token, _claims} = AshAuthentication.Jwt.token_for_user(user)

    %{
      "user_id" => user.id,
      "token" => token
    }
  end

  @doc """
  Verifies a session token.
  Returns `{:ok, user_id}` if valid, otherwise `{:error, reason}`.
  """
  def verify_session_token(token) do
    case AshAuthentication.Jwt.verify(token, KumaSanKanji.Accounts.User) do
      {:ok, %{"sub" => subject}, _} ->
        # Extract user ID from subject (format: "user?id=UUID")
        case URI.parse(subject) do
          %URI{query: query} when is_binary(query) ->
             case URI.decode_query(query) do
               %{"id" => id} -> {:ok, id}
               _ -> {:error, :invalid}
             end
          _ -> {:error, :invalid}
        end
      _ -> {:error, :invalid}
    end
  end

  @doc """
  Extracts and validates a user from the session.
  Returns `{:ok, user}` if valid, otherwise `{:error, reason}`.
  """
  def get_user_from_session(user_id, token) when is_binary(user_id) and is_binary(token) do
    with {:ok, verified_user_id} <- verify_session_token(token),
         true <- verified_user_id == user_id,
         {:ok, user} <- get_user(user_id) do
      {:ok, user}
    else
      _error -> {:error, :invalid_session}
    end
  end

  def get_user_from_session(_user_id, _token), do: {:error, :invalid_session}
end
