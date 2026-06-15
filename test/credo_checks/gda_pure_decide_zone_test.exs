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
end
