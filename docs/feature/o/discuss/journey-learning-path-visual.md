# Journey: Grade 1 Thematic Learning Path

## Persona

**Yuki Tanaka** -- 34-year-old software developer in Melbourne, Australia. Studied Japanese casually for 2 years using Anki and Duolingo. Passed JLPT N5 but struggles to read even simple children's texts. Knows ~30 kanji from flashcards but cannot recognize them in sentences. Frustrated by the gap between "quiz correct" and "actually reading."

## Goal

Complete a structured learn-then-quiz cycle through a thematic group of Grade 1 kanji, building confidence that studied kanji are truly understood in context -- not just memorized as isolated flashcard answers.

## Emotional Arc

```
Start: Curious but skeptical     Middle: Engaged, building confidence     End: Satisfied, wants more
("Another kanji app?")           ("Oh, I SEE how these connect")         ("I actually learned something")
```

---

## Journey Flow

```
[1. Browse Groups]  -->  [2. Enter Group]  -->  [3. Learn Kanji]  -->  [4. Quiz Kanji]  -->  [5. Group Progress]
   See thematic          See group overview      Teach step:            Test recall           See completion
   groups as cards       with kanji preview      meaning, reading,      within thematic        and next steps
                                                 sentence, stroke       context
                                                 order
```

---

## Step 1: Browse Thematic Groups

**Route**: `/learn`
**Trigger**: Yuki clicks "Learn" in the main navigation (new nav item)

```
+-----------------------------------------------------------------------+
|  Grade 1 Kanji -- Learning Path                                       |
|                                                                       |
|  Choose a thematic group to begin learning.                           |
|                                                                       |
|  +-------------------+  +-------------------+  +-------------------+  |
|  | 1. Numbers        |  | 2. Directions     |  | 3. Nature         |  |
|  | 一二三四五六七八九十|  | 上下中左右        |  | 水火木山川空雨天... |  |
|  | 百千              |  |                   |  |                   |  |
|  | 12 kanji          |  | 5 kanji           |  | 19 kanji          |  |
|  | [Not started]     |  | [Not started]     |  | [Not started]     |  |
|  +-------------------+  +-------------------+  +-------------------+  |
|                                                                       |
|  +-------------------+  +-------------------+  +-------------------+  |
|  | 4. People         |  | 5. Body Parts     |  | 6. Actions        |  |
|  | 人男女子犬虫       |  | 口目耳手足        |  | 見立生休入出       |  |
|  | 6 kanji           |  | 5 kanji           |  | 6 kanji           |  |
|  | [Not started]     |  | [Not started]     |  | [Not started]     |  |
|  +-------------------+  +-------------------+  +-------------------+  |
|                                                                       |
|  +-------------------+  +-------------------+  +-------------------+  |
|  | 7. Colors         |  | 8. Time           |  | 9. Places         |  |
|  | 赤青白            |  | 年夕              |  | 学校町村金         |  |
|  | 3 kanji           |  | 2 kanji           |  | 5 kanji           |  |
|  | [Not started]     |  | [Not started]     |  | [Not started]     |  |
|  +-------------------+  +-------------------+  +-------------------+  |
|                                                                       |
|  +-------------------+                                                |
|  | 10. Objects       |                                                |
|  | 車本玉貝円        |                                                |
|  | 5 kanji           |                                                |
|  | [Not started]     |                                                |
|  +-------------------+                                                |
|                                                                       |
|  Overall: 0/80 kanji learned                                          |
+-----------------------------------------------------------------------+
```

**Emotional State**: Curious -> Oriented ("I can see the whole path, I know where to start")
**Key Design Decision**: Cards show actual kanji characters as preview, not just group names. This gives Yuki immediate visual familiarity.

---

## Step 2: Enter a Thematic Group

**Route**: `/learn/numbers` (or `/learn/:group_slug`)
**Trigger**: Yuki clicks the "Numbers" group card

```
+-----------------------------------------------------------------------+
|  Numbers (数字) -- 12 kanji                                           |
|                                                                       |
|  These form the foundation of the Japanese counting system and are    |
|  among the first kanji taught.                                        |
|                                                                       |
|  +------+------+------+------+------+------+------+------+------+    |
|  |  一  |  二  |  三  |  四  |  五  |  六  |  七  |  八  |  九  |    |
|  | one  | two  |three | four | five | six  |seven |eight | nine |    |
|  |  *   |  *   |  *   |      |      |      |      |      |      |    |
|  +------+------+------+------+------+------+------+------+------+    |
|  |  十  |  百  |  千  |                                              |
|  | ten  | 100  | 1000 |     * = already learned                      |
|  |      |      |      |                                              |
|  +------+------+------+                                              |
|                                                                       |
|  Progress: 3/12 learned                                               |
|                                                                       |
|  [Continue Learning]  -- starts at next unlearned kanji (四)          |
|  [Review Learned]     -- quiz only on the 3 learned kanji            |
+-----------------------------------------------------------------------+
```

**Emotional State**: Oriented -> Motivated ("3 done, 9 to go -- I can do this")
**Key Design Decision**: "Continue Learning" resumes where Yuki left off. No decision fatigue about what to study next.

---

## Step 3: Learn a Kanji (Teach Step)

**Route**: `/learn/numbers/4` (group + position within group)
**Trigger**: Yuki clicks "Continue Learning" or taps a specific kanji

This is the critical teach-before-test step that discovery identified as the #1 feasibility hypothesis (H6).

```
+-----------------------------------------------------------------------+
|  Numbers (数字) -- Kanji 4 of 12                            [< >]     |
|                                                                       |
|        +--------+                                                     |
|        |        |                                                     |
|        |   四   |   Stroke count: 5                                   |
|        |        |   JLPT: N5                                          |
|        +--------+                                                     |
|        [Show stroke order]                                            |
|                                                                       |
|  -------------------------------------------------------------------  |
|                                                                       |
|  Meaning:  four                                                       |
|                                                                       |
|  Readings:                                                            |
|    kun: よん (yon), よ (yo), よっつ (yottsu)                            |
|    on:  シ (shi)                                                      |
|                                                                       |
|  -------------------------------------------------------------------  |
|                                                                       |
|  Example:                                                             |
|    四月は春です。                                                       |
|    April is spring.                                                   |
|                                                                       |
|  -------------------------------------------------------------------  |
|                                                                       |
|  Learning tip:                                                        |
|    四 originally depicted four lines, like 亖, but was                |
|    simplified. The box shape (囗) contains divided space.              |
|                                                                       |
|  [I've learned this -- Quiz me!]                                      |
|  [Skip to next]                                                       |
+-----------------------------------------------------------------------+
```

**Emotional State**: Focused -> Confident ("I understand this character now, I'm ready to be tested")
**Key Design Decision**: The learner explicitly opts into the quiz. No surprise testing. This directly addresses the "tested on things I wasn't taught" complaint (famahar, HN).

---

## Step 4: Quiz on Learned Kanji

**Route**: `/learn/numbers/quiz` (or inline transition)
**Trigger**: Yuki clicks "I've learned this -- Quiz me!"

The quiz tests only kanji from the current thematic group that the learner has marked as "learned." This uses the existing SRS quiz infrastructure but scoped to the group.

```
+-----------------------------------------------------------------------+
|  Numbers Quiz -- Review 4 learned kanji                               |
|                                                                       |
|        +--------+                                                     |
|        |        |                                                     |
|        |   四   |                                                     |
|        |        |                                                     |
|        +--------+                                                     |
|                                                                       |
|  What does this kanji mean?                                           |
|                                                                       |
|  [_________________________]  [Submit]                                |
|                                                                       |
|  Or type a reading (hiragana or romaji)                               |
|                                                                       |
|  Progress: 1/4 reviewed this session                                  |
|  [Skip]                                                               |
+-----------------------------------------------------------------------+

--- After correct answer ---

+-----------------------------------------------------------------------+
|  Numbers Quiz -- Review 4 learned kanji                               |
|                                                                       |
|        +--------+                                                     |
|        |        |                                                     |
|        |   四   |                                                     |
|        |        |                                                     |
|        +--------+                                                     |
|                                                                       |
|  Correct! 四 means "four"                                             |
|  Readings: よん, よ, よっつ, シ                                         |
|                                                                       |
|  四月は春です。                                                        |
|  April is spring.                                                     |
|                                                                       |
|  [Next]                                                               |
+-----------------------------------------------------------------------+
```

**Emotional State**: Engaged -> Satisfied ("I knew it! The learning step worked.")
**Key Design Decision**: Quiz shows the example sentence on the feedback screen, reinforcing contextual learning (Opportunity O2). The quiz uses existing SRS `record_review` infrastructure.

---

## Step 5: Group Progress Summary

**Route**: `/learn/numbers` (return to group view)
**Trigger**: Yuki completes the quiz round

```
+-----------------------------------------------------------------------+
|  Numbers (数字) -- Session Complete!                                   |
|                                                                       |
|  This session: 4/4 correct                                            |
|  Group progress: 4/12 learned                                         |
|                                                                       |
|  +------+------+------+------+------+------+------+------+------+    |
|  |  一  |  二  |  三  |  四  |  五  |  六  |  七  |  八  |  九  |    |
|  |  OK  |  OK  |  OK  |  OK  |      |      |      |      |      |    |
|  +------+------+------+------+------+------+------+------+------+    |
|  |  十  |  百  |  千  |                                              |
|  |      |      |      |                                              |
|  +------+------+------+                                              |
|                                                                       |
|  [Continue Learning]  -- learn 五 next                                |
|  [Back to All Groups]                                                 |
+-----------------------------------------------------------------------+
```

**Emotional State**: Satisfied -> Motivated ("Clear progress, I want to keep going")
**Key Design Decision**: Visual grid with completion markers provides instant gratification and clear next action.

---

## Error Paths

### E1: No kanji data seeded for a thematic group
**Trigger**: Group exists in ThematicGroup table but no kanji are linked via KanjiThematicGroup
**User sees**: "This group is being prepared. Check back soon." with a link back to the groups list.
**Recovery**: Admin seeds the missing kanji data.

### E2: User not authenticated and tries to access learn path
**Trigger**: Unauthenticated user clicks "Learn" nav item
**User sees**: Redirect to sign-in with flash: "Sign in to start learning."
**Recovery**: After sign-in, redirect back to `/learn`.

### E3: Feature flag disabled
**Trigger**: `:grade1_learning_path` FunWithFlags flag is off
**User sees**: The "Learn" nav item does not appear. Direct URL access shows 404 or redirect to home.
**Recovery**: Admin enables the flag.

### E4: User tries to quiz before learning any kanji in a group
**Trigger**: User navigates directly to `/learn/numbers/quiz` with 0 learned kanji
**User sees**: "Learn at least one kanji before starting the quiz. Start with 一." with link to the first kanji.
**Recovery**: User goes to learn step first.

---

## Integration Points

| From | To | Data Passed |
|------|----|-------------|
| ThematicGroup (Content domain) | Learn page group cards | group name, description, kanji count, color |
| KanjiThematicGroup (Content domain) | Group detail kanji grid | kanji IDs in order |
| Kanji + Meanings + Pronunciations + ExampleSentences (Kanji domain) | Learn step | character, meanings, readings, sentences |
| KanjiLearningMeta (Content domain) | Learn step | learning tips, mnemonic hints |
| UserKanjiProgress (SRS domain) | Progress tracking | learned/not-learned per kanji, quiz results |
| FunWithFlags | Feature visibility | `:grade1_learning_path` flag |
