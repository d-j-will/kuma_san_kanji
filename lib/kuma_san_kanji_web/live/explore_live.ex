defmodule KumaSanKanjiWeb.ExploreLive do
  use KumaSanKanjiWeb, :live_view
  alias KumaSanKanji.Domain
  alias KumaSanKanjiWeb.StrokeOrderEvents
  alias KumaSanKanjiWeb.StrokeOrderEvents

  @impl true
  def mount(_params, _session, socket) do
    count = Domain.count_all_kanjis!()
    is_authenticated = socket.assigns[:current_user] != nil
    socket = assign(socket, :show_stroke_order, false)

    case count do
      total_kanji when total_kanji > 0 ->
  current_offset = 0

        case get_kanji_by_offset(current_offset) do
          {:ok, kanji, thematic_info, learning_meta, usage_examples} ->
            radical = kanji.radical || load_radical(kanji)
            {:ok,
             assign(socket,
               kanji: kanji,
               current_offset: current_offset,
               total_kanji: total_kanji,
               is_authenticated: is_authenticated,
               thematic_info: thematic_info,
               learning_meta: learning_meta,
               usage_examples: usage_examples,
                radical: radical,
               show_stroke_order: false
             )}

          _ ->
            # Should not happen if count > 0, but handle defensively
            {:ok,
             assign(socket,
               kanji: nil,
               current_offset: 0,
               total_kanji: 0,
               is_authenticated: is_authenticated,
               thematic_info: nil,
               learning_meta: nil,
               usage_examples: [],
               show_stroke_order: false
             )}
        end

      _ ->
        # No kanji in the database
        {:ok,
         assign(socket,
           kanji: nil,
           current_offset: 0,
           total_kanji: 0,
           is_authenticated: is_authenticated,
           thematic_info: nil,
           learning_meta: nil,
           usage_examples: [],
           show_stroke_order: false
         )}
    end
  end

  @impl true
  def handle_event("new_kanji", _params, socket) do
    current_offset = socket.assigns.current_offset + 1
    total_kanji = socket.assigns.total_kanji

    new_offset =
      if total_kanji > 0 do
        rem(current_offset, total_kanji)
      else
        0
      end

    case get_kanji_by_offset(new_offset) do
      {:ok, kanji, thematic_info, learning_meta, usage_examples} ->
        radical = kanji.radical || load_radical(kanji)
        socket = assign(socket,
          kanji: kanji,
          current_offset: new_offset,
          thematic_info: thematic_info,
          learning_meta: learning_meta,
          usage_examples: usage_examples,
          radical: radical
        )

        # If stroke order panel is currently visible, replay animation for new kanji
        socket =
          if socket.assigns.show_stroke_order && kanji && kanji.character do
            Phoenix.LiveView.push_event(socket, "stroke_order_restart", %{kanji: kanji.character, mode: "brush"})
          else
            socket
          end

        {:noreply, socket}

      _ ->
        # Error fetching, or no kanji, keep current state or show error
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("toggle_stroke_order", _params, socket) do
    new_val = !socket.assigns.show_stroke_order
    socket = StrokeOrderEvents.toggle(socket)
    socket =
      if new_val && socket.assigns.kanji && socket.assigns.kanji.character do
        Phoenix.LiveView.push_event(socket, "stroke_order_restart", %{kanji: socket.assigns.kanji.character, mode: "brush"})
      else
        socket
      end
    {:noreply, socket}
  end

  def handle_event(event, params = %{"kanji" => _}, socket) when event in ["stroke_order_restart", "stroke_order_step", "stroke_order_toggle_style"] do
    {:noreply, StrokeOrderEvents.handle(socket, event, params)}
  end

  @impl true
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  defp get_kanji_by_offset(offset) do
    # Updated call to use Domain and pass offset as a direct argument
    case Domain.get_kanji_by_offset(offset) do
      # Handle the case when a single kanji is returned
      {:ok, kanji} when not is_nil(kanji) ->
        # Load relationships
        # Ensure get_kanji_by_id! is used as per Ash guidelines for expected success
        loaded_kanji =
          Domain.get_kanji_by_id!(kanji.id,
            load: [:meanings, :pronunciations, :example_sentences]
          )

        with {:ok, thematic_groups, kanji_thematic_groups} <-
               KumaSanKanji.ContentContext.get_thematic_group_for_kanji(loaded_kanji.id),
             edu_context <-
               if(loaded_kanji.grade,
                 do: KumaSanKanji.ContentContext.get_educational_context(loaded_kanji.grade),
                 else: {:ok, []}
               ),
             {:ok, learning_meta} <-
               KumaSanKanji.ContentContext.get_learning_meta(loaded_kanji.id),
             {:ok, usage_examples} <-
               KumaSanKanji.ContentContext.get_usage_examples(loaded_kanji.id) do
          thematic_info = %{
            groups: thematic_groups,
            joins: kanji_thematic_groups,
            edu_context:
              case edu_context do
                {:ok, [context]} -> context
                _ -> nil
              end
          }

          loaded_kanji = Ash.load!(loaded_kanji, :radical)
          {:ok, loaded_kanji, thematic_info, learning_meta, usage_examples}
        else
          _error ->
            # Fallback: if related data fails, still return the main kanji
            # This assumes loaded_kanji is available even if the 'with' block fails partway
            # It's safer to re-fetch or ensure loaded_kanji is correctly scoped.
            # For simplicity, assuming loaded_kanji from the initial successful fetch is sufficient.
            {:ok, loaded_kanji, %{groups: [], joins: [], edu_context: nil}, [], []}
        end

      # Case where Domain.get_kanji_by_offset returns {:ok, nil} or an error
      # Or handle as per specific return of get_kanji_by_offset
      {:ok, nil} ->
        {:error, :no_kanji_at_offset}

      error ->
        error
    end
  end

  # Template is now in explore_live.html.heex

  defp load_radical(kanji) do
    case Ash.load(kanji, :radical) do
      {:ok, with_radical} -> with_radical.radical
      _ -> nil
    end
  end
end
