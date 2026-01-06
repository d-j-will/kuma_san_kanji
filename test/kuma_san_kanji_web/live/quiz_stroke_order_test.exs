defmodule KumaSanKanjiWeb.QuizStrokeOrderTest do
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.TestHelpers

  setup do
    user = create_simple_test_user("stroke#{System.system_time(:millisecond)}@ex.com")
    setup_auth_mocks(user)
    {:ok, kanji} = KumaSanKanji.Domain.create_kanji(%{character: "日", grade: 1, stroke_count: 4, jlpt_level: 5})
    {:ok, _} = KumaSanKanji.SRS.Logic.initialize_progress(user.id, kanji.id, user)
    conn = log_in_user(build_conn(), user)
    {:ok, conn: conn, user: user, kanji: kanji}
  end

  test "toggle stroke order renders component", %{conn: conn, kanji: kanji} do
    {:ok, view, html} = live(conn, ~p"/quiz")
    assert html =~ kanji.character
    refute has_element?(view, "#quiz-stroke-order")
    view |> element("button", "Show Stroke Order") |> render_click()
    assert has_element?(view, "#quiz-stroke-order")
  end

  test "toggle practice mode renders tracing canvas", %{conn: conn} do
    {:ok, view, _html} = live(conn, ~p"/quiz")
    
    # First show stroke order
    view |> element("button", "Show Stroke Order") |> render_click()
    assert has_element?(view, "#quiz-stroke-order")
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
