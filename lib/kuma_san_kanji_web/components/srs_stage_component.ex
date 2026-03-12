defmodule KumaSanKanjiWeb.Components.SrsStageComponent do
  @moduledoc """
  Phoenix components for displaying SRS stage badges and pipeline summaries.

  Uses the Bear Seasons theme from `KumaSanKanji.SRS.Stage` to render
  colored badges, a horizontal pipeline bar, and stage transition displays.

  ## Components

  - `srs_stage_badge/1` — single stage badge/pill
  - `srs_stage_pipeline/1` — horizontal pipeline bar with group counts
  - `srs_stage_transition/1` — stage transition display (for quiz results)
  """
  use Phoenix.Component

  alias KumaSanKanji.SRS.Stage

  # ── srs_stage_badge ──────────────────────────────────────────────────

  @doc """
  Renders a colored badge/pill for a single SRS stage.

  ## Examples

      <.srs_stage_badge stage={5} />
      <.srs_stage_badge stage={1} size="sm" />
  """
  attr :stage, :integer, required: true
  attr :size, :string, default: "md", values: ["sm", "md"]

  def srs_stage_badge(assigns) do
    assigns = assign(assigns, :stage_info, stage_info(assigns.stage))

    ~H"""
    <span
      :if={@stage_info}
      class={badge_classes(@size)}
      style={badge_style(@stage_info.color)}
      title={"Stage #{@stage}: #{@stage_info.label}"}
    >
      <span class="font-medium">{@stage_info.japanese}</span>
      <span>{@stage_info.label}</span>
    </span>
    """
  end

  defp badge_classes("sm"), do: "inline-flex items-center gap-1 px-1.5 py-0.5 rounded text-xs"
  defp badge_classes("md"), do: "inline-flex items-center gap-1.5 px-2.5 py-1 rounded-md text-sm"

  defp badge_style(color) do
    "background-color: #{color}20; color: #{color}; border: 1px solid #{color}40;"
  end

  # ── srs_stage_pipeline ───────────────────────────────────────────────

  @doc """
  Renders a horizontal pipeline bar showing counts per SRS group.

  ## Examples

      <.srs_stage_pipeline stages={%{mezame: 12, sakari: 5, minori: 3, chikara: 1, tomin: 8}} />
  """
  attr :stages, :map, required: true

  def srs_stage_pipeline(assigns) do
    segments =
      Enum.map(Stage.groups(), fn group ->
        count = Map.get(assigns.stages, group, 0)
        color = Stage.group_color(group)
        japanese = Stage.group_japanese(group)
        %{group: group, count: count, color: color, japanese: japanese}
      end)

    total = Enum.reduce(segments, 0, fn seg, acc -> acc + seg.count end)

    assigns =
      assigns
      |> assign(:segments, segments)
      |> assign(:total, total)

    ~H"""
    <div class="flex flex-col gap-1">
      <div class="flex flex-col md:flex-row gap-0.5 rounded-lg overflow-hidden">
        <div
          :for={seg <- @segments}
          class={[
            "flex items-center justify-center gap-1 px-3 py-2 min-w-0 flex-1 transition-opacity",
            seg.count == 0 && "opacity-30"
          ]}
          style={pipeline_segment_style(seg.color)}
        >
          <span class="font-medium text-sm whitespace-nowrap">{seg.japanese}</span>
          <span class="text-sm font-bold">{seg.count}</span>
        </div>
      </div>
      <div class="text-xs text-base-content/60 text-right tabular-nums">
        Total: {@total}
      </div>
    </div>
    """
  end

  defp pipeline_segment_style(color) do
    "background-color: #{color}; color: #fff;"
  end

  # ── srs_stage_transition ─────────────────────────────────────────────

  @doc """
  Renders a stage transition display showing movement between stages.

  Used in quiz result screens to show stage changes.

  ## Examples

      <.srs_stage_transition from={3} to={4} />
      <.srs_stage_transition from={5} to={3} />
  """
  attr :from, :integer, required: true
  attr :to, :integer, required: true

  def srs_stage_transition(assigns) do
    from_info = stage_info(assigns.from)
    to_info = stage_info(assigns.to)
    direction = transition_direction(assigns.from, assigns.to)

    assigns =
      assigns
      |> assign(:from_info, from_info)
      |> assign(:to_info, to_info)
      |> assign(:direction, direction)
      |> assign(:same?, assigns.from == assigns.to)

    ~H"""
    <div :if={@from_info && @to_info} class="inline-flex items-center gap-2 text-sm">
      <%= if @same? do %>
        <span style={badge_style(@from_info.color)} class={badge_classes("md")}>
          <span class="font-medium">{@from_info.japanese}</span>
          <span>{@from_info.label}</span>
        </span>
      <% else %>
        <span style={badge_style(@from_info.color)} class={badge_classes("md")}>
          <span class="font-medium">{@from_info.japanese}</span>
          <span>{@from_info.label}</span>
        </span>
        <span class={transition_arrow_classes(@direction)} aria-label={arrow_label(@direction)}>
          →
        </span>
        <span style={badge_style(@to_info.color)} class={badge_classes("md")}>
          <span class="font-medium">{@to_info.japanese}</span>
          <span>{@to_info.label}</span>
        </span>
      <% end %>
    </div>
    """
  end

  defp transition_direction(from, to) when to > from, do: :up
  defp transition_direction(from, to) when to < from, do: :down
  defp transition_direction(_, _), do: :same

  defp transition_arrow_classes(:up), do: "text-green-500 font-bold text-lg"
  defp transition_arrow_classes(:down), do: "text-red-500 font-bold text-lg"
  defp transition_arrow_classes(:same), do: "text-base-content/50 font-bold text-lg"

  defp arrow_label(:up), do: "promoted to"
  defp arrow_label(:down), do: "demoted to"
  defp arrow_label(:same), do: "stayed at"

  # ── srs_stage_guide ──────────────────────────────────────────────────

  @doc """
  Renders the Bear Seasons SRS guide as a collapsible accordion.

  Uses `<details>/<summary>` for progressive disclosure (matches mobile UX
  architecture ADR-003). All content is data-driven from the Stage module.
  DaisyUI 4.x `collapse` component uses native `<details>` internally.

  ## Examples

      <.srs_stage_guide />
  """

  @shu_ha_ri %{
    mezame: %{phase: "守 Shu", meaning: "Follow the pattern"},
    sakari: %{phase: "破 Ha", meaning: "Break from rote memory"},
    minori: %{phase: "破→離", meaning: "Transition to mastery"},
    chikara: %{phase: "離 Ri", meaning: "Transcend — the kanji is part of you"},
    tomin: %{phase: "Beyond 離", meaning: "Knowledge rests deep and safe"}
  }

  @season_narratives %{
    mezame:
      "The bear stirs — spring has come. You've just encountered this kanji. Reviews come frequently to build the initial neural pathway.",
    sakari:
      "Summer — the bear roams freely. You know this kanji well enough to recall it without hints. Reviews space out to weekly.",
    minori:
      "Autumn — the fruit is ripe. You can recall this kanji without effort. One review at the 1-month mark confirms it's truly rooted.",
    chikara:
      "The bear is fully nourished, ready for winter. One final review after 4 months. If you still remember, the knowledge is permanent.",
    tomin:
      "The bear sleeps. The knowledge rests deep and safe. No more reviews — but it can always be awakened again."
  }

  def srs_stage_guide(assigns) do
    groups =
      Enum.map(Stage.groups(), fn group ->
        {:ok, stage_numbers} = Stage.stages_for_group(group)
        color = Stage.group_color(group)
        japanese = Stage.group_japanese(group)
        english = Stage.group_english(group)

        stages =
          Enum.map(stage_numbers, fn num ->
            {:ok, info} = Stage.info(num)
            {:ok, human} = Stage.human_interval(num)
            Map.put(info, :human_interval, human)
          end)

        %{
          group: group,
          color: color,
          japanese: japanese,
          english: english,
          stages: stages,
          shu_ha_ri: Map.fetch!(@shu_ha_ri, group),
          narrative: Map.fetch!(@season_narratives, group)
        }
      end)

    assigns = assign(assigns, :groups, groups)

    ~H"""
    <details class="collapse collapse-arrow bg-base-200 rounded-lg">
      <summary class="collapse-title text-lg font-wabi-display cursor-pointer">
        <span class="flex items-center gap-2">
          <span>How SRS Works — Bear Seasons</span>
        </span>
      </summary>
      <div class="collapse-content">
        <p class="text-sm text-base-content/70 mb-4">
          Kuma San Kanji uses a spaced repetition system inspired by a bear's journey
          through the seasons. Each kanji progresses through 9 stages across 5 seasons,
          with increasing review intervals.
        </p>

        <div class="flex flex-col gap-3">
          <.guide_season_card :for={g <- @groups} group={g} />
        </div>

        <div class="mt-4 p-3 bg-base-300 rounded-lg">
          <h4 class="font-medium text-sm text-base-content mb-1">Incorrect answers</h4>
          <p class="text-xs text-base-content/70">
            Getting an answer wrong drops your stage back. Early stages (Mezame) drop by 1.
            Later stages (Sakari and above) drop by 2 — the further you've climbed, the more
            you fall. But you can never drop below stage 1.
          </p>
        </div>
      </div>
    </details>
    """
  end

  attr :group, :map, required: true

  defp guide_season_card(assigns) do
    ~H"""
    <div class="rounded-lg p-3 border" style={"border-color: #{@group.color}40;"}>
      <div class="flex items-center gap-2 mb-1">
        <span
          class="inline-block w-3 h-3 rounded-full"
          style={"background-color: #{@group.color};"}
        />
        <span class="font-medium text-base-content">
          {@group.japanese} <span class="text-base-content/60">{@group.english}</span>
        </span>
        <span class="ml-auto text-xs text-base-content/50">{@group.shu_ha_ri.phase}</span>
      </div>

      <p class="text-xs text-base-content/70 mb-2">{@group.narrative}</p>

      <div class="flex flex-wrap gap-1">
        <span
          :for={stage <- @group.stages}
          class="inline-flex items-center gap-1 px-2 py-0.5 rounded text-xs"
          style={"background-color: #{stage.color}20; color: #{stage.color}; border: 1px solid #{stage.color}40;"}
        >
          {stage.label} · {stage.human_interval}
        </span>
      </div>
    </div>
    """
  end

  # ── srs_kanji_card_badge ───────────────────────────────────────────

  @doc """
  Renders a compact SRS stage label with review timing for kanji grid cards.

  Shows the stage label (e.g., "Awakening I"), the stage color, and a
  relative review time ("Due now", "2h", "5d") or "Mastered" for stage 9.

  Renders nothing when `progress` is nil (unstarted kanji).
  """
  attr :progress, :map, default: nil

  def srs_kanji_card_badge(%{progress: nil} = assigns) do
    ~H""
  end

  def srs_kanji_card_badge(assigns) do
    info = stage_info(assigns.progress.srs_stage)
    review_label = format_review_time(assigns.progress)

    assigns =
      assigns
      |> assign(:info, info)
      |> assign(:review_label, review_label)

    ~H"""
    <div :if={@info} class="flex flex-col items-center gap-0.5">
      <span
        class="text-xs font-medium px-1.5 py-0.5 rounded"
        style={"background-color: #{@info.color}20; color: #{@info.color};"}
      >
        {@info.label}
      </span>
      <span class="text-xs text-base-content/50">{@review_label}</span>
    </div>
    """
  end

  defp format_review_time(%{srs_stage: 9}), do: "Mastered"

  defp format_review_time(%{next_review_date: nil}), do: ""

  defp format_review_time(%{next_review_date: dt}) do
    now = DateTime.utc_now()

    case DateTime.compare(dt, now) do
      :lt -> "Due now"
      :eq -> "Due now"
      :gt -> format_relative_duration(DateTime.diff(dt, now, :second))
    end
  end

  defp format_relative_duration(seconds) when seconds < 60, do: "<1m"

  defp format_relative_duration(seconds) when seconds < 3600 do
    "#{div(seconds, 60)}m"
  end

  defp format_relative_duration(seconds) when seconds < 86_400 do
    "#{div(seconds, 3600)}h"
  end

  defp format_relative_duration(seconds) when seconds < 604_800 do
    "#{div(seconds, 86_400)}d"
  end

  defp format_relative_duration(seconds) do
    "#{div(seconds, 604_800)}w"
  end

  # ── helpers ──────────────────────────────────────────────────────────

  defp stage_info(stage) do
    case Stage.info(stage) do
      {:ok, info} -> info
      {:error, :invalid_stage} -> nil
    end
  end
end
