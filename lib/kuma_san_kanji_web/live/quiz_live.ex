defmodule KumaSanKanjiWeb.QuizLive do
  @moduledoc """
  LiveView for the SRS-based kanji quiz system.

  Features:
  - Secure, authenticated quiz sessions
  - SM-2 spaced repetition algorithm
  - Accessible UI with ARIA labels and keyboard navigation
  - Real-time feedback and progress tracking
  - Rate limiting and input validation
  """
  use KumaSanKanjiWeb, :live_view

  alias KumaSanKanji.SRS.Logic
  alias KumaSanKanji.Quiz.Session
  alias KumaSanKanji.Quiz.Core.SessionState
  alias KumaSanKanjiWeb.StrokeOrderEvents
  import KumaSanKanjiWeb.LiveHelpers

  # Rate limiting: max 100 answers per 5 minutes per user
  # 5 minutes in milliseconds
  @rate_limit_window 300_000
  @rate_limit_max_answers 100

  # Authentication required for this LiveView
  on_mount {KumaSanKanjiWeb.UserLiveAuth, :live_user_required}

  @impl true
  def mount(params, _session, socket) do
    require Logger
    user = socket.assigns.current_user

    socket =
      socket
      |> assign(:show_stroke_order, false)
      |> assign(:show_tracing, false)

    quiz_state =
      case restore_session_if_exists(user.id, params["session_id"], user) do
        {:ok, restored_state} ->
          restored_state

        {:error, :no_session_id} ->
          case initialize_quiz_session(user.id, user) do
            {:ok, new_state} ->
              new_state

            {:error, reason} ->
              Logger.error(
                "[QuizLive] Failed to initialize quiz session for user #{user.id}: #{inspect(reason)}"
              )

              {:error, reason}
          end

        {:error, reason} ->
          Logger.error(
            "[QuizLive] Failed to restore session for user #{user.id} with session_id #{params["session_id"]}: #{inspect(reason)}"
          )

          case initialize_quiz_session(user.id, user) do
            {:ok, new_state} ->
              new_state

            {:error, reason2} ->
              Logger.error(
                "[QuizLive] Failed to initialize quiz session for user #{user.id}: #{inspect(reason2)}"
              )

              {:error, reason2}
          end
      end

    case quiz_state do
      {:error, reason} ->
        Logger.error("[QuizLive] Quiz state error for user #{user.id}: #{inspect(reason)}")

        socket =
          socket
          |> put_flash(:error, get_error_message(reason, user) <> " (debug: #{inspect(reason)})")
          |> assign(:quiz_error, true)
          |> assign(:keyboard_shortcuts_visible, false)
          |> assign(:mobile_help_visible, false)
          |> assign(:dev_mode, dev_mode_enabled?(user))

        {:ok, socket}

      quiz_state when is_map(quiz_state) ->
        next_dt =
          case Logic.get_next_review_datetime(user.id, user) do
            {:ok, dt} -> dt
            _ -> nil
          end

        socket =
          socket
          |> assign(quiz_state)
          |> assign(:user_answer, "")
          |> assign(:show_feedback, false)
          |> assign(:feedback_message, "")
          |> assign(:feedback_type, :info)
          |> assign(:feedback_details_expanded, false)
          |> assign(
            :session_start_time,
            quiz_state[:session_start_time] || System.system_time(:millisecond)
          )
          |> assign(:answers_count, quiz_state[:answers_count] || 0)
          |> assign(:last_answer_times, quiz_state[:last_answer_times] || [])
          |> assign(:quiz_complete, false)
          |> assign(:keyboard_shortcuts_visible, false)
          |> assign(:mobile_help_visible, false)
          |> assign(:dev_mode, dev_mode_enabled?(user))
          |> assign(:results, %{correct: 0, incorrect: 0})
          |> assign(:next_review_at, next_dt)

        {:ok, socket}
    end
  end

  @impl true
  def handle_event("submit_answer", %{"answer" => answer}, socket) do
    user = socket.assigns.current_user
    current_kanji = socket.assigns.current_kanji
    current_progress = socket.assigns.current_progress

    # Rate limiting check
    case check_rate_limit(socket) do
      :ok ->
        # Validate and sanitize user input
        case validate_and_sanitize_answer(answer) do
          {:ok, sanitized_answer} ->
            process_answer(socket, user, current_kanji, current_progress, sanitized_answer)

          {:error, reason} ->
            socket =
              socket
              |> assign(:show_feedback, true)
              |> assign(:feedback_message, get_validation_error_message(reason))
              |> assign(:feedback_type, :error)

            {:noreply, socket}
        end

      {:error, :rate_limited} ->
        socket =
          socket
          |> put_flash(:error, "Too many answers submitted. Please wait before continuing.")
          |> assign(:show_feedback, true)
          |> assign(
            :feedback_message,
            "Rate limit exceeded. Please wait before submitting more answers."
          )
          |> assign(:feedback_type, :warning)

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("skip_kanji", _params, socket) do
    user = socket.assigns.current_user
    current_progress = socket.assigns.current_progress

    case Logic.record_review(current_progress.id, :skip, user.id, user) do
      {:ok, _updated_progress} ->
        load_next_kanji(socket)

      {:error, reason} ->
        socket =
          socket
          |> put_flash(:error, "Failed to skip kanji: #{get_error_message(reason, user)}")

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("next_kanji", _params, socket) do
    load_next_kanji(socket)
  end

  def handle_event("show_results", _params, socket) do
    {:noreply, assign(socket, :show_results, true)}
  end

  @impl true
  def handle_event("toggle_keyboard_shortcuts", _params, socket) do
    {:noreply,
     assign(socket, :keyboard_shortcuts_visible, !socket.assigns.keyboard_shortcuts_visible)}
  end

  @impl true
  def handle_event("toggle_mobile_help", _params, socket) do
    {:noreply, assign(socket, :mobile_help_visible, !socket.assigns.mobile_help_visible)}
  end

  @impl true
  def handle_event("toggle_feedback_details", _params, socket) do
    {:noreply,
     assign(socket, :feedback_details_expanded, !socket.assigns.feedback_details_expanded)}
  end

  @impl true
  def handle_event("restart_quiz", _params, socket) do
    user = socket.assigns.current_user

    case initialize_quiz_session(user.id, user) do
      {:ok, quiz_state} ->
        socket =
          socket
          |> assign(quiz_state)
          |> assign(:user_answer, "")
          |> assign(:show_feedback, false)
          |> assign(:feedback_message, "")
          |> assign(:feedback_type, :info)
          |> assign(:quiz_complete, false)
          |> assign(:answers_count, 0)
          |> assign(:last_answer_times, [])

        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> put_flash(:error, get_error_message(reason, user))

        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("reset_progress", _params, socket) do
    require Logger
    user = socket.assigns.current_user

    if dev_mode_enabled?(user) do
      # Add detailed error handling with try/rescue
      try do
        # Use enhanced reset options - 15 kanji that are all due immediately
        case Logic.reset_user_progress(user.id, limit: 15, immediate: true, actor: user) do
          {:ok, result} ->
            Logger.debug(
              "[QuizLive] Reset progress: cleared #{result.cleared} records, initialized #{result.initialized} kanji"
            )

            # Re-initialize the quiz session after reset
            case initialize_quiz_session(user.id, user) do
              {:ok, quiz_state} ->
                socket =
                  socket
                  |> assign(quiz_state)
                  |> assign(:user_answer, "")
                  |> assign(:show_feedback, false)
                  |> assign(
                    :feedback_message,
                    "Progress reset! #{result.initialized} kanji ready for review."
                  )
                  |> assign(:feedback_type, :info)
                  |> assign(:quiz_complete, false)
                  |> assign(:answers_count, 0)
                  |> assign(:last_answer_times, [])
                  |> put_flash(
                    :info,
                    "Quiz progress reset. #{result.initialized} kanji ready for immediate review."
                  )

                {:noreply, socket}

              {:error, reason} ->
                {:noreply,
                 put_flash(
                   socket,
                   :error,
                   "Failed to re-initialize quiz: #{get_error_message(reason, user)}"
                 )}
            end

          {:error, reason} ->
            Logger.error("[QuizLive] Failed to reset progress: #{inspect(reason)}")
            {:noreply, put_flash(socket, :error, "Failed to reset progress: #{inspect(reason)}")}
        end
      rescue
        e ->
          Logger.error(
            "[QuizLive] Exception in reset_progress: #{inspect(e)}\n#{Exception.format_stacktrace(__STACKTRACE__)}"
          )

          {:noreply, put_flash(socket, :error, "Error: #{Exception.message(e)}")}
      end
    else
      {:noreply, socket}
    end
  end

  # Keyboard event handling
  @impl true
  def handle_event("key_down", %{"key" => "Enter"}, socket) do
    if socket.assigns.show_feedback do
      handle_event("next_kanji", %{}, socket)
    else
      # Let the form's phx-submit handle the submission to avoid duplicate processing
      # The browser will handle the Enter key submission via the form's phx-submit
      {:noreply, socket}
    end
  end

  def handle_event("key_down", %{"key" => "Escape"}, socket) do
    handle_event("skip_kanji", %{}, socket)
  end

  def handle_event("key_down", %{"key" => "?"}, socket) do
    handle_event("toggle_keyboard_shortcuts", %{}, socket)
  end

  def handle_event("key_down", _params, socket) do
    {:noreply, socket}
  end

  # Direct key event handlers for test framework compatibility
  def handle_event("Escape", _params, socket) do
    handle_event("key_down", %{"key" => "Escape"}, socket)
  end

  def handle_event("Enter", _params, socket) do
    handle_event("key_down", %{"key" => "Enter"}, socket)
  end

  @impl true
  def handle_event("update_answer", %{"answer" => answer}, socket) do
    {:noreply, assign(socket, :user_answer, answer)}
  end

  def handle_event("toggle_stroke_order", _params, socket) do
    new_val = !socket.assigns.show_stroke_order
    socket = StrokeOrderEvents.toggle(socket)

    socket =
      if new_val && socket.assigns.current_kanji && socket.assigns.current_kanji.character do
        Phoenix.LiveView.push_event(socket, "stroke_order_restart", %{
          kanji: socket.assigns.current_kanji.character,
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

  @impl true
  def handle_event("japanese_voice_missing", _params, socket) do
    # Only show the flash if it hasn't been shown recently (e.g., within the last minute)
    # or if there's no existing flash about it.
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

  # Handle test messages
  @impl true
  def handle_info({:set_last_answer_times, times}, socket) do
    {:noreply, assign(socket, :last_answer_times, times)}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end

  # Private helper functions

  defp restore_session_if_exists(_user_id, nil, _actor), do: {:error, :no_session_id}

  defp restore_session_if_exists(user_id, session_id, actor) do
    require Logger

    try do
      case Session.restore_for_user(user_id, session_id) do
        {:ok, session_data} ->
          # Get user stats to include with restored session
          case Logic.get_user_stats(user_id, actor) do
            # Get progress for the current kanji if available
            {:ok, stats} ->
              current_progress =
                case session_data.current_kanji do
                  nil ->
                    nil

                  kanji ->
                    # Try to get the progress for this kanji
                    case Logic.get_due_kanji(user_id, 1, actor) do
                      {:ok, [progress | _]} when progress.kanji.id == kanji.id -> progress
                      {:ok, _} -> nil
                      {:error, _} -> nil
                    end
                end

              {:ok,
               %{
                 current_kanji: session_data.current_kanji,
                 current_progress: current_progress,
                 user_stats: stats,
                 quiz_error: false,
                 answers_count: session_data.answers_count || 0,
                 last_answer_times: session_data.last_answer_times || []
               }}

            {:error, reason} ->
              {:error, reason}
          end

        {:error, _reason} ->
          {:error, :session_not_found}
      end
    rescue
      e ->
        Logger.error(
          "[QuizLive] Exception in restore_session_if_exists for user #{user_id}, session_id #{inspect(session_id)}: #{Exception.message(e)}\n" <>
            Exception.format(:error, e, __STACKTRACE__)
        )

        {:error, {:exception, Exception.message(e)}}
    end
  end

  defp save_session_state(socket, user_id) do
    current_kanji_id =
      case socket.assigns.current_kanji do
        nil -> nil
        kanji -> kanji.id
      end

    # Include both the kanji and progress data in the session
    session_data = %{
      user_id: user_id,
      current_kanji_id: current_kanji_id,
      answers_count: socket.assigns.answers_count,
      last_answer_times: socket.assigns.last_answer_times,
      session_start_time: socket.assigns.session_start_time
    }

    # Save session asynchronously to avoid blocking the LiveView
    Task.start(fn ->
      case Session.save(session_data) do
        {:ok, _session_id} ->
          :ok

        {:error, reason} ->
          # Log error but don't interrupt the quiz flow
          require Logger
          Logger.warning("Failed to save quiz session: #{inspect(reason)}")
      end
    end)
  end

  # Private helper functions
  defp initialize_quiz_session(user_id, actor) do
    stats_result = Logic.get_user_stats(user_id, actor)
    due_result = Logic.get_due_kanji(user_id, 1, actor)
    SessionState.init_state(stats_result, due_result)
  end

  defp validate_and_sanitize_answer(answer) when is_binary(answer) do
    # Basic validation and sanitization
    trimmed = String.trim(answer)

    cond do
      String.length(trimmed) == 0 ->
        {:error, :empty_answer}

      String.length(trimmed) > 100 ->
        {:error, :answer_too_long}

      !String.match?(trimmed, ~r/^[\p{L}\p{N}\p{P}\s]+$/u) ->
        {:error, :invalid_characters}

      true ->
        # HTML escape for XSS prevention
        sanitized = Phoenix.HTML.html_escape(trimmed) |> Phoenix.HTML.safe_to_string()
        {:ok, sanitized}
    end
  end

  defp validate_and_sanitize_answer(_), do: {:error, :invalid_format}

  defp check_rate_limit(socket) do
    user = socket.assigns.current_user
    current_time = System.system_time(:millisecond)

    # Fetch latest timestamps from persistent session to prevent multi-tab bypass
    last_times =
      case KumaSanKanji.Quiz.Session.get_for_user(user.id) do
        {:ok, session} -> session.last_answer_times || []
        _ -> socket.assigns.last_answer_times
      end

    # Remove old timestamps outside the window
    recent_times =
      Enum.filter(last_times, fn time ->
        current_time - time < @rate_limit_window
      end)

    if length(recent_times) >= @rate_limit_max_answers do
      {:error, :rate_limited}
    else
      :ok
    end
  end

  defp process_answer(socket, user, current_kanji, current_progress, sanitized_answer) do
    is_correct = check_answer_correctness(current_kanji, sanitized_answer)
    result = if is_correct, do: :correct, else: :incorrect

    case Logic.record_review(current_progress.id, result, user.id, user) do
      {:ok, _updated_progress} ->
        current_time = System.system_time(:millisecond)
        updated_times = [current_time | socket.assigns.last_answer_times]

        results = socket.assigns[:results] || %{correct: 0, incorrect: 0}

        results =
          case result do
            :correct -> %{results | correct: results.correct + 1}
            :incorrect -> %{results | incorrect: results.incorrect + 1}
          end

        next_review_dt =
          case Logic.get_next_review_datetime(user.id, user) do
            {:ok, dt} -> dt
            _ -> nil
          end

        socket =
          socket
          |> assign(:show_feedback, true)
          |> assign(:feedback_message, get_feedback_message(result, current_kanji))
          |> assign(:feedback_type, if(is_correct, do: :success, else: :error))
          |> assign(:user_answer, "")
          |> assign(:answers_count, socket.assigns.answers_count + 1)
          |> assign(:last_answer_times, updated_times)
          |> assign(:current_kanji, current_kanji)
          |> assign(:results, results)
          |> assign(:next_review_at, next_review_dt)

        socket =
          if is_correct do
            push_event(socket, "play_audio", %{text: current_kanji.character, lang: "ja-JP"})
          else
            socket
          end

        save_session_state(socket, user.id)
        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> put_flash(:error, "Failed to record answer: #{get_error_message(reason, user)}")

        {:noreply, socket}
    end
  end

  defp load_next_kanji(socket) do
    user = socket.assigns.current_user

    case Logic.get_due_kanji(user.id, 1, user) do
      {:ok, [progress | _]} ->
        # Extract kanji from progress record
        next_kanji = progress.kanji

        # Reset quiz state for next kanji
        socket =
          socket
          |> assign(:current_kanji, next_kanji)
          # Save the progress record
          |> assign(:current_progress, progress)
          |> assign(:show_feedback, false)
          |> assign(:show_tracing, false)
          |> assign(:feedback_message, "")
          |> assign(:feedback_type, :info)
          |> assign(:feedback_details_expanded, false)
          |> assign(:user_answer, "")
          |> assign(:quiz_complete, false)

        # If stroke order panel is visible, trigger a restart of animation for the new kanji
        socket =
          if socket.assigns.show_stroke_order && next_kanji && next_kanji.character do
            Phoenix.LiveView.push_event(socket, "stroke_order_restart", %{
              kanji: next_kanji.character,
              mode: "brush"
            })
          else
            socket
          end

        # Save session state for the new kanji
        save_session_state(socket, user.id)

        {:noreply, socket}

      {:ok, []} ->
        socket =
          socket
          |> assign(:current_kanji, nil)
          |> assign(:current_progress, nil)
          |> assign(:quiz_complete, true)
          |> assign(:show_feedback, false)
          |> assign(:feedback_message, "")
          |> assign(:feedback_type, :info)
          |> assign(
            :next_review_at,
            case Logic.get_next_review_datetime(user.id, user) do
              {:ok, dt} -> dt
              _ -> nil
            end
          )

        save_session_state(socket, user.id)

        {:noreply, socket}

      {:error, reason} ->
        socket =
          socket
          |> put_flash(:error, "Failed to load next kanji: #{get_error_message(reason, user)}")
          |> assign(:quiz_error, true)

        {:noreply, socket}
    end
  end

  defp check_answer_correctness(kanji, user_answer),
    do: KumaSanKanjiWeb.Live.AnswerChecker.check_answer_correctness(kanji, user_answer)

  defp get_feedback_message(result, kanji),
    do: KumaSanKanjiWeb.Live.AnswerChecker.get_feedback_message(result, kanji)

  # Helper to get a user-friendly error message
  # Only show debug info in non-prod environments or for users with dev mode enabled
  defp get_error_message(reason, user) do
    case reason do
      :no_session_id -> "No quiz session found."
      {:exception, msg} -> "Quiz error: #{msg}"
      _ -> if dev_mode_enabled?(user), do: "Quiz Error (#{inspect(reason)})", else: "Quiz Error"
    end
  end

  defp get_validation_error_message(:empty_answer), do: "Please enter an answer"

  defp get_validation_error_message(:answer_too_long),
    do: "Answer is too long (max 100 characters)"

  defp get_validation_error_message(:invalid_characters), do: "Answer contains invalid characters"
  defp get_validation_error_message(:invalid_format), do: "Invalid answer format"

  defp format_relative_time(nil), do: "N/A"

  defp format_relative_time(%DateTime{} = dt) do
    now = DateTime.utc_now()

    if DateTime.compare(dt, now) in [:lt, :eq] do
      "Now"
    else
      diff = DateTime.diff(dt, now, :second)

      cond do
        diff < 60 ->
          "in #{diff}s"

        diff < 3600 ->
          m = div(diff, 60)
          "in #{m}m"

        diff < 86_400 ->
          h = div(diff, 3600)
          m = div(rem(diff, 3600), 60)
          if m > 0, do: "in #{h}h #{m}m", else: "in #{h}h"

        true ->
          d = div(diff, 86_400)
          "in #{d}d"
      end
    end
  end

  defp format_duration(start_time) when is_integer(start_time) do
    diff = System.system_time(:millisecond) - start_time
    seconds = div(diff, 1000)
    minutes = div(seconds, 60)
    seconds = rem(seconds, 60)

    "#{minutes}:#{String.pad_leading(Integer.to_string(seconds), 2, "0")}"
  end

  defp format_duration(_), do: "0:00"
end
