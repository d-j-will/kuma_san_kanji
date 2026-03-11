defmodule KumaSanKanjiWeb.TeachLive do
  @moduledoc "Individual kanji teaching view within a thematic group."
  use KumaSanKanjiWeb, :live_view

  alias KumaSanKanji.Content.ContentContext
  alias KumaSanKanji.NLP.Furigana
  alias KumaSanKanji.SRS.{Logic, UserKanjiProgress}
  alias KumaSanKanjiWeb.StrokeOrderEvents
  import KumaSanKanjiWeb.FeatureFlagHelper, only: [learning_path_enabled?: 0]
  import Phoenix.HTML, only: [raw: 1]

  @tabs [:character, :meaning, :readings, :examples]
  @tab_labels %{
    character: "Character",
    meaning: "Meaning",
    readings: "Readings",
    examples: "Examples"
  }

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
           on_readings: readings_of_type(kanji, :on),
           active_tab: :character,
           show_stroke_order: false,
           show_tracing: false,
           show_furigana: true,
           mecab_available: System.find_executable("mecab") != nil
         )}

      {:error, :not_found} ->
        {:ok, redirect(socket, to: ~p"/learn/#{group.slug || group.id}")}
    end
  end

  # Tab navigation
  @impl true
  def handle_event("next_tab", _params, socket) do
    {:noreply, advance_tab(socket)}
  end

  def handle_event("prev_tab", _params, socket) do
    {:noreply, retreat_tab(socket)}
  end

  def handle_event("select_tab", %{"tab" => tab_str}, socket) do
    tab = String.to_existing_atom(tab_str)
    if tab in @tabs, do: {:noreply, assign(socket, active_tab: tab)}, else: {:noreply, socket}
  rescue
    ArgumentError -> {:noreply, socket}
  end

  def handle_event("keydown", %{"key" => "ArrowRight"}, socket) do
    {:noreply, advance_tab(socket)}
  end

  def handle_event("keydown", %{"key" => "ArrowLeft"}, socket) do
    {:noreply, retreat_tab(socket)}
  end

  def handle_event("keydown", _params, socket) do
    {:noreply, socket}
  end

  # Stroke order events
  def handle_event("toggle_stroke_order", _params, socket) do
    new_val = !socket.assigns.show_stroke_order
    socket = StrokeOrderEvents.toggle(socket)

    socket =
      if new_val && socket.assigns.kanji && socket.assigns.kanji.character do
        Phoenix.LiveView.push_event(socket, "stroke_order_restart", %{
          kanji: socket.assigns.kanji.character,
          mode: "brush"
        })
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_event("toggle_tracing", _params, socket) do
    {:noreply, StrokeOrderEvents.toggle_tracing(socket)}
  end

  def handle_event(event, params = %{"kanji" => _}, socket)
      when event in ["stroke_order_restart", "stroke_order_step", "stroke_order_toggle_style"] do
    {:noreply, StrokeOrderEvents.handle(socket, event, params)}
  end

  # Furigana toggle
  def handle_event("toggle_furigana", _params, socket) do
    {:noreply, assign(socket, show_furigana: !socket.assigns.show_furigana)}
  end

  # Quiz
  def handle_event("mark_learned", _params, socket) do
    user = socket.assigns.current_user
    kanji = socket.assigns.kanji
    slug_or_id = socket.assigns.slug_or_id

    case UserKanjiProgress.get_user_kanji_progress(user.id, kanji.id, actor: user) do
      {:ok, [_ | _]} -> :already_tracked
      _ -> Logic.initialize_progress(user.id, kanji.id, user)
    end

    {:noreply, redirect(socket, to: ~p"/learn/#{slug_or_id}/quiz")}
  end

  def handle_event("japanese_voice_missing", _params, socket) do
    {:noreply,
     put_flash(
       socket,
       :info,
       "Japanese voice pack not found. Install a Japanese voice in your OS settings for audio pronunciation."
     )}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  defp advance_tab(socket) do
    idx = tab_index(socket.assigns.active_tab)

    if idx < length(@tabs) - 1,
      do: assign(socket, active_tab: Enum.at(@tabs, idx + 1)),
      else: socket
  end

  defp retreat_tab(socket) do
    idx = tab_index(socket.assigns.active_tab)
    if idx > 0, do: assign(socket, active_tab: Enum.at(@tabs, idx - 1)), else: socket
  end

  defp tab_index(tab), do: Enum.find_index(@tabs, &(&1 == tab))

  @impl true
  def render(assigns) do
    active_idx = tab_index(assigns.active_tab)

    assigns =
      assigns
      |> assign(
        :tabs_info,
        Enum.with_index(@tabs, fn tab, idx ->
          %{
            key: tab,
            label: @tab_labels[tab],
            index: idx,
            state:
              cond do
                idx == active_idx -> :active
                idx < active_idx -> :completed
                true -> :upcoming
              end
          }
        end)
      )
      |> assign(:is_last_tab, active_idx == length(@tabs) - 1)
      |> assign(:is_first_tab, active_idx == 0)

    ~H"""
    <div class="max-w-3xl mx-auto px-4 py-8" phx-window-keydown="keydown">
      <%!-- Header: breadcrumb + kanji prev/next --%>
      <div class="flex items-center justify-between mb-6">
        <div class="flex items-center gap-2 text-sm text-base-content/60">
          <.link navigate={~p"/learn/#{@slug_or_id}"} class="link-wabi">{@group.name}</.link>
          <span>&mdash;</span>
          <span>{@position} of {@total_kanji}</span>
        </div>
        <div class="flex items-center gap-1">
          <%= if @position > 1 do %>
            <.link
              navigate={~p"/learn/#{@slug_or_id}/#{@position - 1}"}
              class="px-2 py-1 text-base-content/50 hover:text-base-content rounded transition-colors"
              aria-label="Previous kanji"
            >
              &larr;
            </.link>
          <% else %>
            <span class="px-2 py-1 text-base-content/20" aria-disabled="true">&larr;</span>
          <% end %>
          <%= if @position < @total_kanji do %>
            <.link
              navigate={~p"/learn/#{@slug_or_id}/#{@position + 1}"}
              class="px-2 py-1 text-base-content/50 hover:text-base-content rounded transition-colors"
              aria-label="Next kanji"
            >
              &rarr;
            </.link>
          <% else %>
            <span class="px-2 py-1 text-base-content/20" aria-disabled="true">&rarr;</span>
          <% end %>
        </div>
      </div>

      <%!-- Tab indicators --%>
      <div class="flex items-center justify-center gap-2 sm:gap-3 mb-8">
        <button
          :for={tab <- @tabs_info}
          phx-click="select_tab"
          phx-value-tab={tab.key}
          class={[
            "flex items-center gap-1.5 px-2 sm:px-3 py-1.5 rounded-full text-sm transition-all",
            tab.state == :active && "bg-primary/15 text-primary font-medium",
            tab.state == :completed && "text-success/70 hover:text-success",
            tab.state == :upcoming && "text-base-content/40 hover:text-base-content/60"
          ]}
        >
          <span class={[
            "w-6 h-6 rounded-full flex items-center justify-center text-xs",
            tab.state == :active && "bg-primary text-primary-content",
            tab.state == :completed && "bg-success/20 text-success",
            tab.state == :upcoming && "bg-base-300 text-base-content/50"
          ]}>
            {tab.index + 1}
          </span>
          <span class="hidden sm:inline">{tab.label}</span>
        </button>
      </div>

      <%!-- Tab content --%>
      <div class="min-h-[300px]">
        <%= case @active_tab do %>
          <% :character -> %>
            <.character_tab
              kanji={@kanji}
              show_stroke_order={@show_stroke_order}
              show_tracing={@show_tracing}
            />
          <% :meaning -> %>
            <.meaning_tab kanji={@kanji} meta={@meta} />
          <% :readings -> %>
            <.readings_tab kun_readings={@kun_readings} on_readings={@on_readings} />
          <% :examples -> %>
            <.examples_tab
              kanji={@kanji}
              show_furigana={@show_furigana}
              mecab_available={@mecab_available}
            />
        <% end %>
      </div>

      <%!-- Tab navigation footer --%>
      <div class="mt-10 flex items-center justify-between">
        <%= if @is_first_tab do %>
          <div></div>
        <% else %>
          <button
            phx-click="prev_tab"
            class="px-4 py-2 text-base-content/60 hover:text-base-content transition-colors"
          >
            &larr; Back
          </button>
        <% end %>

        <%= if @is_last_tab do %>
          <button
            phx-click="mark_learned"
            class="btn-wabi-accent px-6 py-3 rounded-lg font-medium"
          >
            I've learned this &mdash; Quiz me!
          </button>
        <% else %>
          <button
            phx-click="next_tab"
            class="btn-wabi-accent px-5 py-2.5 rounded-lg font-medium"
          >
            Next &rarr;
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  # Tab content components

  defp character_tab(assigns) do
    ~H"""
    <div class="text-center">
      <div class="flex flex-col items-center mb-6">
        <div class="kanji-container flex items-center justify-center w-32 h-32 rounded-lg">
          <span class="kanji-display select-none">{@kanji.character}</span>
        </div>
        <div class="flex gap-2 mt-2">
          <button
            type="button"
            class="text-xs underline text-wabi-accent"
            phx-click="toggle_stroke_order"
            aria-expanded={@show_stroke_order}
          >
            {if @show_stroke_order, do: "Hide Stroke Order", else: "Show Stroke Order"}
          </button>
          <%= if @show_stroke_order do %>
            <button
              type="button"
              class="text-xs underline text-wabi-hok_blue"
              phx-click="toggle_tracing"
              aria-expanded={@show_tracing}
            >
              {if @show_tracing, do: "Disable Tracing", else: "Practice Writing"}
            </button>
          <% end %>
        </div>
      </div>

      <%= if @show_stroke_order do %>
        <div class="mb-6 border border-base-300 rounded-md p-3 bg-base-200/30">
          <KumaSanKanjiWeb.KanjiStrokeOrderComponent.stroke_order
            id="teach-stroke-order"
            kanji={@kanji.character}
            animate?={true}
            mode={if @show_tracing, do: :trace, else: :view}
          />
          <p class="mt-2 text-[10px] text-base-content/40">
            Stroke order data &copy; KanjiVG (CC BY-SA 3.0)
          </p>
        </div>
      <% end %>

      <div class="flex justify-center gap-8 text-base-content/70">
        <div class="text-center">
          <p class="text-sm text-base-content/50">Strokes</p>
          <p class="text-xl font-wabi-display">{@kanji.stroke_count}</p>
        </div>
        <%= if @kanji.grade do %>
          <div class="text-center">
            <p class="text-sm text-base-content/50">Grade</p>
            <p class="text-xl font-wabi-display">{@kanji.grade}</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  defp meaning_tab(assigns) do
    ~H"""
    <div class="space-y-6">
      <div class="text-center mb-4">
        <span class="text-5xl kanji-text select-none">{@kanji.character}</span>
      </div>

      <div>
        <h2 class="text-lg font-wabi-display text-base-content/80">Meaning</h2>
        <p class="text-2xl text-base-content mt-1">
          {@kanji.meanings |> Enum.map(& &1.value) |> Enum.join(", ")}
        </p>
      </div>

      <%= if @meta do %>
        <%= if @meta.learning_tips do %>
          <div class="p-4 bg-warning/10 rounded-lg border border-warning/30">
            <h3 class="text-base font-semibold text-base-content">Learning Tips</h3>
            <p class="text-base-content/90 mt-1">{@meta.learning_tips}</p>
          </div>
        <% end %>
        <%= if @meta.mnemonic_hints do %>
          <div class="p-4 bg-info/10 rounded-lg border border-info/30">
            <h3 class="text-base font-semibold text-base-content">Mnemonic</h3>
            <p class="text-base-content/90 mt-1">{@meta.mnemonic_hints}</p>
          </div>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp readings_tab(assigns) do
    ~H"""
    <div class="space-y-6">
      <%= if @kun_readings != [] do %>
        <div>
          <h2 class="text-lg font-wabi-display text-base-content/80">Kun Readings</h2>
          <p class="text-sm text-base-content/50 mb-2">Japanese origin</p>
          <div class="flex flex-wrap gap-2">
            <span
              :for={reading <- @kun_readings}
              class="px-3 py-1.5 bg-primary/10 text-primary rounded-lg text-lg"
            >
              {reading}
            </span>
          </div>
        </div>
      <% end %>

      <%= if @on_readings != [] do %>
        <div>
          <h2 class="text-lg font-wabi-display text-base-content/80">On Readings</h2>
          <p class="text-sm text-base-content/50 mb-2">Chinese origin</p>
          <div class="flex flex-wrap gap-2">
            <span
              :for={reading <- @on_readings}
              class="px-3 py-1.5 bg-secondary/10 text-secondary rounded-lg text-lg"
            >
              {reading}
            </span>
          </div>
        </div>
      <% end %>

      <%= if @kun_readings == [] and @on_readings == [] do %>
        <p class="text-base-content/50 text-center py-8">No readings available for this kanji.</p>
      <% end %>
    </div>
    """
  end

  defp examples_tab(assigns) do
    ~H"""
    <div class="space-y-6">
      <%= if @kanji.example_sentences != [] do %>
        <div class="flex items-center justify-between">
          <h2 class="text-lg font-wabi-display text-base-content/80">Example Sentences</h2>
          <%= if @mecab_available do %>
            <button
              type="button"
              phx-click="toggle_furigana"
              class="text-xs px-2 py-1 rounded border border-base-300 text-base-content/60 hover:text-base-content transition-colors"
            >
              {if @show_furigana, do: "Hide Furigana", else: "Show Furigana"}
            </button>
          <% end %>
        </div>
        <div class="space-y-3">
          <div
            :for={sentence <- @kanji.example_sentences}
            class="p-3 bg-base-200/50 rounded-lg"
          >
            <%= if @show_furigana and @mecab_available do %>
              <p class="text-lg text-base-content">{raw(Furigana.parse_sentence(sentence.japanese))}</p>
            <% else %>
              <p class="text-lg text-base-content">{sentence.japanese}</p>
            <% end %>
            <p class="info-text-wabi mt-1">{sentence.translation}</p>
          </div>
        </div>
      <% else %>
        <p class="text-base-content/50 text-center py-8">No example sentences available yet.</p>
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
