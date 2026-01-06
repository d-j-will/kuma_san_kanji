defmodule KumaSanKanjiWeb.ExploreLive do
  use KumaSanKanjiWeb, :live_view
  alias KumaSanKanji.Domain
  alias KumaSanKanjiWeb.StrokeOrderEvents
  alias KumaSanKanji.SRS.Logic

  @impl true
  def mount(_params, _session, socket) do
    total_kanji = KumaSanKanji.Kanji.count_all!()
    user = socket.assigns[:current_user]
    is_authenticated = user != nil
    socket =
      socket
      |> assign(:show_stroke_order, false)
      |> assign(:show_tracing, false)

    case total_kanji do
      n when n > 0 ->
        current_offset = 0

        case get_kanji_by_offset(current_offset) do
          {:ok, kanji, thematic_info, learning_meta, usage_examples} ->
            radical = kanji.radical || load_radical(kanji)
            progress = if is_authenticated, do: load_user_progress(user.id, kanji.id), else: nil

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
               progress: progress,
               note_form: to_form(%{"notes" => if(progress, do: progress.notes, else: "")})
             )}

          _ ->
            {:ok,
             assign(socket,
               kanji: nil,
               current_offset: 0,
               total_kanji: 0,
               is_authenticated: is_authenticated,
               thematic_info: nil,
               learning_meta: nil,
               usage_examples: [],
               progress: nil,
               show_stroke_order: false
             )}
        end

      _ ->
        {:ok,
         assign(socket,
           kanji: nil,
           current_offset: 0,
           total_kanji: 0,
           is_authenticated: is_authenticated,
           thematic_info: nil,
           learning_meta: nil,
           usage_examples: [],
           progress: nil,
           show_stroke_order: false
         )}
    end
  end

  @impl true
  def handle_event("new_kanji", _params, socket) do
    current_offset = socket.assigns.current_offset + 1
    total_kanji = socket.assigns.total_kanji
    user = socket.assigns[:current_user]

    new_offset =
      if total_kanji > 0 do
        rem(current_offset, total_kanji)
      else
        0
      end

    case get_kanji_by_offset(new_offset) do
      {:ok, kanji, thematic_info, learning_meta, usage_examples} ->
        radical = kanji.radical || load_radical(kanji)
        progress = if user, do: load_user_progress(user.id, kanji.id), else: nil

        socket = assign(socket,
          kanji: kanji,
          current_offset: new_offset,
          thematic_info: thematic_info,
          learning_meta: learning_meta,
          usage_examples: usage_examples,
          radical: radical,
          progress: progress,
          show_tracing: false,
          note_form: to_form(%{"notes" => if(progress, do: progress.notes, else: "")})
        )

        socket =
          if socket.assigns.show_stroke_order && kanji && kanji.character do
            Phoenix.LiveView.push_event(socket, "stroke_order_restart", %{kanji: kanji.character, mode: "brush"})
          else
            socket
          end

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("save_note", %{"notes" => notes}, socket) do
    user = socket.assigns.current_user
    kanji = socket.assigns.kanji
    progress = socket.assigns.progress

    if user && kanji do
      case progress do
        nil ->
          # Create new progress with note
          # We use initialize_progress first, then update the note
          # Or we could just use `create` if we wanted specific control, but initialize handles logic.
          case Logic.initialize_progress(user.id, kanji.id, user) do
            {:ok, new_progress} ->
              # Now update the note
              case Logic.update_user_notes(new_progress.id, notes, user.id, user) do
                {:ok, updated} ->
                  {:noreply,
                   socket
                   |> assign(:progress, updated)
                   |> put_flash(:info, "Note saved!")}
                {:error, _} ->
                  {:noreply, put_flash(socket, :error, "Failed to save note.")}
              end
            {:error, _} ->
              {:noreply, put_flash(socket, :error, "Failed to initialize progress.")}
          end

        existing ->
          case Logic.update_user_notes(existing.id, notes, user.id, user) do
            {:ok, updated} ->
              {:noreply,
               socket
               |> assign(:progress, updated)
               |> put_flash(:info, "Note saved!")}
            {:error, _} ->
              {:noreply, put_flash(socket, :error, "Failed to save note.")}
          end
      end
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("validate_note", %{"notes" => notes}, socket) do
    {:noreply, assign(socket, :note_form, to_form(%{"notes" => notes}))}
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

  def handle_event("toggle_tracing", _params, socket) do
    {:noreply, StrokeOrderEvents.toggle_tracing(socket)}
  end

  def handle_event(event, params = %{"kanji" => _}, socket) when event in ["stroke_order_restart", "stroke_order_step", "stroke_order_toggle_style"] do
    {:noreply, StrokeOrderEvents.handle(socket, event, params)}
  end

  @impl true
  def handle_event("japanese_voice_missing", _params, socket) do
    if !Phoenix.Flash.get(socket.assigns.flash, :info) =~ "Japanese voice pack" do
      {:noreply,
       put_flash(
         socket,
         :info,
         "Japanese voice pack not found. Please install a Japanese voice in your OS settings for audio pronunciation. (e.g., Windows: Settings > Time & Language > Speech; macOS: System Settings > Accessibility > Spoken Content)"
       )}
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  defp get_kanji_by_offset(offset) do
    case Domain.get_kanji_by_offset(offset) do
      {:ok, kanji} when not is_nil(kanji) ->
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
            {:ok, loaded_kanji, %{groups: [], joins: [], edu_context: nil}, [], []}
        end

      {:ok, nil} ->
        {:error, :no_kanji_at_offset}

      error ->
        error
    end
  end

  defp load_radical(kanji) do
    case Ash.load(kanji, :radical) do
      {:ok, with_radical} -> with_radical.radical
      _ -> nil
    end
  end

  defp load_user_progress(user_id, kanji_id) do
    # Use code interface for loading user progress
    case KumaSanKanji.SRS.UserKanjiProgress.get_user_kanji_progress(user_id, kanji_id) do
      {:ok, [progress]} -> progress
      {:ok, []} -> nil
      _ -> nil
    end
  end
end
