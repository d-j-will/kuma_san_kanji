defmodule KumaSanKanjiWeb.CreditsLiveTest do
  use KumaSanKanjiWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  test "credits page renders KanjiVG attribution", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/credits")
    assert html =~ "KanjiVG"
    assert html =~ "CC BY-SA 3.0"
  end

  test "footer attribution present on root page", %{conn: conn} do
    {:ok, _view, html} = live(conn, ~p"/")
    assert html =~ "KanjiVG project"
  end
end
