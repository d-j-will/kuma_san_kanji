defmodule KumaSanKanjiWeb.KanjiStrokeOrderComponentTest do
  use KumaSanKanjiWeb.ConnCase
  import Phoenix.LiveViewTest
  import Phoenix.Component
  import KumaSanKanjiWeb.KanjiStrokeOrderComponent

  test "renders viewing mode by default" do
    assigns = %{kanji: "水", id: "kanji-1"}
    html = rendered_to_string(~H"<.stroke_order kanji={@kanji} id={@id} />")

    assert html =~ "stroke-order-container"
    assert html =~ "svg"
    refute html =~ "<canvas"
    assert html =~ "data-mode=\"view\""
  end

  test "renders tracing mode with canvas" do
    assigns = %{kanji: "水", id: "kanji-1", mode: :trace}
    html = rendered_to_string(~H"<.stroke_order kanji={@kanji} id={@id} mode={@mode} />")

    assert html =~ "<canvas"
    assert html =~ "data-mode=\"trace\""
    assert html =~ "role=\"img\""
    assert html =~ "aria-label=\"Canvas for tracing kanji strokes\""
    # Ensure hook is attached
    assert html =~ "phx-hook=\"KanjiStrokeTracing\""
  end
end
