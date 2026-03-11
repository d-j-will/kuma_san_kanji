# Wave Decisions: Grade 1 Thematic Learning Path

**Feature**: grade1-thematic-learning-path
**Wave**: DISTILL
**Date**: 2026-03-11
**Status**: Ready for DELIVER handoff

---

## Decision 1: Test Organization -- One Module per User Story

### Decision

Acceptance tests are organized as one ExUnit test module per user story, with a shared test helper module for data setup:

| File | Story | Scenarios |
|------|-------|-----------|
| `learn_live_test.exs` | US-01: Browse Thematic Groups | 7 scenarios |
| `teach_live_test.exs` | US-02: Study Kanji (Teach Step) | 8 scenarios |
| `mark_learned_test.exs` | US-03: Mark Kanji as Learned | 5 scenarios |
| `group_quiz_live_test.exs` | US-04: Group Quiz | 10 scenarios |
| `group_live_test.exs` | US-05: Group Progress | 9 scenarios |
| `feature_flag_test.exs` | US-05 cross-cutting: Feature Flag | 9 scenarios |
| `learning_path_helpers.ex` | Test data setup helpers | -- |

### Rationale

- Matches the codebase convention of one test module per LiveView
- Each module maps directly to a user story for traceability
- Feature flag tests extracted to their own module because the concern cross-cuts all stories
- `learning_path_helpers.ex` centralizes test data creation to avoid duplication

---

## Decision 2: Driving Ports -- LiveView as Entry Point

### Decision

All acceptance tests invoke through LiveView mounts and events (the driving ports), never through internal domain modules directly. Test assertions verify observable HTML output and navigation behavior.

### Rationale

- LiveViews are the user-facing entry points (driving ports) in this Phoenix application
- Tests use `Phoenix.LiveViewTest.live/2` for mounts and `render_click/2`, `render_submit/2` for events
- SRS state assertions use `UserKanjiProgress.get_user_kanji_progress/3` to verify observable side effects, but the action that creates them goes through the LiveView event handler
- This ensures integration wiring between LiveView -> ContentContext -> SRS.Logic is exercised

### Exception

The `LearningPathHelpers` module calls domain APIs directly (`SRS.Logic.initialize_progress`, `Content.create_thematic_group!`, `Domain.create_kanji!`) for test data setup only. This is the Given (precondition) layer, not the When (action) layer.

---

## Decision 3: All Tests Skip-Tagged for One-at-a-Time TDD

### Decision

Every test has `@tag :skip`. The DELIVER wave software-crafter enables one test at a time, implements until it passes, then enables the next.

### Rationale

- Follows outside-in TDD: one failing outer-loop test drives the inner-loop implementation
- Prevents the "wall of red" problem where 48 failing tests provide no signal
- Walking skeleton tests are listed first in each module to guide implementation order

### Implementation Sequence

1. `feature_flag_test.exs` -- Flag gating and route setup (infrastructure)
2. `learn_live_test.exs` -- Walking skeleton first, then remaining scenarios
3. `group_live_test.exs` -- Group detail with progress grid
4. `teach_live_test.exs` -- Teach step display and navigation
5. `mark_learned_test.exs` -- Mark learned + skip actions
6. `group_quiz_live_test.exs` -- Quiz with answer checking

---

## Decision 4: Group Identifier in URLs

### Decision

Tests currently use `group.id` (UUID) in URL paths rather than slug strings. When the slug migration (DESIGN Step 1) is completed, the routes will switch to slug-based paths. The test helper can be updated in one place.

### Rationale

- The `slug` attribute does not yet exist on `ThematicGroup`
- Using `group.id` allows tests to compile and exercise routing immediately
- Once the DELIVER wave adds the slug column, updating `~p"/learn/#{group.id}"` to `~p"/learn/#{group.slug}"` is a single find-replace

---

## Decision 5: Test Data via Helpers, Not Seeds

### Decision

Tests create their own data using `LearningPathHelpers` functions rather than relying on seed data. Each test is self-contained.

### Rationale

- Tests must be independent and repeatable regardless of seed state
- The sandbox checkout ensures test data is rolled back after each test
- Helper functions like `create_numbers_group/0` provide consistent, well-known test data
- Avoids brittle coupling to seed data that may change

---

## Scenario Coverage Summary

| Category | Count | Percentage |
|----------|-------|------------|
| Walking skeletons | 5 | 10% |
| Happy path | 17 | 35% |
| Error/edge path | 22 | 46% |
| Cross-cutting (flag) | 4 | 8% |
| **Total** | **48** | **100%** |

Error/edge path ratio: 46% (exceeds 40% target).

Walking skeletons:
1. First-time learner sees all thematic groups (US-01)
2. Learner studies a kanji in the teach step (US-02)
3. Marking a new kanji as learned creates progress and navigates to quiz (US-03)
4. Quiz presents only learned kanji from the current group (US-04)
5. Partially completed group shows kanji grid with learned indicators (US-05)

---

## Mandate Compliance Evidence

### CM-A: Hexagonal Boundary Enforcement

All test files invoke through LiveView driving ports:
- `live(conn, ~p"/learn")` -- LearnLive mount
- `live(conn, ~p"/learn/#{group.id}")` -- GroupLive mount
- `live(conn, ~p"/learn/#{group.id}/N")` -- TeachLive mount
- `live(conn, ~p"/learn/#{group.id}/quiz")` -- GroupQuizLive mount
- `render_click/2`, `render_submit/2` -- LiveView event handlers

No test imports or invokes internal modules (AnswerChecker, FeatureFlagHelper, etc.) for the When/Then layers.

### CM-B: Business Language Purity

Test names and assertions use business language:
- "first-time learner sees all thematic groups"
- "returning learner sees accurate progress"
- "marking a new kanji as learned creates progress"
- "quiz presents only learned kanji from the current group"

Zero technical terms (HTTP, JSON, database, controller, schema, GenServer) in test descriptions.

### CM-C: Walking Skeleton + Focused Scenario Counts

- Walking skeletons: 5 (one per user story)
- Focused scenarios: 43
- Total: 48

---

## Handoff Summary for DELIVER Wave

### What the software-crafter receives

1. **6 acceptance test files** in `test/kuma_san_kanji_web/live/learn/` -- 48 executable scenarios
2. **Test data helper** in `test/support/learning_path_helpers.ex` -- all factory functions
3. **Implementation sequence** -- ordered by dependency chain (Decision 3)
4. **This document** -- design rationale and mandate compliance evidence

### What DELIVER needs to implement

1. Database migration: add `slug` to `thematic_groups`, `position` to `kanji_thematic_groups`
2. Extend Ash resources: ThematicGroup (slug), KanjiThematicGroup (position)
3. Extend ContentContext: `get_group_by_slug/1`, `get_group_progress/2`, `get_kanji_at_position/2`
4. Create FeatureFlagHelper and AnswerChecker modules
5. Add routes to router, add "Learn" nav item with feature flag
6. Build LearnLive, GroupLive, TeachLive, GroupQuizLive
7. Update seed data (slugs, positions)

### First test to enable

`KumaSanKanjiWeb.FeatureFlagTest` -- "GET /learn redirects to home" (requires route + flag check, no UI).
