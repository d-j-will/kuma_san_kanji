defmodule KumaSanKanji.SRS.StageTest do
  use ExUnit.Case, async: true

  alias KumaSanKanji.SRS.Stage

  describe "stages/0" do
    test "returns all 9 stage numbers" do
      assert Stage.stages() == [1, 2, 3, 4, 5, 6, 7, 8, 9]
    end
  end

  describe "groups/0" do
    test "returns ordered list of group atoms" do
      assert Stage.groups() == [:mezame, :sakari, :minori, :chikara, :tomin]
    end
  end

  describe "stages_for_group/1" do
    test "returns Mezame stages" do
      assert {:ok, [1, 2, 3, 4]} = Stage.stages_for_group(:mezame)
    end

    test "returns Sakari stages" do
      assert {:ok, [5, 6]} = Stage.stages_for_group(:sakari)
    end

    test "returns Minori stages" do
      assert {:ok, [7]} = Stage.stages_for_group(:minori)
    end

    test "returns Chikara stages" do
      assert {:ok, [8]} = Stage.stages_for_group(:chikara)
    end

    test "returns Tomin stages" do
      assert {:ok, [9]} = Stage.stages_for_group(:tomin)
    end

    test "returns error for invalid group" do
      assert {:error, :invalid_group} = Stage.stages_for_group(:nonexistent)
    end

    test "returns error for non-atom input" do
      assert {:error, :invalid_group} = Stage.stages_for_group("mezame")
    end
  end

  describe "advance/1" do
    test "advances stage 1 to 2" do
      assert {:ok, 2} = Stage.advance(1)
    end

    test "advances stage 2 to 3" do
      assert {:ok, 3} = Stage.advance(2)
    end

    test "advances stage 3 to 4" do
      assert {:ok, 4} = Stage.advance(3)
    end

    test "advances stage 4 to 5" do
      assert {:ok, 5} = Stage.advance(4)
    end

    test "advances stage 5 to 6" do
      assert {:ok, 6} = Stage.advance(5)
    end

    test "advances stage 6 to 7" do
      assert {:ok, 7} = Stage.advance(6)
    end

    test "advances stage 7 to 8" do
      assert {:ok, 8} = Stage.advance(7)
    end

    test "advances stage 8 to 9" do
      assert {:ok, 9} = Stage.advance(8)
    end

    test "stage 9 remains at 9 (capped)" do
      assert {:ok, 9} = Stage.advance(9)
    end

    test "returns error for stage 0" do
      assert {:error, :invalid_stage} = Stage.advance(0)
    end

    test "returns error for stage 10" do
      assert {:error, :invalid_stage} = Stage.advance(10)
    end

    test "returns error for negative stage" do
      assert {:error, :invalid_stage} = Stage.advance(-1)
    end

    test "returns error for non-integer input" do
      assert {:error, :invalid_stage} = Stage.advance("1")
    end

    test "returns error for float input" do
      assert {:error, :invalid_stage} = Stage.advance(1.5)
    end

    test "returns error for nil input" do
      assert {:error, :invalid_stage} = Stage.advance(nil)
    end
  end

  describe "penalize/2" do
    # Mezame stages (1-4): penalty_factor = 1
    test "0 incorrect returns same stage" do
      assert {:ok, 3} = Stage.penalize(3, 0)
    end

    test "0 incorrect at stage 1 stays at 1" do
      assert {:ok, 1} = Stage.penalize(1, 0)
    end

    test "Mezame: 1 incorrect drops by ceil(1/2)*1 = 1" do
      assert {:ok, 3} = Stage.penalize(4, 1)
    end

    test "Mezame: 2 incorrect drops by ceil(2/2)*1 = 1" do
      assert {:ok, 3} = Stage.penalize(4, 2)
    end

    test "Mezame: 3 incorrect drops by ceil(3/2)*1 = 2" do
      assert {:ok, 2} = Stage.penalize(4, 3)
    end

    test "Mezame: 4 incorrect drops by ceil(4/2)*1 = 2" do
      assert {:ok, 2} = Stage.penalize(4, 4)
    end

    test "Mezame: penalty never drops below 1" do
      assert {:ok, 1} = Stage.penalize(2, 10)
    end

    test "Mezame: penalty at stage 1 stays at 1" do
      assert {:ok, 1} = Stage.penalize(1, 5)
    end

    # Sakari+ stages (5-9): penalty_factor = 2
    test "Sakari: 1 incorrect drops by ceil(1/2)*2 = 2" do
      assert {:ok, 4} = Stage.penalize(6, 1)
    end

    test "Sakari: 2 incorrect drops by ceil(2/2)*2 = 2" do
      assert {:ok, 4} = Stage.penalize(6, 2)
    end

    test "Sakari: 3 incorrect drops by ceil(3/2)*2 = 4" do
      assert {:ok, 2} = Stage.penalize(6, 3)
    end

    test "Sakari: 4 incorrect drops by ceil(4/2)*2 = 4" do
      assert {:ok, 2} = Stage.penalize(6, 4)
    end

    test "Chikara: 1 incorrect drops by ceil(1/2)*2 = 2" do
      assert {:ok, 6} = Stage.penalize(8, 1)
    end

    test "Chikara: 3 incorrect drops by ceil(3/2)*2 = 4" do
      assert {:ok, 4} = Stage.penalize(8, 3)
    end

    test "Tomin: penalty applies with factor 2" do
      # ceil(1/2)*2 = 2 => 9 - 2 = 7
      assert {:ok, 7} = Stage.penalize(9, 1)
    end

    test "high penalty never drops below 1" do
      assert {:ok, 1} = Stage.penalize(5, 100)
    end

    test "Sakari: 0 incorrect returns same stage" do
      assert {:ok, 6} = Stage.penalize(6, 0)
    end

    test "returns error for invalid stage" do
      assert {:error, :invalid_stage} = Stage.penalize(0, 1)
    end

    test "returns error for stage 10" do
      assert {:error, :invalid_stage} = Stage.penalize(10, 1)
    end

    test "returns error for negative incorrect_count" do
      assert {:error, :invalid_stage} = Stage.penalize(5, -1)
    end

    test "returns error for non-integer stage" do
      assert {:error, :invalid_stage} = Stage.penalize("5", 1)
    end

    test "returns error for nil stage" do
      assert {:error, :invalid_stage} = Stage.penalize(nil, 1)
    end
  end

  describe "interval/1" do
    test "stage 1: 4 hours = 14400 seconds" do
      assert {:ok, 14_400} = Stage.interval(1)
    end

    test "stage 2: 8 hours = 28800 seconds" do
      assert {:ok, 28_800} = Stage.interval(2)
    end

    test "stage 3: 1 day = 86400 seconds" do
      assert {:ok, 86_400} = Stage.interval(3)
    end

    test "stage 4: 2 days = 172800 seconds" do
      assert {:ok, 172_800} = Stage.interval(4)
    end

    test "stage 5: 1 week = 604800 seconds" do
      assert {:ok, 604_800} = Stage.interval(5)
    end

    test "stage 6: 2 weeks = 1209600 seconds" do
      assert {:ok, 1_209_600} = Stage.interval(6)
    end

    test "stage 7: 1 month = 2592000 seconds" do
      assert {:ok, 2_592_000} = Stage.interval(7)
    end

    test "stage 8: 4 months = 10368000 seconds" do
      assert {:ok, 10_368_000} = Stage.interval(8)
    end

    test "stage 9: nil (retired)" do
      assert {:ok, nil} = Stage.interval(9)
    end

    test "returns error for stage 0" do
      assert {:error, :invalid_stage} = Stage.interval(0)
    end

    test "returns error for stage 10" do
      assert {:error, :invalid_stage} = Stage.interval(10)
    end

    test "returns error for non-integer" do
      assert {:error, :invalid_stage} = Stage.interval("1")
    end
  end

  describe "info/1" do
    test "stage 1 returns Mezame Awakening I info" do
      assert {:ok, info} = Stage.info(1)
      assert info.name == :mezame_1
      assert info.group == :mezame
      assert info.label == "Awakening I"
      assert info.japanese == "目覚め"
      assert info.color == "#F4A7BB"
    end

    test "stage 2 returns Mezame Awakening II info" do
      assert {:ok, info} = Stage.info(2)
      assert info.name == :mezame_2
      assert info.group == :mezame
      assert info.label == "Awakening II"
      assert info.japanese == "目覚め"
      assert info.color == "#F4A7BB"
    end

    test "stage 3 returns Mezame Awakening III info" do
      assert {:ok, info} = Stage.info(3)
      assert info.name == :mezame_3
      assert info.group == :mezame
      assert info.label == "Awakening III"
    end

    test "stage 4 returns Mezame Awakening IV info" do
      assert {:ok, info} = Stage.info(4)
      assert info.name == :mezame_4
      assert info.group == :mezame
      assert info.label == "Awakening IV"
    end

    test "stage 5 returns Sakari Peak I info" do
      assert {:ok, info} = Stage.info(5)
      assert info.name == :sakari_1
      assert info.group == :sakari
      assert info.label == "Peak I"
      assert info.japanese == "盛り"
      assert info.color == "#4CAF50"
    end

    test "stage 6 returns Sakari Peak II info" do
      assert {:ok, info} = Stage.info(6)
      assert info.name == :sakari_2
      assert info.group == :sakari
      assert info.label == "Peak II"
      assert info.japanese == "盛り"
      assert info.color == "#4CAF50"
    end

    test "stage 7 returns Minori Harvest info" do
      assert {:ok, info} = Stage.info(7)
      assert info.name == :minori
      assert info.group == :minori
      assert info.label == "Harvest"
      assert info.japanese == "実り"
      assert info.color == "#FF9800"
    end

    test "stage 8 returns Chikara Strength info" do
      assert {:ok, info} = Stage.info(8)
      assert info.name == :chikara
      assert info.group == :chikara
      assert info.label == "Strength"
      assert info.japanese == "力"
      assert info.color == "#1E88E5"
    end

    test "stage 9 returns Tomin Hibernation info" do
      assert {:ok, info} = Stage.info(9)
      assert info.name == :tomin
      assert info.group == :tomin
      assert info.label == "Hibernation"
      assert info.japanese == "冬眠"
      assert info.color == "#9E9E9E"
    end

    test "info map contains exactly 5 keys" do
      {:ok, info} = Stage.info(1)
      assert map_size(info) == 5
      assert Map.keys(info) |> Enum.sort() == [:color, :group, :japanese, :label, :name]
    end

    test "returns error for stage 0" do
      assert {:error, :invalid_stage} = Stage.info(0)
    end

    test "returns error for stage 10" do
      assert {:error, :invalid_stage} = Stage.info(10)
    end

    test "returns error for non-integer" do
      assert {:error, :invalid_stage} = Stage.info(nil)
    end
  end

  describe "hibernated?/1" do
    test "returns true for stage 9" do
      assert {:ok, true} = Stage.hibernated?(9)
    end

    test "returns false for stage 1" do
      assert {:ok, false} = Stage.hibernated?(1)
    end

    test "returns false for all non-9 stages" do
      for stage <- 1..8 do
        assert {:ok, false} = Stage.hibernated?(stage)
      end
    end

    test "returns error for stage 0" do
      assert {:error, :invalid_stage} = Stage.hibernated?(0)
    end

    test "returns error for stage 10" do
      assert {:error, :invalid_stage} = Stage.hibernated?(10)
    end

    test "returns error for non-integer" do
      assert {:error, :invalid_stage} = Stage.hibernated?("9")
    end
  end
end
