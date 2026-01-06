defmodule KumaSanKanjiWeb.ExploreStrokeOrderTest do
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  setup do
    {:ok, _kanji} = KumaSanKanji.Domain.create_kanji(%{character: "日", grade: 1, stroke_count: 4, jlpt_level: 5})
    {:ok, conn: build_conn()}
  end

  test "toggle practice mode in explore renders tracing canvas", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/explore")
    
    # First show stroke order
    view |> element("button", "Show Stroke Order") |> render_click()
    assert has_element?(view, "#explore-stroke-order")
    refute has_element?(view, "canvas")

    # Now enable tracing
    view |> element("button", "Practice Writing") |> render_click()
    assert has_element?(view, "canvas")
    assert render(view) =~ "Disable Tracing"

    # Disable it again
    view |> element("button", "Disable Tracing") |> render_click()
    refute has_element?(view, "canvas")
  end
end
