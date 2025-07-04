defmodule KumaSanKanjiWeb.UserLiveAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """

  import Phoenix.Component
  use KumaSanKanjiWeb, :verified_routes
  import KumaSanKanjiWeb.LiveHelpers

  def on_mount(:mount_current_user, _params, _session, socket) do
    # The ash_authentication_live_session already sets current_user
    # This hook just ensures the socket continues with the user already set
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

  def on_mount(:live_admin_required, _params, _session, socket) do
    user = socket.assigns[:current_user]

    if user && admin?(user) do
      {:cont, socket}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, "Access denied. Admin privileges required.")
       |> Phoenix.LiveView.redirect(to: ~p"/")}
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
