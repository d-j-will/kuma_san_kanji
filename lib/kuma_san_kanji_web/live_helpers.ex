defmodule KumaSanKanjiWeb.LiveHelpers do
  @moduledoc """
  Helper functions for LiveViews, including feature toggle support.
  """

  @doc """
  Checks if dev mode should be enabled for the current user/session.
  Returns true in development environment or if user has dev_mode_enabled flag.
  """
  def dev_mode_enabled?(user \\ nil) do
    # Always enable in development
    if development_env?() do
      true
    else
      # In production, check user's dev mode setting
      user && user.dev_mode_enabled == true
    end
  end

  @doc """
  Checks if the current user is an admin.
  """
  def admin?(user \\ nil) do
    user && user.admin == true
  end

  defp development_env? do
    Code.ensure_loaded?(Mix) and function_exported?(Mix, :env, 0) and Mix.env() == :dev
  end
end
