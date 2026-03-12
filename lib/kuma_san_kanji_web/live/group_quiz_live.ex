defmodule KumaSanKanjiWeb.GroupQuizLive do
  @moduledoc "Quiz mode for a thematic group."
  use KumaSanKanjiWeb, :live_view

  alias KumaSanKanji.Content.ContentContext
  alias KumaSanKanji.SRS.{Logic, UserKanjiProgress}
  alias KumaSanKanjiWeb.Live.AnswerChecker
  alias KumaSanKanjiWeb.Components.SrsStageComponent

  import KumaSanKanjiWeb.FeatureFlagHelper,
    only: [learning_path_enabled?: 0, bear_seasons_srs_enabled?: 0]

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
          {:ok, [progress | _]} ->
            # Load associations for rich feedback
            case Ash.load(k, [:meanings, :pronunciations, :example_sentences], authorize?: false) do
              {:ok, loaded_kanji} -> [{loaded_kanji, progress}]
              _ -> [{k, progress}]
            end

          _ ->
            []
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
         total_quiz_items: length(quiz_pool),
         current_index: 0,
         current_kanji: current_kanji,
         current_progress: current_progress,
         show_feedback: false,
         feedback_message: "",
         feedback_type: :info,
         last_answer: "",
         results: %{correct: 0, incorrect: 0},
         per_kanji_results: [],
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

      # Capture stage before review for transition display
      stage_before = progress.srs_stage

      Logic.record_review(progress.id, result, user.id, user)

      # Reload progress to get updated stage
      stage_after =
        case UserKanjiProgress.get_by_id(progress.id, actor: user) do
          {:ok, updated} -> updated.srs_stage
          _ -> stage_before
        end

      feedback = AnswerChecker.get_feedback_message(result, kanji)
      results = socket.assigns.results
      results = Map.update!(results, result, &(&1 + 1))

      # Track per-kanji result for summary
      kanji_result = %{
        kanji: kanji,
        result: result,
        user_answer: trimmed,
        stage_before: stage_before,
        stage_after: stage_after
      }

      per_kanji_results = socket.assigns.per_kanji_results ++ [kanji_result]

      {:noreply,
       assign(socket,
         show_feedback: true,
         feedback_message: feedback,
         feedback_type: if(is_correct, do: :success, else: :error),
         results: results,
         last_answer: trimmed,
         per_kanji_results: per_kanji_results,
         stage_before: stage_before,
         stage_after: stage_after
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
         feedback_type: :info,
         last_answer: ""
       )}
    end
  end

  @impl true
  def handle_event("review_mistakes", _params, socket) do
    # Filter quiz_pool to only incorrectly answered kanji
    incorrect_kanji_ids =
      socket.assigns.per_kanji_results
      |> Enum.filter(&(&1.result == :incorrect))
      |> Enum.map(& &1.kanji.id)
      |> MapSet.new()

    filtered_pool =
      socket.assigns.quiz_pool
      |> Enum.filter(fn {kanji, _progress} -> MapSet.member?(incorrect_kanji_ids, kanji.id) end)
      |> Enum.shuffle()

    if filtered_pool == [] do
      {:noreply, socket}
    else
      {current_kanji, current_progress} = hd(filtered_pool)

      {:noreply,
       assign(socket,
         quiz_pool: filtered_pool,
         total_quiz_items: length(filtered_pool),
         current_index: 0,
         current_kanji: current_kanji,
         current_progress: current_progress,
         show_feedback: false,
         feedback_message: "",
         feedback_type: :info,
         last_answer: "",
         results: %{correct: 0, incorrect: 0},
         per_kanji_results: [],
         quiz_complete: false
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
        <.quiz_summary
          results={@results}
          per_kanji_results={@per_kanji_results}
          group={@group}
          slug_or_id={@slug_or_id}
          total_quiz_items={@total_quiz_items}
        />
      <% end %>

      <%= if not @no_learned_kanji and not @quiz_complete do %>
        <%!-- Progress bar --%>
        <.progress_bar
          current_index={@current_index}
          total_quiz_items={@total_quiz_items}
          results={@results}
        />

        <div class="text-center mb-8">
          <div class="kanji-text text-8xl font-light text-base-content font-wabi-display">
            {@current_kanji.character}
          </div>
          <%= if bear_seasons_srs_enabled?() do %>
            <div class="mt-2">
              <SrsStageComponent.srs_stage_badge
                stage={@current_progress.srs_stage}
                size="sm"
              />
            </div>
          <% end %>
        </div>

        <%= if @show_feedback do %>
          <.feedback_card
            feedback_type={@feedback_type}
            kanji={@current_kanji}
            last_answer={@last_answer}
          />

          <%= if bear_seasons_srs_enabled?() and assigns[:stage_before] do %>
            <div class="mb-4 flex justify-center">
              <SrsStageComponent.srs_stage_transition
                from={@stage_before}
                to={@stage_after}
              />
            </div>
          <% end %>

          <button
            phx-click="next_kanji"
            phx-window-keydown="next_kanji"
            phx-key="Enter"
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
              autofocus
              class="form-input-wabi px-4 py-3 text-base"
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

  # ── Component: Progress Bar ──

  defp progress_bar(assigns) do
    display_index = assigns.current_index + 1
    pct = round(display_index / assigns.total_quiz_items * 100)
    assigns = assign(assigns, display_index: display_index, pct: pct)

    ~H"""
    <div class="mb-6">
      <div class="flex justify-between items-center mb-2">
        <span class="info-text-wabi text-sm">
          Question {@display_index} of {@total_quiz_items}
        </span>
        <span class="info-text-wabi text-sm">
          <span class="text-success">{@results.correct} correct</span>
          <span class="mx-1">|</span>
          <span class="text-error">{@results.incorrect} incorrect</span>
        </span>
      </div>
      <div class="w-full bg-base-300 rounded-full h-1">
        <div class="h-1 bg-primary rounded transition-all duration-300" style={"width: #{@pct}%"}>
        </div>
      </div>
    </div>
    """
  end

  # ── Component: Feedback Card ──

  defp feedback_card(assigns) do
    kanji = assigns.kanji
    meanings = kanji.meanings |> Enum.map(& &1.value) |> Enum.join(", ")

    on_readings =
      kanji.pronunciations
      |> Enum.filter(&(to_string(&1.type) == "on"))
      |> Enum.map(& &1.value)
      |> Enum.join(", ")

    kun_readings =
      kanji.pronunciations
      |> Enum.filter(&(to_string(&1.type) == "kun"))
      |> Enum.map(& &1.value)
      |> Enum.join(", ")

    example =
      case kanji.example_sentences do
        [sentence | _] -> sentence
        _ -> nil
      end

    is_correct = assigns.feedback_type == :success

    assigns =
      assign(assigns,
        meanings: meanings,
        on_readings: on_readings,
        kun_readings: kun_readings,
        example: example,
        is_correct: is_correct
      )

    ~H"""
    <div class={[
      "p-5 rounded-lg border-2 mb-6",
      if(@is_correct,
        do: "bg-success/10 border-success/30",
        else: "bg-error/10 border-error/30"
      )
    ]}>
      <div class="flex items-center gap-2 mb-3">
        <%= if @is_correct do %>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-6 w-6 text-success"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7" />
          </svg>
          <span class="text-success font-semibold text-lg">Correct!</span>
        <% else %>
          <svg
            xmlns="http://www.w3.org/2000/svg"
            class="h-6 w-6 text-error"
            fill="none"
            viewBox="0 0 24 24"
            stroke="currentColor"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              stroke-width="2"
              d="M6 18L18 6M6 6l12 12"
            />
          </svg>
          <span class="text-error font-semibold text-lg">Incorrect</span>
        <% end %>
      </div>

      <%= unless @is_correct do %>
        <div class="mb-3">
          <span class="info-text-wabi text-sm">Your answer:</span>
          <span class="text-base-content font-medium ml-1">{@last_answer}</span>
        </div>
      <% end %>

      <div class="space-y-2">
        <div>
          <span class="info-text-wabi text-sm font-medium">Character:</span>
          <span class="kanji-text text-2xl ml-2 font-wabi-display">{@kanji.character}</span>
        </div>
        <div>
          <span class="info-text-wabi text-sm font-medium">Meanings:</span>
          <span class="text-base-content ml-1">{@meanings}</span>
        </div>
        <%= if @on_readings != "" do %>
          <div>
            <span class="info-text-wabi text-sm font-medium">On'yomi:</span>
            <span class="text-base-content ml-1">{@on_readings}</span>
          </div>
        <% end %>
        <%= if @kun_readings != "" do %>
          <div>
            <span class="info-text-wabi text-sm font-medium">Kun'yomi:</span>
            <span class="text-base-content ml-1">{@kun_readings}</span>
          </div>
        <% end %>
        <%= if @example do %>
          <div class="mt-3 pt-3 border-t border-base-300">
            <span class="info-text-wabi text-sm font-medium">Example:</span>
            <p class="text-base-content mt-1">{@example.japanese}</p>
            <p class="info-text-wabi text-sm">{@example.translation}</p>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  # ── Component: Quiz Summary ──

  defp quiz_summary(assigns) do
    total = assigns.results.correct + assigns.results.incorrect
    accuracy = if total > 0, do: round(assigns.results.correct / total * 100), else: 0

    encouragement =
      cond do
        accuracy > 90 -> "Excellent!"
        accuracy > 70 -> "Good job!"
        true -> "Keep practicing!"
      end

    has_mistakes =
      Enum.any?(assigns.per_kanji_results, &(&1.result == :incorrect))

    assigns =
      assign(assigns,
        total: total,
        accuracy: accuracy,
        encouragement: encouragement,
        has_mistakes: has_mistakes
      )

    ~H"""
    <div class="text-center py-8">
      <h2 class="text-xl font-semibold text-base-content mb-2">Quiz Complete!</h2>
      <p class="text-4xl font-bold text-primary mb-2">{@accuracy}%</p>
      <p class="text-lg info-text-wabi mb-6">{@encouragement}</p>

      <div class="flex justify-center gap-8 mb-8">
        <div class="text-center">
          <p class="text-3xl font-bold text-success">{@results.correct}</p>
          <p class="info-text-wabi text-sm">Correct</p>
        </div>
        <div class="text-center">
          <p class="text-3xl font-bold text-error">{@results.incorrect}</p>
          <p class="info-text-wabi text-sm">Incorrect</p>
        </div>
        <div class="text-center">
          <p class="text-3xl font-bold text-base-content">{@total}</p>
          <p class="info-text-wabi text-sm">Total</p>
        </div>
      </div>

      <%!-- Per-kanji breakdown --%>
      <%= if @per_kanji_results != [] do %>
        <div class="mb-8">
          <h3 class="info-text-wabi text-sm font-medium mb-3 text-left">Results Breakdown</h3>
          <div class="overflow-x-auto">
            <table class="table table-sm w-full">
              <thead>
                <tr class="info-text-wabi text-xs">
                  <th>Kanji</th>
                  <th>Your Answer</th>
                  <th>Correct Answer</th>
                  <th>Result</th>
                  <%= if bear_seasons_srs_enabled?() do %>
                    <th>Stage</th>
                  <% end %>
                </tr>
              </thead>
              <tbody>
                <%= for item <- @per_kanji_results do %>
                  <tr class={[
                    "border-b border-base-300",
                    if(item.result == :correct, do: "bg-success/5", else: "bg-error/5")
                  ]}>
                    <td class="kanji-text text-xl font-wabi-display">{item.kanji.character}</td>
                    <td class="text-base-content">{item.user_answer}</td>
                    <td class="text-base-content">
                      {item.kanji.meanings |> Enum.map(& &1.value) |> Enum.join(", ")}
                    </td>
                    <td>
                      <%= if item.result == :correct do %>
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          class="h-5 w-5 text-success inline"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M5 13l4 4L19 7"
                          />
                        </svg>
                      <% else %>
                        <svg
                          xmlns="http://www.w3.org/2000/svg"
                          class="h-5 w-5 text-error inline"
                          fill="none"
                          viewBox="0 0 24 24"
                          stroke="currentColor"
                        >
                          <path
                            stroke-linecap="round"
                            stroke-linejoin="round"
                            stroke-width="2"
                            d="M6 18L18 6M6 6l12 12"
                          />
                        </svg>
                      <% end %>
                    </td>
                    <%= if bear_seasons_srs_enabled?() do %>
                      <td>
                        <SrsStageComponent.srs_stage_transition
                          from={item.stage_before}
                          to={item.stage_after}
                        />
                      </td>
                    <% end %>
                  </tr>
                <% end %>
              </tbody>
            </table>
          </div>
        </div>
      <% end %>

      <%!-- Action buttons --%>
      <div class="flex flex-col sm:flex-row gap-3 justify-center">
        <%= if @has_mistakes do %>
          <button
            phx-click="review_mistakes"
            class="btn-wabi-accent px-6 py-3 rounded-lg font-medium"
          >
            Review Mistakes
          </button>
        <% end %>
        <.link
          navigate={
            ~p"/learn/#{@slug_or_id}?correct=#{@results.correct}&incorrect=#{@results.incorrect}"
          }
          class="btn-wabi-accent px-6 py-3 rounded-lg font-medium inline-block"
        >
          Back to {@group.name}
        </.link>
        <.link
          navigate={~p"/learn/#{@slug_or_id}/1"}
          class="btn-wabi-accent px-6 py-3 rounded-lg font-medium inline-block"
        >
          Continue Learning
        </.link>
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
end
