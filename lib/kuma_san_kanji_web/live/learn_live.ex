defmodule KumaSanKanjiWeb.LearnLive do
  @moduledoc "Learning path overview - lists thematic groups for Grade 1."
  use KumaSanKanjiWeb, :live_view

  alias KumaSanKanji.Content.ContentContext
  alias KumaSanKanji.SRS.{Stage, UserKanjiProgress}
  alias KumaSanKanjiWeb.Components.SrsStageComponent

  import KumaSanKanjiWeb.FeatureFlagHelper,
    only: [learning_path_enabled?: 0, bear_seasons_srs_enabled?: 0]

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

      values = Map.values(progress_map)
      total_learned = values |> Enum.map(& &1.learned) |> Enum.sum()
      total_kanji = values |> Enum.map(& &1.total) |> Enum.sum()

      reviews_due = reviews_due_count(user.id, user)
      streak = study_streak(user.id, user)

      stage_counts =
        if bear_seasons_srs_enabled?() do
          compute_stage_counts(user.id, user)
        else
          nil
        end

      {:ok,
       assign(socket,
         page_title: "Learn",
         groups: groups,
         progress_map: progress_map,
         total_learned: total_learned,
         total_kanji: total_kanji,
         reviews_due: reviews_due,
         study_streak: streak,
         stage_counts: stage_counts
       )}
    end
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 py-8">
      <div class="mb-8">
        <h1 class="text-3xl font-wabi-display tracking-tight text-base-content sm:text-4xl">Learn</h1>
        <p class="mt-2 info-text-wabi">
          {@total_learned} of {@total_kanji} kanji learned
        </p>

        <%!-- Overall progress bar --%>
        <div class="mt-4">
          <div class="w-full bg-base-300 rounded-full h-3">
            <div
              class="bg-primary h-3 rounded-full transition-all duration-500"
              style={"width: #{progress_percent(@total_learned, @total_kanji)}%"}
            >
            </div>
          </div>
        </div>

        <%!-- Stats row: reviews due + study streak --%>
        <div class="mt-4 flex flex-wrap gap-6">
          <div class="flex items-center gap-2">
            <span class="text-2xl font-wabi-display text-base-content">{@reviews_due}</span>
            <span class="text-sm text-base-content/60">
              {if @reviews_due == 1, do: "review", else: "reviews"} due
            </span>
            <%= if @reviews_due > 0 do %>
              <.link
                navigate={~p"/quiz"}
                class="ml-1 text-sm font-medium text-primary hover:underline"
              >
                Start Review
              </.link>
            <% end %>
          </div>

          <div class="flex items-center gap-2">
            <span class="text-2xl font-wabi-display text-base-content">{@study_streak}</span>
            <span class="text-sm text-base-content/60">
              day {if @study_streak == 1, do: "streak", else: "streak"}
            </span>
          </div>
        </div>

        <%= if bear_seasons_srs_enabled?() and @stage_counts do %>
          <div class="mt-6">
            <h2 class="text-lg font-wabi-display text-base-content mb-3">SRS Progress</h2>
            <SrsStageComponent.srs_stage_pipeline stages={@stage_counts} />
          </div>
          <div class="mt-4">
            <SrsStageComponent.srs_stage_guide />
          </div>
        <% end %>
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
    assigns = assign(assigns, :border_class, group_border_class(assigns.progress))

    ~H"""
    <.link
      navigate={~p"/learn/#{@group.slug || @group.id}"}
      class={"card-wabi block p-6 hover:shadow-lg transition-shadow border-2 #{@border_class}"}
    >
      <h2 class="text-xl font-wabi-display text-base-content">{@group.name}</h2>
      <p class="mt-1 text-sm text-base-content/60">{@progress.total} kanji</p>

      <%!-- Mini progress bar --%>
      <div class="mt-3">
        <div class="w-full bg-base-300 rounded-full h-2">
          <div
            class={"#{mini_bar_color(@progress)} h-2 rounded-full transition-all duration-500"}
            style={"width: #{progress_percent(@progress.learned, @progress.total)}%"}
          >
          </div>
        </div>
      </div>

      <div class="mt-2">
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

  # ---------- Helpers ----------

  defp progress_percent(_learned, 0), do: 0

  defp progress_percent(learned, total) do
    Float.round(learned / total * 100, 1)
  end

  defp group_border_class(%{learned: 0}), do: "border-base-300"

  defp group_border_class(%{learned: learned, total: total}) when learned == total and total > 0,
    do: "border-success"

  defp group_border_class(_), do: "border-primary"

  defp mini_bar_color(%{learned: learned, total: total}) when learned == total and total > 0,
    do: "bg-success"

  defp mini_bar_color(_), do: "bg-primary"

  # ---------- SRS queries ----------

  defp compute_stage_counts(user_id, actor) do
    case UserKanjiProgress.user_stats(user_id, actor: actor) do
      {:ok, records} ->
        Enum.reduce(Stage.groups(), %{}, fn group, acc ->
          {:ok, stage_numbers} = Stage.stages_for_group(group)
          count = Enum.count(records, fn r -> r.srs_stage in stage_numbers end)
          Map.put(acc, group, count)
        end)

      _ ->
        %{mezame: 0, sakari: 0, minori: 0, chikara: 0, tomin: 0}
    end
  end

  defp reviews_due_count(user_id, actor) do
    case UserKanjiProgress.due_for_review(user_id, %{horizon_seconds: 0, limit: 500},
           actor: actor
         ) do
      {:ok, records} -> length(records)
      _ -> 0
    end
  end

  defp study_streak(user_id, actor) do
    case UserKanjiProgress.user_stats(user_id, actor: actor) do
      {:ok, records} -> calculate_streak(records)
      _ -> 0
    end
  end

  defp calculate_streak(records) do
    today = Date.utc_today()

    review_dates =
      records
      |> Enum.map(& &1.last_reviewed_at)
      |> Enum.reject(&is_nil/1)
      |> Enum.map(fn dt -> DateTime.to_date(dt) end)
      |> Enum.uniq()
      |> Enum.sort(:desc)

    count_consecutive_days(review_dates, today, 0)
  end

  defp count_consecutive_days([], _expected, count), do: count

  defp count_consecutive_days([date | rest], expected, count) do
    cond do
      Date.compare(date, expected) == :eq ->
        count_consecutive_days(rest, Date.add(expected, -1), count + 1)

      # Allow streak to start from yesterday if no review today yet
      count == 0 and Date.compare(date, Date.add(expected, -1)) == :eq ->
        count_consecutive_days(rest, Date.add(expected, -2), 1)

      true ->
        count
    end
  end
end
