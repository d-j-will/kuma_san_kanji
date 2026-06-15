%{
  configs: [
    %{
      name: "default",
      files: %{included: ["lib/", "test/"]},
      requires: ["test/support/credo_checks/gda_pure_decide_zone.ex"],
      checks: %{
        extra: [
          {GdaCredo.Check.PureDecideZone, []}
        ]
      }
    }
  ]
}
