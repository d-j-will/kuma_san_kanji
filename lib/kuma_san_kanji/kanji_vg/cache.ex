defmodule KumaSanKanji.KanjiVG.Cache do
  @moduledoc "In-memory ETS cache for sanitized KanjiVG SVG markup." 
  use GenServer

  @table :kanjivg_svg_cache
  @expiry_ms :timer.hours(12)

  def start_link(_opts), do: GenServer.start_link(__MODULE__, %{}, name: __MODULE__)

  def get(hex) when is_binary(hex) do
    case :ets.lookup(@table, hex) do
      [{^hex, svg, ts}] ->
        if System.monotonic_time(:millisecond) - ts < @expiry_ms do
          {:hit, svg}
        else
          :ets.delete(@table, hex)
          :miss
        end
      _ -> :miss
    end
  end

  def put(hex, svg) when is_binary(hex) and is_binary(svg) do
    true = :ets.insert(@table, {hex, svg, System.monotonic_time(:millisecond)})
    :ok
  end

  @impl true
  def init(_) do
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true, write_concurrency: true])
    {:ok, %{}}
  end
end
