defmodule KumaSanKanjiWeb.GroupQuizLive do
  @moduledoc "Quiz mode for a thematic group."
  use KumaSanKanjiWeb, :live_view

  alias KumaSanKanji.Content.ContentContext
  alias KumaSanKanji.SRS.{Logic, UserKanjiProgress}
  alias KumaSanKanjiWeb.Live.AnswerChecker
  import KumaSanKanjiWeb.FeatureFlagHelper, only: [learning_path_enabled?: 0]

  @impl true
  def mount(params, _session, socket) do
    unless learning_path_enabled?() do
      {:ok, redirect(socket, to: "/")}
    else
      case find_group(params["slug"]) do
        {:ok, group} ->
          mount_quiz(socket, group)

        {:error, :not_found} ->
          {:ok,
           socket
           |> put_flash(:error, "Group not found")
           |> redirect(to: ~p"/learn")}
      end
    end
  end

  defp mount_quiz(socket, group) do
    user = socket.assigns.current_user
    {:ok, all_kanji} = ContentContext.get_kanji_by_thematic_group(group.id)
    slug_or_id = group.slug || group.id

    # Build list of {kanji, progress} for learned kanji only
    quiz_pool =
      all_kanji
      |> Enum.flat_map(fn k ->
        case UserKanjiProgress.get_user_kanji_progress(user.id, k.id, actor: user) do
          {:ok, [progress | _]} -> [{k, progress}]
          _ -> []
        end
      end)
      |> Enum.shuffle()

    if quiz_pool == [] do
      {:ok,
       assign(socket,
         page_title: "#{group.name} Quiz",
         group: group,
         slug_or_id: slug_or_id,
         no_learned_kanji: true,
         quiz_complete: false
       )}
    else
      {current_kanji, current_progress} = hd(quiz_pool)

      {:ok,
       assign(socket,
         page_title: "#{group.name} Quiz",
         group: group,
         slug_or_id: slug_or_id,
         no_learned_kanji: false,
         quiz_pool: quiz_pool,
         current_index: 0,
         current_kanji: current_kanji,
         current_progress: current_progress,
         show_feedback: false,
         feedback_message: "",
         feedback_type: :info,
         results: %{correct: 0, incorrect: 0},
         quiz_complete: false
       )}
    end
  end

  @impl true
  def handle_event("submit_answer", %{"answer" => answer}, socket) do
    trimmed = String.trim(answer)

    if trimmed == "" do
      {:noreply,
       assign(socket,
         show_feedback: true,
         feedback_message: "Please enter an answer",
         feedback_type: :warning
       )}
    else
      user = socket.assigns.current_user
      kanji = socket.assigns.current_kanji
      progress = socket.assigns.current_progress

      is_correct = AnswerChecker.check_answer_correctness(kanji, trimmed)
      result = if is_correct, do: :correct, else: :incorrect

      Logic.record_review(progress.id, result, user.id, user)

      feedback = AnswerChecker.get_feedback_message(result, kanji)
      results = socket.assigns.results
      results = Map.update!(results, result, &(&1 + 1))

      {:noreply,
       assign(socket,
         show_feedback: true,
         feedback_message: feedback,
         feedback_type: if(is_correct, do: :success, else: :error),
         results: results
       )}
    end
  end

  @impl true
  def handle_event("next_kanji", _params, socket) do
    next_index = socket.assigns.current_index + 1
    pool = socket.assigns.quiz_pool

    if next_index >= length(pool) do
      {:noreply, assign(socket, quiz_complete: true, show_feedback: false)}
    else
      {next_kanji, next_progress} = Enum.at(pool, next_index)

      {:noreply,
       assign(socket,
         current_index: next_index,
         current_kanji: next_kanji,
         current_progress: next_progress,
         show_feedback: false,
         feedback_message: "",
         feedback_type: :info
       )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-3xl mx-auto px-4 py-8">
      <h1 class="section-header-wabi text-2xl mb-6">{@group.name} Quiz</h1>

      <%= if @no_learned_kanji do %>
        <div class="text-center py-12">
          <p class="info-text-wabi text-lg">Learn at least one kanji before starting the quiz.</p>
          <.link
            navigate={~p"/learn/#{@slug_or_id}/1"}
            class="btn-wabi-accent inline-block mt-4 px-6 py-3 rounded-lg"
          >
            Start with the first kanji
          </.link>
        </div>
      <% end %>

      <%= if not @no_learned_kanji and @quiz_complete do %>
        <div class="text-center py-12">
          <h2 class="text-xl font-semibold text-base-content mb-4">Quiz session complete!</h2>
          <p class="info-text-wabi">
            Correct: {@results.correct} | Incorrect: {@results.incorrect}
          </p>
          <.link
            navigate={
              ~p"/learn/#{@slug_or_id}?correct=#{@results.correct}&incorrect=#{@results.incorrect}"
            }
            class="btn-wabi-accent inline-block mt-6 px-6 py-3 rounded-lg"
          >
            Back to {@group.name}
          </.link>
        </div>
      <% end %>

      <%= if not @no_learned_kanji and not @quiz_complete do %>
        <div class="text-center mb-8">
          <div class="text-8xl font-light text-base-content">{@current_kanji.character}</div>
        </div>

        <%= if @show_feedback do %>
          <div class={"p-4 rounded-lg border mb-6 #{feedback_class(@feedback_type)}"}>
            <p>{@feedback_message}</p>
          </div>

          <button
            phx-click="next_kanji"
            class="btn-wabi-accent w-full px-6 py-3 rounded-lg font-medium"
          >
            Next
          </button>
        <% else %>
          <form phx-submit="submit_answer" class="space-y-4">
            <input
              type="text"
              name="answer"
              placeholder="Type the meaning or reading..."
              autocomplete="off"
              class="form-input-wabi px-4 py-3"
            />
            <button
              type="submit"
              class="btn-wabi-accent w-full px-6 py-3 rounded-lg font-medium"
            >
              Submit
            </button>
          </form>
        <% end %>
      <% end %>
    </div>
    """
  end

  defp feedback_class(:success), do: "bg-success/10 border-success/30 text-success"
  defp feedback_class(:warning), do: "bg-warning/10 border-warning/30 text-warning"
  defp feedback_class(_), do: "bg-error/10 border-error/30 text-error"

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
end
