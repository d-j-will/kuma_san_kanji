defmodule KumaSanKanjiWeb.FeatureFlagHelper do
  @moduledoc "Centralized feature flag checks for LiveViews."

  def learning_path_enabled? do
    FunWithFlags.enabled?(:grade1_learning_path)
  end

  def mobile_ux_enabled? do
    FunWithFlags.enabled?(:mobile_ux_optimization)
  end

  def bear_seasons_srs_enabled? do
    FunWithFlags.enabled?(:bear_seasons_srs)
  end
end
