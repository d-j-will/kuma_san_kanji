defmodule GdaCredo.Fixtures.DecideZoneViolation.Core.Scheduler do
  @moduledoc "Fixture: a Decide-zone module that violates GDA (for the integration smoke test)."
  def schedule(progress) do
    KumaSanKanji.Repo.update(progress)
  end
end
