<!-- markdownlint-disable MD024 -->

# User Stories: Grade 1 Thematic Learning Path

All stories are part of Release 1 (Walking Skeleton) unless noted otherwise.

---

## US-01: Browse Thematic Groups

### Problem

Yuki Tanaka is a 34-year-old developer who has studied ~30 kanji via flashcards. She opens Kuma San Kanji and sees an explore page with individual kanji and a quiz that tests characters she was never taught. She finds it overwhelming to decide what to study next. There is no guided starting point, no sense of a curriculum.

### Who

- Kanji learner (JLPT N5 level) | First visit to learning path | Wants to know where to begin and what the scope is

### Solution

A "Learn" page showing the 10 Grade 1 thematic groups as cards. Each card previews the kanji in the group, shows the count, and displays the learner's progress. The page gives Yuki a clear overview of the full curriculum and an obvious entry point.

### Domain Examples

#### 1: First-time learner sees the full path

Yuki Tanaka signs in and clicks "Learn" in the navigation. She sees 10 cards: Numbers (12 kanji), Directions (5), Nature (19), People (6), Body Parts (5), Actions (6), Colors (3), Time (2), Places (5), Objects (5). All show "Not started." She clicks Numbers to begin.

#### 2: Returning learner sees progress

Yuki has been studying for a week. She returns to /learn and sees Numbers shows "8/12 learned," Directions shows "5/5 learned" with a completion marker, and the rest show "Not started." Overall progress reads "13/80 kanji learned." She clicks Numbers to continue.

#### 3: Feature flag disabled hides the page

An admin has not yet enabled the learning path for production users. Kenji Nakamura (a new user) looks at the navigation and does not see a "Learn" link. If he types /learn directly, he is redirected to the home page.

### UAT Scenarios (BDD)

#### Scenario: First-time learner sees all groups

Given Yuki Tanaka is signed in
And the grade1_learning_path feature flag is enabled
And Yuki has not started any thematic group
When Yuki navigates to /learn
Then Yuki sees 10 thematic group cards ordered by curriculum sequence
And each card shows the group name, a preview of its kanji characters, and the total count
And each card shows "Not started"
And overall progress shows "0/80 kanji learned"

#### Scenario: Returning learner sees accurate progress

Given Yuki Tanaka is signed in
And Yuki has learned 8 kanji in the Numbers group
And Yuki has learned all 5 kanji in the Directions group
When Yuki navigates to /learn
Then the Numbers card shows "8/12 learned"
And the Directions card shows "5/5 learned" with a completion indicator
And overall progress shows "13/80 kanji learned"

#### Scenario: Unauthenticated visitor is redirected

Given a visitor is not signed in
When the visitor navigates to /learn
Then the visitor is redirected to the sign-in page
And a flash message says "Sign in to start learning."

#### Scenario: Feature flag disabled hides access

Given the grade1_learning_path feature flag is disabled
And Kenji Nakamura is signed in
When Kenji looks at the main navigation
Then there is no "Learn" navigation item

### Acceptance Criteria

- [ ] /learn page displays 10 thematic group cards in curriculum order
- [ ] Each card shows group name, kanji character preview, kanji count, and progress badge
- [ ] Overall progress counter shows X/80 across all groups
- [ ] Page requires authentication (redirect to sign-in if not logged in)
- [ ] Page is gated behind `:grade1_learning_path` FunWithFlags flag
- [ ] "Learn" nav item only appears when feature flag is enabled

### Outcome KPIs

- **Who**: Authenticated learners visiting for the first time
- **Does what**: Click into a thematic group from the Learn page (activation)
- **By how much**: >60% of visitors to /learn click a group within the session
- **Measured by**: LiveView event tracking (group card click)
- **Baseline**: N/A (new feature)

### Technical Notes

- Thematic groups already exist as `Content.ThematicGroup` Ash resource with `order_index`
- Progress requires aggregating `UserKanjiProgress` records per group via `KanjiThematicGroup` join
- Feature flag: `:grade1_learning_path` via FunWithFlags
- Route: `/learn` in authenticated scope

---

## US-02: Study a Kanji in the Teach Step

### Problem

Yuki Tanaka opens the quiz and is immediately asked "What does 四 mean?" She has never studied 四. She guesses wrong, feels frustrated, and thinks "this is a practice app, not a learning app." She needs to see the character, its meaning, readings, and context before being tested.

### Who

- Kanji learner (JLPT N5) | Inside a thematic group | Encountering a kanji for the first time

### Solution

A teach step that presents a single kanji with its meaning, readings (kun and on), stroke count, and one example sentence with translation. The learner studies at their own pace before opting into a quiz.

### Domain Examples

#### 1: Yuki studies 四 for the first time

Yuki is learning the Numbers group and reaches kanji #4. She sees 四 displayed large, with meaning "four," readings よん/よ/よっつ (kun) and シ (on), stroke count 5, and the sentence "四月は春です。/ April is spring." She takes 30 seconds to absorb it.

#### 2: Yuki studies 山 in the Nature group

Yuki is learning Nature and reaches 山. She sees the character large, meaning "mountain," readings やま (kun) and サン (on), stroke count 3, and the sentence "あの山は高いです。/ That mountain is tall." She notices it looks like three peaks -- the visual association clicks.

#### 3: Kanji without learning tips displays gracefully

Yuki reaches 百 (hundred) in Numbers. No KanjiLearningMeta record exists for 百 yet. The page shows character, meaning, readings, and example sentence. The "Learning tip" section is simply absent -- no empty box, no "coming soon" placeholder.

### UAT Scenarios (BDD)

#### Scenario: Learner sees full kanji detail in teach step

Given Yuki Tanaka is learning the Numbers group
And 四 is at position 4 in the group
When Yuki opens the teach step for position 4
Then Yuki sees the character 四 displayed prominently
And Yuki sees the meaning "four"
And Yuki sees kun readings: よん, よ, よっつ
And Yuki sees on reading: シ
And Yuki sees stroke count: 5
And Yuki sees at least one example sentence with Japanese text and English translation

#### Scenario: Teach step shows learning tips when available

Given Yuki is on the teach step for 四
And 四 has a KanjiLearningMeta record with a learning tip
When the page renders
Then Yuki sees the learning tip below the example sentence

#### Scenario: Teach step omits learning tips section when none exist

Given Yuki is on the teach step for 百
And 百 has no KanjiLearningMeta record
When the page renders
Then the learning tip section is not displayed
And all other kanji information (meaning, readings, example sentence) displays normally

#### Scenario: Learner navigates the group position

Given Yuki is on the teach step for 四 at position 4 of 12
Then Yuki sees "Numbers -- Kanji 4 of 12" in the header

### Acceptance Criteria

- [ ] Teach step displays character, meaning(s), readings (kun/on), stroke count, and example sentence(s)
- [ ] Position indicator shows "Group Name -- Kanji X of Y"
- [ ] Learning tips from KanjiLearningMeta display when available
- [ ] Learning tips section is hidden (not empty) when no data exists
- [ ] "I've learned this -- Quiz me!" button is present
- [ ] "Skip to next" link advances without marking the kanji as learned

### Outcome KPIs

- **Who**: Learners in the teach step
- **Does what**: Click "I've learned this" rather than "Skip" (engagement)
- **By how much**: >80% of teach step visits result in "learned" not "skip"
- **Measured by**: LiveView event tracking (button clicks)
- **Baseline**: N/A (new feature)

### Technical Notes

- Reuses existing Kanji resource with loaded `:meanings`, `:pronunciations`, `:example_sentences`
- KanjiLearningMeta from Content domain provides optional tips/mnemonics
- Route: `/learn/:group_slug/:position`
- Data comes from existing resources -- no new Ash resources needed for this story

---

## US-03: Mark a Kanji as Learned

### Problem

Yuki studies 四 in the teach step and feels ready to be tested. But there is no way to signal "I've studied this" -- the system does not know the difference between a kanji Yuki has never seen and one she has just spent 30 seconds studying. Without this signal, the quiz cannot scope to "learned" kanji.

### Who

- Kanji learner | Just completed studying a kanji in the teach step | Wants to transition from learning to testing

### Solution

An "I've learned this -- Quiz me!" action that records the kanji as "learned" in UserKanjiProgress (initializing the SRS record if it does not exist) and transitions the learner to the group quiz.

### Domain Examples

#### 1: Yuki marks 四 as learned and enters quiz

Yuki finishes studying 四. She clicks "I've learned this -- Quiz me!" The system creates a UserKanjiProgress record for Yuki + 四 (if none exists) and redirects Yuki to the Numbers quiz with 四 included in the quiz pool.

#### 2: Yuki re-learns a kanji she already has progress on

Yuki returns to Numbers after a week and reviews 三 in the teach step. She already has a UserKanjiProgress record for 三 from a previous session. Clicking "learned" does not create a duplicate -- the existing record is preserved with its SRS state intact.

#### 3: Yuki skips 五 without marking it learned

Yuki is not ready for 五 yet. She clicks "Skip to next" and advances to 六. No UserKanjiProgress record is created for 五. The quiz pool does not include 五.

### UAT Scenarios (BDD)

#### Scenario: Marking a new kanji as learned creates SRS progress

Given Yuki Tanaka is on the teach step for 四
And Yuki has no existing UserKanjiProgress for 四
When Yuki clicks "I've learned this -- Quiz me!"
Then a UserKanjiProgress record is created for Yuki and 四
And the record has initial SRS values (interval: 1, ease_factor: 2.5, repetitions: 0)
And Yuki is navigated to the Numbers group quiz

#### Scenario: Marking an already-tracked kanji preserves SRS state

Given Yuki Tanaka is on the teach step for 三
And Yuki already has a UserKanjiProgress for 三 with interval 6 and repetitions 3
When Yuki clicks "I've learned this -- Quiz me!"
Then the existing UserKanjiProgress is not modified
And Yuki is navigated to the Numbers group quiz

#### Scenario: Skipping does not create a progress record

Given Yuki Tanaka is on the teach step for 五
And Yuki has no existing UserKanjiProgress for 五
When Yuki clicks "Skip to next"
Then no UserKanjiProgress record is created for 五
And Yuki advances to the teach step for 六

### Acceptance Criteria

- [ ] "I've learned this" initializes a UserKanjiProgress record via the existing `initialize` action (upsert)
- [ ] Existing SRS state is not overwritten if a progress record already exists
- [ ] After marking learned, user is navigated to the group quiz
- [ ] "Skip to next" advances to next kanji position without creating/modifying progress
- [ ] Navigation wraps: skipping past the last kanji returns to the group detail page

### Outcome KPIs

- **Who**: Learners encountering a kanji for the first time
- **Does what**: Mark it as learned (opt into quiz rather than skipping)
- **By how much**: >80% learned vs <20% skipped
- **Measured by**: LiveView events on "learned" vs "skip" buttons
- **Baseline**: N/A (new feature)

### Technical Notes

- Uses existing `UserKanjiProgress.initialize/2` action which is already an upsert
- The `initialize` action sets `next_review_date` to now, making the kanji immediately quiz-eligible
- Depends on: US-02 (teach step exists to host the button)

---

## US-04: Quiz Scoped to Learned Kanji in a Group

### Problem

Yuki finishes studying Numbers kanji 1-4 and enters the quiz. The existing quiz pulls from ALL kanji due for review across all groups -- she gets tested on 川 (river) which she has never studied. The quiz needs to test only kanji she has learned within the current thematic group.

### Who

- Kanji learner | Has learned 1+ kanji in a thematic group | Wants to test recall within that group's context

### Solution

A group-scoped quiz that draws questions only from kanji the learner has marked as "learned" within the current thematic group. Uses the existing answer-checking logic and SRS recording but filters the quiz pool.

### Domain Examples

#### 1: Yuki quizzes on 4 learned Numbers kanji

Yuki has learned 一, 二, 三, 四. She starts the Numbers quiz. The quiz presents these 4 kanji in sequence. She types "four" for 四 and sees "Correct!" with the example sentence "四月は春です。"

#### 2: Yuki answers with a reading instead of meaning

The quiz shows 三. Yuki types "さん" (the on reading). The system accepts it as correct because readings are valid answers (existing behavior in QuizLive).

#### 3: Yuki has zero learned kanji and tries to quiz

Yuki navigates directly to /learn/nature/quiz but has not learned any Nature kanji. She sees: "Learn at least one kanji before starting the quiz. Start with 水." with a link to the first Nature kanji teach step.

### UAT Scenarios (BDD)

#### Scenario: Quiz presents only learned kanji from the group

Given Yuki has learned 一, 二, 三, 四 in the Numbers group
And Yuki has learned 山, 川 in the Nature group
When Yuki starts the Numbers group quiz
Then the quiz draws only from 一, 二, 三, 四
And 山 and 川 do not appear

#### Scenario: Correct answer shows contextual feedback

Given Yuki is in the Numbers group quiz
And the current question shows 四
When Yuki types "four" and submits
Then Yuki sees "Correct!" feedback
And the feedback includes the meaning "four"
And the feedback includes readings よん, シ
And the feedback includes an example sentence for 四
And the SRS record for 四 is updated as correct

#### Scenario: Incorrect answer shows learning reinforcement

Given Yuki is in the Numbers group quiz
And the current question shows 四
When Yuki types "five" and submits
Then Yuki sees "Incorrect" feedback
And the feedback shows the correct meaning "four" and readings
And the feedback shows an example sentence for 四
And the SRS record for 四 is updated as incorrect

#### Scenario: Quiz blocks when no kanji learned in group

Given Yuki has not learned any kanji in the Nature group
When Yuki navigates to /learn/nature/quiz
Then Yuki sees "Learn at least one kanji before starting the quiz."
And Yuki sees a link "Start with 水" pointing to the first Nature kanji teach step

#### Scenario: Quiz session ends after all learned kanji reviewed

Given Yuki has learned 一, 二, 三 in the Numbers group
And the quiz has presented all 3 kanji
When Yuki answers the last question
Then the quiz transitions to the group progress summary

### Acceptance Criteria

- [ ] Quiz pool is filtered to kanji where UserKanjiProgress exists AND kanji is in the current ThematicGroup
- [ ] Answer checking accepts meanings and readings (reuse existing `check_answer_correctness` logic)
- [ ] Correct/incorrect results recorded via existing `SRS.Logic.record_review`
- [ ] Feedback includes meaning, readings, and example sentence for contextual reinforcement
- [ ] Quiz blocked with helpful message when 0 kanji learned in group
- [ ] Quiz ends after all eligible kanji reviewed in the session

### Outcome KPIs

- **Who**: Learners who just completed the teach step
- **Does what**: Answer correctly on first attempt for kanji they studied in the teach step
- **By how much**: >60% first-attempt accuracy (vs unknown baseline for kanji tested without teach step)
- **Measured by**: `record_review` result tracking (correct vs incorrect, first review only)
- **Baseline**: Measure current first-attempt accuracy in existing QuizLive for comparison

### Technical Notes

- Quiz pool query: `UserKanjiProgress` WHERE `user_id = Yuki` AND `kanji_id IN (group's kanji_ids)`
- Reuses `SRS.Logic.record_review` for SRS updates
- Reuses answer normalization and checking from existing QuizLive
- Does NOT use the existing QuizLive's `due_for_review` filter -- learning path quiz shows all learned kanji in the group regardless of SRS due date (this is a learning review, not SRS-scheduled review)
- Route: `/learn/:group_slug/quiz`
- Depends on: US-03 (kanji must be markable as learned)

---

## US-05: View Group Progress and Continue Learning

### Problem

Yuki finishes a quiz session on Numbers and does not know what to do next. Did she complete the group? How many are left? The quiz just shows "no more kanji due" which is the SRS completion message, not a learning progress summary. She needs to see how far she has come in the group and what the next step is.

### Who

- Kanji learner | Just completed a group quiz session | Wants to see progress and know what comes next

### Solution

A group progress view showing session results, a visual kanji grid with learned/unlearned markers, and a clear "Continue Learning" call-to-action pointing to the next unlearned kanji.

### Domain Examples

#### 1: Yuki sees progress after a partial quiz

Yuki answered 3/4 correct in the Numbers quiz. The summary shows "This session: 3/4 correct" and "Group progress: 4/12 learned." The kanji grid shows 一, 二, 三, 四 with checkmarks. "Continue Learning" points to 五.

#### 2: Yuki completes a small group

Yuki finishes all 2 kanji in the Time group (年, 夕). After her final quiz, she sees "Group progress: 2/2 learned" with a completion celebration. "Continue Learning" is replaced by "All learned!" and "Review All" lets her re-quiz.

#### 3: Yuki returns to a group she partially completed last week

Yuki opens Numbers from the /learn page. She sees the grid with 4 kanji marked learned. "Continue Learning" points to 五. She picks up where she left off without confusion.

### UAT Scenarios (BDD)

#### Scenario: Session results display after quiz

Given Yuki just completed a Numbers quiz session
And Yuki answered 3 correct and 1 incorrect
When the quiz session ends and returns to the group view
Then Yuki sees "This session: 3/4 correct"
And Yuki sees "Group progress: 4/12 learned"

#### Scenario: Kanji grid reflects learned state

Given Yuki has learned 一, 二, 三, 四 in Numbers
When Yuki views the Numbers group page
Then 一, 二, 三, 四 show a learned indicator in the grid
And 五 through 千 show no indicator
And "Continue Learning" links to the teach step for 五

#### Scenario: Completed group shows celebration

Given Yuki has learned all 5 kanji in the Directions group
When Yuki views the Directions group page
Then all 5 kanji show learned indicators
And the page shows "All learned!" instead of "Continue Learning"
And "Review All" is available for re-quizzing

#### Scenario: Continue learning resumes at correct position

Given Yuki has learned 一, 二, 三 but not 四 in Numbers
When Yuki clicks "Continue Learning"
Then Yuki is taken to the teach step for 四 (position 4)

### Acceptance Criteria

- [ ] Group page shows session results (X/Y correct) when returning from quiz
- [ ] Kanji grid shows learned/unlearned state for every kanji in the group
- [ ] "Continue Learning" links to the first unlearned kanji in group order
- [ ] Fully completed groups show "All learned!" with "Review All" option
- [ ] Progress count (X/Y learned) is accurate and updates after each quiz session

### Outcome KPIs

- **Who**: Learners who just finished a quiz session
- **Does what**: Click "Continue Learning" to study the next kanji (retention/engagement)
- **By how much**: >40% of quiz completions result in immediately continuing to the next kanji
- **Measured by**: LiveView event tracking ("Continue Learning" click after quiz return)
- **Baseline**: N/A (new feature)

### Technical Notes

- Progress data: count of UserKanjiProgress records where `kanji_id` is in the group's kanji set
- Session results can be passed via URL params or flash assigns from the quiz LiveView
- "Continue Learning" position: first kanji in `KanjiThematicGroup` order without a matching `UserKanjiProgress` record
- Route: `/learn/:group_slug` (same as group detail, with optional session result display)
- Depends on: US-04 (quiz must exist to generate session results)

---

## Release 2 Stories (Summary)

These are defined at task-level for story mapping. Full LeanUX templates will be written when Release 1 is validated.

### US-06: Navigate Between Kanji in Teach Step

Add next/previous arrows to the teach step so learners can browse the group sequentially. Wraps at boundaries (first/last). 1 day effort.

### US-07: Stroke Order in Teach Step

Add "Show stroke order" toggle to the teach step, reusing existing StrokeOrderEvents and KanjiVG integration from ExploreLive. 1 day effort.

### US-08: Learning Tips and Mnemonics Display

Show KanjiLearningMeta learning_tips and mnemonic_hints in the teach step when data exists. Graceful degradation when absent. 0.5 day effort.

### US-09: Overall Progress on Learn Page

Show "X/80 kanji learned" counter on /learn and per-group progress badges on each card. 0.5 day effort.

### US-10: Review Learned Quiz Mode

"Review Learned" button on group detail quizzes all learned kanji in the group (not just newly learned). Separate from the "just learned, quiz me" flow. 1 day effort.

---

## Release 3 Stories (Summary)

### US-11: Seed All 80 Grade 1 Kanji

Ensure all 80 Grade 1 kanji from the curriculum reference exist in the kanjis table with correct grade, stroke_count, jlpt_level, meanings, pronunciations, and example sentences. Currently only a subset is seeded. 2 day effort (data work).

### US-12: Seed Thematic Group Assignments

Create KanjiThematicGroup records mapping all 80 kanji to their 10 thematic groups per the curriculum reference. Update Content.Seeds to match the full Grade 1 curriculum. 1 day effort.

### US-13: Seed Learning Metadata

Create KanjiLearningMeta records with learning_tips and mnemonic_hints for Grade 1 kanji. Prioritize groups with visual/pictographic kanji (Nature, Body Parts) where mnemonics are most effective. 2 day effort (content writing).
