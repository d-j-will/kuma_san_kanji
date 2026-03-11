# ADR-004: Extract Answer Checking to Shared Module

## Status

Accepted

## Context

The `QuizLive` module contains a private function `check_answer_correctness/2` that normalizes user input and checks it against kanji meanings and readings. The new `GroupQuizLive` needs identical answer-checking behavior. Duplicating this logic would create a maintenance burden and risk behavioral drift between the two quiz experiences.

## Decision

Extract the answer-checking logic from `QuizLive` into a new module `KumaSanKanjiWeb.Live.AnswerChecker` with a public function `correct?/2`. Both `QuizLive` and `GroupQuizLive` call this shared module. The extraction includes:

- `correct?/2` -- main check: meaning match OR reading match
- `normalize_kana/1` -- katakana-to-hiragana normalization (supporting helper)

`QuizLive` is updated to call the extracted module instead of its private function.

## Alternatives Considered

### Alternative A: Duplicate the logic in GroupQuizLive

Copy `check_answer_correctness/2` and helpers into `GroupQuizLive`.

- Pro: No changes to existing `QuizLive`. Zero coupling.
- Con: Two copies to maintain. Bug fixes must be applied twice. Behavioral drift risk.
- Rejected because: DRY principle applies strongly here -- answer checking is core quiz behavior that must be consistent.

### Alternative B: Put answer checking in SRS.Logic

Move the function to the business logic layer.

- Pro: Centralized business logic.
- Con: Answer checking depends on web-layer concerns (HTML escaping, input sanitization). `SRS.Logic` currently has no presentation concerns. Mixing layers.
- Rejected because: Answer normalization is a presentation/input concern, not SRS logic. The SRS module receives `:correct` or `:incorrect` atoms, not raw user input.

## Consequences

### Positive

- Single source of truth for answer checking.
- Both quiz experiences behave identically.
- The module is independently testable with unit tests.

### Negative

- Requires a small refactor of existing `QuizLive` to call the extracted module.
- Adds one new file to the codebase.
