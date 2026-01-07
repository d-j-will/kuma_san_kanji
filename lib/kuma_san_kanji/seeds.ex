defmodule KumaSanKanji.Seeds do
  @moduledoc """
  Seeds for the Kuma-san Kanji application.
  """

  require Ash.Query
  alias KumaSanKanji.Domain

  def seed_all do
    # Seed Kanji data
    insert_initial_data()
    # Backfill radicals for existing kanji records that have no radical_id yet.
    IO.puts("Backfilling radicals for existing kanji without radical_id ...")

    missing =
      KumaSanKanji.Kanji.Kanji
      |> Ash.Query.filter(is_nil(radical_id))
      |> Ash.read!(authorize?: false)

    Enum.each(missing, fn kanji ->
      char = kanji.character

      # Simple heuristic mapping: use the character itself if it is a radical glyph; else attempt a few known reductions
      candidate =
        with {:ok, _} <- Domain.get_radical_by_glyph(char) do
          char
        else
          _ ->
            cond do
              String.contains?(char, "林") -> "木"
              String.contains?(char, "森") -> "木"
              true -> nil
            end
        end

      case candidate do
        nil ->
          :noop

        glyph ->
          case Domain.get_radical_by_glyph(glyph) do
            {:ok, radical} ->
              kanji
              |> Ash.Changeset.for_update(:update, %{radical_id: radical.id}, authorize?: false)
              |> Ash.update!(authorize?: false)

            _ ->
              :noop
          end
      end
    end)

    IO.puts("Backfill complete: #{Enum.count(missing)} kanji checked.")
    # Seed Content data
    KumaSanKanji.Content.Seeds.insert_initial_data()
  end

  def insert_initial_data do
    # ------------------------------------------------------------------
    # Radicals seed data (214). For brevity of comments, only essential
    # metadata is provided. Frequency rank is left nil for now.
    # High-yield flagged based on handbook section.
    # ------------------------------------------------------------------
    radicals = [
      %{kangxi_index: 1, glyph: "一", stroke_count: 1, meaning: "one", japanese_name: "いち"},
      %{kangxi_index: 2, glyph: "丨", stroke_count: 1, meaning: "line", japanese_name: "ぼう"},
      %{kangxi_index: 3, glyph: "丶", stroke_count: 1, meaning: "dot", japanese_name: "てん"},
      %{kangxi_index: 4, glyph: "丿", stroke_count: 1, meaning: "slash", japanese_name: "の"},
      %{
        kangxi_index: 5,
        glyph: "乙",
        stroke_count: 1,
        meaning: "second",
        japanese_name: "おつ",
        alt_forms: ["乚"]
      },
      %{kangxi_index: 6, glyph: "亅", stroke_count: 1, meaning: "hook", japanese_name: "かぎ"},
      %{kangxi_index: 7, glyph: "二", stroke_count: 2, meaning: "two", japanese_name: "に"},
      %{kangxi_index: 8, glyph: "亠", stroke_count: 2, meaning: "lid", japanese_name: "なべぶた"},
      %{
        kangxi_index: 9,
        glyph: "人",
        stroke_count: 2,
        meaning: "person",
        japanese_name: "ひと",
        high_yield: true,
        alt_forms: ["亻"]
      },
      %{kangxi_index: 10, glyph: "儿", stroke_count: 2, meaning: "legs", japanese_name: "ひとあし"},
      %{kangxi_index: 11, glyph: "入", stroke_count: 2, meaning: "enter", japanese_name: "いる"},
      %{
        kangxi_index: 12,
        glyph: "八",
        stroke_count: 2,
        meaning: "eight",
        japanese_name: "はち",
        alt_forms: ["丷"]
      },
      %{
        kangxi_index: 13,
        glyph: "冂",
        stroke_count: 2,
        meaning: "wide box",
        japanese_name: "けいがまえ"
      },
      %{kangxi_index: 14, glyph: "冖", stroke_count: 2, meaning: "cover", japanese_name: "わかんむり"},
      %{kangxi_index: 15, glyph: "冫", stroke_count: 2, meaning: "ice", japanese_name: "にすい"},
      %{kangxi_index: 16, glyph: "几", stroke_count: 2, meaning: "table", japanese_name: "つくえ"},
      %{
        kangxi_index: 17,
        glyph: "凵",
        stroke_count: 2,
        meaning: "open box",
        japanese_name: "うけばこ"
      },
      %{
        kangxi_index: 18,
        glyph: "刀",
        stroke_count: 2,
        meaning: "knife",
        japanese_name: "かたな",
        alt_forms: ["刂"]
      },
      %{kangxi_index: 19, glyph: "力", stroke_count: 2, meaning: "power", japanese_name: "ちから"},
      %{kangxi_index: 20, glyph: "勹", stroke_count: 2, meaning: "wrap", japanese_name: "つつみがまえ"},
      %{kangxi_index: 21, glyph: "匕", stroke_count: 2, meaning: "spoon", japanese_name: "さじ"},
      %{kangxi_index: 22, glyph: "匚", stroke_count: 2, meaning: "box", japanese_name: "はこがまえ"},
      %{
        kangxi_index: 23,
        glyph: "匸",
        stroke_count: 2,
        meaning: "conceal",
        japanese_name: "かくしがまえ"
      },
      %{kangxi_index: 24, glyph: "十", stroke_count: 2, meaning: "ten", japanese_name: "じゅう"},
      %{
        kangxi_index: 25,
        glyph: "卜",
        stroke_count: 2,
        meaning: "divination",
        japanese_name: "ぼく"
      },
      %{
        kangxi_index: 26,
        glyph: "卩",
        stroke_count: 2,
        meaning: "seal",
        japanese_name: "ふしづくり",
        alt_forms: ["⺋"]
      },
      %{kangxi_index: 27, glyph: "厂", stroke_count: 2, meaning: "cliff", japanese_name: "がんだれ"},
      %{kangxi_index: 28, glyph: "厶", stroke_count: 2, meaning: "private", japanese_name: "む"},
      %{
        kangxi_index: 29,
        glyph: "又",
        stroke_count: 2,
        meaning: "right hand",
        japanese_name: "また"
      },
      %{
        kangxi_index: 30,
        glyph: "口",
        stroke_count: 3,
        meaning: "mouth",
        japanese_name: "くち",
        high_yield: true
      },
      %{
        kangxi_index: 31,
        glyph: "囗",
        stroke_count: 3,
        meaning: "enclosure",
        japanese_name: "くにがまえ"
      },
      %{
        kangxi_index: 32,
        glyph: "土",
        stroke_count: 3,
        meaning: "earth",
        japanese_name: "つち",
        high_yield: true
      },
      %{kangxi_index: 33, glyph: "士", stroke_count: 3, meaning: "scholar", japanese_name: "さむらい"},
      %{
        kangxi_index: 34,
        glyph: "夂",
        stroke_count: 3,
        meaning: "go (late)",
        japanese_name: "ふゆがしら"
      },
      %{
        kangxi_index: 35,
        glyph: "夊",
        stroke_count: 3,
        meaning: "go slowly",
        japanese_name: "すいにょう"
      },
      %{kangxi_index: 36, glyph: "夕", stroke_count: 3, meaning: "evening", japanese_name: "た"},
      %{kangxi_index: 37, glyph: "大", stroke_count: 3, meaning: "big", japanese_name: "だい"},
      %{
        kangxi_index: 38,
        glyph: "女",
        stroke_count: 3,
        meaning: "woman",
        japanese_name: "おんな",
        high_yield: true
      },
      %{kangxi_index: 39, glyph: "子", stroke_count: 3, meaning: "child", japanese_name: "こ"},
      %{
        kangxi_index: 40,
        glyph: "宀",
        stroke_count: 3,
        meaning: "roof",
        japanese_name: "うかんむり",
        high_yield: true
      },
      %{kangxi_index: 41, glyph: "寸", stroke_count: 3, meaning: "inch", japanese_name: "すん"},
      %{
        kangxi_index: 42,
        glyph: "小",
        stroke_count: 3,
        meaning: "small",
        japanese_name: "しょう",
        alt_forms: ["⺌", "⺍"]
      },
      %{
        kangxi_index: 43,
        glyph: "尢",
        stroke_count: 3,
        meaning: "lame",
        japanese_name: "だいのまげあし",
        alt_forms: ["尣"]
      },
      %{kangxi_index: 44, glyph: "尸", stroke_count: 3, meaning: "corpse", japanese_name: "しかばね"},
      %{kangxi_index: 45, glyph: "屮", stroke_count: 3, meaning: "sprout", japanese_name: "てつ"},
      %{kangxi_index: 46, glyph: "山", stroke_count: 3, meaning: "mountain", japanese_name: "やま"},
      %{
        kangxi_index: 47,
        glyph: "巛",
        stroke_count: 3,
        meaning: "river",
        japanese_name: "まがりがわ",
        alt_forms: ["川", "巜"]
      },
      %{kangxi_index: 48, glyph: "工", stroke_count: 3, meaning: "work", japanese_name: "たくみ"},
      %{
        kangxi_index: 49,
        glyph: "己",
        stroke_count: 3,
        meaning: "self",
        japanese_name: "おのれ",
        alt_forms: ["巳", "已"]
      },
      %{kangxi_index: 50, glyph: "巾", stroke_count: 3, meaning: "cloth", japanese_name: "はば"},
      %{kangxi_index: 51, glyph: "干", stroke_count: 3, meaning: "dry", japanese_name: "ほす"},
      %{kangxi_index: 52, glyph: "幺", stroke_count: 3, meaning: "tiny", japanese_name: "いとがしら"},
      %{
        kangxi_index: 53,
        glyph: "广",
        stroke_count: 3,
        meaning: "dotted cliff",
        japanese_name: "まだれ"
      },
      %{
        kangxi_index: 54,
        glyph: "廴",
        stroke_count: 3,
        meaning: "long stride",
        japanese_name: "えんにょう"
      },
      %{
        kangxi_index: 55,
        glyph: "廾",
        stroke_count: 3,
        meaning: "two hands",
        japanese_name: "こまぬき"
      },
      %{
        kangxi_index: 56,
        glyph: "弋",
        stroke_count: 3,
        meaning: "javelin",
        japanese_name: "しきがまえ"
      },
      %{kangxi_index: 57, glyph: "弓", stroke_count: 3, meaning: "bow", japanese_name: "ゆみ"},
      %{
        kangxi_index: 58,
        glyph: "彑",
        stroke_count: 3,
        meaning: "snout",
        japanese_name: "けいがしら",
        alt_forms: ["彐"]
      },
      %{
        kangxi_index: 59,
        glyph: "彡",
        stroke_count: 3,
        meaning: "bristle",
        japanese_name: "さんづくり"
      },
      %{kangxi_index: 60, glyph: "彳", stroke_count: 3, meaning: "step", japanese_name: "ぎょうにんべん"},
      %{
        kangxi_index: 61,
        glyph: "心",
        stroke_count: 4,
        meaning: "heart",
        japanese_name: "こころ",
        high_yield: true,
        alt_forms: ["忄", "⺗"]
      },
      %{
        kangxi_index: 62,
        glyph: "戈",
        stroke_count: 4,
        meaning: "halberd",
        japanese_name: "ほこづくり"
      },
      %{
        kangxi_index: 63,
        glyph: "戶",
        stroke_count: 4,
        meaning: "door",
        japanese_name: "と",
        alt_forms: ["戸"]
      },
      %{
        kangxi_index: 64,
        glyph: "手",
        stroke_count: 4,
        meaning: "hand",
        japanese_name: "て",
        high_yield: true,
        alt_forms: ["扌", "龵"]
      },
      %{kangxi_index: 65, glyph: "支", stroke_count: 4, meaning: "branch", japanese_name: "し"},
      %{
        kangxi_index: 66,
        glyph: "攴",
        stroke_count: 4,
        meaning: "tap",
        japanese_name: "ぼくづくり",
        alt_forms: ["攵"]
      },
      %{kangxi_index: 67, glyph: "文", stroke_count: 4, meaning: "script", japanese_name: "ぶん"},
      %{kangxi_index: 68, glyph: "斗", stroke_count: 4, meaning: "dipper", japanese_name: "と"},
      %{kangxi_index: 69, glyph: "斤", stroke_count: 4, meaning: "axe", japanese_name: "おの"},
      %{kangxi_index: 70, glyph: "方", stroke_count: 4, meaning: "direction", japanese_name: "ほう"},
      %{kangxi_index: 71, glyph: "无", stroke_count: 4, meaning: "not", japanese_name: "む"},
      %{
        kangxi_index: 72,
        glyph: "日",
        stroke_count: 4,
        meaning: "sun",
        japanese_name: "ひ",
        high_yield: true
      },
      %{kangxi_index: 73, glyph: "曰", stroke_count: 4, meaning: "say", japanese_name: "ひらび"},
      %{
        kangxi_index: 74,
        glyph: "月",
        stroke_count: 4,
        meaning: "moon",
        japanese_name: "つき",
        high_yield: true
      },
      %{
        kangxi_index: 75,
        glyph: "木",
        stroke_count: 4,
        meaning: "tree",
        japanese_name: "き",
        high_yield: true
      },
      %{kangxi_index: 76, glyph: "欠", stroke_count: 4, meaning: "lack", japanese_name: "あくび"},
      %{kangxi_index: 77, glyph: "止", stroke_count: 4, meaning: "stop", japanese_name: "とめる"},
      %{
        kangxi_index: 78,
        glyph: "歹",
        stroke_count: 4,
        meaning: "death",
        japanese_name: "がつ",
        alt_forms: ["歺"]
      },
      %{kangxi_index: 79, glyph: "殳", stroke_count: 4, meaning: "weapon", japanese_name: "るまた"},
      %{
        kangxi_index: 80,
        glyph: "毋",
        stroke_count: 4,
        meaning: "do not",
        japanese_name: "なかれ",
        alt_forms: ["母"]
      },
      %{kangxi_index: 81, glyph: "比", stroke_count: 4, meaning: "compare", japanese_name: "くらべる"},
      %{kangxi_index: 82, glyph: "毛", stroke_count: 4, meaning: "fur", japanese_name: "け"},
      %{kangxi_index: 83, glyph: "氏", stroke_count: 4, meaning: "clan", japanese_name: "うじ"},
      %{
        kangxi_index: 84,
        glyph: "气",
        stroke_count: 4,
        meaning: "steam",
        japanese_name: "き",
        alt_forms: ["氣"]
      },
      %{
        kangxi_index: 85,
        glyph: "水",
        stroke_count: 4,
        meaning: "water",
        japanese_name: "みず",
        high_yield: true,
        alt_forms: ["氵", "氺"]
      },
      %{
        kangxi_index: 86,
        glyph: "火",
        stroke_count: 4,
        meaning: "fire",
        japanese_name: "ひ",
        high_yield: true,
        alt_forms: ["灬", "⺣"]
      },
      %{
        kangxi_index: 87,
        glyph: "爪",
        stroke_count: 4,
        meaning: "claw",
        japanese_name: "つめ",
        alt_forms: ["爫"]
      },
      %{kangxi_index: 88, glyph: "父", stroke_count: 4, meaning: "father", japanese_name: "ちち"},
      %{kangxi_index: 89, glyph: "爻", stroke_count: 4, meaning: "trigrams", japanese_name: "こう"},
      %{
        kangxi_index: 90,
        glyph: "爿",
        stroke_count: 4,
        meaning: "split wood",
        japanese_name: "しょうへん",
        alt_forms: ["丬"]
      },
      %{kangxi_index: 91, glyph: "片", stroke_count: 4, meaning: "slice", japanese_name: "かた"},
      %{kangxi_index: 92, glyph: "牙", stroke_count: 4, meaning: "tusk", japanese_name: "きば"},
      %{
        kangxi_index: 93,
        glyph: "牛",
        stroke_count: 4,
        meaning: "cow",
        japanese_name: "うし",
        alt_forms: ["牜", "⺧"]
      },
      %{
        kangxi_index: 94,
        glyph: "犬",
        stroke_count: 4,
        meaning: "dog",
        japanese_name: "いぬ",
        alt_forms: ["犭"]
      },
      %{
        kangxi_index: 95,
        glyph: "玄",
        stroke_count: 5,
        meaning: "mysterious",
        japanese_name: "げん"
      },
      %{
        kangxi_index: 96,
        glyph: "玉",
        stroke_count: 5,
        meaning: "jade",
        japanese_name: "たま",
        alt_forms: ["王", "玊"]
      },
      %{kangxi_index: 97, glyph: "瓜", stroke_count: 5, meaning: "melon", japanese_name: "うり"},
      %{kangxi_index: 98, glyph: "瓦", stroke_count: 5, meaning: "tile", japanese_name: "かわら"},
      %{kangxi_index: 99, glyph: "甘", stroke_count: 5, meaning: "sweet", japanese_name: "あまい"},
      %{kangxi_index: 100, glyph: "生", stroke_count: 5, meaning: "life", japanese_name: "うまれる"},
      %{kangxi_index: 101, glyph: "用", stroke_count: 5, meaning: "use", japanese_name: "もちいる"},
      %{kangxi_index: 102, glyph: "田", stroke_count: 5, meaning: "field", japanese_name: "た"},
      %{
        kangxi_index: 103,
        glyph: "疋",
        stroke_count: 5,
        meaning: "roll",
        japanese_name: "ひき",
        alt_forms: ["⺪"]
      },
      %{
        kangxi_index: 104,
        glyph: "疒",
        stroke_count: 5,
        meaning: "sickness",
        japanese_name: "やまいだれ"
      },
      %{
        kangxi_index: 105,
        glyph: "癶",
        stroke_count: 5,
        meaning: "foot steps",
        japanese_name: "はつがしら"
      },
      %{kangxi_index: 106, glyph: "白", stroke_count: 5, meaning: "white", japanese_name: "しろ"},
      %{kangxi_index: 107, glyph: "皮", stroke_count: 5, meaning: "skin", japanese_name: "かわ"},
      %{kangxi_index: 108, glyph: "皿", stroke_count: 5, meaning: "dish", japanese_name: "さら"},
      %{
        kangxi_index: 109,
        glyph: "目",
        stroke_count: 5,
        meaning: "eye",
        japanese_name: "め",
        high_yield: true,
        alt_forms: ["罒", "⺫"]
      },
      %{kangxi_index: 110, glyph: "矛", stroke_count: 5, meaning: "halberd", japanese_name: "ほこ"},
      %{kangxi_index: 111, glyph: "矢", stroke_count: 5, meaning: "arrow", japanese_name: "や"},
      %{
        kangxi_index: 112,
        glyph: "石",
        stroke_count: 5,
        meaning: "stone",
        japanese_name: "いし",
        high_yield: true
      },
      %{
        kangxi_index: 113,
        glyph: "示",
        stroke_count: 5,
        meaning: "altar",
        japanese_name: "しめす",
        alt_forms: ["礻"]
      },
      %{kangxi_index: 114, glyph: "禸", stroke_count: 5, meaning: "track", japanese_name: "じゅう"},
      %{kangxi_index: 115, glyph: "禾", stroke_count: 5, meaning: "grain", japanese_name: "のぎ"},
      %{kangxi_index: 116, glyph: "穴", stroke_count: 5, meaning: "cave", japanese_name: "あな"},
      %{kangxi_index: 117, glyph: "立", stroke_count: 5, meaning: "stand", japanese_name: "たつ"},
      %{
        kangxi_index: 118,
        glyph: "竹",
        stroke_count: 6,
        meaning: "bamboo",
        japanese_name: "たけ",
        high_yield: true,
        alt_forms: ["⺮"]
      },
      %{
        kangxi_index: 119,
        glyph: "米",
        stroke_count: 6,
        meaning: "rice",
        japanese_name: "こめ",
        high_yield: true
      },
      %{
        kangxi_index: 120,
        glyph: "糸",
        stroke_count: 6,
        meaning: "thread",
        japanese_name: "いと",
        high_yield: true,
        alt_forms: ["糹", "纟"]
      },
      %{kangxi_index: 121, glyph: "缶", stroke_count: 6, meaning: "jar", japanese_name: "かん"},
      %{
        kangxi_index: 122,
        glyph: "网",
        stroke_count: 6,
        meaning: "net",
        japanese_name: "あみ",
        alt_forms: ["罒", "⺲", "⺳"]
      },
      %{
        kangxi_index: 123,
        glyph: "羊",
        stroke_count: 6,
        meaning: "sheep",
        japanese_name: "ひつじ",
        alt_forms: ["⺶", "⺷"]
      },
      %{kangxi_index: 124, glyph: "羽", stroke_count: 6, meaning: "feather", japanese_name: "はね"},
      %{
        kangxi_index: 125,
        glyph: "老",
        stroke_count: 6,
        meaning: "old",
        japanese_name: "おい",
        alt_forms: ["耂"]
      },
      %{kangxi_index: 126, glyph: "而", stroke_count: 6, meaning: "and", japanese_name: "じ"},
      %{kangxi_index: 127, glyph: "耒", stroke_count: 6, meaning: "plow", japanese_name: "らいすき"},
      %{kangxi_index: 128, glyph: "耳", stroke_count: 6, meaning: "ear", japanese_name: "みみ"},
      %{
        kangxi_index: 129,
        glyph: "聿",
        stroke_count: 6,
        meaning: "brush",
        japanese_name: "ふで",
        alt_forms: ["⺻", "肀"]
      },
      %{
        kangxi_index: 130,
        glyph: "肉",
        stroke_count: 6,
        meaning: "flesh",
        japanese_name: "にく",
        alt_forms: ["月"]
      },
      %{kangxi_index: 131, glyph: "臣", stroke_count: 6, meaning: "minister", japanese_name: "しん"},
      %{kangxi_index: 132, glyph: "自", stroke_count: 6, meaning: "self", japanese_name: "みずから"},
      %{kangxi_index: 133, glyph: "至", stroke_count: 6, meaning: "arrive", japanese_name: "いたる"},
      %{kangxi_index: 134, glyph: "臼", stroke_count: 6, meaning: "mortar", japanese_name: "うす"},
      %{kangxi_index: 135, glyph: "舌", stroke_count: 6, meaning: "tongue", japanese_name: "した"},
      %{kangxi_index: 136, glyph: "舛", stroke_count: 6, meaning: "opposite", japanese_name: "まい"},
      %{kangxi_index: 137, glyph: "舟", stroke_count: 6, meaning: "boat", japanese_name: "ふね"},
      %{
        kangxi_index: 138,
        glyph: "艮",
        stroke_count: 6,
        meaning: "stopping",
        japanese_name: "うしとら"
      },
      %{kangxi_index: 139, glyph: "色", stroke_count: 6, meaning: "color", japanese_name: "いろ"},
      %{
        kangxi_index: 140,
        glyph: "艸",
        stroke_count: 6,
        meaning: "grass",
        japanese_name: "くさ",
        high_yield: true,
        alt_forms: ["艹"]
      },
      %{kangxi_index: 141, glyph: "虍", stroke_count: 6, meaning: "tiger", japanese_name: "とらがしら"},
      %{
        kangxi_index: 142,
        glyph: "虫",
        stroke_count: 6,
        meaning: "insect",
        japanese_name: "むし",
        high_yield: true
      },
      %{kangxi_index: 143, glyph: "血", stroke_count: 6, meaning: "blood", japanese_name: "ち"},
      %{kangxi_index: 144, glyph: "行", stroke_count: 6, meaning: "go", japanese_name: "ぎょう"},
      %{
        kangxi_index: 145,
        glyph: "衣",
        stroke_count: 6,
        meaning: "clothes",
        japanese_name: "ころも",
        alt_forms: ["衤"]
      },
      %{
        kangxi_index: 146,
        glyph: "襾",
        stroke_count: 6,
        meaning: "cover",
        japanese_name: "にし",
        alt_forms: ["西"]
      },
      %{kangxi_index: 147, glyph: "見", stroke_count: 7, meaning: "see", japanese_name: "みる"},
      %{kangxi_index: 148, glyph: "角", stroke_count: 7, meaning: "horn", japanese_name: "つの"},
      %{
        kangxi_index: 149,
        glyph: "言",
        stroke_count: 7,
        meaning: "speech",
        japanese_name: "こと",
        high_yield: true,
        alt_forms: ["訁", "讠"]
      },
      %{kangxi_index: 150, glyph: "谷", stroke_count: 7, meaning: "valley", japanese_name: "たに"},
      %{kangxi_index: 151, glyph: "豆", stroke_count: 7, meaning: "bean", japanese_name: "まめ"},
      %{kangxi_index: 152, glyph: "豕", stroke_count: 7, meaning: "pig", japanese_name: "いのこ"},
      %{kangxi_index: 153, glyph: "豸", stroke_count: 7, meaning: "beast", japanese_name: "むじなへん"},
      %{
        kangxi_index: 154,
        glyph: "貝",
        stroke_count: 7,
        meaning: "shell",
        japanese_name: "かい",
        high_yield: true
      },
      %{kangxi_index: 155, glyph: "赤", stroke_count: 7, meaning: "red", japanese_name: "あか"},
      %{kangxi_index: 156, glyph: "走", stroke_count: 7, meaning: "run", japanese_name: "はしる"},
      %{
        kangxi_index: 157,
        glyph: "足",
        stroke_count: 7,
        meaning: "foot",
        japanese_name: "あし",
        alt_forms: ["⻊"]
      },
      %{kangxi_index: 158, glyph: "身", stroke_count: 7, meaning: "body", japanese_name: "み"},
      %{
        kangxi_index: 159,
        glyph: "車",
        stroke_count: 7,
        meaning: "vehicle",
        japanese_name: "くるま",
        high_yield: true
      },
      %{kangxi_index: 160, glyph: "辛", stroke_count: 7, meaning: "bitter", japanese_name: "からい"},
      %{
        kangxi_index: 161,
        glyph: "辰",
        stroke_count: 7,
        meaning: "辰 (zodiac)",
        japanese_name: "しんのたつ"
      },
      %{
        kangxi_index: 162,
        glyph: "辵",
        stroke_count: 7,
        meaning: "walk",
        japanese_name: "しんにょう",
        high_yield: true,
        alt_forms: ["辶", "⻌", "⻍"]
      },
      %{
        kangxi_index: 163,
        glyph: "邑",
        stroke_count: 7,
        meaning: "village",
        japanese_name: "おおざと",
        alt_forms: ["阝"]
      },
      %{kangxi_index: 164, glyph: "酉", stroke_count: 7, meaning: "wine", japanese_name: "とり"},
      %{kangxi_index: 165, glyph: "采", stroke_count: 7, meaning: "pick", japanese_name: "とる"},
      %{kangxi_index: 166, glyph: "里", stroke_count: 7, meaning: "village", japanese_name: "さと"},
      %{
        kangxi_index: 167,
        glyph: "金",
        stroke_count: 8,
        meaning: "metal",
        japanese_name: "かね",
        high_yield: true,
        alt_forms: ["釒"]
      },
      %{
        kangxi_index: 168,
        glyph: "長",
        stroke_count: 8,
        meaning: "long",
        japanese_name: "ながい",
        alt_forms: ["镸"]
      },
      %{kangxi_index: 169, glyph: "門", stroke_count: 8, meaning: "gate", japanese_name: "もん"},
      %{
        kangxi_index: 170,
        glyph: "阜",
        stroke_count: 8,
        meaning: "mound",
        japanese_name: "こざと",
        alt_forms: ["阝"]
      },
      %{kangxi_index: 171, glyph: "隶", stroke_count: 8, meaning: "capture", japanese_name: "れい"},
      %{
        kangxi_index: 172,
        glyph: "隹",
        stroke_count: 8,
        meaning: "small bird",
        japanese_name: "ふるとり"
      },
      %{
        kangxi_index: 173,
        glyph: "雨",
        stroke_count: 8,
        meaning: "rain",
        japanese_name: "あめ",
        high_yield: true
      },
      %{
        kangxi_index: 174,
        glyph: "靑",
        stroke_count: 8,
        meaning: "blue",
        japanese_name: "あお",
        alt_forms: ["青"]
      },
      %{kangxi_index: 175, glyph: "非", stroke_count: 8, meaning: "not", japanese_name: "あらず"},
      %{kangxi_index: 176, glyph: "面", stroke_count: 9, meaning: "face", japanese_name: "めん"},
      %{kangxi_index: 177, glyph: "革", stroke_count: 9, meaning: "leather", japanese_name: "かわ"},
      %{
        kangxi_index: 178,
        glyph: "韋",
        stroke_count: 9,
        meaning: "tanned leather",
        japanese_name: "なめしがわ"
      },
      %{kangxi_index: 179, glyph: "韭", stroke_count: 9, meaning: "leek", japanese_name: "にら"},
      %{kangxi_index: 180, glyph: "音", stroke_count: 9, meaning: "sound", japanese_name: "おと"},
      %{kangxi_index: 181, glyph: "頁", stroke_count: 9, meaning: "head", japanese_name: "おおがい"},
      %{kangxi_index: 182, glyph: "風", stroke_count: 9, meaning: "wind", japanese_name: "かぜ"},
      %{kangxi_index: 183, glyph: "飛", stroke_count: 9, meaning: "fly", japanese_name: "とぶ"},
      %{
        kangxi_index: 184,
        glyph: "食",
        stroke_count: 9,
        meaning: "eat",
        japanese_name: "しょく",
        high_yield: true,
        alt_forms: ["飠", "⻞"]
      },
      %{kangxi_index: 185, glyph: "首", stroke_count: 9, meaning: "head", japanese_name: "くび"},
      %{
        kangxi_index: 186,
        glyph: "香",
        stroke_count: 9,
        meaning: "fragrance",
        japanese_name: "かおり"
      },
      %{
        kangxi_index: 187,
        glyph: "馬",
        stroke_count: 10,
        meaning: "horse",
        japanese_name: "うま",
        high_yield: true
      },
      %{kangxi_index: 188, glyph: "骨", stroke_count: 10, meaning: "bone", japanese_name: "ほね"},
      %{kangxi_index: 189, glyph: "高", stroke_count: 10, meaning: "tall", japanese_name: "たかい"},
      %{
        kangxi_index: 190,
        glyph: "髟",
        stroke_count: 10,
        meaning: "long hair",
        japanese_name: "かみがしら"
      },
      %{kangxi_index: 191, glyph: "鬥", stroke_count: 10, meaning: "fight", japanese_name: "とう"},
      %{
        kangxi_index: 192,
        glyph: "鬯",
        stroke_count: 10,
        meaning: "sacrificial wine",
        japanese_name: "ちょう"
      },
      %{kangxi_index: 193, glyph: "鬲", stroke_count: 10, meaning: "tripod", japanese_name: "かなえ"},
      %{kangxi_index: 194, glyph: "鬼", stroke_count: 10, meaning: "ghost", japanese_name: "おに"},
      %{
        kangxi_index: 195,
        glyph: "魚",
        stroke_count: 11,
        meaning: "fish",
        japanese_name: "うお",
        high_yield: true
      },
      %{
        kangxi_index: 196,
        glyph: "鳥",
        stroke_count: 11,
        meaning: "bird",
        japanese_name: "とり",
        high_yield: true
      },
      %{kangxi_index: 197, glyph: "鹵", stroke_count: 11, meaning: "salt", japanese_name: "ろ"},
      %{kangxi_index: 198, glyph: "鹿", stroke_count: 11, meaning: "deer", japanese_name: "しか"},
      %{
        kangxi_index: 199,
        glyph: "麥",
        stroke_count: 11,
        meaning: "wheat",
        japanese_name: "むぎ",
        alt_forms: ["麦"]
      },
      %{kangxi_index: 200, glyph: "麻", stroke_count: 11, meaning: "hemp", japanese_name: "あさ"},
      %{
        kangxi_index: 201,
        glyph: "黃",
        stroke_count: 12,
        meaning: "yellow",
        japanese_name: "き",
        alt_forms: ["黄"]
      },
      %{kangxi_index: 202, glyph: "黍", stroke_count: 12, meaning: "millet", japanese_name: "きび"},
      %{
        kangxi_index: 203,
        glyph: "黑",
        stroke_count: 12,
        meaning: "black",
        japanese_name: "くろ",
        alt_forms: ["黒"]
      },
      %{
        kangxi_index: 204,
        glyph: "黹",
        stroke_count: 12,
        meaning: "embroidery",
        japanese_name: "ち"
      },
      %{kangxi_index: 205, glyph: "黽", stroke_count: 13, meaning: "frog", japanese_name: "べん"},
      %{kangxi_index: 206, glyph: "鼎", stroke_count: 13, meaning: "tripod", japanese_name: "かなえ"},
      %{kangxi_index: 207, glyph: "鼓", stroke_count: 13, meaning: "drum", japanese_name: "つづみ"},
      %{kangxi_index: 208, glyph: "鼠", stroke_count: 13, meaning: "rat", japanese_name: "ねずみ"},
      %{kangxi_index: 209, glyph: "鼻", stroke_count: 14, meaning: "nose", japanese_name: "はな"},
      %{
        kangxi_index: 210,
        glyph: "齊",
        stroke_count: 14,
        meaning: "even",
        japanese_name: "せい",
        alt_forms: ["斉"]
      },
      %{
        kangxi_index: 211,
        glyph: "齒",
        stroke_count: 15,
        meaning: "tooth",
        japanese_name: "は",
        alt_forms: ["歯"]
      },
      %{
        kangxi_index: 212,
        glyph: "龍",
        stroke_count: 16,
        meaning: "dragon",
        japanese_name: "りゅう",
        alt_forms: ["竜"]
      },
      %{
        kangxi_index: 213,
        glyph: "龜",
        stroke_count: 16,
        meaning: "turtle",
        japanese_name: "かめ",
        alt_forms: ["亀"]
      },
      %{kangxi_index: 214, glyph: "龠", stroke_count: 17, meaning: "flute", japanese_name: "やく"}
    ]

    Enum.each(radicals, fn rad ->
      case Domain.get_radical_by_glyph(rad.glyph) do
        {:ok, _} ->
          :ok

        {:error, _} ->
          _ = Domain.create_radical(rad)
          :ok
      end
    end)

    # List of Kanji with their data
    kanji_list = [
      %{
        character: "水",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "water", is_primary: true},
          %{value: "liquid"}
        ],
        pronunciations: [
          %{value: "みず", type: "kun"},
          %{value: "スイ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "水を飲みます。",
            translation: "I drink water."
          },
          %{
            japanese: "水曜日は水泳に行きます。",
            translation: "On Wednesday, I go swimming."
          }
        ]
      },
      %{
        character: "火",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "fire", is_primary: true},
          %{value: "flame"}
        ],
        pronunciations: [
          %{value: "ひ", type: "kun"},
          %{value: "カ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "火をつけます。",
            translation: "I light a fire."
          },
          %{
            japanese: "火曜日に会議があります。",
            translation: "There is a meeting on Tuesday."
          }
        ]
      },
      %{
        character: "木",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "tree", is_primary: true},
          %{value: "wood"}
        ],
        pronunciations: [
          %{value: "き", type: "kun"},
          %{value: "モク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "公園に木がたくさんあります。",
            translation: "There are many trees in the park."
          },
          %{
            japanese: "木曜日に授業があります。",
            translation: "I have class on Thursday."
          }
        ]
      },
      # Additional kanji
      %{
        character: "山",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "mountain", is_primary: true},
          %{value: "hill"}
        ],
        pronunciations: [
          %{value: "やま", type: "kun"},
          %{value: "サン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "富士山は日本で一番高い山です。",
            translation: "Mount Fuji is the highest mountain in Japan."
          },
          %{
            japanese: "週末に山に登ります。",
            translation: "I climb mountains on weekends."
          }
        ]
      },
      %{
        character: "川",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "river", is_primary: true},
          %{value: "stream"}
        ],
        pronunciations: [
          %{value: "かわ", type: "kun"},
          %{value: "セン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "川で泳ぐのは危険です。",
            translation: "Swimming in the river is dangerous."
          },
          %{
            japanese: "この川は長いです。",
            translation: "This river is long."
          }
        ]
      },
      %{
        character: "日",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "day", is_primary: true},
          %{value: "sun"},
          %{value: "Japan"}
        ],
        pronunciations: [
          %{value: "ひ", type: "kun"},
          %{value: "ニチ", type: "on"},
          %{value: "ジツ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "今日はいい日です。",
            translation: "Today is a good day."
          },
          %{
            japanese: "日本語を勉強しています。",
            translation: "I am studying Japanese."
          }
        ]
      },
      %{
        character: "月",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "month", is_primary: true},
          %{value: "moon"}
        ],
        pronunciations: [
          %{value: "つき", type: "kun"},
          %{value: "ゲツ", type: "on"},
          %{value: "ガツ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "月がきれいですね。",
            translation: "The moon is beautiful, isn't it?"
          },
          %{
            japanese: "来月日本に行きます。",
            translation: "I'm going to Japan next month."
          }
        ]
      },
      %{
        character: "人",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "person", is_primary: true},
          %{value: "human being"}
        ],
        pronunciations: [
          %{value: "ひと", type: "kun"},
          %{value: "ジン", type: "on"},
          %{value: "ニン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "あの人は先生です。",
            translation: "That person is a teacher."
          },
          %{
            japanese: "日本人の友達がいます。",
            translation: "I have a Japanese friend."
          }
        ]
      },
      %{
        character: "一",
        grade: 1,
        stroke_count: 1,
        jlpt_level: 5,
        meanings: [
          %{value: "one", is_primary: true},
          %{value: "first"}
        ],
        pronunciations: [
          %{value: "ひと", type: "kun"},
          %{value: "イチ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "一人で行きました。",
            translation: "I went alone."
          },
          %{
            japanese: "一番好きな食べ物は何ですか。",
            translation: "What is your favorite food?"
          }
        ]
      },
      %{
        character: "二",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "two", is_primary: true},
          %{value: "second"}
        ],
        pronunciations: [
          %{value: "ふた", type: "kun"},
          %{value: "ニ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "二人で映画を見ました。",
            translation: "We watched a movie together (two people)."
          },
          %{
            japanese: "二階に住んでいます。",
            translation: "I live on the second floor."
          }
        ]
      },
      %{
        character: "三",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "three", is_primary: true}
        ],
        pronunciations: [
          %{value: "み", type: "kun"},
          %{value: "みっ", type: "kun"},
          %{value: "サン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "三時に会いましょう。",
            translation: "Let's meet at three o'clock."
          },
          %{
            japanese: "三日後に帰ります。",
            translation: "I will return in three days."
          }
        ]
      },
      %{
        character: "四",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "four", is_primary: true}
        ],
        pronunciations: [
          %{value: "よ", type: "kun"},
          %{value: "よん", type: "kun"},
          %{value: "シ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "四時に起きます。",
            translation: "I wake up at four o'clock."
          },
          %{
            japanese: "家族は四人です。",
            translation: "My family has four people."
          }
        ]
      },
      %{
        character: "五",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "five", is_primary: true}
        ],
        pronunciations: [
          %{value: "いつ", type: "kun"},
          %{value: "ゴ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "五時に家に帰ります。",
            translation: "I go home at five o'clock."
          },
          %{
            japanese: "私には五人兄弟がいます。",
            translation: "I have five siblings."
          }
        ]
      },
      %{
        character: "六",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "six", is_primary: true}
        ],
        pronunciations: [
          %{value: "む", type: "kun"},
          %{value: "むっ", type: "kun"},
          %{value: "ロク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "六時に夕食を食べます。",
            translation: "I eat dinner at six o'clock."
          },
          %{
            japanese: "六月に日本へ行きます。",
            translation: "I'm going to Japan in June."
          }
        ]
      },
      %{
        character: "七",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "seven", is_primary: true}
        ],
        pronunciations: [
          %{value: "なな", type: "kun"},
          %{value: "シチ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "七時に寝ます。",
            translation: "I go to bed at seven o'clock."
          },
          %{
            japanese: "七月は暑いです。",
            translation: "July is hot."
          }
        ]
      },
      %{
        character: "八",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "eight", is_primary: true}
        ],
        pronunciations: [
          %{value: "や", type: "kun"},
          %{value: "よう", type: "kun"},
          %{value: "ハチ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "八時に学校が始まります。",
            translation: "School starts at eight o'clock."
          },
          %{
            japanese: "八月は夏休みです。",
            translation: "August is summer vacation."
          }
        ]
      },
      %{
        character: "九",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "nine", is_primary: true}
        ],
        pronunciations: [
          %{value: "ここの", type: "kun"},
          %{value: "キュウ", type: "on"},
          %{value: "ク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "九時に起きます。",
            translation: "I wake up at nine o'clock."
          },
          %{
            japanese: "私は九歳です。",
            translation: "I am nine years old."
          }
        ]
      },
      %{
        character: "十",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "ten", is_primary: true}
        ],
        pronunciations: [
          %{value: "とお", type: "kun"},
          %{value: "ジュウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "十時に寝ます。",
            translation: "I go to sleep at ten o'clock."
          },
          %{
            japanese: "十月は秋です。",
            translation: "October is autumn."
          }
        ]
      },
      %{
        character: "口",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "mouth", is_primary: true},
          %{value: "opening"}
        ],
        pronunciations: [
          %{value: "くち", type: "kun"},
          %{value: "コウ", type: "on"},
          %{value: "ク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "口を開けてください。",
            translation: "Please open your mouth."
          },
          %{
            japanese: "日本語で言うと、口が難しいです。",
            translation: "When speaking Japanese, pronunciation is difficult."
          }
        ]
      },
      %{
        character: "目",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "eye", is_primary: true},
          %{value: "sight"}
        ],
        pronunciations: [
          %{value: "め", type: "kun"},
          %{value: "モク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "目が痛いです。",
            translation: "My eyes hurt."
          },
          %{
            japanese: "大きな目をしています。",
            translation: "He/She has big eyes."
          }
        ]
      },
      %{
        character: "耳",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "ear", is_primary: true}
        ],
        pronunciations: [
          %{value: "みみ", type: "kun"},
          %{value: "ジ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "耳が聞こえません。",
            translation: "I can't hear (my ears don't work)."
          },
          %{
            japanese: "彼女は小さい耳をしています。",
            translation: "She has small ears."
          }
        ]
      },
      %{
        character: "手",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "hand", is_primary: true},
          %{value: "arm"}
        ],
        pronunciations: [
          %{value: "て", type: "kun"},
          %{value: "た", type: "kun"},
          %{value: "シュ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "手を洗ってください。",
            translation: "Please wash your hands."
          },
          %{
            japanese: "手紙を書きます。",
            translation: "I'm writing a letter."
          }
        ]
      },
      %{
        character: "足",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "foot", is_primary: true},
          %{value: "leg"}
        ],
        pronunciations: [
          %{value: "あし", type: "kun"},
          %{value: "た", type: "kun"},
          %{value: "ソク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "足が痛いです。",
            translation: "My foot/leg hurts."
          },
          %{
            japanese: "足りません。",
            translation: "It's not enough."
          }
        ]
      },
      %{
        character: "上",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "above", is_primary: true},
          %{value: "up"},
          %{value: "top"}
        ],
        pronunciations: [
          %{value: "うえ", type: "kun"},
          %{value: "あ", type: "kun"},
          %{value: "のぼ", type: "kun"},
          %{value: "ジョウ", type: "on"},
          %{value: "ショウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "机の上に本があります。",
            translation: "There is a book on the desk."
          },
          %{
            japanese: "上手ですね。",
            translation: "You're good at it."
          }
        ]
      },
      %{
        character: "下",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "below", is_primary: true},
          %{value: "down"},
          %{value: "under"}
        ],
        pronunciations: [
          %{value: "した", type: "kun"},
          %{value: "さ", type: "kun"},
          %{value: "カ", type: "on"},
          %{value: "ゲ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "机の下に猫がいます。",
            translation: "There is a cat under the desk."
          },
          %{
            japanese: "下に行きましょう。",
            translation: "Let's go downstairs."
          }
        ]
      },
      %{
        character: "右",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "right", is_primary: true},
          %{value: "right side"}
        ],
        pronunciations: [
          %{value: "みぎ", type: "kun"},
          %{value: "ウ", type: "on"},
          %{value: "ユウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "右に曲がってください。",
            translation: "Please turn right."
          },
          %{
            japanese: "右手で書きます。",
            translation: "I write with my right hand."
          }
        ]
      },
      %{
        character: "左",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "left", is_primary: true},
          %{value: "left side"}
        ],
        pronunciations: [
          %{value: "ひだり", type: "kun"},
          %{value: "サ", type: "on"},
          %{value: "シャ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "左に曲がってください。",
            translation: "Please turn left."
          },
          %{
            japanese: "左手で書くことができます。",
            translation: "I can write with my left hand."
          }
        ]
      },
      %{
        character: "中",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "middle", is_primary: true},
          %{value: "inside"},
          %{value: "center"}
        ],
        pronunciations: [
          %{value: "なか", type: "kun"},
          %{value: "チュウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "箱の中に何がありますか。",
            translation: "What is inside the box?"
          },
          %{
            japanese: "中国語を勉強しています。",
            translation: "I'm studying Chinese."
          }
        ]
      },

      # Add after the existing kanji entries (after "中")

      %{
        character: "大",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "big", is_primary: true},
          %{value: "large"}
        ],
        pronunciations: [
          %{value: "おお", type: "kun"},
          %{value: "ダイ", type: "on"},
          %{value: "タイ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "大きな家に住んでいます。",
            translation: "I live in a big house."
          },
          %{
            japanese: "これは大切です。",
            translation: "This is important."
          }
        ]
      },
      %{
        character: "小",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "small", is_primary: true},
          %{value: "little"}
        ],
        pronunciations: [
          %{value: "ちい", type: "kun"},
          %{value: "こ", type: "kun"},
          %{value: "ショウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "小さな猫がいます。",
            translation: "There is a small cat."
          },
          %{
            japanese: "小学校に行きます。",
            translation: "I go to elementary school."
          }
        ]
      },
      %{
        character: "年",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "year", is_primary: true}
        ],
        pronunciations: [
          %{value: "とし", type: "kun"},
          %{value: "ネン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "今年は良い年です。",
            translation: "This year is a good year."
          },
          %{
            japanese: "去年日本に行きました。",
            translation: "I went to Japan last year."
          }
        ]
      },
      %{
        character: "出",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "exit", is_primary: true},
          %{value: "leave"},
          %{value: "go out"}
        ],
        pronunciations: [
          %{value: "で", type: "kun"},
          %{value: "だ", type: "kun"},
          %{value: "シュツ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "家を出ます。",
            translation: "I leave the house."
          },
          %{
            japanese: "出口はどこですか？",
            translation: "Where is the exit?"
          }
        ]
      },
      %{
        character: "入",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "enter", is_primary: true},
          %{value: "insert"}
        ],
        pronunciations: [
          %{value: "い", type: "kun"},
          %{value: "はい", type: "kun"},
          %{value: "ニュウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "学校に入ります。",
            translation: "I enter the school."
          },
          %{
            japanese: "入口はあそこです。",
            translation: "The entrance is over there."
          }
        ]
      },
      %{
        character: "生",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "life", is_primary: true},
          %{value: "birth"},
          %{value: "raw"}
        ],
        pronunciations: [
          %{value: "い", type: "kun"},
          %{value: "う", type: "kun"},
          %{value: "は", type: "kun"},
          %{value: "なま", type: "kun"},
          %{value: "セイ", type: "on"},
          %{value: "ショウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "私は学生です。",
            translation: "I am a student."
          },
          %{
            japanese: "生まれた国はどこですか。",
            translation: "Which country were you born in?"
          }
        ]
      },
      %{
        character: "花",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "flower", is_primary: true},
          %{value: "blossom"}
        ],
        pronunciations: [
          %{value: "はな", type: "kun"},
          %{value: "カ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "きれいな花が咲いています。",
            translation: "Beautiful flowers are blooming."
          },
          %{
            japanese: "花を買いました。",
            translation: "I bought flowers."
          }
        ]
      },
      %{
        character: "百",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "hundred", is_primary: true}
        ],
        pronunciations: [
          %{value: "ひゃく", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "百円です。",
            translation: "It's 100 yen."
          },
          %{
            japanese: "この本は百ページあります。",
            translation: "This book has 100 pages."
          }
        ]
      },
      %{
        character: "本",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "book", is_primary: true},
          %{value: "origin"},
          %{value: "real"}
        ],
        pronunciations: [
          %{value: "もと", type: "kun"},
          %{value: "ホン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "面白い本を読みます。",
            translation: "I read an interesting book."
          },
          %{
            japanese: "これは日本の本です。",
            translation: "This is a Japanese book."
          }
        ]
      },
      %{
        character: "名",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "name", is_primary: true},
          %{value: "famous"}
        ],
        pronunciations: [
          %{value: "な", type: "kun"},
          %{value: "メイ", type: "on"},
          %{value: "ミョウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "あなたの名前は何ですか。",
            translation: "What is your name?"
          },
          %{
            japanese: "有名な場所です。",
            translation: "It's a famous place."
          }
        ]
      },

      # Add after the existing kanji entries (after "名")

      %{
        character: "田",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "rice field", is_primary: true},
          %{value: "paddy"}
        ],
        pronunciations: [
          %{value: "た", type: "kun"},
          %{value: "デン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "田んぼで働いています。",
            translation: "I'm working in the rice field."
          },
          %{
            japanese: "田舎に住んでいます。",
            translation: "I live in the countryside."
          }
        ]
      },
      %{
        character: "力",
        grade: 1,
        stroke_count: 2,
        jlpt_level: 5,
        meanings: [
          %{value: "power", is_primary: true},
          %{value: "strength"},
          %{value: "energy"}
        ],
        pronunciations: [
          %{value: "ちから", type: "kun"},
          %{value: "リョク", type: "on"},
          %{value: "リキ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "力が強いです。",
            translation: "He/She is strong (has great strength)."
          },
          %{
            japanese: "全力で走りました。",
            translation: "I ran with all my might."
          }
        ]
      },
      %{
        character: "立",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "stand", is_primary: true},
          %{value: "rise"},
          %{value: "set up"}
        ],
        pronunciations: [
          %{value: "た", type: "kun"},
          %{value: "リツ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "立ってください。",
            translation: "Please stand up."
          },
          %{
            japanese: "彼は立派な人です。",
            translation: "He is a respectable person."
          }
        ]
      },
      %{
        character: "文",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "writing", is_primary: true},
          %{value: "sentence"},
          %{value: "literature"}
        ],
        pronunciations: [
          %{value: "ふみ", type: "kun"},
          %{value: "ブン", type: "on"},
          %{value: "モン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "文を書きます。",
            translation: "I write a sentence."
          },
          %{
            japanese: "文学について勉強しています。",
            translation: "I'm studying literature."
          }
        ]
      },
      %{
        character: "石",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "stone", is_primary: true},
          %{value: "rock"}
        ],
        pronunciations: [
          %{value: "いし", type: "kun"},
          %{value: "セキ", type: "on"},
          %{value: "シャク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "石を投げました。",
            translation: "I threw a stone."
          },
          %{
            japanese: "大きな石がありました。",
            translation: "There was a big rock."
          }
        ]
      },
      %{
        character: "空",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "sky", is_primary: true},
          %{value: "empty"},
          %{value: "air"}
        ],
        pronunciations: [
          %{value: "そら", type: "kun"},
          %{value: "から", type: "kun"},
          %{value: "あ", type: "kun"},
          %{value: "クウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "空が青いです。",
            translation: "The sky is blue."
          },
          %{
            japanese: "このボックスは空です。",
            translation: "This box is empty."
          }
        ]
      },
      %{
        character: "車",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "car", is_primary: true},
          %{value: "vehicle"},
          %{value: "wheel"}
        ],
        pronunciations: [
          %{value: "くるま", type: "kun"},
          %{value: "シャ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "新しい車を買いました。",
            translation: "I bought a new car."
          },
          %{
            japanese: "車で行きましょう。",
            translation: "Let's go by car."
          }
        ]
      },
      %{
        character: "森",
        grade: 1,
        stroke_count: 12,
        jlpt_level: 5,
        meanings: [
          %{value: "forest", is_primary: true},
          %{value: "woods"}
        ],
        pronunciations: [
          %{value: "もり", type: "kun"},
          %{value: "シン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "森に行きました。",
            translation: "I went to the forest."
          },
          %{
            japanese: "森の中で道に迷いました。",
            translation: "I got lost in the forest."
          }
        ]
      },
      %{
        character: "金",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "gold", is_primary: true},
          %{value: "money"},
          %{value: "metal"}
        ],
        pronunciations: [
          %{value: "かね", type: "kun"},
          %{value: "かな", type: "kun"},
          %{value: "キン", type: "on"},
          %{value: "コン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "金曜日に映画を見ます。",
            translation: "I watch a movie on Friday."
          },
          %{
            japanese: "金は重い金属です。",
            translation: "Gold is a heavy metal."
          }
        ]
      },
      %{
        character: "雨",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "rain", is_primary: true}
        ],
        pronunciations: [
          %{value: "あめ", type: "kun"},
          %{value: "あま", type: "kun"},
          %{value: "ウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "今日は雨が降っています。",
            translation: "It's raining today."
          },
          %{
            japanese: "雨が止みました。",
            translation: "The rain has stopped."
          }
        ]
      },

      # Add after the existing kanji entries (after "雨")

      %{
        character: "天",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "heaven", is_primary: true},
          %{value: "sky"}
        ],
        pronunciations: [
          %{value: "あめ", type: "kun"},
          %{value: "あま", type: "kun"},
          %{value: "テン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "天気が良いです。",
            translation: "The weather is good."
          },
          %{
            japanese: "天の川がきれいです。",
            translation: "The Milky Way is beautiful."
          }
        ]
      },
      %{
        character: "地",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "earth", is_primary: true},
          %{value: "ground"},
          %{value: "land"}
        ],
        pronunciations: [
          %{value: "チ", type: "on"},
          %{value: "ジ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "地図を見ています。",
            translation: "I'm looking at a map."
          },
          %{
            japanese: "地震がありました。",
            translation: "There was an earthquake."
          }
        ]
      },
      %{
        character: "正",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "correct", is_primary: true},
          %{value: "right"},
          %{value: "justice"}
        ],
        pronunciations: [
          %{value: "ただ", type: "kun"},
          %{value: "まさ", type: "kun"},
          %{value: "セイ", type: "on"},
          %{value: "ショウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "正しい答えです。",
            translation: "That's the correct answer."
          },
          %{
            japanese: "正月は家族と過ごします。",
            translation: "I spend New Year's with my family."
          }
        ]
      },
      %{
        character: "先",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "ahead", is_primary: true},
          %{value: "previous"},
          %{value: "before"}
        ],
        pronunciations: [
          %{value: "さき", type: "kun"},
          %{value: "せん", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "先生に質問しました。",
            translation: "I asked the teacher a question."
          },
          %{
            japanese: "先に行ってください。",
            translation: "Please go ahead."
          }
        ]
      },
      %{
        character: "早",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "early", is_primary: true},
          %{value: "fast"}
        ],
        pronunciations: [
          %{value: "はや", type: "kun"},
          %{value: "サッ", type: "on"},
          %{value: "ソウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "早く起きます。",
            translation: "I wake up early."
          },
          %{
            japanese: "彼女は走るのが早いです。",
            translation: "She runs fast."
          }
        ]
      },
      %{
        character: "虫",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "insect", is_primary: true},
          %{value: "bug"}
        ],
        pronunciations: [
          %{value: "むし", type: "kun"},
          %{value: "チュウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "庭に虫がいます。",
            translation: "There are insects in the garden."
          },
          %{
            japanese: "子供は虫が好きです。",
            translation: "Children like insects."
          }
        ]
      },
      %{
        character: "字",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "character", is_primary: true},
          %{value: "letter"},
          %{value: "word"}
        ],
        pronunciations: [
          %{value: "あざ", type: "kun"},
          %{value: "ジ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "この字を書いてください。",
            translation: "Please write this character."
          },
          %{
            japanese: "漢字を勉強しています。",
            translation: "I'm studying kanji characters."
          }
        ]
      },
      %{
        character: "町",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "town", is_primary: true},
          %{value: "block"}
        ],
        pronunciations: [
          %{value: "まち", type: "kun"},
          %{value: "チョウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "私の町は小さいです。",
            translation: "My town is small."
          },
          %{
            japanese: "静かな町に住んでいます。",
            translation: "I live in a quiet town."
          }
        ]
      },
      %{
        character: "村",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "village", is_primary: true}
        ],
        pronunciations: [
          %{value: "むら", type: "kun"},
          %{value: "ソン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "彼は小さな村から来ました。",
            translation: "He came from a small village."
          },
          %{
            japanese: "山の村に行きました。",
            translation: "I went to a mountain village."
          }
        ]
      },
      %{
        character: "男",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "man", is_primary: true},
          %{value: "male"}
        ],
        pronunciations: [
          %{value: "おとこ", type: "kun"},
          %{value: "ダン", type: "on"},
          %{value: "ナン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "彼は男の子です。",
            translation: "He is a boy."
          },
          %{
            japanese: "男性用のトイレはどこですか。",
            translation: "Where is the men's restroom?"
          }
        ]
      },

      # Add after the existing kanji entries (after "男")

      %{
        character: "女",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "woman", is_primary: true},
          %{value: "female"}
        ],
        pronunciations: [
          %{value: "おんな", type: "kun"},
          %{value: "め", type: "kun"},
          %{value: "ジョ", type: "on"},
          %{value: "ニョ", type: "on"},
          %{value: "ニョウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "彼女は女の子です。",
            translation: "She is a girl."
          },
          %{
            japanese: "女性用のトイレはこちらです。",
            translation: "The women's restroom is this way."
          }
        ]
      },
      %{
        character: "子",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "child", is_primary: true},
          %{value: "kid"}
        ],
        pronunciations: [
          %{value: "こ", type: "kun"},
          %{value: "シ", type: "on"},
          %{value: "ス", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "子供が公園で遊んでいます。",
            translation: "Children are playing in the park."
          },
          %{
            japanese: "彼女には二人の子供がいます。",
            translation: "She has two children."
          }
        ]
      },
      %{
        character: "学",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "study", is_primary: true},
          %{value: "learning"},
          %{value: "science"}
        ],
        pronunciations: [
          %{value: "まな", type: "kun"},
          %{value: "ガク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "学校に行きます。",
            translation: "I go to school."
          },
          %{
            japanese: "日本語を学んでいます。",
            translation: "I'm studying Japanese."
          }
        ]
      },
      %{
        character: "気",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "spirit", is_primary: true},
          %{value: "mind"},
          %{value: "air"}
        ],
        pronunciations: [
          %{value: "き", type: "kun"},
          %{value: "け", type: "kun"},
          %{value: "キ", type: "on"},
          %{value: "ケ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "気をつけてください。",
            translation: "Please be careful."
          },
          %{
            japanese: "元気ですか？",
            translation: "How are you? (Are you well?)"
          }
        ]
      },
      %{
        character: "休",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "rest", is_primary: true},
          %{value: "break"},
          %{value: "holiday"}
        ],
        pronunciations: [
          %{value: "やす", type: "kun"},
          %{value: "キュウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "今日は休みです。",
            translation: "Today is a day off."
          },
          %{
            japanese: "少し休みましょう。",
            translation: "Let's rest a little."
          }
        ]
      },
      %{
        character: "玉",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "jewel", is_primary: true},
          %{value: "ball"}
        ],
        pronunciations: [
          %{value: "たま", type: "kun"},
          %{value: "ギョク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "玉を転がします。",
            translation: "I roll the ball."
          },
          %{
            japanese: "彼女はきれいな玉を持っています。",
            translation: "She has a beautiful jewel."
          }
        ]
      },
      %{
        character: "犬",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "dog", is_primary: true}
        ],
        pronunciations: [
          %{value: "いぬ", type: "kun"},
          %{value: "ケン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "私は犬が好きです。",
            translation: "I like dogs."
          },
          %{
            japanese: "あの犬は大きいです。",
            translation: "That dog is big."
          }
        ]
      },
      %{
        character: "青",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "blue", is_primary: true},
          %{value: "green"}
        ],
        pronunciations: [
          %{value: "あお", type: "kun"},
          %{value: "セイ", type: "on"},
          %{value: "ショウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "空は青いです。",
            translation: "The sky is blue."
          },
          %{
            japanese: "青い服を着ています。",
            translation: "I'm wearing blue clothes."
          }
        ]
      },
      %{
        character: "赤",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "red", is_primary: true}
        ],
        pronunciations: [
          %{value: "あか", type: "kun"},
          %{value: "セキ", type: "on"},
          %{value: "シャク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "赤いリンゴを食べました。",
            translation: "I ate a red apple."
          },
          %{
            japanese: "彼女は赤いドレスを着ています。",
            translation: "She is wearing a red dress."
          }
        ]
      },
      %{
        character: "白",
        grade: 1,
        stroke_count: 5,
        jlpt_level: 5,
        meanings: [
          %{value: "white", is_primary: true}
        ],
        pronunciations: [
          %{value: "しろ", type: "kun"},
          %{value: "しら", type: "kun"},
          %{value: "ハク", type: "on"},
          %{value: "ビャク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "白い紙を使います。",
            translation: "I use white paper."
          },
          %{
            japanese: "白い雲が見えます。",
            translation: "I can see white clouds."
          }
        ]
      },

      # Add these entries before the closing bracket of kanji_list

      %{
        character: "円",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "circle", is_primary: true},
          %{value: "yen"},
          %{value: "round"}
        ],
        pronunciations: [
          %{value: "まる", type: "kun"},
          %{value: "エン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "これは百円です。",
            translation: "This is 100 yen."
          },
          %{
            japanese: "円を書きました。",
            translation: "I drew a circle."
          }
        ]
      },
      %{
        character: "王",
        grade: 1,
        stroke_count: 4,
        jlpt_level: 5,
        meanings: [
          %{value: "king", is_primary: true},
          %{value: "ruler"}
        ],
        pronunciations: [
          %{value: "オウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "王様の話が好きです。",
            translation: "I like stories about kings."
          },
          %{
            japanese: "彼はチェスの王です。",
            translation: "He is the king of chess."
          }
        ]
      },
      %{
        character: "音",
        grade: 1,
        stroke_count: 9,
        jlpt_level: 5,
        meanings: [
          %{value: "sound", is_primary: true},
          %{value: "noise"}
        ],
        pronunciations: [
          %{value: "おと", type: "kun"},
          %{value: "ね", type: "kun"},
          %{value: "オン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "大きな音がしました。",
            translation: "There was a loud sound."
          },
          %{
            japanese: "音楽を聞いています。",
            translation: "I'm listening to music."
          }
        ]
      },
      %{
        character: "貝",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "shell", is_primary: true},
          %{value: "shellfish"}
        ],
        pronunciations: [
          %{value: "かい", type: "kun"},
          %{value: "バイ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "海で貝を集めました。",
            translation: "I collected shells at the beach."
          },
          %{
            japanese: "この貝はきれいです。",
            translation: "This shell is beautiful."
          }
        ]
      },
      %{
        character: "校",
        grade: 1,
        stroke_count: 10,
        jlpt_level: 5,
        meanings: [
          %{value: "school", is_primary: true},
          %{value: "exam"}
        ],
        pronunciations: [
          %{value: "コウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "学校は9時に始まります。",
            translation: "School starts at 9 o'clock."
          },
          %{
            japanese: "私の学校は大きいです。",
            translation: "My school is big."
          }
        ]
      },
      %{
        character: "糸",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "thread", is_primary: true},
          %{value: "string"}
        ],
        pronunciations: [
          %{value: "いと", type: "kun"},
          %{value: "シ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "この糸は赤いです。",
            translation: "This thread is red."
          },
          %{
            japanese: "糸で服を縫います。",
            translation: "I sew clothes with thread."
          }
        ]
      },
      %{
        character: "見",
        grade: 1,
        stroke_count: 7,
        jlpt_level: 5,
        meanings: [
          %{value: "see", is_primary: true},
          %{value: "look"},
          %{value: "watch"}
        ],
        pronunciations: [
          %{value: "み", type: "kun"},
          %{value: "ケン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "映画を見ました。",
            translation: "I watched a movie."
          },
          %{
            japanese: "見てください。",
            translation: "Please look."
          }
        ]
      },
      %{
        character: "千",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "thousand", is_primary: true}
        ],
        pronunciations: [
          %{value: "ち", type: "kun"},
          %{value: "セン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "千円を払いました。",
            translation: "I paid 1000 yen."
          },
          %{
            japanese: "この本は千ページあります。",
            translation: "This book has 1000 pages."
          }
        ]
      },
      %{
        character: "夕",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "evening", is_primary: true}
        ],
        pronunciations: [
          %{value: "ゆう", type: "kun"},
          %{value: "セキ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "夕方に帰ります。",
            translation: "I'll return in the evening."
          },
          %{
            japanese: "夕日がきれいです。",
            translation: "The sunset is beautiful."
          }
        ]
      },
      %{
        character: "草",
        grade: 1,
        stroke_count: 9,
        jlpt_level: 5,
        meanings: [
          %{value: "grass", is_primary: true},
          %{value: "weed"},
          %{value: "herb"}
        ],
        pronunciations: [
          %{value: "くさ", type: "kun"},
          %{value: "ソウ", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "草が青いです。",
            translation: "The grass is green."
          },
          %{
            japanese: "庭に草があります。",
            translation: "There is grass in the garden."
          }
        ]
      },
      %{
        character: "竹",
        grade: 1,
        stroke_count: 6,
        jlpt_level: 5,
        meanings: [
          %{value: "bamboo", is_primary: true}
        ],
        pronunciations: [
          %{value: "たけ", type: "kun"},
          %{value: "チク", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "竹で作った箸です。",
            translation: "These are chopsticks made of bamboo."
          },
          %{
            japanese: "庭に竹を植えました。",
            translation: "I planted bamboo in the garden."
          }
        ]
      },
      %{
        character: "土",
        grade: 1,
        stroke_count: 3,
        jlpt_level: 5,
        meanings: [
          %{value: "soil", is_primary: true},
          %{value: "earth"},
          %{value: "ground"}
        ],
        pronunciations: [
          %{value: "つち", type: "kun"},
          %{value: "ド", type: "on"},
          %{value: "ト", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "土曜日に買い物に行きます。",
            translation: "I go shopping on Saturday."
          },
          %{
            japanese: "花を土に植えました。",
            translation: "I planted flowers in the soil."
          }
        ]
      },
      %{
        character: "林",
        grade: 1,
        stroke_count: 8,
        jlpt_level: 5,
        meanings: [
          %{value: "grove", is_primary: true},
          %{value: "forest"}
        ],
        pronunciations: [
          %{value: "はやし", type: "kun"},
          %{value: "リン", type: "on"}
        ],
        example_sentences: [
          %{
            japanese: "林の中を散歩しました。",
            translation: "I took a walk in the grove."
          },
          %{
            japanese: "林さんは私の友達です。",
            translation: "Mr. Hayashi is my friend."
          }
        ]
      }
    ]

    # Insert each Kanji and its related data
    Enum.each(kanji_list, fn kanji_data ->
      # Check if kanji already exists, if not create it
      kanji =
        case Domain.get_kanji_by_character(kanji_data.character) do
          {:ok, existing_kanji} ->
            # Kanji already exists, use it
            existing_kanji

          {:error, _} ->
            # Kanji doesn't exist, create it
            # Determine primary radical glyph (simple heuristic for starter set)
            radical_glyph =
              case kanji_data.character do
                # Known exceptions where radical differs from full form
                "林" -> "木"
                other -> other
              end

            radical_id =
              case Domain.get_radical_by_glyph(radical_glyph) do
                {:ok, radical} -> radical.id
                _ -> nil
              end

            create_attrs =
              kanji_data
              |> Map.take([:character, :grade, :stroke_count, :jlpt_level])
              |> Map.put(:radical_id, radical_id)

            case Domain.create_kanji(create_attrs) do
              {:ok, new_kanji} ->
                new_kanji

              {:error, error} ->
                # If creation fails due to duplication (race condition), try to get it again
                case Domain.get_kanji_by_character(kanji_data.character) do
                  {:ok, existing_kanji} ->
                    existing_kanji

                  {:error, _} ->
                    # If we still can't get it, raise the original error
                    raise "Failed to create or find kanji #{kanji_data.character}: #{inspect(error)}"
                end
            end
        end

      # Insert meanings only if they don't already exist
      Enum.each(kanji_data.meanings, fn meaning_data ->
        # Check if meaning already exists
        language = meaning_data[:language] || "en"
        value = meaning_data.value

        existing_meanings =
          KumaSanKanji.Kanji.Meaning
          |> Ash.Query.filter(kanji_id: kanji.id, value: value, language: language)
          |> Ash.read!(authorize?: false)

        if existing_meanings == [] do
          # Meaning doesn't exist, create it
          case Domain.create_meaning(Map.put(meaning_data, :kanji_id, kanji.id)) do
            {:ok, _meaning} -> :ok
            # Ignore creation errors (might be race condition)
            {:error, _error} -> :ok
          end
        end
      end)

      # Insert pronunciations only if they don't already exist
      Enum.each(kanji_data.pronunciations, fn pronunciation_data ->
        # Check if pronunciation already exists
        pronunciation_value = pronunciation_data.value
        pronunciation_type = pronunciation_data.type

        existing_pronunciations =
          KumaSanKanji.Kanji.Pronunciation
          |> Ash.Query.filter(
            kanji_id: kanji.id,
            value: pronunciation_value,
            type: pronunciation_type
          )
          |> Ash.read!(authorize?: false)

        if existing_pronunciations == [] do
          # Pronunciation doesn't exist, create it
          case Domain.create_pronunciation(Map.put(pronunciation_data, :kanji_id, kanji.id)) do
            {:ok, _pronunciation} -> :ok
            # Ignore creation errors (might be race condition)
            {:error, _error} -> :ok
          end
        end
      end)

      # Insert example sentences only if they don't already exist
      Enum.each(kanji_data.example_sentences, fn sentence_data ->
        # Check if sentence already exists
        language = sentence_data[:language] || "en"
        japanese_text = sentence_data.japanese || ""
        translation_text = sentence_data.translation

        existing_sentences =
          KumaSanKanji.Kanji.ExampleSentence
          |> Ash.Query.filter(
            kanji_id: kanji.id,
            japanese: japanese_text,
            translation: translation_text,
            language: language
          )
          |> Ash.read!(authorize?: false)

        if existing_sentences == [] do
          # Sentence doesn't exist, create it
          case Domain.create_example_sentence(Map.put(sentence_data, :kanji_id, kanji.id)) do
            {:ok, _sentence} -> :ok
            # Ignore creation errors (might be race condition)
            {:error, _error} -> :ok
          end
        end
      end)
    end)
  end
end
