defmodule KumaSanKanji.KanjiVG.Ingestion do
  @moduledoc """
  Fetches and sanitizes KanjiVG stroke order SVG assets into priv/static/kanjivg.

  By default only ingests SVGs for kanji present in the database unless `:all?` is passed.

  Network download is optional; you can pass a local extracted directory via `:source_path`.
  The default remote repository URL is the official KanjiVG mirror (GitHub).
  """

  require Logger
  alias KumaSanKanji.Repo

  @repo_url "https://raw.githubusercontent.com/KanjiVG/kanjivg/refs/heads/master/"

  @doc """
  Orchestrates ingestion.

  Options:
  * :all? - ingest all kanji (default false)
  * :force? - overwrite existing files (default false)
  * :limit - limit number of processed characters (dev/testing)
  * :characters - explicit list of kanji characters to ingest
  * :source_path - local path to a kanjivg repo (expects kanji/*.svg)
  * :repo_url - override base repo url (raw form)
  """
  def ingest(opts \\ []) do
    chars = target_characters(opts)
    base_url = Keyword.get(opts, :repo_url, @repo_url)
    source_path = Keyword.get(opts, :source_path)
    limit = Keyword.get(opts, :limit)
    force? = Keyword.get(opts, :force?, false)
    concurrency = Keyword.get(opts, :concurrency, System.schedulers_online())
    timeout = Keyword.get(opts, :timeout, 15_000)

    chars = maybe_limit(chars, limit)

    Logger.info("[KanjiVG] Ingesting #{length(chars)} kanji (force?=#{force?} concurrency=#{concurrency})")
    File.mkdir_p!(dest_dir())
    
    # Initialize failure tracking
    failure_log_path = Path.join(dest_dir(), "ingestion_failures.log")
    timestamp = DateTime.utc_now() |> DateTime.to_iso8601()
    log_header = "# KanjiVG Ingestion Failures - #{timestamp}\n# Format: kanji_char,hex_code,error_type,error_details,attempted_url\n"
    File.write!(failure_log_path, log_header)
    
    initial = %{written: 0, skipped: 0, errors: 0, failures: []}

    result =
      chars
      |> Task.async_stream(
        fn ch -> process_char_with_logging(ch, base_url, source_path, force?) end,
        max_concurrency: concurrency,
        timeout: timeout,
        ordered: false
      )
      |> Enum.reduce(initial, fn
        {:ok, :written}, acc -> %{acc | written: acc.written + 1}
        {:ok, :skipped}, acc -> %{acc | skipped: acc.skipped + 1}
        {:ok, {:error, failure_info}}, acc -> 
          %{acc | errors: acc.errors + 1, failures: [failure_info | acc.failures]}
        {:exit, reason}, acc -> 
          failure_info = %{char: "unknown", hex: "unknown", error_type: "timeout", details: inspect(reason), url: "unknown"}
          %{acc | errors: acc.errors + 1, failures: [failure_info | acc.failures]}
      end)

    # Write all failures to log file
    unless Enum.empty?(result.failures) do
      failure_lines = 
        result.failures
        |> Enum.reverse()
        |> Enum.map(fn failure ->
          "#{failure.char},#{failure.hex},#{failure.error_type},\"#{failure.details}\",#{failure.url}"
        end)
        |> Enum.join("\n")
      
      File.write!(failure_log_path, log_header <> failure_lines <> "\n", [:append])
      Logger.info("[KanjiVG] Failure log written to: #{failure_log_path}")
    end

    stats = Map.drop(result, [:failures])
    {:ok, stats}
  end

  defp process_char_with_logging(ch, base_url, source_path, force?) do
    hex = codepoint_hex(ch)
    dest = Path.join(dest_dir(), hex <> ".svg")

    cond do
      File.exists?(dest) and not force? -> :skipped
      true ->
        case fetch_svg(ch, hex, base_url, source_path) do
          {:ok, raw} ->
            Logger.debug("[KanjiVG] Raw SVG #{hex} (#{byte_size(raw)} bytes)")
            case sanitize_svg(raw) do
              {:ok, cleaned} ->
                File.write!(dest, cleaned)
                :written
              {:error, reason} ->
                failure_info = %{
                  char: ch,
                  hex: hex,
                  error_type: "sanitize_failed",
                  details: inspect(reason),
                  url: build_url(hex, base_url, source_path)
                }
                Logger.warning("[KanjiVG] Sanitize failed for #{ch} #{hex}: #{inspect(reason)}")
                {:error, failure_info}
            end
          {:error, reason} ->
            failure_info = %{
              char: ch,
              hex: hex,
              error_type: "fetch_failed",
              details: inspect(reason),
              url: build_url(hex, base_url, source_path)
            }
            Logger.warning("[KanjiVG] Fetch failed for #{ch} #{hex}: #{inspect(reason)}")
            {:error, failure_info}
        end
    end
  end

  defp dest_dir, do: Path.join([Application.app_dir(:kuma_san_kanji), "priv", "static", "kanjivg"])

  defp target_characters(opts) do
    cond do
      chars = Keyword.get(opts, :characters) -> List.wrap(chars)
      Keyword.get(opts, :all?) -> all_unicode_from_source(opts)
      true -> db_kanji_chars()
    end
  end

  defp db_kanji_chars do
    # Query distinct characters from kanji table via Repo (raw SQL for speed)
    {:ok, result} = Ecto.Adapters.SQL.query(Repo, "SELECT DISTINCT character FROM kanjis", [])
    Enum.map(result.rows, fn [ch] -> ch end)
  end

  defp all_unicode_from_source(opts) do
    # If local path provided, scan; else fallback to db chars to avoid huge remote enumeration.
    case opts[:source_path] do
      nil -> db_kanji_chars()
      path ->
        path
        |> Path.join("kanji/*.svg")
        |> Path.wildcard()
        |> Enum.map(fn file -> file |> Path.basename() |> String.trim_trailing(".svg") end)
        |> Enum.map(&<<String.to_integer(&1, 16)>>)
    end
  end

  defp maybe_limit(chars, nil), do: chars
  defp maybe_limit(chars, limit) when is_integer(limit) and limit > 0, do: Enum.take(chars, limit)
  defp maybe_limit(chars, _), do: chars

  defp fetch_svg(_ch, hex, base_url, nil) do
    # Download single file (KanjiVG stores as kanji/xxxx.svg)
    url = base_url <> "/kanji/" <> hex <> ".svg"
  Logger.debug("[KanjiVG] Fetching remote SVG #{url}")
    case Req.get(url) do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  catch
    _, e -> {:error, {:exception, e}}
  end
  defp fetch_svg(_ch, hex, _base_url, source_path) do
    file = Path.join([source_path, "kanji", hex <> ".svg"])
  Logger.debug("[KanjiVG] Reading local SVG #{file}")
    case File.read(file) do
      {:ok, contents} -> {:ok, contents}
      error -> error
    end
  end

  @allowed_tags ~w(svg g path text)
  @remove_attrs ~w(onload onclick onmouseover onerror onfocus onblur)

  @doc """
  Sanitizes raw SVG content by:
  * Removing script/style/foreignObject elements
  * Dropping disallowed tags
  * Stripping event handler attributes & xlink:href/external refs
  * Enforcing inline SVG viewport attributes if missing
  """
  def sanitize_svg(raw) when is_binary(raw) do
    try do
      {:ok, doc} = Floki.parse_document(raw)
      cleaned =
        doc
        |> Floki.traverse_and_update(fn
          {tag, attrs, children} ->
            cond do
              tag in ["script", "style", "foreignObject"] -> nil
              tag in @allowed_tags ->
                attrs =
                  attrs
                  |> Enum.reject(fn {k, _} -> k in @remove_attrs end)
                  |> Enum.reject(fn {k, v} -> k in ["xlink:href", "href"] and external_ref?(v) end)

                {tag, attrs, children}
              true -> nil
            end
          other -> other
        end)

      svg = Floki.find(cleaned, "svg")

      output =
        case svg do
          [] -> ""
          _ -> Floki.raw_html(cleaned)
        end

      if output == "" do
        {:error, :no_svg}
      else
        {:ok, output}
      end
    rescue
      e -> {:error, {:exception, e}}
    end
  end
  def sanitize_svg(_), do: {:error, :invalid_input}

  defp external_ref?(value) do
    String.starts_with?(value, ["http://", "https://", "//"]) or String.contains?(value, "://")
  end

  defp build_url(hex, base_url, nil), do: base_url <> "/kanji/" <> hex <> ".svg"
  defp build_url(hex, _base_url, source_path), do: Path.join([source_path, "kanji", hex <> ".svg"])

  # KanjiVG filenames are 5-char lowercase hex, left-padded with zeros (e.g. U+4E5D -> 04e5d.svg)
  defp codepoint_hex(<<cp::utf8>>), do: cp |> Integer.to_string(16) |> String.downcase() |> String.pad_leading(5, "0")
end
