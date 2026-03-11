defmodule Mix.Tasks.Srs.Run do
  @shortdoc "Process due SRS reviews (simulate or interactive)"
  @moduledoc """
  Runs pending SRS reviews for a user.

  Usage:
  mix srs.run --user <uuid> [--limit N] [--horizon SECONDS] [--mode random|all-correct|all-incorrect|interactive] [--json]

  Options:
    --user        User UUID (required)
    --limit       Max due items to process (default 10)
  --horizon     Seconds to look ahead and include near-due items (default 0)
  --mode        Processing mode (default: random)
  --json        Output JSON only (suppress per-row lines)
                  random        - random :correct/:incorrect (80/20) with occasional :skip
                  all-correct   - mark all as correct
                  all-incorrect - mark all as incorrect
                  interactive   - prompt per item (c/i/s to record)

  Output shows before/after interval, repetitions, ease factor.
  """
  use Mix.Task
  @switches [user: :string, limit: :integer, mode: :string, horizon: :integer, json: :boolean]
  @default_limit 10

  alias KumaSanKanji.SRS.UserKanjiProgress
  alias Ash.Query

  def run(argv) do
    Mix.Task.run("app.start")
    opts = OptionParser.parse!(argv, switches: @switches) |> elem(0)

    user_id = opts[:user] || abort!("--user <uuid> is required")
    limit = opts[:limit] || @default_limit
    horizon_opt = opts[:horizon]
    mode = opts[:mode] || "random"
    json? = opts[:json] || false

    {:ok, uuid} = Ecto.UUID.cast(user_id)
    user = get_user!(uuid)

    due = fetch_due(uuid, limit, horizon_opt, user)

    if due == [] do
      Mix.shell().info("No due items.")
      :ok
    else
      unless json?, do: Mix.shell().info("Processing #{length(due)} due items (mode=#{mode})\n")

      {processed, stats} =
        Enum.map_reduce(due, init_stats(), fn item, acc ->
          {result, acc2} = decide_result(mode, acc, item)
          before = snapshot(item)
          updated = apply_result(item, result, user)
          after_ = snapshot(updated)
          unless json?, do: print_row(before, after_, result)

          {Map.merge(updated, %{__before__: before, __result__: result}),
           update_stats(acc2, result)}
        end)

      if json? do
        output = %{
          summary: stats,
          items: Enum.map(processed, &json_item/1)
        }

        IO.puts(Jason.encode!(output))
      else
        print_summary(stats)
      end

      :ok
    end
  end

  defp fetch_due(user_id, limit, nil, actor) do
    UserKanjiProgress
    |> Query.for_read(:due_for_review, %{user_id: user_id, limit: limit}, actor: actor)
    |> Ash.read!(authorize?: true)
  end

  defp fetch_due(user_id, limit, horizon, actor) when is_integer(horizon) do
    UserKanjiProgress
    |> Query.for_read(
      :due_for_review,
      %{user_id: user_id, limit: limit, horizon_seconds: horizon}, actor: actor)
    |> Ash.read!(authorize?: true)
  end

  defp apply_result(progress, result, actor) do
    # Use code interface function generated for :record_review
    UserKanjiProgress.record_review!(progress, %{last_result: result}, actor: actor)
  end

  defp decide_result("all-correct", stats, _item), do: {:correct, stats}
  defp decide_result("all-incorrect", stats, _item), do: {:incorrect, stats}

  defp decide_result("interactive", stats, item) do
    prompt = "Result for kanji #{short(item.kanji_id)} (c=correct i=incorrect s=skip) > "

    case IO.gets(prompt) |> to_string() |> String.trim() do
      "c" -> {:correct, stats}
      "i" -> {:incorrect, stats}
      "s" -> {:skip, stats}
      _ -> decide_result("interactive", stats, item)
    end
  end

  defp decide_result(_random, stats, _item) do
    # random: 80% correct, 15% incorrect, 5% skip
    r = :rand.uniform()

    cond do
      r < 0.80 -> {:correct, stats}
      r < 0.95 -> {:incorrect, stats}
      true -> {:skip, stats}
    end
  end

  defp snapshot(p) do
    %{
      id: p.id,
      interval: p.interval,
      reps: p.repetitions,
      ef: p.ease_factor,
      next: p.next_review_date
    }
  end

  defp json_item(p) do
    before = Map.get(p, :__before__)

    %{
      id: p.id,
      kanji_id: p.kanji_id,
      result: Map.get(p, :__result__),
      before: %{
        interval: before.interval,
        repetitions: before.reps,
        ease_factor: Decimal.to_string(before.ef),
        next_review_date: fmt_dt(before.next)
      },
      after: %{
        interval: p.interval,
        repetitions: p.repetitions,
        ease_factor: Decimal.to_string(p.ease_factor),
        next_review_date: fmt_dt(p.next_review_date)
      }
    }
  end

  defp print_row(before, after_snapshot, result) do
    IO.puts(
      Enum.join(
        [
          short(before.id || ""),
          to_string(result),
          "i: #{before.interval} -> #{after_snapshot.interval}",
          "r: #{before.reps} -> #{after_snapshot.reps}",
          "ef: #{Decimal.to_string(before.ef)} -> #{Decimal.to_string(after_snapshot.ef)}",
          "next: #{fmt_dt(after_snapshot.next)}"
        ],
        " | "
      )
    )
  end

  defp init_stats, do: %{correct: 0, incorrect: 0, skip: 0}
  defp update_stats(stats, :correct), do: Map.update!(stats, :correct, &(&1 + 1))
  defp update_stats(stats, :incorrect), do: Map.update!(stats, :incorrect, &(&1 + 1))
  defp update_stats(stats, :skip), do: Map.update!(stats, :skip, &(&1 + 1))

  defp print_summary(%{correct: c, incorrect: i, skip: s}) do
    total = c + i + s
    IO.puts("\nSummary: total=#{total} correct=#{c} incorrect=#{i} skip=#{s}")
  end

  defp get_user!(uuid) do
    KumaSanKanji.Accounts.User
    |> Query.for_read(:read, %{}, actor: nil)
    |> Query.do_filter(id: uuid)
    |> Ash.read_one!(authorize?: false)
  end

  defp fmt_dt(nil), do: ""
  defp fmt_dt(%DateTime{} = dt), do: DateTime.to_iso8601(dt)
  defp short(nil), do: ""
  defp short(id) when is_binary(id), do: String.slice(id, 0, 8)

  defp abort!(msg) do
    Mix.shell().error(msg)
    exit({:shutdown, 1})
  end
end
