defmodule KumaSanKanjiWeb.RadicalLive do
  use KumaSanKanjiWeb, :live_view
  alias KumaSanKanji.Domain
  require Ash.Query

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    kangxi_index = parse_int(id)
    radical = if kangxi_index, do: Domain.get_radical_by_kangxi_index!(kangxi_index), else: nil

    radical =
      if radical do
        # Limit to first 50 kanji using this radical for performance
        kanji_query =
          KumaSanKanji.Kanji.Kanji
          |> Ash.Query.sort(character: :asc)
          |> Ash.Query.limit(50)
          |> Ash.Query.select([:id, :character, :grade, :stroke_count, :jlpt_level])

        Ash.load!(radical, kanjis: kanji_query)
      else
        radical
      end

    {:ok, assign(socket, radical: radical)}
  end

  defp parse_int(val) when is_binary(val) do
    case Integer.parse(val) do
      {i, ""} -> i
      _ -> nil
    end
  end

  defp parse_int(_), do: nil

  @impl true
  def render(assigns) do
    ~H"""
    <div class="px-4 py-10 sm:px-6 sm:py-16 lg:px-8">
      <div class="mx-auto max-w-2xl">
        <h1 class="text-3xl font-wabi-display mb-6 text-wabi-hok_blue_dark">Radical Details</h1>
        <%= if @radical do %>
          <div class="wabi-paper wabi-texture border border-wabi-border rounded p-6">
            <div class="flex items-start gap-6">
              <div class="flex items-center justify-center w-24 h-24 rounded bg-wabi-paper text-5xl font-wabi">
                {@radical.glyph}
              </div>
              <div class="flex-1">
                <h2 class="text-2xl font-wabi-display mb-2">{@radical.meaning}</h2>
                <p class="text-sm wabi-text mb-2">Kangxi # {@radical.kangxi_index} • Strokes: {@radical.stroke_count}</p>
                <p :if={@radical.japanese_name} class="text-sm wabi-text mb-2">Japanese: {@radical.japanese_name}</p>
                <p :if={@radical.alt_forms != []} class="text-xs wabi-text mb-2">Alt Forms: {Enum.join(@radical.alt_forms, ", ")}</p>
                <p :if={@radical.mnemonic} class="text-xs italic wabi-text mb-2">{@radical.mnemonic}</p>
                <p :if={@radical.notes} class="text-xs wabi-text mb-2">{@radical.notes}</p>
                <p :if={@radical.high_yield} class="inline-block text-xs font-semibold px-2 py-1 bg-wabi-hok_blue/10 border border-wabi-hok_blue rounded text-wabi-hok_blue_dark">High Yield</p>
              </div>
            </div>
            <div :if={@radical.kanjis != []} class="mt-8">
              <h3 class="text-xl font-wabi-display mb-3 text-wabi-indigo">Kanji Using This Radical (showing up to 50)</h3>
              <div class="flex flex-wrap gap-2">
                <%= for k <- @radical.kanjis do %>
                  <span class="inline-flex items-center justify-center w-12 h-12 text-2xl font-wabi rounded bg-wabi-paper-aged border border-wabi-border">
                    {k.character}
                  </span>
                <% end %>
              </div>
            </div>
          </div>
        <% else %>
          <div class="wabi-paper wabi-texture border border-wabi-border rounded p-6">
            <p class="wabi-text">Radical not found.</p>
          </div>
        <% end %>
        <div class="mt-6">
          <.link navigate={~p"/explore"} class="text-wabi-accent underline">Back to Explore</.link>
        </div>
      </div>
    </div>
    """
  end
end
