defmodule KumaSanKanjiWeb.TeachLive do
  @moduledoc "Individual kanji teaching view within a thematic group."
  use KumaSanKanjiWeb, :live_view

  alias KumaSanKanji.Content.ContentContext
  alias KumaSanKanji.SRS.{Logic, UserKanjiProgress}
  import KumaSanKanjiWeb.FeatureFlagHelper, only: [learning_path_enabled?: 0]

  @impl true
  def mount(params, _session, socket) do
    unless learning_path_enabled?() do
      {:ok, redirect(socket, to: "/")}
    else
      slug_or_id = params["slug"]

      case find_group(slug_or_id) do
        {:ok, group} ->
          mount_with_group(socket, group, params)

        {:error, :not_found} ->
          {:ok, redirect(socket, to: ~p"/learn")}
      end
    end
  end

  defp mount_with_group(socket, group, params) do
    position = parse_position(params["position"])

    case ContentContext.get_kanji_at_position(group.id, position) do
      {:ok, kanji} ->
        kanji = load_kanji_associations(kanji)

        meta =
          case ContentContext.get_learning_meta(kanji.id) do
            {:ok, meta} -> meta
            _ -> nil
          end

        {:ok, kanji_list} = ContentContext.get_kanji_by_thematic_group(group.id)
        total_kanji = length(kanji_list)
        slug_or_id = group.slug || group.id

        {:ok,
         assign(socket,
           page_title: "#{group.name} - #{kanji.character}",
           group: group,
           kanji: kanji,
           meta: meta,
           position: position,
           total_kanji: total_kanji,
           slug_or_id: slug_or_id,
           kun_readings: readings_of_type(kanji, :kun),
           on_readings: readings_of_type(kanji, :on)
         )}

      {:error, :not_found} ->
        {:ok, redirect(socket, to: ~p"/learn/#{group.slug || group.id}")}
    end
  end

  @impl true
  def handle_event("mark_learned", _params, socket) do
    user = socket.assigns.current_user
    kanji = socket.assigns.kanji
    slug_or_id = socket.assigns.slug_or_id

    # Only initialize if no progress exists (preserve existing SRS state)
    case UserKanjiProgress.get_user_kanji_progress(user.id, kanji.id, actor: user) do
      {:ok, [_ | _]} -> :already_tracked
      _ -> Logic.initialize_progress(user.id, kanji.id, user)
    end

    {:noreply, redirect(socket, to: ~p"/learn/#{slug_or_id}/quiz")}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto px-4 py-8">
      <div class="flex items-center gap-2 text-sm text-base-content/60 mb-6">
        <.link navigate={~p"/learn/#{@slug_or_id}"} class="link-wabi">{@group.name}</.link>
        <span>&mdash;</span>
        <span>{@position} of {@total_kanji}</span>
      </div>

      <div class="text-center mb-8">
        <div class="text-9xl font-light text-base-content">{@kanji.character}</div>
      </div>

      <div class="space-y-6">
        <div>
          <h2 class="text-lg font-semibold text-base-content/80">Meaning</h2>
          <p class="text-xl text-base-content">
            {@kanji.meanings |> Enum.map(& &1.value) |> Enum.join(", ")}
          </p>
        </div>

        <%= if @kun_readings != [] do %>
          <div>
            <h2 class="text-lg font-semibold text-base-content/80">Kun Readings</h2>
            <p class="text-xl text-base-content">{Enum.join(@kun_readings, ", ")}</p>
          </div>
        <% end %>

        <%= if @on_readings != [] do %>
          <div>
            <h2 class="text-lg font-semibold text-base-content/80">On Readings</h2>
            <p class="text-xl text-base-content">{Enum.join(@on_readings, ", ")}</p>
          </div>
        <% end %>

        <div>
          <h2 class="text-lg font-semibold text-base-content/80">Stroke Count</h2>
          <p class="text-xl text-base-content">{@kanji.stroke_count}</p>
        </div>

        <%= if @kanji.example_sentences != [] do %>
          <div>
            <h2 class="text-lg font-semibold text-base-content/80">Example Sentences</h2>
            <div :for={sentence <- @kanji.example_sentences} class="mt-2">
              <p class="text-lg text-base-content">{sentence.japanese}</p>
              <p class="info-text-wabi">{sentence.translation}</p>
            </div>
          </div>
        <% end %>

        <%= if @meta do %>
          <div class="p-4 bg-warning/10 rounded-lg border border-warning/30">
            <h2 class="text-lg font-semibold text-base-content">Learning Tips</h2>
            <p class="text-base-content/90 mt-1">{@meta.learning_tips}</p>
          </div>
        <% end %>
      </div>

      <div class="mt-10 flex items-center gap-4">
        <button
          phx-click="mark_learned"
          class="btn-wabi-accent px-6 py-3 rounded-lg font-medium"
        >
          I've learned this &mdash; Quiz me!
        </button>

        <%= if @position < @total_kanji do %>
          <.link
            navigate={~p"/learn/#{@slug_or_id}/#{@position + 1}"}
            class="px-6 py-3 text-base-content/70 hover:text-base-content"
          >
            Skip to next
          </.link>
        <% else %>
          <.link
            navigate={~p"/learn/#{@slug_or_id}"}
            class="px-6 py-3 text-base-content/70 hover:text-base-content"
          >
            Skip to group
          </.link>
        <% end %>
      </div>
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

  defp parse_position(str) when is_binary(str) do
    case Integer.parse(str) do
      {n, _} -> n
      :error -> 0
    end
  end

  defp parse_position(_), do: 0

  defp load_kanji_associations(kanji) do
    case Ash.load(kanji, [:meanings, :pronunciations, :example_sentences], authorize?: false) do
      {:ok, loaded} -> loaded
      _ -> kanji
    end
  end

  defp readings_of_type(kanji, type) do
    type_str = to_string(type)

    kanji.pronunciations
    |> Enum.filter(&(to_string(&1.type) == type_str))
    |> Enum.map(& &1.value)
  end
end
