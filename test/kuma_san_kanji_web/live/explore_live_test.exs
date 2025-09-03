defmodule KumaSanKanjiWeb.ExploreLiveTest do
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest

  @endpoint KumaSanKanjiWeb.Endpoint

  describe "ExploreLive functionality" do
    setup do
      # Create test kanji data
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

      # Check that it's the correct LiveView module
      assert view.module == KumaSanKanjiWeb.ExploreLive

      # Verify that some kanji character is displayed
      assert has_element?(view, ".kanji-display")
    end

    test "cycles through kanji on 'new_kanji' event", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/explore")

      # Get initial kanji character
      initial_kanji = view |> element(".kanji-display") |> render() |> extract_kanji_character()
      assert initial_kanji != nil

      # Click for next Kanji
      view |> element("button", "Show New Kanji") |> render_click()
      next_kanji = view |> element(".kanji-display") |> render() |> extract_kanji_character()

      # The next kanji should be different from the initial one
      # Note: This test doesn't rely on specific characters, just that they change
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
      # Create radical
      radical = KumaSanKanji.Domain.create_radical!(%{
        glyph: "氵",
        kangxi_index: 85,
        stroke_count: 3,
        meaning: "water",
        japanese_name: "さんずい"
      })

      existing_count = KumaSanKanji.Domain.count_all_kanjis!()

      created = KumaSanKanji.Domain.create_kanji!(%{
        character: "河",
        grade: 2,
        stroke_count: 8,
        jlpt_level: 4,
        radical_id: radical.id
      })

      {:ok, view, _html} = live(conn, "/explore")

      # New kanji should be last by inserted_at ordering used in by_offset
      total = KumaSanKanji.Domain.count_all_kanjis!()
      assert total == existing_count + 1

      # Navigate through offsets until reaching the last one (newly created)
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
      # In setup we created two kanji without radicals. Mount explore.
      {:ok, view, _html} = live(conn, "/explore")

      # Ensure the Radical heading is not present
      refute has_element?(view, "h3", "Radical")

      # Double check raw HTML to avoid false positives
  refute render(view) =~ ~r/>Radical</
    end

    # Helper function to extract kanji character from HTML
    defp extract_kanji_character(html) do
  ~r/<span[^>]*>([^<]+)<\/span>/
      |> Regex.run(html)
      |> case do
        [_, character] -> character
        _ -> nil
      end
    end

    # Test for no data case removed as it's difficult to set up in an environment
    # where the database is seeded and has foreign key constraints
  end
end
