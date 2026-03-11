defmodule KumaSanKanjiWeb.FeatureFlagHelper do
  @moduledoc "Centralized feature flag checks for LiveViews."

  def learning_path_enabled? do
    FunWithFlags.enabled?(:grade1_learning_path)
  end
end
