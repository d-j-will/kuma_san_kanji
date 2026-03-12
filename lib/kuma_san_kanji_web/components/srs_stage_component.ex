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

  # ── helpers ──────────────────────────────────────────────────────────

  defp stage_info(stage) do
    case Stage.info(stage) do
      {:ok, info} -> info
      {:error, :invalid_stage} -> nil
    end
  end
end
