defmodule KumaSanKanji.Quiz.Core.SessionStateTest do
  use ExUnit.Case, async: true

  alias KumaSanKanji.Quiz.Core.SessionState

  # Plain structs/maps only — no Ash, no DB

  describe "init_state/2" do
    test "returns ok map with first due kanji when progress list is non-empty" do
      progress = %{kanji: %{id: "k1"}}
      stats = %{total: 5}

      assert {:ok, state} = SessionState.init_state({:ok, stats}, {:ok, [progress]})
      assert state.current_kanji == %{id: "k1"}
      assert state.current_progress == progress
      assert state.user_stats == stats
      assert state.quiz_error == false
    end

    test "returns ok map with nil kanji when due list is empty" do
      stats = %{total: 3}

      assert {:ok, state} = SessionState.init_state({:ok, stats}, {:ok, []})
      assert state.current_kanji == nil
      assert state.user_stats == stats
      assert state.quiz_error == false
    end

    test "returns ok map with nil kanji when due result is :not_found error" do
      stats = %{total: 3}

      assert {:ok, state} = SessionState.init_state({:ok, stats}, {:error, :not_found})
      assert state.current_kanji == nil
      assert state.user_stats == stats
      assert state.quiz_error == false
    end

    test "propagates non-:not_found errors from due result" do
      stats = %{total: 3}

      assert {:error, :boom} = SessionState.init_state({:ok, stats}, {:error, :boom})
    end

    test "degrades stats to empty map when stats result is an error" do
      assert {:ok, state} = SessionState.init_state({:error, :nostats}, {:ok, []})
      assert state.user_stats == %{}
    end
  end

  describe "restored_state/3" do
    test "returns session_not_found when session result is an error" do
      assert {:error, :session_not_found} =
               SessionState.restored_state({:error, :x}, {:ok, %{}}, {:ok, []})
    end

    test "propagates stats error when session is ok but stats fails" do
      session_data = %{
        current_kanji: nil,
        answers_count: 0,
        last_answer_times: []
      }

      assert {:error, :r} =
               SessionState.restored_state({:ok, session_data}, {:error, :r}, {:ok, []})
    end

    test "returns ok map with nil kanji and nil current_progress when current_kanji is nil" do
      session_data = %{
        current_kanji: nil,
        answers_count: 3,
        last_answer_times: [1]
      }

      stats = %{total: 7}

      assert {:ok, state} =
               SessionState.restored_state({:ok, session_data}, {:ok, stats}, {:ok, []})

      assert state.current_kanji == nil
      assert state.current_progress == nil
      assert state.answers_count == 3
      assert state.last_answer_times == [1]
      assert state.user_stats == stats
      assert state.quiz_error == false
    end

    test "matches current_progress when first due progress kanji.id matches current_kanji.id" do
      kanji = %{id: "k1"}
      progress = %{kanji: %{id: "k1"}}

      session_data = %{
        current_kanji: kanji,
        answers_count: nil,
        last_answer_times: nil
      }

      stats = %{total: 2}

      assert {:ok, state} =
               SessionState.restored_state(
                 {:ok, session_data},
                 {:ok, stats},
                 {:ok, [progress]}
               )

      assert state.current_progress == progress
      assert state.answers_count == 0
      assert state.last_answer_times == []
    end

    test "returns nil current_progress when first due kanji.id does not match current_kanji.id" do
      kanji = %{id: "k1"}
      other_progress = %{kanji: %{id: "k2"}}

      session_data = %{
        current_kanji: kanji,
        answers_count: nil,
        last_answer_times: nil
      }

      stats = %{total: 2}

      assert {:ok, state} =
               SessionState.restored_state(
                 {:ok, session_data},
                 {:ok, stats},
                 {:ok, [other_progress]}
               )

      assert state.current_progress == nil
    end
  end
end
