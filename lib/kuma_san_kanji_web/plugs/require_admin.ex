defmodule KumaSanKanjiWeb.Plugs.RequireAdmin do
  @moduledoc """
  Plug that requires the current user to be an admin.
  Returns 403 for non-admin users and redirects unauthenticated users to sign-in.
  """
  import Plug.Conn
  import Phoenix.Controller, only: [put_flash: 3, redirect: 2]

  def init(opts), do: opts

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    cond do
      user && user.admin == true ->
        conn

      user ->
        conn
        |> put_flash(:error, "Access denied. Admin privileges required.")
        |> redirect(to: "/")
        |> halt()

      true ->
        conn
        |> put_flash(:error, "You must sign in to access this page.")
        |> redirect(to: "/sign-in")
        |> halt()
    end
  end
end
