defmodule KumaSanKanjiWeb.Components.BottomNav do
  @moduledoc """
  Bottom tab navigation component for mobile viewports.

  Renders a 4-tab navigation bar (Learn, Explore, Quiz, Profile) using DaisyUI's
  btm-nav component. Hidden on desktop (md: and above). Active tab is determined
  by matching the current path prefix.

  Accepts:
    - current_path: string, the current URL path (e.g., "/learn" or "/learn/numbers/1")
    - current_user: User struct or nil for guest users
  """
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: KumaSanKanjiWeb.Endpoint, router: KumaSanKanjiWeb.Router

  @doc """
  Renders the bottom tab navigation bar for mobile viewports.
  """
  attr :current_path, :string, default: "/"
  attr :current_user, :any, default: nil

  def bottom_nav(assigns) do
    assigns = assign(assigns, :tabs, build_tabs(assigns.current_path, assigns.current_user))

    ~H"""
    <nav class="btm-nav md:hidden pb-[env(safe-area-inset-bottom)]" aria-label="Bottom navigation">
      <.tab_link :for={tab <- @tabs} tab={tab} />
    </nav>
    """
  end

  defp tab_link(assigns) do
    ~H"""
    <.link
      navigate={@tab.path}
      class={tab_classes(@tab.active)}
      aria-label={@tab.aria_label}
    >
      <span class={@tab.icon_class} />
      <span class="btm-nav-label text-xs">{@tab.label}</span>
    </.link>
    """
  end

  defp tab_classes(true), do: "active"
  defp tab_classes(false), do: ""

  defp build_tabs(current_path, current_user) do
    learn_tab =
      if KumaSanKanjiWeb.FeatureFlagHelper.learning_path_enabled?() do
        [
          %{
            path: ~p"/learn",
            label: "Learn",
            icon_class: "hero-academic-cap w-5 h-5",
            aria_label: "Learn",
            active: path_matches?(current_path, "/learn")
          }
        ]
      else
        []
      end

    learn_tab ++
      [
        %{
          path: ~p"/explore",
          label: "Explore",
          icon_class: "hero-magnifying-glass w-5 h-5",
          aria_label: "Explore",
          active: path_matches?(current_path, "/explore")
        },
        %{
          path: ~p"/quiz",
          label: "Quiz",
          icon_class: "hero-pencil-square w-5 h-5",
          aria_label: "Quiz",
          active: path_matches?(current_path, "/quiz")
        },
        profile_tab(current_path, current_user)
      ]
  end

  defp profile_tab(current_path, nil) do
    %{
      path: ~p"/sign-in",
      label: "Sign In",
      icon_class: "hero-user w-5 h-5",
      aria_label: "Sign in",
      active: path_matches?(current_path, "/sign-in")
    }
  end

  defp profile_tab(current_path, _current_user) do
    %{
      path: ~p"/settings",
      label: "Profile",
      icon_class: "hero-user w-5 h-5",
      aria_label: "Profile",
      active: path_matches?(current_path, "/settings")
    }
  end

  defp path_matches?(current_path, prefix) do
    String.starts_with?(current_path || "/", prefix)
  end
end
