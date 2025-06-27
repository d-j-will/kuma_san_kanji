defmodule KumaSanKanjiWeb.Admin.UserAdminLive do
  use KumaSanKanjiWeb, :live_view
  
  import KumaSanKanjiWeb.LiveHelpers

  @impl true
  def mount(_params, _session, socket) do
    current_user = socket.assigns[:current_user]
    
    if admin?(current_user) do
      users = KumaSanKanji.Accounts.list_users!(load: [:dev_mode_enabled, :admin])
      {:ok, assign(socket, users: users)}
    else
      {:ok, 
       socket 
       |> put_flash(:error, "Access denied. Admin privileges required.")
       |> redirect(to: ~p"/")}
    end
  end

  @impl true
  def handle_event("toggle_dev_mode", %{"user_id" => user_id, "enabled" => enabled}, socket) do
    enabled = enabled == "true"
    current_user = socket.assigns.current_user
    
    case KumaSanKanji.Accounts.toggle_user_dev_mode(user_id, enabled, actor: current_user) do
      {:ok, _user} ->
        users = KumaSanKanji.Accounts.list_users!(load: [:dev_mode_enabled, :admin])
        {:noreply, 
         socket
         |> assign(users: users)
         |> put_flash(:info, "Dev mode #{if enabled, do: "enabled", else: "disabled"} for user")}
      
      {:error, _error} ->
        {:noreply, put_flash(socket, :error, "Failed to update user dev mode")}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-6xl mx-auto px-4 py-8">
      <div class="bg-white shadow-lg rounded-lg">
        <div class="px-6 py-4 border-b border-gray-200">
          <h1 class="text-2xl font-bold text-gray-900">User Administration</h1>
          <p class="mt-2 text-sm text-gray-600">Manage user dev mode settings and permissions</p>
        </div>
        
        <div class="p-6">
          <div class="overflow-x-auto">
            <table class="min-w-full divide-y divide-gray-200">
              <thead class="bg-gray-50">
                <tr>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Email
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Username
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Admin
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Dev Mode
                  </th>
                  <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
                    Created
                  </th>
                </tr>
              </thead>
              <tbody class="bg-white divide-y divide-gray-200">
                <tr :for={user <- @users} class="hover:bg-gray-50">
                  <td class="px-6 py-4 whitespace-nowrap text-sm font-medium text-gray-900">
                    <%= user.email %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= user.username %>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <span class={[
                      "inline-flex px-2 py-1 text-xs font-semibold rounded-full",
                      if(user.admin, 
                        do: "bg-purple-100 text-purple-800", 
                        else: "bg-gray-100 text-gray-800")
                    ]}>
                      <%= if user.admin, do: "Admin", else: "User" %>
                    </span>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap">
                    <button 
                      phx-click="toggle_dev_mode" 
                      phx-value-user_id={user.id} 
                      phx-value-enabled={!user.dev_mode_enabled}
                      class={[
                        "inline-flex px-3 py-1 rounded-md text-sm font-medium transition-colors",
                        if(user.dev_mode_enabled, 
                          do: "bg-green-100 text-green-800 hover:bg-green-200", 
                          else: "bg-gray-100 text-gray-800 hover:bg-gray-200")
                      ]}
                    >
                      <%= if user.dev_mode_enabled, do: "Enabled", else: "Disabled" %>
                    </button>
                  </td>
                  <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-500">
                    <%= if user.created_at do %>
                      <%= Calendar.strftime(user.created_at, "%Y-%m-%d") %>
                    <% else %>
                      -
                    <% end %>
                  </td>
                </tr>
              </tbody>
            </table>
          </div>
          
          <div class="mt-6 p-4 bg-blue-50 rounded-md">
            <div class="flex">
              <div class="flex-shrink-0">
                <svg class="h-5 w-5 text-blue-400" viewBox="0 0 20 20" fill="currentColor">
                  <path fill-rule="evenodd" d="M8.257 3.099c.765-1.36 2.722-1.36 3.486 0l5.58 9.92c.75 1.334-.213 2.98-1.742 2.98H4.42c-1.53 0-2.493-1.646-1.743-2.98l5.58-9.92zM11 13a1 1 0 11-2 0 1 1 0 012 0zm-1-8a1 1 0 00-1 1v3a1 1 0 002 0V6a1 1 0 00-1-1z" clip-rule="evenodd" />
                </svg>
              </div>
              <div class="ml-3">
                <h3 class="text-sm font-medium text-blue-800">
                  About Dev Mode
                </h3>
                <div class="mt-2 text-sm text-blue-700">
                  <p>
                    Dev mode allows users to see debug information and development features in production. 
                    It's always enabled in development environments, but can be toggled per-user in production.
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
