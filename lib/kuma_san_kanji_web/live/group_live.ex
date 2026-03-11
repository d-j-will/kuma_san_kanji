defmodule KumaSanKanjiWeb.GroupLive do
  @moduledoc "Thematic group detail view - shows kanji in a group."
  use KumaSanKanjiWeb, :live_view

  alias KumaSanKanji.Content.ContentContext
  alias KumaSanKanji.SRS.UserKanjiProgress
  import KumaSanKanjiWeb.FeatureFlagHelper, only: [learning_path_enabled?: 0]

  @impl true
  def mount(params, _session, socket) do
    unless learning_path_enabled?() do
      {:ok, redirect(socket, to: "/")}
    else
      case find_group(params["slug"]) do
        {:ok, group} ->
          user = socket.assigns.current_user
          {:ok, kanji_list} = ContentContext.get_kanji_by_thematic_group(group.id)

          learned_kanji_ids =
            kanji_list
            |> Enum.filter(fn k ->
              case UserKanjiProgress.get_user_kanji_progress(user.id, k.id, actor: user) do
                {:ok, [_ | _]} -> true
                _ -> false
              end
            end)
            |> Enum.map(& &1.id)
            |> MapSet.new()

          next_unlearned_position =
            kanji_list
            |> Enum.with_index(1)
            |> Enum.find_value(1, fn {k, pos} ->
              unless MapSet.member?(learned_kanji_ids, k.id), do: pos
            end)

          correct = parse_int(params["correct"])
          incorrect = parse_int(params["incorrect"])
          slug_or_id = group.slug || group.id

          {:ok,
           assign(socket,
             page_title: group.name,
             group: group,
             kanji_list: kanji_list,
             learned_kanji_ids: learned_kanji_ids,
             learned_count: MapSet.size(learned_kanji_ids),
             total_count: length(kanji_list),
             next_unlearned_position: next_unlearned_position,
             all_learned:
               MapSet.size(learned_kanji_ids) == length(kanji_list) and kanji_list != [],
             slug_or_id: slug_or_id,
             session_correct: correct,
             session_incorrect: incorrect,
             show_session_results: correct != nil or incorrect != nil
           )}

        {:error, :not_found} ->
          {:ok,
           socket
           |> put_flash(:error, "Group not found")
           |> redirect(to: ~p"/learn")}
      end
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <.link navigate={~p"/learn"} class="link-wabi text-sm">
        &larr; Back to Learn
      </.link>

      <h1 class="text-3xl font-wabi-display tracking-tight text-base-content sm:text-4xl mt-4">{@group.name}</h1>
      <p class="mt-1 info-text-wabi">{@learned_count} of {@total_count} learned</p>

      <%= if @show_session_results do %>
        <div class="mt-4 p-4 rounded-lg bg-info/10 border border-info/30">
          <p class="font-medium text-base-content">Session Results</p>
          <p class="info-text-wabi">
            Correct: {@session_correct || 0} | Incorrect: {@session_incorrect || 0}
          </p>
        </div>
      <% end %>

      <%= if @kanji_list == [] do %>
        <p class="mt-6 text-base-content/60">
          This group is being prepared. No kanji have been added yet.
        </p>
      <% else %>
        <div class="mt-6 grid grid-cols-4 sm:grid-cols-6 gap-3">
          <%= for {kanji, idx} <- Enum.with_index(@kanji_list, 1) do %>
            <.link
              navigate={~p"/learn/#{@slug_or_id}/#{idx}"}
              class={"flex flex-col items-center p-3 rounded-lg border #{if MapSet.member?(@learned_kanji_ids, kanji.id), do: "border-success/40 bg-success/10", else: "border-base-300 bg-base-100"} hover:shadow-md transition-shadow"}
            >
              <span class="text-2xl kanji-text">{kanji.character}</span>
              <%= if MapSet.member?(@learned_kanji_ids, kanji.id) do %>
                <span class="text-xs text-success mt-1">Learned</span>
              <% end %>
            </.link>
          <% end %>
        </div>

        <div class="mt-8">
          <%= if @all_learned do %>
            <p class="text-success font-semibold mb-3">All learned!</p>
            <.link
              navigate={~p"/learn/#{@slug_or_id}/quiz"}
              class="btn-wabi-accent inline-block px-6 py-3 rounded-lg"
            >
              Review All
            </.link>
          <% else %>
            <.link
              navigate={~p"/learn/#{@slug_or_id}/#{@next_unlearned_position}"}
              class="btn-wabi-accent inline-block px-6 py-3 rounded-lg"
            >
              Continue Learning
            </.link>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end

  defp find_group(slug_or_id) do
    case ContentContext.get_group_by_slug(slug_or_id) do
      {:ok, group} ->
        {:ok, group}

      _ ->
        case Ash.get(KumaSanKanji.Content.ThematicGroup, slug_or_id, authorize?: false) do
          {:ok, group} -> {:ok, group}
          _ -> {:error, :not_found}
        end
    end
  end

  defp parse_int(nil), do: nil

  defp parse_int(str) when is_binary(str) do
    case Integer.parse(str) do
      {n, _} -> n
      :error -> nil
    end
  end
end
