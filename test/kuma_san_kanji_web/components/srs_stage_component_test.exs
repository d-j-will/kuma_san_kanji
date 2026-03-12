defmodule KumaSanKanjiWeb.Components.SrsStageComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.Component
  import Phoenix.LiveViewTest

  alias KumaSanKanjiWeb.Components.SrsStageComponent

  describe "srs_stage_guide/1" do
    test "renders the guide header" do
      assigns = %{}
      html = rendered_to_string(~H"<SrsStageComponent.srs_stage_guide />")
      assert html =~ "Bear Seasons"
      assert html =~ "How SRS Works"
    end

    test "renders all five season groups with Japanese and English names" do
      assigns = %{}
      html = rendered_to_string(~H"<SrsStageComponent.srs_stage_guide />")
      assert html =~ "目覚め"
      assert html =~ "Awakening"
      assert html =~ "盛り"
      assert html =~ "Peak"
      assert html =~ "実り"
      assert html =~ "Harvest"
      assert html =~ "力"
      assert html =~ "Strength"
      assert html =~ "冬眠"
      assert html =~ "Hibernation"
    end

    test "renders interval information for stages" do
      assigns = %{}
      html = rendered_to_string(~H"<SrsStageComponent.srs_stage_guide />")
      assert html =~ "4 hours"
      assert html =~ "1 week"
      assert html =~ "1 month"
      assert html =~ "4 months"
    end

    test "renders the Shu-Ha-Ri framework labels" do
      assigns = %{}
      html = rendered_to_string(~H"<SrsStageComponent.srs_stage_guide />")
      assert html =~ "守"
      assert html =~ "破"
      assert html =~ "離"
    end

    test "uses details/summary for progressive disclosure" do
      assigns = %{}
      html = rendered_to_string(~H"<SrsStageComponent.srs_stage_guide />")
      assert html =~ "<details"
      assert html =~ "<summary"
    end

    test "renders stage colors as inline styles" do
      assigns = %{}
      html = rendered_to_string(~H"<SrsStageComponent.srs_stage_guide />")
      # Mezame pink
      assert html =~ "#F4A7BB"
      # Sakari green
      assert html =~ "#4CAF50"
    end
  end
end
