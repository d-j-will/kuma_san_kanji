# ADR-003: Quiz Pool Strategy -- All Learned Kanji, No SRS Date Filter

## Status

Accepted

## Context

The learning path quiz needs to determine which kanji to include in the quiz pool for a given thematic group. The existing `QuizLive` uses `UserKanjiProgress.due_for_review` which filters by `next_review_date <= now()`. The learning path quiz serves a different purpose: reinforcing what was just studied, not enforcing spaced repetition schedules.

This decision was already made in the DISCUSS wave (Decision 3) and is documented here as a formal ADR.

## Decision

`GroupQuizLive` queries all `UserKanjiProgress` records where:
- `user_id` matches the current user
- `kanji_id` is in the set of kanji belonging to the current thematic group (via `KanjiThematicGroup`)

No `next_review_date` filter is applied. All learned kanji in the group are eligible for quiz regardless of SRS schedule.

SRS records ARE still updated via `SRS.Logic.record_review/4` when answers are submitted. The quiz is a learning review that also feeds the SRS algorithm.

## Alternatives Considered

### Alternative A: Respect SRS due dates

Only quiz kanji that are due for review (`next_review_date <= now()`).

- Pro: Consistent with SRS philosophy.
- Con: A kanji marked "learned" 30 seconds ago has `next_review_date = now()`. After one correct answer, it is scheduled for tomorrow and disappears from the group quiz. This breaks the learn-then-test expectation entirely. Learners would study 4 kanji but only be quizzed on 1 (the one just marked learned).
- Rejected because: Fundamentally breaks the user experience. The learning path quiz is about reinforcement, not scheduling.

### Alternative B: Separate non-SRS quiz mode

Create a quiz mode that does not record results to `UserKanjiProgress` at all.

- Pro: Clean separation between learning quiz and SRS.
- Con: The teach step IS the first SRS encounter. The group quiz IS the first SRS review. Not recording means the SRS has no data about these interactions, and the learner would need to re-encounter these kanji in the general quiz.
- Rejected because: We WANT the SRS to track these reviews. The value is in both learning AND feeding the spaced repetition system.

## Consequences

### Positive

- Learners are always quizzed on everything they have studied in a group -- predictable and satisfying.
- SRS data is captured from the very first encounter, improving long-term scheduling.
- Simple query -- no date filtering logic needed.

### Negative

- A group quiz session may include kanji that were studied weeks ago and are well-mastered. This is acceptable for groups of max 19 kanji -- the overhead is minimal.
- The general quiz (`/quiz`) and the learning path quiz (`/learn/:slug/quiz`) serve different purposes with different pool strategies. This must be clear to users (addressed by distinct UI and navigation).
