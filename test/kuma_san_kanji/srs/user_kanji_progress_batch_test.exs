defmodule KumaSanKanji.SRS.UserKanjiProgressBatchTest do
  @moduledoc "Tests for the batch query action on UserKanjiProgress."
  use KumaSanKanjiWeb.ConnCase, async: false

  import KumaSanKanji.LearningPathHelpers

  alias KumaSanKanji.SRS.UserKanjiProgress

  describe "list_for_user_and_kanji_ids/3" do
    test "returns progress records matching the given kanji_ids for a user" do
      # Given a user with progress on some kanji
      {_conn, user} = create_authenticated_learner(build_conn(), "batch-test")
      {_group, kanji_list} = create_numbers_group()

      # Mark first 2 kanji as learned
      [k1, k2 | _rest] = kanji_list
      mark_kanji_learned(user, k1)
      mark_kanji_learned(user, k2)

      # When we batch-query for all 4 kanji ids
      all_ids = Enum.map(kanji_list, & &1.id)
      {:ok, results} = UserKanjiProgress.list_for_user_and_kanji_ids(user.id, all_ids, actor: user)

      # Then we get exactly 2 records back (only the learned ones)
      assert length(results) == 2
      result_kanji_ids = Enum.map(results, & &1.kanji_id) |> MapSet.new()
      assert MapSet.member?(result_kanji_ids, k1.id)
      assert MapSet.member?(result_kanji_ids, k2.id)
    end

    test "returns empty list when no progress exists" do
      {_conn, user} = create_authenticated_learner(build_conn(), "batch-empty")
      {_group, kanji_list} = create_numbers_group()

      all_ids = Enum.map(kanji_list, & &1.id)
      {:ok, results} = UserKanjiProgress.list_for_user_and_kanji_ids(user.id, all_ids, actor: user)

      assert results == []
    end

    test "does not return progress for other users" do
      {_conn, user_a} = create_authenticated_learner(build_conn(), "batch-a")
      {_conn, user_b} = create_authenticated_learner(build_conn(), "batch-b")
      {_group, kanji_list} = create_numbers_group()

      [k1 | _] = kanji_list
      mark_kanji_learned(user_a, k1)

      all_ids = Enum.map(kanji_list, & &1.id)
      {:ok, results} = UserKanjiProgress.list_for_user_and_kanji_ids(user_b.id, all_ids, actor: user_b)

      assert results == []
    end

    test "returns records with srs_stage field populated" do
      {_conn, user} = create_authenticated_learner(build_conn(), "batch-stage")
      {_group, kanji_list} = create_numbers_group()

      [k1 | _] = kanji_list
      mark_kanji_learned(user, k1)

      all_ids = Enum.map(kanji_list, & &1.id)
      {:ok, [progress]} = UserKanjiProgress.list_for_user_and_kanji_ids(user.id, all_ids, actor: user)

      assert progress.srs_stage == 1
      assert progress.kanji_id == k1.id
    end
  end
end
