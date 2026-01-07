defmodule KumaSanKanjiWeb.Router do
  use KumaSanKanjiWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {KumaSanKanjiWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  scope "/", KumaSanKanjiWeb do
    get "/health", HealthController, :check
  end

  scope "/", KumaSanKanjiWeb do
    pipe_through :browser

    ash_authentication_live_session :public_routes,
      on_mount: {KumaSanKanjiWeb.UserLiveAuth, :live_user_optional} do
      live "/", PageLive
      live "/explore", ExploreLive
      live "/radicals/:id", RadicalLive
      live "/credits", CreditsLive
    end

    auth_routes(AuthController, KumaSanKanji.Accounts.User, path: "/auth")
    sign_out_route(AuthController)

    # Remove these if you'd like to use your own authentication views
    sign_in_route(
      register_path: "/register",
      reset_path: "/reset",
      auth_routes_prefix: "/auth",
      on_mount: [{KumaSanKanjiWeb.UserLiveAuth, :live_no_user}],
      overrides: [
        KumaSanKanjiWeb.AuthOverrides,
        AshAuthentication.Phoenix.Overrides.Default
      ]
    )
  end

  # Protected routes that require authentication
  scope "/", KumaSanKanjiWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes,
      on_mount: {KumaSanKanjiWeb.UserLiveAuth, :live_user_required} do
      live "/quiz", QuizLive
      live "/settings", SettingsLive
      live "/admin", Admin.DashboardLive
      live "/admin/users", Admin.UserAdminLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", KumaSanKanjiWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:kuma_san_kanji, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: KumaSanKanjiWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
