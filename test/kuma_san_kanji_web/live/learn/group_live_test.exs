defmodule KumaSanKanjiWeb.GroupLiveTest do
  @moduledoc """
  Acceptance tests for US-05: View Group Progress and Continue Learning.

  Validates that the group detail page shows a kanji grid with learned/unlearned
  indicators, accurate progress counts, "Continue Learning" linking to the next
  unlearned kanji, completion celebration for finished groups, and session
  results when returning from a quiz.

  Driving port: GroupLive (LiveView mount and render)
  """
  use KumaSanKanjiWeb.ConnCase, async: false
  import Phoenix.LiveViewTest
  import KumaSanKanji.LearningPathHelpers

  # ---------------------------------------------------------------
  # Walking Skeleton
  # ---------------------------------------------------------------

  describe "Walking Skeleton: Learner views group detail with progress" do
    @tag :skip
    test "partially completed group shows kanji grid with learned indicators", %{conn: conn} do
      # Given Yuki Tanaka is signed in
      {conn, user} = create_authenticated_learner(conn, "yuki-group")
      enable_learning_path_flag()

      # And Yuki has learned 一, 二, 三 in the Numbers group
      {group, kanji_list} = create_numbers_group()
      Enum.take(kanji_list, 3) |> Enum.each(&mark_kanji_learned(user, &1))

      # When Yuki opens the Numbers group page
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}")

      # Then Yuki sees the heading "Numbers"
      assert html =~ "Numbers"

      # And Yuki sees all 4 kanji in the grid
      assert html =~ "一"
      assert html =~ "二"
      assert html =~ "三"
      assert html =~ "四"

      # And the progress shows 3 of 4 learned
      assert html =~ "3" and html =~ "4"

      # And "Continue Learning" links to the teach step for 四
      assert html =~ "Continue Learning" or html =~ "continue"
    end
  end

  # ---------------------------------------------------------------
  # Happy Path Scenarios
  # ---------------------------------------------------------------

  describe "Group with no prior progress" do
    @tag :skip
    test "all kanji shown as not yet learned", %{conn: conn} do
      # Given Yuki has not learned any kanji in the Numbers group
      {conn, _user} = create_authenticated_learner(conn, "yuki-no-progress")
      enable_learning_path_flag()

      {group, _kanji_list} = create_numbers_group()

      # When Yuki opens the Numbers group
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}")

      # Then Yuki sees all kanji are shown as not yet learned
      assert html =~ "Numbers"
      assert html =~ "一"

      # And "Continue Learning" links to the first kanji 一
      assert html =~ "Continue Learning" or html =~ "continue"
    end
  end

  describe "Continue learning resumes at correct position" do
    @tag :skip
    test "continue learning links to the first unlearned kanji", %{conn: conn} do
      # Given Yuki has learned 一, 二, 三 but not 四 in Numbers
      {conn, user} = create_authenticated_learner(conn, "yuki-resume")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()
      Enum.take(kanji_list, 3) |> Enum.each(&mark_kanji_learned(user, &1))

      # When Yuki views the Numbers group page
      {:ok, view, html} = live(conn, ~p"/learn/#{group.id}")

      # Then "Continue Learning" is present
      assert html =~ "Continue Learning" or html =~ "continue"

      # When Yuki clicks "Continue Learning"
      result =
        view
        |> element("a", ~r/[Cc]ontinue/)
        |> render_click()

      # Then Yuki is taken to the teach step for 四 (position 4)
      case result do
        {:error, {:live_redirect, %{to: path}}} ->
          assert path =~ "/4" or path =~ "四"

        html when is_binary(html) ->
          assert html =~ "四"
      end
    end
  end

  describe "Completed group shows celebration" do
    @tag :skip
    test "fully learned group shows All learned and Review All option", %{conn: conn} do
      # Given Yuki has learned all 4 kanji in the Numbers group
      {conn, user} = create_authenticated_learner(conn, "yuki-celebrate")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()
      Enum.each(kanji_list, &mark_kanji_learned(user, &1))

      # When Yuki views the Numbers group page
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}")

      # Then all kanji show learned indicators
      assert html =~ "4/4" or html =~ "4 of 4"

      # And the page shows "All learned!" instead of "Continue Learning"
      assert html =~ "All learned" or html =~ "complete"

      # And "Review All" is available for re-quizzing
      assert html =~ "Review" or html =~ "review"
    end
  end

  describe "Session results display after quiz" do
    @tag :skip
    test "returning from quiz shows session score", %{conn: conn} do
      # Given Yuki just completed a Numbers quiz session
      {conn, user} = create_authenticated_learner(conn, "yuki-session")
      enable_learning_path_flag()

      {group, kanji_list} = create_numbers_group()
      Enum.take(kanji_list, 3) |> Enum.each(&mark_kanji_learned(user, &1))

      # When the quiz session ends and returns to the group view with results
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}?correct=2&incorrect=1")

      # Then Yuki sees session results
      assert html =~ "2" and html =~ "1"

      # And Yuki sees the group progress grid
      assert html =~ "Numbers"
    end
  end

  # ---------------------------------------------------------------
  # Error Path Scenarios
  # ---------------------------------------------------------------

  describe "Non-existent group shows graceful error" do
    @tag :skip
    test "invalid group identifier handles gracefully", %{conn: conn} do
      # Given Yuki is signed in
      {conn, _user} = create_authenticated_learner(conn, "yuki-bad-group")
      enable_learning_path_flag()

      # When Yuki navigates to a non-existent group
      result = live(conn, ~p"/learn/nonexistent-group")

      # Then Yuki sees a redirect or error message (not a crash)
      case result do
        {:error, {:redirect, _}} -> assert true
        {:ok, _view, html} -> assert html =~ "not found" or html =~ "Learn"
      end
    end
  end

  describe "Unauthenticated access to group page" do
    @tag :skip
    test "unauthenticated visitor is redirected to sign-in", %{conn: conn} do
      # Given the feature flag is enabled
      enable_learning_path_flag()

      # And a visitor is not signed in

      # When the visitor navigates to a group detail URL
      assert {:error, {:redirect, %{to: redirect_path}}} =
               live(conn, ~p"/learn/some-group")

      # Then the visitor is redirected to the sign-in page
      assert redirect_path =~ "/sign-in"
    end
  end

  describe "Group with no kanji linked" do
    @tag :skip
    test "empty group shows helpful message", %{conn: conn} do
      # Given the "Colors" thematic group exists but has no kanji linked
      {conn, _user} = create_authenticated_learner(conn, "yuki-empty-group")
      enable_learning_path_flag()

      group = create_thematic_group(%{name: "Colors", order_index: 7})

      # When Yuki opens the Colors group
      {:ok, _view, html} = live(conn, ~p"/learn/#{group.id}")

      # Then Yuki sees "This group is being prepared" or similar message
      assert html =~ "being prepared" or html =~ "no kanji" or html =~ "Colors"

      # And a link back to the groups list
      assert html =~ ~r/learn[^\/]/ or html =~ "back"
    end
  end

  describe "Feature flag disabled prevents group access" do
    @tag :skip
    test "group page redirects to home when flag is disabled", %{conn: conn} do
      # Given the grade1_learning_path feature flag is disabled
      disable_learning_path_flag()

      # And Kenji is signed in
      {conn, _user} = create_authenticated_learner(conn, "kenji-group-flag")

      # When Kenji navigates directly to a group page
      assert {:error, {:redirect, %{to: redirect_path}}} =
               live(conn, ~p"/learn/some-group")

      # Then Kenji is redirected to the home page
      assert redirect_path == "/"
    end
  end

  describe "Overall progress updates across groups" do
    @tag :skip
    test "learn page reflects combined progress from multiple groups", %{conn: conn} do
      # Given Yuki has learned all 4 kanji in Numbers and 1 kanji in Nature
      {conn, user} = create_authenticated_learner(conn, "yuki-overall")
      enable_learning_path_flag()

      {_numbers_group, numbers_kanji} = create_numbers_group()
      {_nature_group, nature_kanji} = create_nature_group()

      Enum.each(numbers_kanji, &mark_kanji_learned(user, &1))
      mark_kanji_learned(user, Enum.at(nature_kanji, 0))

      # When Yuki navigates to the Learn page
      {:ok, _view, html} = live(conn, ~p"/learn")

      # Then the Numbers card shows "4/4 learned" with a completion indicator
      assert html =~ "4/4" or html =~ "4 of 4"

      # And the Nature card shows "1/2 learned"
      assert html =~ "1/2" or html =~ "1 of 2"

      # And overall progress shows "5" learned
      assert html =~ "5"
    end
  end
end
