defmodule KumaSanKanjiWeb.KanjiStrokeOrderComponent do
  @moduledoc """
  Renders an (optionally animated) stroke order SVG for a given kanji character.

  Looks up a sanitized KanjiVG svg in priv/static/kanjivg using a zero-padded
  (to 5 chars) lowercase hex codepoint of the character, e.g. 水 (U+6C34) => 06c34.svg.

  Security:
  - Only serves static, pre-sanitized assets.
  - Validates single-character input (no path traversal risk).
  - Escapes alt text.

  Accessibility:
  - Adds alt/aria labels and fallback messaging.
  """
  use Phoenix.Component
  import Phoenix.HTML, only: [raw: 1]

  attr :id, :string, default: nil
  attr :kanji, :string, required: true
  attr :animate?, :boolean, default: true
  attr :class, :string, default: ""
  attr :style_mode, :string, default: "brush"
  attr :mode, :atom, default: :view, values: [:view, :trace]

  def stroke_order(assigns) do
    assigns = assign(assigns, :svg_markup, load_svg(assigns.kanji))

    ~H"""
    <div
      id={@id}
      class={[
        "stroke-order-container",
        @style_mode,
        @class,
        "flex flex-col items-center justify-center text-center"
      ]}
      data-kanji={@kanji}
      data-animate={@animate?}
      data-style={@style_mode}
      data-mode={@mode}
      phx-hook={@animate? && "KanjiStrokeOrderAnimate"}
      role="img"
      aria-label={
        if @mode == :trace,
          do: "Canvas for tracing kanji strokes",
          else: "Stroke order diagram for kanji #{@kanji}"
      }
    >
      <%= if @svg_markup do %>
        <div class="relative">
          {raw(@svg_markup)}
          <svg width="0" height="0" aria-hidden="true" class="hidden">
            <defs>
              <filter id={"ink-bleed-#{@kanji}"} x="-5%" y="-5%" width="110%" height="110%">
                <feTurbulence
                  type="fractalNoise"
                  baseFrequency="0.95"
                  numOctaves="2"
                  seed="7"
                  result="noise"
                />
                <feGaussianBlur in="SourceGraphic" stdDeviation="0.55" result="blur" />
                <feBlend in="blur" in2="noise" mode="multiply" result="ink" />
                <feMerge>
                  <feMergeNode in="ink" />
                  <feMergeNode in="SourceGraphic" />
                </feMerge>
              </filter>
            </defs>
          </svg>
          <div class="sr-only">Stroke order diagram for kanji {@kanji}</div>

          <%= if @mode == :trace do %>
            <canvas
              id={"#{@id}-canvas"}
              class="absolute top-0 left-0 w-full h-full z-10 cursor-crosshair touch-none"
              width="109"
              height="109"
              phx-hook="KanjiStrokeTracing"
              data-kanji={@kanji}
              aria-label={"Drawing area for #{@kanji}"}
            >
            </canvas>
          <% end %>
        </div>
        <div
          class="mt-2 flex gap-2 items-center justify-center text-xs"
          id={"controls-#{@kanji}"}
          phx-hook="AudioFeedback"
        >
          <button
            type="button"
            class="px-2 py-1 rounded bg-wabi-stone/20 hover:bg-wabi-stone/30"
            data-audio-text={@kanji}
            aria-label={"Pronounce #{@kanji}"}
          >
            Speak
          </button>
          <button
            type="button"
            class="px-2 py-1 rounded bg-wabi-stone/20 hover:bg-wabi-stone/30"
            phx-click="stroke_order_restart"
            phx-value-kanji={@kanji}
            phx-value-mode={@style_mode}
            aria-label="Replay stroke order"
          >
            Replay
          </button>
          <button
            type="button"
            class="px-2 py-1 rounded bg-wabi-stone/20 hover:bg-wabi-stone/30"
            phx-click="stroke_order_step"
            phx-value-kanji={@kanji}
            phx-value-mode={@style_mode}
            aria-label="Step through strokes"
          >
            Step
          </button>
          <button
            type="button"
            class="px-2 py-1 rounded bg-wabi-stone/20 hover:bg-wabi-stone/30"
            phx-click="stroke_order_toggle_style"
            phx-value-kanji={@kanji}
            aria-label="Toggle stroke style"
          >
            Toggle Style
          </button>
        </div>
      <% else %>
        <div class="p-4 text-sm text-wabi-stone/70" aria-live="polite">
          Stroke order SVG not available.
        </div>
      <% end %>
    </div>
    """
  end

  defp load_svg(kanji) when is_binary(kanji) do
    if String.length(kanji) == 1 do
      <<codepoint::utf8>> = kanji
      hex = Integer.to_string(codepoint, 16) |> String.downcase()
      padded = String.pad_leading(hex, 5, "0")
      cache_key = padded

      contents =
        case KumaSanKanji.KanjiVG.Cache.get(cache_key) do
          {:hit, svg} ->
            if String.contains?(svg, "&lt;!ATTLIST") do
              cleaned = sanitize(svg)
              KumaSanKanji.KanjiVG.Cache.put(cache_key, cleaned)
              cleaned
            else
              svg
            end

          :miss ->
            path =
              Path.join([
                Application.app_dir(:kuma_san_kanji),
                "priv",
                "static",
                "kanjivg",
                padded <> ".svg"
              ])

            if File.exists?(path) do
              case File.read(path) do
                {:ok, raw} ->
                  cleaned = sanitize(raw)
                  # inject data-ink for each stroke path to allow style variants
                  enriched = Regex.replace(~r/<path /, cleaned, "<path data-ink=\"stroke\" ")
                  KumaSanKanji.KanjiVG.Cache.put(cache_key, enriched)
                  enriched

                _ ->
                  nil
              end
            else
              nil
            end
        end

      contents
    else
      nil
    end
  end

  defp load_svg(_), do: nil

  defp sanitize(raw) when is_binary(raw) do
    raw
    |> String.replace(~r/&lt;!ATTLIST[\s\S]*?]\&gt;\r?\n?/s, "")
    |> String.replace(~r/<!ATTLIST[\s\S]*?]>\r?\n?/s, "")
  end

  defp sanitize(raw), do: raw
end
