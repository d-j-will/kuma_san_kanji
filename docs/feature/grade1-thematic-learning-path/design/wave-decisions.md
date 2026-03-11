# Wave Decisions: Grade 1 Thematic Learning Path

**Feature**: grade1-thematic-learning-path
**Wave**: DESIGN
**Date**: 2026-03-11
**Status**: Ready for DISTILL handoff

---

## Decision 1: Separate LiveViews per Page

### Decision

Four separate LiveViews (`LearnLive`, `GroupLive`, `TeachLive`, `GroupQuizLive`) rather than a single LiveView with handle_params or live components.

### Rationale

Follows the existing codebase pattern (one LiveView per page). Each page has distinct state and events. Solo developer needs independently testable units. Max ~150 lines each vs one 600+ line monolith.

### ADR

[ADR-001: LiveView Structure](adr-001-liveview-structure.md)

---

## Decision 2: Slug-Based URL Routing

### Decision

Add `slug` attribute to `ThematicGroup` for human-readable URLs (`/learn/numbers` not `/learn/uuid`).

### Rationale

User-facing URLs should be readable and bookmarkable. This is a standard web pattern. Requires one non-breaking migration (expand phase).

### ADR

[ADR-002: Slug Routing](adr-002-slug-routing.md)

---

## Decision 3: Position Attribute on KanjiThematicGroup

### Decision

Add nullable `position` integer to `KanjiThematicGroup` for explicit ordering of kanji within groups.

### Rationale

The current `relevance_score` (float) was designed for ranking relevance, not curriculum ordering. The teach step needs deterministic sequential positions ("Kanji 4 of 12"). Position is the curriculum order within a thematic group. Nullable to avoid breaking existing rows -- the learning path sorts by `position ASC NULLS LAST, relevance_score DESC` as fallback.

### Alternatives Considered

- **Use relevance_score for ordering**: Awkward semantic overload. Float comparison for integer positions is fragile.
- **Add a separate CurriculumOrder table**: Over-engineering for one integer column.

---

## Decision 4: Extract Answer Checker from QuizLive

### Decision

Extract `check_answer_correctness/2` and `normalize_kana/1` from QuizLive into `KumaSanKanjiWeb.Live.AnswerChecker`. Both QuizLive and GroupQuizLive use the shared module.

### Rationale

This is the only code extraction from existing modules. Answer checking must be identical across both quiz experiences. The extracted module is pure (no side effects) and independently testable.

### ADR

[ADR-004: Answer Checker Extraction](adr-004-answer-checker-extraction.md)

---

## Decision 5: Feature Flag Helper Module

### Decision

Create `KumaSanKanjiWeb.FeatureFlagHelper` with a `learning_path_enabled?/0` function used by navigation and all learning path LiveView mounts.

### Rationale

Centralizes the `FunWithFlags.enabled?(:grade1_learning_path)` call. If the flag name changes, only one place to update. Provides a clean pattern for future feature flags. Each LiveView mount calls this helper and redirects to `/` if disabled.

### Alternatives Considered

- **Inline FunWithFlags calls**: Scatters the flag name string across 5+ files.
- **Plug-based gate**: Would require a custom plug in the router pipeline. LiveViews do not support plugs in the same way -- `on_mount` is the correct mechanism for LiveView gating, but the flag check is lightweight enough for a mount callback.

---

## Decision 6: Quiz Session Results via URL Params

### Decision

When the group quiz completes, navigate to `/learn/:slug?correct=N&incorrect=M` to pass session results to the group detail page.

### Rationale

Since `GroupQuizLive` and `GroupLive` are separate LiveViews (Decision 1), they do not share socket state. URL params are the simplest way to pass summary data. The params are optional -- visiting `/learn/:slug` directly shows the group without session results.

### Alternatives Considered

- **Flash assigns**: Phoenix flash is designed for messages, not structured data. Would need to encode/decode counts.
- **ETS/process storage**: Over-engineering for two integers.
- **Database session table**: Over-engineering. The session results are ephemeral display data.

---

## Decision 7: Route Ordering for Quiz vs Position

### Decision

Define `/learn/:slug/quiz` BEFORE `/learn/:slug/:position` in the router.

### Rationale

Phoenix matches routes top-down. If `:position` route is first, the literal "quiz" matches as a position value. Placing the explicit `/quiz` route first ensures correct dispatch. This is a standard Phoenix routing pattern.

---

## Decision 8: No New Database Tables

### Decision

Release 1 creates zero new database tables. Only adds columns to two existing tables (slug, position).

### Rationale

Honors DISCUSS Decision 2 (reuse over creation) and Decision 6 (no new domain). "Learned" = "has a UserKanjiProgress record." Progress aggregation is a query, not a stored value. This eliminates data synchronization issues.

### Risk

If aggregating progress per group becomes a performance concern (it will not for 80 kanji and 10 groups), a materialized view or cache can be added later.

---

## Handoff Summary for DISTILL Wave

### What the acceptance-designer receives

1. **Architecture document**: Component boundaries, data model, LiveView state design, integration patterns, C4 diagrams
2. **5 ADRs**: LiveView structure, slug routing, quiz pool strategy, answer checker extraction, no new domain
3. **This document**: Design decisions with rationale and alternatives
4. **User stories from DISCUSS**: US-01 through US-05 with BDD scenarios and acceptance criteria (unchanged)

### What DISTILL needs to produce

- Acceptance tests for each user story based on the BDD scenarios
- Test data setup helpers for thematic groups, kanji, and user progress
- Feature flag toggle helpers for test setup
