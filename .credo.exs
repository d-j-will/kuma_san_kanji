%{
  configs: [
    %{
      name: "default",
      files: %{included: ["lib/", "test/"]},
      requires: ["test/support/credo_checks/**/*.ex"],
      checks: %{
        extra: [
          {GdaCredo.Check.PureDecideZone, []}
        ]
      }
    }
  ]
}
