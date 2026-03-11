defmodule KumaSanKanjiWeb.LearnLive do
  @moduledoc "Learning path overview - lists thematic groups for Grade 1."
  use KumaSanKanjiWeb, :live_view

  alias KumaSanKanji.Content.ContentContext
  import KumaSanKanjiWeb.FeatureFlagHelper, only: [learning_path_enabled?: 0]

  @impl true
  def mount(_params, _session, socket) do
    unless learning_path_enabled?() do
      {:ok, redirect(socket, to: "/")}
    else
      user = socket.assigns.current_user
      {:ok, groups} = ContentContext.get_all_thematic_groups()

      progress_map =
        Map.new(groups, fn group ->
          {:ok, progress} = ContentContext.get_group_progress(user.id, group.id)
          {group.id, progress}
        end)

      total_learned = progress_map |> Map.values() |> Enum.sum_by(& &1.learned)
      total_kanji = progress_map |> Map.values() |> Enum.sum_by(& &1.total)

      {:ok,
       assign(socket,
         page_title: "Learn",
         groups: groups,
         progress_map: progress_map,
         total_learned: total_learned,
         total_kanji: total_kanji
       )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <div class="mb-8">
        <h1 class="section-header-wabi text-3xl">Learn</h1>
        <p class="mt-2 info-text-wabi">
          {@total_learned} of {@total_kanji} kanji learned
        </p>
      </div>

      <%= if @groups == [] do %>
        <p class="text-base-content/60">No thematic groups available yet. Check back soon!</p>
      <% else %>
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-6">
          <.group_card
            :for={group <- @groups}
            group={group}
            progress={Map.get(@progress_map, group.id, %{learned: 0, total: 0})}
          />
        </div>
      <% end %>
    </div>
    """
  end

  defp group_card(assigns) do
    ~H"""
    <.link
      navigate={~p"/learn/#{@group.slug || @group.id}"}
      class="card-wabi block p-6 hover:shadow-lg transition-shadow"
    >
      <h2 class="text-xl font-semibold text-base-content">{@group.name}</h2>
      <p class="mt-1 text-sm text-base-content/60">{@progress.total} kanji</p>
      <div class="mt-3">
        <%= cond do %>
          <% @progress.learned == 0 -> %>
            <span class="text-sm text-base-content/50">Not started</span>
          <% @progress.learned == @progress.total -> %>
            <span class="text-sm font-medium text-success">
              {@progress.learned}/{@progress.total} learned
            </span>
          <% true -> %>
            <span class="text-sm text-primary">
              {@progress.learned}/{@progress.total} learned
            </span>
        <% end %>
      </div>
    </.link>
    """
  end
end
