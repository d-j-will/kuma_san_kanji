defmodule GdaCredo.Check.PureDecideZone do
  @moduledoc """
  Gather → Decide → Act: a Decide zone must be pure. Flags IO/effect calls.
  Escape hatch: `# gda:override reason: "..." ref: ...` on or above the line.
  """

  @default_forbidden_modules [:Repo, :Ecto, :Finch, :Req, :File, :GenServer]
  @default_forbidden_calls []
  @default_markers ["/core/"]
  @default_suffixes [".decide.ex"]

  use Credo.Check,
    base_priority: :high,
    category: :warning,
    param_defaults: [
      forbidden_modules: @default_forbidden_modules,
      forbidden_calls: @default_forbidden_calls,
      decide_path_markers: @default_markers,
      decide_suffixes: @default_suffixes
    ],
    explanations: [
      check: "Decide zones must be pure. Move IO to a Gather step, or annotate with `# gda:override reason: \"...\" ref: ...`."
    ]

  def run(%Credo.SourceFile{} = source_file, params) do
    if decide_zone?(source_file.filename, params) do
      issue_meta = IssueMeta.for(source_file, params)
      modules = Keyword.get(params, :forbidden_modules, @default_forbidden_modules)

      Credo.Code.prewalk(
        source_file,
        &traverse(&1, &2, source_file, issue_meta, modules)
      )
    else
      []
    end
  end

  # Elixir remote call: Mod.fun(...) / A.B.fun(...)
  defp traverse(
         {{:., _, [{:__aliases__, _, alias_parts}, fun]}, call_meta, _args} = ast,
         issues,
         source_file,
         issue_meta,
         modules
       ) do
    mod = List.last(alias_parts)

    if mod in modules and not overridden?(source_file, call_meta[:line]) do
      {ast, issues ++ [issue_for(issue_meta, call_meta[:line], mod, fun)]}
    else
      {ast, issues}
    end
  end

  defp traverse(ast, issues, _sf, _im, _mods), do: {ast, issues}

  defp decide_zone?(nil, _params), do: false

  defp decide_zone?(filename, params) do
    markers = Keyword.get(params, :decide_path_markers, @default_markers)
    suffixes = Keyword.get(params, :decide_suffixes, @default_suffixes)

    Enum.any?(markers, &String.contains?(filename, &1)) or
      Enum.any?(suffixes, &String.ends_with?(filename, &1))
  end

  defp overridden?(_source_file, nil), do: false

  defp overridden?(source_file, line_no) do
    current = Credo.SourceFile.line_at(source_file, line_no) || ""
    Regex.match?(~r/gda:override\s+reason:\s*"[^"]+"\s+ref:\s*\S+/, current)
  end

  defp issue_for(issue_meta, line_no, mod, fun) do
    format_issue(
      issue_meta,
      message:
        "IO/effect call `#{mod}.#{fun}` inside a Decide zone. " <>
          "Move it to a Gather step, or add `# gda:override reason: \"...\" ref: ...`.",
      trigger: "#{mod}.#{fun}",
      line_no: line_no
    )
  end
end
