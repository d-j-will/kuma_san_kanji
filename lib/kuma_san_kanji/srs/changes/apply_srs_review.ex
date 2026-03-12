defmodule KumaSanKanji.SRS.Changes.ApplySrsReview do
  @moduledoc """
  Dispatches review processing to either Bear Seasons or SM-2 based on feature flag.

  When `:bear_seasons_srs` flag is enabled, uses the stage-based Bear Seasons algorithm.
  Otherwise, falls back to the classic SM-2 algorithm.
  """

  use Ash.Resource.Change

  @impl true
  def change(changeset, opts, context) do
    if FunWithFlags.enabled?(:bear_seasons_srs) do
      KumaSanKanji.SRS.Changes.ApplyBearSeasons.change(changeset, opts, context)
    else
      KumaSanKanji.SRS.Changes.ApplySm2.change(changeset, opts, context)
    end
  end
end
