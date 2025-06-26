defmodule KumaSanKanjiWeb.UserLiveAuth do
  @moduledoc """
  Module for handling LiveView authentication.
  """

  import Phoenix.Component
  use KumaSanKanjiWeb, :verified_routes

  # This is used for nested liveviews to fetch the current user.
  # To use, place the following at the top of that liveview:
  # on_mount {KumaSanKanjiWeb.UserLiveAuth, :current_user}
  def on_mount(:current_user, _params, session, socket) do
    case AshAuthentication.Plug.Helpers.retrieve_from_session(session, KumaSanKanji.Accounts) do
      {:ok, user} -> {:cont, assign(socket, :current_user, user)}
      _ -> {:cont, assign(socket, :current_user, nil)}
    end
  end

  # This is the standard AshAuthentication hook
  def on_mount(:mount_current_user, _params, session, socket) do
    # Get current user from session using AshAuthentication
    current_user =
      case AshAuthentication.Plug.Helpers.retrieve_from_session(session, KumaSanKanji.Accounts) do
        {:ok, user} -> user
        _ -> nil
      end

    socket = assign(socket, :current_user, current_user)
    {:cont, socket}
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/sign-in")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end
end
