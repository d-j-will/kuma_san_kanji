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

  describe "srs_kanji_card_badge/1" do
    test "renders stage label for a progress record at stage 1" do
      assigns = %{progress: %{srs_stage: 1, next_review_date: DateTime.utc_now()}}

      html =
        rendered_to_string(~H"<SrsStageComponent.srs_kanji_card_badge progress={@progress} />")

      assert html =~ "Awakening"
      assert html =~ "#F4A7BB"
    end

    test "renders 'Due now' when next_review_date is in the past" do
      past = DateTime.add(DateTime.utc_now(), -3600, :second)
      assigns = %{progress: %{srs_stage: 3, next_review_date: past}}

      html =
        rendered_to_string(~H"<SrsStageComponent.srs_kanji_card_badge progress={@progress} />")

      assert html =~ "Due now"
    end

    test "renders relative time when next_review_date is in the future" do
      future = DateTime.add(DateTime.utc_now(), 7200, :second)
      assigns = %{progress: %{srs_stage: 5, next_review_date: future}}

      html =
        rendered_to_string(~H"<SrsStageComponent.srs_kanji_card_badge progress={@progress} />")

      assert html =~ "h"
      assert html =~ "Peak"
    end

    test "renders Mastered for stage 9 (Hibernation)" do
      assigns = %{progress: %{srs_stage: 9, next_review_date: nil}}

      html =
        rendered_to_string(~H"<SrsStageComponent.srs_kanji_card_badge progress={@progress} />")

      assert html =~ "Hibernation"
      assert html =~ "Mastered"
    end

    test "renders nothing when progress is nil" do
      assigns = %{progress: nil}

      html =
        rendered_to_string(~H"<SrsStageComponent.srs_kanji_card_badge progress={@progress} />")

      refute html =~ "Awakening"
      refute html =~ "Peak"
    end
  end
end
