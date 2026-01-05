defmodule KumaSanKanjiWeb.SettingsLive do
  use KumaSanKanjiWeb, :live_view
  
  @themes [
    "light", "dark", "cupcake", "bumblebee", "emerald", "corporate", "synthwave", "retro", "cyberpunk", 
    "valentine", "halloween", "garden", "forest", "aqua", "lofi", "pastel", "fantasy", "wireframe", 
    "black", "luxury", "dracula", "cmyk", "autumn", "business", "acid", "lemonade", "night", "coffee", 
    "winter", "dim", "nord", "sunset"
  ]

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    
    # Initialize form with current user data
    form = AshPhoenix.Form.for_update(user, :update_settings, as: "user_settings", actor: user) |> to_form()
    
    {:ok, 
     socket
     |> assign(:page_title, "Settings")
     |> assign(:form, form)
     |> assign(:themes, @themes)
     |> assign(:active_tab, "profile")}
  end

  def handle_event("change_tab", %{"tab" => tab}, socket) do
    {:noreply, assign(socket, :active_tab, tab)}
  end

  def handle_event("validate", %{"user_settings" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.form, params) |> to_form()
    {:noreply, assign(socket, :form, form)}
  end

  def handle_event("save", %{"user_settings" => params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:form, AshPhoenix.Form.for_update(user, :update_settings, as: "user_settings", actor: user) |> to_form())
         |> put_flash(:info, "Settings updated successfully.")
         |> push_event("theme-changed", %{theme: user.theme})}

      {:error, form} ->
        {:noreply, assign(socket, :form, to_form(form))}
    end
  end
  
  # Instant theme preview when clicking a theme button
  def handle_event("set_theme", %{"theme" => theme}, socket) do
    params = %{"theme" => theme}
    
    # Submit just the theme change
    case AshPhoenix.Form.submit(socket.assigns.form, params: params) do
      {:ok, user} ->
        {:noreply,
         socket
         |> assign(:current_user, user)
         |> assign(:form, AshPhoenix.Form.for_update(user, :update_settings, as: "user_settings", actor: user) |> to_form())
         |> push_event("theme-changed", %{theme: theme})}
         
      {:error, form} ->
        {:noreply, assign(socket, :form, to_form(form))}
    end
  end
end
