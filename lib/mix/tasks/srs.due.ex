defmodule Mix.Tasks.Srs.Due do
  @shortdoc "List due SRS items for a user"
  @moduledoc """
  Usage:
      mix srs.due --user <uuid> [--limit N] [--horizon SECONDS] [--raw] [--json]

  Prints the next due reviews (default limit 10) showing kanji id, interval, repetitions, ease factor, next review timestamp (UTC), and last result.

  Options:
    --user    UUID of the user (required)
    --limit   Max items (default 10)
  --horizon Seconds to look ahead (default 3600 if omitted)
  --raw     Output raw inspect instead of table
  --json    Output JSON array of due items
  """
  use Mix.Task

  @switches [user: :string, limit: :integer, raw: :boolean, json: :boolean, horizon: :integer]

  def run(argv) do
    Mix.Task.run("app.start")
    opts = OptionParser.parse!(argv, switches: @switches) |> elem(0)

    user_id = opts[:user] || abort!("--user <uuid> is required")
  limit = opts[:limit] || 10
  horizon_opt = opts[:horizon]
  raw? = opts[:raw] || false
  json? = opts[:json] || false

    {:ok, user_uuid} = Ecto.UUID.cast(user_id)

    # We need an actor (the user) for authorization; load or fabricate minimal struct
    user = get_user!(user_uuid)

    args =
      case horizon_opt do
        nil -> %{user_id: user_uuid, limit: limit}
        v -> %{user_id: user_uuid, limit: limit, horizon_seconds: v}
      end

    results =
      KumaSanKanji.SRS.UserKanjiProgress
      |> Ash.Query.for_read(:due_for_review, args, actor: user)
      |> Ash.read!(authorize?: true)

    cond do
      json? ->
        json_items = Enum.map(results, &to_json_map/1)
        IO.puts(Jason.encode!(json_items))
      raw? ->
      IO.inspect(results, label: "due_items")
      true ->
      render_table(results)
    end
  end

  defp get_user!(uuid) do
    KumaSanKanji.Accounts.User
    |> Ash.Query.for_read(:read, %{}, actor: nil)
    |> Ash.Query.do_filter(id: uuid)
    |> Ash.read_one!(authorize?: false)
  end

  defp render_table(items) do
    header = ["Kanji ID", "Interval", "Reps", "EF", "Next Review (UTC)", "Last Result"]
    rows =
      Enum.map(items, fn r ->
        [ short(r.kanji_id), r.interval, r.repetitions, Decimal.to_string(r.ease_factor), fmt_dt(r.next_review_date), to_string(r.last_result || :nil) ]
      end)

    widths = header |> Enum.map(&String.length/1)
    widths = adjust_widths(widths, rows)

    IO.puts(table_line(widths))
    IO.puts(row_line(header, widths))
    IO.puts(table_line(widths))
    Enum.each(rows, &IO.puts(row_line(&1, widths)))
    IO.puts(table_line(widths))
    IO.puts("Total: #{length(rows)}")
  end

  defp to_json_map(r) do
    %{
      id: r.id,
      kanji_id: r.kanji_id,
      interval: r.interval,
      repetitions: r.repetitions,
      ease_factor: Decimal.to_string(r.ease_factor),
      next_review_date: fmt_dt(r.next_review_date),
      last_result: r.last_result,
      total_reviews: r.total_reviews,
      correct_reviews: r.correct_reviews,
      first_reviewed_at: fmt_dt(r.first_reviewed_at),
      last_reviewed_at: fmt_dt(r.last_reviewed_at)
    }
  end

  defp adjust_widths(widths, rows) do
    Enum.reduce(rows, widths, fn row, acc ->
      Enum.zip(row, acc)
      |> Enum.map(fn {val, w} -> max(String.length(to_string(val)), w) end)
    end)
  end

  defp table_line(widths), do: Enum.map(widths, &String.duplicate("-", &1 + 2)) |> Enum.join("+") |> surround("+")
  defp row_line(cols, widths) do
    cols
    |> Enum.zip(widths)
    |> Enum.map(fn {val, w} -> " " <> pad(to_string(val), w) <> " " end)
    |> Enum.join("|")
    |> surround("|")
  end

  defp pad(str, w) do
    str <> String.duplicate(" ", w - String.length(str))
  end

  defp surround(str, char), do: char <> str <> char

  defp fmt_dt(nil), do: ""
  defp fmt_dt(%DateTime{} = dt), do: DateTime.to_iso8601(dt)

  defp short(nil), do: ""
  defp short(id) when is_binary(id), do: String.slice(id, 0, 8)

  defp abort!(msg) do
    Mix.shell().error(msg)
    exit({:shutdown, 1})
  end
end
