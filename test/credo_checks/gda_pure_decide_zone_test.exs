defmodule GdaCredo.Check.PureDecideZoneTest do
  use Credo.Test.Case

  alias GdaCredo.Check.PureDecideZone

  # `decide_path_markers: [""]` forces every file to count as a Decide zone,
  # so we can test the AST logic without controlling the synthetic filename.
  test "fires on a Repo call inside a Decide zone" do
    """
    defmodule MyApp.Scheduling.Core do
      def next(progress) do
        Repo.update(progress)
      end
    end
    """
    |> to_source_file()
    |> run_check(PureDecideZone, decide_path_markers: [""])
    |> assert_issue(fn issue ->
      assert issue.line_no == 3
      assert issue.trigger == "Repo.update"
    end)
  end

  test "does not fire when the file is outside any Decide zone" do
    """
    defmodule MyApp.Scheduling.Worker do
      def next(progress) do
        Repo.update(progress)
      end
    end
    """
    |> to_source_file()
    |> run_check(PureDecideZone, decide_path_markers: ["/zone_that_never_matches/"])
    |> refute_issues()
  end

  test "a valid override (reason + ref) suppresses the issue" do
    """
    defmodule MyApp.Scheduling.Core do
      def next(progress) do
        Repo.update(progress) # gda:override reason: "legacy batch path" ref: docs/adr/0007.md
      end
    end
    """
    |> to_source_file()
    |> run_check(PureDecideZone, decide_path_markers: [""])
    |> refute_issues()
  end

  test "an override on the previous line also suppresses the issue" do
    """
    defmodule MyApp.Scheduling.Core do
      def next(progress) do
        # gda:override reason: "legacy batch path" ref: docs/adr/0007.md
        Repo.update(progress)
      end
    end
    """
    |> to_source_file()
    |> run_check(PureDecideZone, decide_path_markers: [""])
    |> refute_issues()
  end

  test "a bare override with no reason/ref still fires" do
    """
    defmodule MyApp.Scheduling.Core do
      def next(progress) do
        Repo.update(progress) # gda:override
      end
    end
    """
    |> to_source_file()
    |> run_check(PureDecideZone, decide_path_markers: [""])
    |> assert_issue()
  end
end
