# Definition of Ready Validation

## Release 1 -- Walking Skeleton Stories

---

### Story: US-01 -- Browse Thematic Groups

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "She finds it overwhelming to decide what to study next. There is no guided starting point." Domain language used (thematic groups, curriculum). |
| User/persona identified | PASS | Yuki Tanaka -- 34yo developer, JLPT N5, ~30 kanji from flashcards. Specific characteristics. |
| 3+ domain examples | PASS | 3 examples: first-time learner, returning learner with progress, feature flag disabled. Real persona names (Yuki Tanaka, Kenji Nakamura). |
| UAT scenarios (3-7) | PASS | 4 scenarios: first-time view, returning with progress, unauthenticated redirect, flag disabled. All Given/When/Then. |
| AC derived from UAT | PASS | 6 ACs, each traceable to scenarios (group cards, progress badge, auth gate, feature flag). |
| Right-sized | PASS | 1-2 days effort, 4 scenarios. Single LiveView page rendering group cards with progress query. |
| Technical notes | PASS | ThematicGroup resource, UserKanjiProgress aggregation, FunWithFlags flag name, route path. |
| Dependencies tracked | PASS | No dependencies (first story in sequence). |
| Outcome KPIs defined | PASS | Activation: >60% click into a group. Measured by LiveView event. |

### DoR Status: PASSED

---

### Story: US-02 -- Study a Kanji in the Teach Step

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "She has never studied 四. She guesses wrong, feels frustrated." Maps directly to validated problem #3 (tested on things not taught). |
| User/persona identified | PASS | Yuki Tanaka, same persona, now inside a thematic group encountering a kanji for the first time. |
| 3+ domain examples | PASS | 3 examples: studying 四 (Numbers), studying 山 (Nature), kanji without learning tips (百). Real data throughout. |
| UAT scenarios (3-7) | PASS | 4 scenarios: full kanji detail, learning tips present, tips absent, group position indicator. |
| AC derived from UAT | PASS | 6 ACs covering display elements, conditional tips, button presence. |
| Right-sized | PASS | 1-2 days effort, 4 scenarios. Single LiveView rendering kanji data from existing resources. |
| Technical notes | PASS | Reuses Kanji resource with loaded relationships, KanjiLearningMeta, route pattern. Notes no new Ash resources needed. |
| Dependencies tracked | PASS | Depends on US-01 (group page exists to navigate from). |
| Outcome KPIs defined | PASS | Engagement: >80% "learned" vs <20% "skip". |

### DoR Status: PASSED

---

### Story: US-03 -- Mark a Kanji as Learned

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "The system does not know the difference between a kanji Yuki has never seen and one she has just spent 30 seconds studying." Clear domain problem. |
| User/persona identified | PASS | Yuki Tanaka, just completed studying in the teach step. |
| 3+ domain examples | PASS | 3 examples: first-time learned (create progress), re-learn existing (upsert preserves state), skip without learning. |
| UAT scenarios (3-7) | PASS | 3 scenarios: new kanji creates progress, existing kanji preserves state, skip creates nothing. |
| AC derived from UAT | PASS | 5 ACs covering initialize upsert, no overwrite, navigation to quiz, skip behavior, wrap at boundary. |
| Right-sized | PASS | 0.5-1 day effort, 3 scenarios. Single button action using existing `UserKanjiProgress.initialize`. |
| Technical notes | PASS | Uses existing `initialize` action (upsert), sets `next_review_date` to now. Dependency on US-02 noted. |
| Dependencies tracked | PASS | US-02 (teach step hosts the button). |
| Outcome KPIs defined | PASS | >80% learned vs <20% skipped. |

### DoR Status: PASSED

---

### Story: US-04 -- Quiz Scoped to Learned Kanji in a Group

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "The existing quiz pulls from ALL kanji due for review across all groups -- she gets tested on 川 (river) which she has never studied." Concrete example of the problem. |
| User/persona identified | PASS | Yuki Tanaka, has learned 1+ kanji in a thematic group. |
| 3+ domain examples | PASS | 3 examples: quiz on 4 learned Numbers kanji, answer with reading instead of meaning, zero-learned kanji guard. |
| UAT scenarios (3-7) | PASS | 5 scenarios: scoped pool, correct answer, incorrect answer, reading-as-answer, zero-learned guard. All Given/When/Then. |
| AC derived from UAT | PASS | 6 ACs covering pool filter, answer checking, SRS recording, feedback content, zero-learned guard, session end. |
| Right-sized | PASS | 1-2 days effort, 5 scenarios. New LiveView but reuses existing answer-checking and SRS logic. |
| Technical notes | PASS | Query strategy documented (UserKanjiProgress WHERE kanji_id IN group). Notes reuse of SRS.Logic.record_review. Explicitly notes NOT using due_for_review filter. Route path. Dependency on US-03. |
| Dependencies tracked | PASS | US-03 (kanji must be markable as learned). |
| Outcome KPIs defined | PASS | >60% first-attempt accuracy. Baseline measurement method specified. |

### DoR Status: PASSED

---

### Story: US-05 -- View Group Progress and Continue Learning

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Yuki finishes a quiz session and does not know what to do next. The quiz just shows 'no more kanji due' which is the SRS completion message, not a learning progress summary." |
| User/persona identified | PASS | Yuki Tanaka, just completed a group quiz session. |
| 3+ domain examples | PASS | 3 examples: partial quiz results, completing a small group (Time), returning to partially completed group. Real group names and kanji. |
| UAT scenarios (3-7) | PASS | 4 scenarios: session results display, kanji grid learned state, completed group celebration, continue learning position. |
| AC derived from UAT | PASS | 5 ACs covering session results, grid state, continue learning link, completion state, accurate count. |
| Right-sized | PASS | 1 day effort, 4 scenarios. Adds progress display to existing group detail page. |
| Technical notes | PASS | Progress query strategy, session result passing, "Continue Learning" position calculation. Route. Dependency on US-04. |
| Dependencies tracked | PASS | US-04 (quiz generates session results). |
| Outcome KPIs defined | PASS | >40% immediate continuation rate. |

### DoR Status: PASSED

---

## Summary

| Story | DoR Items Passed | Status |
|-------|-----------------|--------|
| US-01: Browse Thematic Groups | 9/9 | PASSED |
| US-02: Study a Kanji in Teach Step | 9/9 | PASSED |
| US-03: Mark a Kanji as Learned | 9/9 | PASSED |
| US-04: Quiz Scoped to Group | 9/9 | PASSED |
| US-05: Group Progress View | 9/9 | PASSED |

All Release 1 stories pass the Definition of Ready gate and are ready for DESIGN wave handoff.
