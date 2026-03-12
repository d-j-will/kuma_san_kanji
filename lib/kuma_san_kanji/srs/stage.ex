defmodule KumaSanKanji.SRS.Stage do
  @moduledoc """
  Bear Seasons SRS stage system.

  Maps spaced-repetition stages to a bear's seasonal journey through the year:
  from Mezame (Awakening) in spring, through Sakari (Peak) and Minori (Harvest)
  in summer/autumn, gaining Chikara (Strength) into winter, and finally reaching
  Tomin (Hibernation) — mastery so deep the kanji sleeps peacefully in long-term
  memory.

  Nine stages across five named groups, each with increasing review intervals.
  """

  @type stage :: 1..9
  @type group :: :mezame | :sakari | :minori | :chikara | :tomin

  @stages_data %{
    1 => %{
      name: :mezame_1,
      group: :mezame,
      label: "Awakening I",
      japanese: "目覚め",
      color: "#F4A7BB",
      interval: 14_400
    },
    2 => %{
      name: :mezame_2,
      group: :mezame,
      label: "Awakening II",
      japanese: "目覚め",
      color: "#F4A7BB",
      interval: 28_800
    },
    3 => %{
      name: :mezame_3,
      group: :mezame,
      label: "Awakening III",
      japanese: "目覚め",
      color: "#F4A7BB",
      interval: 86_400
    },
    4 => %{
      name: :mezame_4,
      group: :mezame,
      label: "Awakening IV",
      japanese: "目覚め",
      color: "#F4A7BB",
      interval: 172_800
    },
    5 => %{
      name: :sakari_1,
      group: :sakari,
      label: "Peak I",
      japanese: "盛り",
      color: "#4CAF50",
      interval: 604_800
    },
    6 => %{
      name: :sakari_2,
      group: :sakari,
      label: "Peak II",
      japanese: "盛り",
      color: "#4CAF50",
      interval: 1_209_600
    },
    7 => %{
      name: :minori,
      group: :minori,
      label: "Harvest",
      japanese: "実り",
      color: "#FF9800",
      interval: 2_592_000
    },
    8 => %{
      name: :chikara,
      group: :chikara,
      label: "Strength",
      japanese: "力",
      color: "#1E88E5",
      interval: 10_368_000
    },
    9 => %{
      name: :tomin,
      group: :tomin,
      label: "Hibernation",
      japanese: "冬眠",
      color: "#9E9E9E",
      interval: nil
    }
  }

  @valid_stages Map.keys(@stages_data) |> Enum.sort()
  @groups [:mezame, :sakari, :minori, :chikara, :tomin]

  @group_stages %{
    mezame: [1, 2, 3, 4],
    sakari: [5, 6],
    minori: [7],
    chikara: [8],
    tomin: [9]
  }

  @doc """
  Returns the list of all stage numbers (1 through 9).
  """
  @spec stages() :: [stage()]
  def stages, do: @valid_stages

  @doc """
  Returns the ordered list of group atoms.
  """
  @spec groups() :: [group()]
  def groups, do: @groups

  @doc """
  Returns the list of stage numbers belonging to the given group.

  ## Examples

      iex> KumaSanKanji.SRS.Stage.stages_for_group(:mezame)
      [1, 2, 3, 4]

      iex> KumaSanKanji.SRS.Stage.stages_for_group(:tomin)
      [9]
  """
  @spec stages_for_group(group()) :: {:ok, [stage()]} | {:error, :invalid_group}
  def stages_for_group(group) when group in @groups do
    {:ok, Map.fetch!(@group_stages, group)}
  end

  def stages_for_group(_group), do: {:error, :invalid_group}

  @doc """
  Advances to the next stage, capped at stage 9.

  ## Examples

      iex> KumaSanKanji.SRS.Stage.advance(1)
      {:ok, 2}

      iex> KumaSanKanji.SRS.Stage.advance(9)
      {:ok, 9}
  """
  @spec advance(stage()) :: {:ok, stage()} | {:error, :invalid_stage}
  def advance(stage) when is_integer(stage) and stage >= 1 and stage <= 9 do
    {:ok, min(stage + 1, 9)}
  end

  def advance(_stage), do: {:error, :invalid_stage}

  @doc """
  Applies a penalty based on incorrect answers, dropping the stage back.

  Penalty factor is 1 for Mezame stages (1-4) and 2 for stages 5+.
  Formula: `new_stage = max(1, current_stage - (ceil(incorrect_count / 2) * penalty_factor))`

  An `incorrect_count` of 0 returns the same stage.

  ## Examples

      iex> KumaSanKanji.SRS.Stage.penalize(5, 1)
      {:ok, 4}

      iex> KumaSanKanji.SRS.Stage.penalize(8, 3)
      {:ok, 4}
  """
  @spec penalize(stage(), non_neg_integer()) :: {:ok, stage()} | {:error, :invalid_stage}
  def penalize(stage, incorrect_count)
      when is_integer(stage) and stage >= 1 and stage <= 9 and
             is_integer(incorrect_count) and incorrect_count >= 0 do
    if incorrect_count == 0 do
      {:ok, stage}
    else
      penalty_factor = if stage <= 4, do: 1, else: 2
      drop = ceil(incorrect_count / 2) * penalty_factor
      {:ok, max(1, stage - drop)}
    end
  end

  def penalize(_stage, _incorrect_count), do: {:error, :invalid_stage}

  @doc """
  Returns the review interval in seconds for the given stage.

  Returns `nil` for stage 9 (Hibernation / retired).

  ## Examples

      iex> KumaSanKanji.SRS.Stage.interval(1)
      {:ok, 14400}

      iex> KumaSanKanji.SRS.Stage.interval(9)
      {:ok, nil}
  """
  @spec interval(stage()) :: {:ok, non_neg_integer() | nil} | {:error, :invalid_stage}
  def interval(stage) when is_integer(stage) and stage >= 1 and stage <= 9 do
    {:ok, @stages_data[stage].interval}
  end

  def interval(_stage), do: {:error, :invalid_stage}

  @doc """
  Returns a map of metadata for the given stage.

  Keys: `:name`, `:group`, `:label`, `:japanese`, `:color`.

  ## Examples

      iex> {:ok, info} = KumaSanKanji.SRS.Stage.info(1)
      iex> info.label
      "Awakening I"
  """
  @spec info(stage()) ::
          {:ok,
           %{
             name: atom(),
             group: group(),
             label: String.t(),
             japanese: String.t(),
             color: String.t()
           }}
          | {:error, :invalid_stage}
  def info(stage) when is_integer(stage) and stage >= 1 and stage <= 9 do
    data = @stages_data[stage]

    {:ok,
     %{
       name: data.name,
       group: data.group,
       label: data.label,
       japanese: data.japanese,
       color: data.color
     }}
  end

  def info(_stage), do: {:error, :invalid_stage}

  @doc """
  Returns `true` if the stage is Hibernation (stage 9), meaning the kanji is retired.

  ## Examples

      iex> KumaSanKanji.SRS.Stage.hibernated?(9)
      {:ok, true}

      iex> KumaSanKanji.SRS.Stage.hibernated?(5)
      {:ok, false}
  """
  @spec hibernated?(stage()) :: {:ok, boolean()} | {:error, :invalid_stage}
  def hibernated?(stage) when is_integer(stage) and stage >= 1 and stage <= 9 do
    {:ok, stage == 9}
  end

  def hibernated?(_stage), do: {:error, :invalid_stage}

  @doc """
  Returns the hex color for a group atom.

  ## Examples

      iex> KumaSanKanji.SRS.Stage.group_color(:mezame)
      "#F4A7BB"
  """
  @spec group_color(group()) :: String.t() | nil
  def group_color(group) when group in @groups do
    # Use the first stage of the group to get the color
    [first_stage | _] = Map.fetch!(@group_stages, group)
    @stages_data[first_stage].color
  end

  def group_color(_group), do: nil

  @doc """
  Returns the Japanese name for a group atom.

  ## Examples

      iex> KumaSanKanji.SRS.Stage.group_japanese(:mezame)
      "目覚め"
  """
  @spec group_japanese(group()) :: String.t() | nil
  def group_japanese(group) when group in @groups do
    [first_stage | _] = Map.fetch!(@group_stages, group)
    @stages_data[first_stage].japanese
  end

  def group_japanese(_group), do: nil
end
