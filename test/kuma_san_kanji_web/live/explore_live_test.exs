defmodule KumaSanKanjiWeb.ExploreLiveTest do
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  @endpoint KumaSanKanjiWeb.Endpoint

  describe "ExploreLive functionality" do
    setup do
      kanji1 = KumaSanKanji.Domain.create_kanji!(%{
        character: "水",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5
      })

      kanji2 = KumaSanKanji.Domain.create_kanji!(%{
        character: "火",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5
      })

      %{kanji1: kanji1, kanji2: kanji2}
    end

    test "displays kanji", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/explore")
      assert view.module == KumaSanKanjiWeb.ExploreLive
      assert has_element?(view, ".kanji-display")
    end

    test "cycles through kanji on 'new_kanji' event", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/explore")

      initial_kanji = view |> element(".kanji-display") |> render() |> extract_kanji_character()
      assert initial_kanji != nil

      view |> element("button", "Show New Kanji") |> render_click()
      next_kanji = view |> element(".kanji-display") |> render() |> extract_kanji_character()

      assert next_kanji != nil
      refute next_kanji == initial_kanji
    end

    test "stroke order toggle shows component", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/explore")
      refute has_element?(view, "#explore-stroke-order")
      view |> element("button", "Show Stroke Order") |> render_click()
      assert has_element?(view, "#explore-stroke-order")
      view |> element("button", "Hide Stroke Order") |> render_click()
      refute has_element?(view, "#explore-stroke-order")
    end

    test "radical information displays when kanji has radical", %{conn: conn} do
      radical = KumaSanKanji.Domain.create_radical!(%{
        glyph: "氵",
        kangxi_index: 85,
        stroke_count: 3,
        meaning: "water",
        japanese_name: "さんずい"
      })

      existing_count = Ash.count!(KumaSanKanji.Kanji.Kanji, action: :read)

      created = KumaSanKanji.Domain.create_kanji!(%{
        character: "河",
        grade: 2,
        stroke_count: 8,
        jlpt_level: 4,
        radical_id: radical.id
      })

      {:ok, view, _html} = live(conn, "/explore")

      total = Ash.count!(KumaSanKanji.Kanji.Kanji, action: :read)
      assert total == existing_count + 1

      Enum.each(1..(total - 1), fn _ ->
        view |> element("button", "Show New Kanji") |> render_click()
      end)

      html = render(view)
      assert html =~ "Radical"
      assert html =~ radical.glyph
      assert html =~ "Kangxi # 85"
      assert html =~ created.character
    end

    test "radical panel hidden when kanji has no radical", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/explore")
      refute has_element?(view, "h3", "Radical")
      refute render(view) =~ ~r/>Radical</
    end

    defp extract_kanji_character(html) do
      ~r/<span[^>]*>([^<]+)<\/span>/
      |> Regex.run(html)
      |> case do
        [_, character] -> character
        _ -> nil
      end
    end
  end
end
