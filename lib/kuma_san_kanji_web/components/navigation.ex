defmodule KumaSanKanjiWeb.Components.Navigation do
  use Phoenix.Component
  use Phoenix.VerifiedRoutes, endpoint: KumaSanKanjiWeb.Endpoint, router: KumaSanKanjiWeb.Router
  alias Phoenix.LiveView.JS

  def navbar(assigns) do
    ~H"""
    <header class="nav-wabi" id="main-nav" phx-hook="MobileMenu">
      <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8">
        <div class="flex h-16 items-center justify-between">
          <div class="flex items-center">
            <div class="flex-shrink-0">
              <.link navigate={~p"/"} class="text-2xl jp-title-wabi">
                Kuma-san Kanji <span class="text-wabi-hok_blue">漢字</span>
              </.link>
            </div>
            
            <div class="hidden md:ml-6 md:flex md:space-x-8">
              <.link
                navigate={~p"/"}
                class="nav-item-wabi inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-base font-medium hover:border-wabi-hok_blue/50"
              >
                Home
              </.link>
              
              <.link
                navigate={~p"/explore"}
                class="nav-item-wabi inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-base font-medium hover:border-wabi-hok_blue/50"
              >
                Explore
              </.link>
              
              <%= if @current_user do %>
                <.link
                  navigate={~p"/quiz"}
                  class="nav-item-wabi inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-base font-medium hover:border-wabi-hok_blue/50"
                >
                  Quiz
                </.link>
              <% end %>
            </div>
          </div>
          
          <div class="hidden md:ml-6 md:flex md:items-center">
            <div class="flex items-center space-x-4">
              <%= if @current_user do %>
                <div class="text-base wabi-accent-text">
                  Hello, <span class="font-bold text-wabi-charcoal">{@current_user.username}</span>
                </div>
                
                <.link
                  href={~p"/logout"}
                  method="delete"
                  class="btn-wabi text-base"
                >
                  Log out
                </.link>
              <% else %>
                <.link
                  navigate={~p"/signup"}
                  class="btn-wabi-accent text-base"
                >
                  Sign up
                </.link>
                
                <.link
                  navigate={~p"/login"}
                  class="btn-wabi text-base"
                >
                  Log in
                </.link>
              <% end %>
            </div>
          </div>
          
          <div class="-mr-2 flex items-center md:hidden">
            <!-- Mobile menu button -->
            <button
              phx-click={JS.dispatch("toggle-mobile-menu")}
              type="button"
              class="btn-wabi p-2"
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
        <div class="space-y-1 pb-3 pt-2 bg-wabi-paper">
          <.link
            navigate={~p"/"}
            class="nav-item-wabi block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-medium hover:border-wabi-hok_blue hover:bg-wabi-cream-dark"
          >
            Home
          </.link>
          
          <.link
            navigate={~p"/explore"}
            class="nav-item-wabi block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-medium hover:border-wabi-hok_blue hover:bg-wabi-cream-dark"
          >
            Explore
          </.link>
          
          <%= if @current_user do %>
            <.link
              navigate={~p"/quiz"}
              class="nav-item-wabi block border-l-4 border-transparent py-2 pl-3 pr-4 text-base font-medium hover:border-wabi-hok_blue hover:bg-wabi-cream-dark"
            >
              Quiz
            </.link>
          <% end %>
        </div>
        
        <div class="border-t border-wabi-stone pb-3 pt-4 bg-wabi-paper">
          <%= if @current_user do %>
            <div class="flex items-center px-4">
              <div class="ml-3">
                <div class="text-base font-medium wabi-text">{@current_user.username}</div>
                
                <div class="text-base font-medium wabi-accent-text">{@current_user.email}</div>
              </div>
            </div>
            
            <div class="mt-3 space-y-1">
              <.link
                href={~p"/logout"}
                method="delete"
                class="block px-4 py-2 text-base font-medium wabi-accent-text hover:bg-wabi-cream-dark"
              >
                Log out
              </.link>
            </div>
          <% else %>
            <div class="mt-3 space-y-1 px-2">
              <.link
                navigate={~p"/signup"}
                class="btn-wabi-accent block text-center text-base mb-2"
              >
                Sign up
              </.link>
              
              <.link
                navigate={~p"/login"}
                class="btn-wabi block text-center text-base"
              >
                Log in
              </.link>
            </div>
          <% end %>
        </div>
      </div>
    </header>
    """
  end
end
