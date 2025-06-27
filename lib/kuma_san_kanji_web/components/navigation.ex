defmodule KumaSanKanjiWeb.Components.Navigation do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: KumaSanKanjiWeb.Endpoint, router: KumaSanKanjiWeb.Router
  alias Phoenix.LiveView.JS
  import KumaSanKanjiWeb.LiveHelpers

  def navbar(assigns) do
    ~H"""
    <header
      class="bg-wabi-paper shadow-lg border-b-2 border-wabi-border nav-wabi"
      id="main-nav"
      phx-hook="MobileMenu"
    >
      <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex h-16 items-center justify-between">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <.link navigate={~p"/"} class="text-2xl font-wabi-display text-wabi-hok_blue">
                Kuma-san Kanji <span class="text-wabi-rust jp-title-wabi">漢字</span>
              </.link>
            </div>

            <div class="hidden md:ml-6 md:flex md:space-x-8">
              <.link
                navigate={~p"/"}
                class="nav-item-wabi inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-wabi font-medium text-wabi-charcoal hover:border-wabi-rust hover:text-wabi-rust"
              >
                Home
              </.link>

              <.link
                navigate={~p"/explore"}
                class="nav-item-wabi inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-wabi font-medium text-wabi-charcoal hover:border-wabi-rust hover:text-wabi-rust"
              >
                Explore
              </.link>

              <%= if @current_user do %>
                <.link
                  navigate={~p"/quiz"}
                  class="nav-item-wabi inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-wabi font-medium text-wabi-charcoal hover:border-wabi-rust hover:text-wabi-rust"
                >
                  Quiz
                </.link>
                
                <%= if admin?(@current_user) do %>
                  <.link
                    navigate={~p"/admin/users"}
                    class="nav-item-wabi inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-wabi font-medium text-wabi-charcoal hover:border-wabi-rust hover:text-wabi-rust"
                  >
                    Admin
                  </.link>
                <% end %>
              <% end %>
            </div>
          </div>

          <div class="hidden md:ml-6 md:flex md:items-center">
            <div class="flex items-center space-x-4">
              <%= if @current_user do %>
                <div class="text-sm font-wabi text-wabi-charcoal/70">
                  Hello,
                  <span class="font-bold text-wabi-hok_blue">
                    {@current_user.username || @current_user.email || "User"}
                  </span>
                </div>

                <.link
                  href={~p"/sign-out"}
                  class="btn-wabi rounded-md bg-wabi-stone px-3 py-2 text-sm font-wabi font-semibold text-wabi-charcoal border border-wabi-border hover:bg-wabi-stone/80"
                >
                  Sign Out
                </.link>
              <% else %>
                <.link
                  navigate={~p"/sign-in"}
                  class="btn-wabi-accent rounded-md bg-wabi-hok_blue px-3 py-2 text-sm font-wabi font-semibold text-wabi-cream hover:bg-wabi-hok_blue_dark"
                >
                  Sign In
                </.link>
              <% end %>
            </div>
          </div>

          <div class="-mr-2 flex items-center md:hidden">
            <!-- Mobile menu button -->
            <button
              phx-click={JS.dispatch("toggle-mobile-menu")}
              type="button"
              class="relative inline-flex items-center justify-center rounded-md bg-wabi-paper p-2 text-wabi-charcoal/60 hover:bg-wabi-cream hover:text-wabi-charcoal focus:outline-none focus:ring-2 focus:ring-wabi-hok_blue focus:ring-offset-2"
              aria-expanded="false"
            >
              <span class="absolute -inset-0.5"></span> <span class="sr-only">Open main menu</span>
              <svg
                class="block h-6 w-6"
                fill="none"
                viewBox="0 0 24 24"
                stroke-width="1.5"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  d="M3.75 6.75h16.5M3.75 12h16.5m-16.5 5.25h16.5"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>
      <!-- Mobile menu, show/hide based on menu state. -->
      <div class="md:hidden hidden" id="mobile-menu">
        <div class="space-y-1 pb-3 pt-2 bg-wabi-cream/50">
          <.link
            navigate={~p"/"}
            class="block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-wabi font-medium text-wabi-charcoal hover:border-wabi-rust hover:bg-wabi-cream hover:text-wabi-rust"
          >
            Home
          </.link>

          <.link
            navigate={~p"/explore"}
            class="block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-wabi font-medium text-wabi-charcoal hover:border-wabi-rust hover:bg-wabi-cream hover:text-wabi-rust"
          >
            Explore
          </.link>

          <%= if @current_user do %>
            <.link
              navigate={~p"/quiz"}
              class="block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-wabi font-medium text-wabi-charcoal hover:border-wabi-rust hover:bg-wabi-cream hover:text-wabi-rust"
            >
              Quiz
            </.link>
          <% end %>
        </div>

        <div class="border-t border-wabi-border_light pb-3 pt-4 bg-wabi-cream/30">
          <%= if @current_user do %>
            <div class="flex items-center px-4">
              <div class="ml-3">
                <div class="text-base font-medium text-wabi-charcoal">
                  {@current_user.username || @current_user.email || "User"}
                </div>

                <div class="text-sm font-medium text-wabi-charcoal/60">
                  {@current_user.email || ""}
                </div>
              </div>
            </div>

            <div class="mt-3 space-y-1">
              <.link
                href={~p"/sign-out"}
                class="block px-4 py-2 text-base font-medium text-wabi-charcoal/70 hover:bg-wabi-cream hover:text-wabi-charcoal"
              >
                Sign Out
              </.link>
            </div>
          <% else %>
            <div class="mt-3 space-y-1 px-2">
              <.link
                navigate={~p"/sign-in"}
                class="block rounded-md px-3 py-2 text-base font-medium text-wabi-charcoal/70 hover:bg-wabi-cream hover:text-wabi-charcoal"
              >
                Sign In
              </.link>
            </div>
          <% end %>
        </div>
      </div>
    </header>
    """
  end
end
