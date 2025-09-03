defmodule Mix.Tasks.Kanjivg.Ingest do
  use Mix.Task
  @shortdoc "Ingest & sanitize KanjiVG stroke order SVGs"

  @moduledoc """
  mix kanjivg.ingest [--all] [--force] [--limit N] [--source PATH] [--concurrency N] [--timeout MS]

  Examples:
    mix kanjivg.ingest                    # Only kanji present in DB
    mix kanjivg.ingest --limit 50          # First 50 DB kanji
    mix kanjivg.ingest --all --force       # Re-download all referenced (requires local source or remote)
    mix kanjivg.ingest --source ../kanjivg # Use local checkout
  """

  @switches [all: :boolean, force: :boolean, limit: :integer, source: :string, concurrency: :integer, timeout: :integer]

  def run(args) do
    Mix.Task.run("app.start")
    {opts, _rest, _invalid} = OptionParser.parse(args, switches: @switches)
    opts =
      []
      |> maybe_put(:all?, opts[:all])
      |> maybe_put(:force?, opts[:force])
      |> maybe_put(:limit, opts[:limit])
  |> maybe_put(:source_path, opts[:source])
  |> maybe_put(:concurrency, opts[:concurrency])
  |> maybe_put(:timeout, opts[:timeout])

  {:ok, %{written: w, skipped: s, errors: e}} = KumaSanKanji.KanjiVG.Ingestion.ingest(opts)
  Mix.shell().info("KanjiVG ingestion complete: written=#{w} skipped=#{s} errors=#{e}")
  end

  defp maybe_put(acc, _k, nil), do: acc
  defp maybe_put(acc, k, v), do: Keyword.put(acc, k, v)
end
