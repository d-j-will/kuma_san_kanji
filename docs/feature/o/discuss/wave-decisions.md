# Wave Decisions: Grade 1 Thematic Learning Path

**Feature**: grade1-thematic-learning-path
**Wave**: DISCUSS
**Date**: 2026-03-11
**Status**: Ready for DESIGN handoff

---

## Decision 1: Walking Skeleton Scope

### Decision

The minimum viable learning path is 5 stories (US-01 through US-05) delivering the complete learn-then-quiz cycle for a single thematic group: browse groups, study a kanji, mark it learned, quiz on learned kanji, see progress.

### Rationale

- Discovery hypothesis H6 (First Encounter Learning Flow) ranked highest feasibility because all kanji data already exists in the database
- The explore page already shows everything needed for the teach step (character, meanings, readings, sentences, stroke order) -- the gap is purely a flow/UX problem
- Validating the core teach-then-test cycle before investing in polish (stroke order, navigation, tips) follows riskiest-assumption-first prioritization

### Alternatives Considered

- **Full feature in one release**: All 13 stories at once. Rejected because it delays validation of the core hypothesis and increases risk of building polish on an unproven foundation.
- **Start with content seeding only**: Seed all 80 kanji first, then build UI. Rejected because the seeding can run in parallel and the UI can be tested with the existing partial kanji data.
- **Start with sentence-completion quiz (H4)**: Build the contextual quiz format first. Rejected because H4 depends on validating that learners want a teach step at all (H6). Sequence: prove teach-then-test works, then improve the test format.

---

## Decision 2: Reuse Existing Infrastructure

### Decision

The learning path reuses existing Ash resources and LiveView patterns rather than creating new domain resources for "lessons" or "learning sessions."

### What is Reused

| Component | Existing Resource | How Used in Learning Path |
|-----------|------------------|--------------------------|
| Thematic groups | `Content.ThematicGroup` | Groups page, group detail |
| Group membership | `Content.KanjiThematicGroup` | Kanji ordering within groups |
| Kanji data | `Kanji.Kanji` + relationships | Teach step display |
| Learning metadata | `Content.KanjiLearningMeta` | Tips and mnemonics in teach step |
| User progress | `SRS.UserKanjiProgress` | Learned/not-learned state, quiz results |
| SRS algorithm | `SRS.Changes.ApplySm2` | Quiz answer recording |
| Answer checking | `QuizLive.check_answer_correctness/2` | Group quiz answer validation |
| Stroke order | `StrokeOrderEvents` + KanjiVG | Teach step animation (Release 2) |

### What is New

| Component | Why New |
|-----------|---------|
| `/learn` LiveView | New page for browsing groups -- does not exist |
| `/learn/:group_slug` LiveView | New page for group detail -- explore page browses individual kanji, not groups |
| `/learn/:group_slug/:position` LiveView | New page for teach step -- explore page shows one kanji but not in a group context |
| `/learn/:group_slug/quiz` LiveView | New quiz variant -- existing QuizLive pulls from all due kanji, not scoped to a group |
| `:grade1_learning_path` feature flag | Required by project rules for all new user-facing features |

### Rationale

- Creating new Ash resources (e.g., `Lesson`, `LearningSession`, `GroupProgress`) would add schema complexity without delivering value that existing resources cannot provide
- `UserKanjiProgress` already tracks per-user per-kanji state -- "learned" is simply "has a progress record"
- `ThematicGroup` and `KanjiThematicGroup` already model the group structure
- Solo developer project: minimize new database tables, maximize reuse

### Risk

The main risk of reuse is that `UserKanjiProgress` conflates "learned in the learning path" with "has been quizzed in the general quiz." A kanji could have a progress record from the general quiz without ever going through the teach step. For the walking skeleton, this is acceptable -- the learning path treats any existing progress record as "learned." If this becomes a problem (learners confused by kanji appearing as "learned" that they never studied in the teach step), a future story can add a `learned_via` attribute to `UserKanjiProgress`.

---

## Decision 3: Quiz Pool Scoping Strategy

### Decision

The group quiz shows all kanji that have a `UserKanjiProgress` record AND belong to the current thematic group, regardless of SRS due date.

### Rationale

- This is a learning review, not an SRS-scheduled review. The purpose is to reinforce what was just studied, not to follow the spaced repetition schedule.
- Learners who just studied 四 expect to be quizzed on 四 immediately, even if the SRS algorithm would schedule it for tomorrow.
- The existing QuizLive with SRS scheduling remains available as the separate `/quiz` page for interval-based review.

### Alternatives Considered

- **Respect SRS due dates in group quiz**: Only quiz kanji that are due for review. Rejected because a kanji marked "learned" 30 seconds ago would have a due date of "now" but after one correct answer would be scheduled for tomorrow, disappearing from the group quiz. This breaks the learn-then-test expectation.
- **Separate "learning quiz" resource**: Create a non-SRS quiz mode that does not record to UserKanjiProgress. Rejected because we WANT the SRS to track these reviews -- the teach step is the first encounter, the group quiz is the first SRS review.

---

## Decision 4: Content Seeding as Parallel Track

### Decision

Release 3 (content seeding -- US-11, US-12, US-13) executes in parallel with Release 1 UI development, not sequentially after it.

### Rationale

- The current database has only a subset of Grade 1 kanji seeded. The existing seed data includes ~31 kanji mapped to 6 thematic groups (Numbers, Nature, People, Actions, Time, Abstract Concepts).
- The curriculum reference defines 80 kanji across 10 groups. 4 groups have no kanji seeded at all (Directions, Body Parts, Colors, Objects).
- Release 1 UI can be developed and tested with the existing partial data. But launching to users with incomplete groups would be confusing.
- Content seeding is independent work (data scripts, no UI changes) that a developer can do without conflicting with LiveView development.

---

## Decision 5: Feature Flag Strategy

### Decision

All learning path pages are gated behind a single `:grade1_learning_path` FunWithFlags flag. The "Learn" navigation item is conditionally rendered based on this flag.

### Rationale

- Project rule: "All new user-facing features must be behind a FunWithFlags flag"
- A single flag for the entire learning path (rather than per-release flags) keeps it simple. The flag gates the entry point (/learn); sub-pages inherit the gate.
- Admin can enable for testing on production by toggling the flag for specific users or globally.

---

## Decision 6: No New Ash Domain

### Decision

The learning path does not introduce a new Ash domain. New LiveViews query existing Content and SRS domain resources directly.

### Rationale

- A "Learning" domain would add module structure overhead for what amounts to querying existing resources in a new combination
- The new LiveViews are the orchestration layer -- they compose data from Content (groups, metadata) and SRS (progress) domains
- If the learning path grows to require its own business logic (e.g., adaptive difficulty, prerequisite checking, spaced group scheduling), a domain can be extracted then. Not now.

---

## Open Questions

| # | Question | Impact | Resolution Path |
|---|----------|--------|-----------------|
| Q1 | How many of the 80 Grade 1 kanji are currently seeded in the database? | Determines R3 scope -- seeding 50 vs 80 kanji is different effort | Query the database: `SELECT COUNT(*) FROM kanjis WHERE grade = 1` |
| Q2 | Should the learning path be the default landing page for new users? | Affects onboarding flow -- currently PageLive at `/` is the landing | Defer to after R1 validation. If learning path proves effective, consider making it the default authenticated landing page. |
| Q3 | Should general quiz (/quiz) exclude kanji from learning path groups to avoid overlap? | Learners might see the same kanji in both flows with different experiences | No for walking skeleton. The general quiz and learning path quiz serve different purposes (SRS review vs learning review). Revisit if user confusion is observed. |

---

## Handoff Summary for DESIGN Wave

### What the solution-architect receives

1. **Journey artifacts**: Visual flow, YAML schema, Gherkin scenarios -- defines the user experience end-to-end
2. **Story map**: 3 releases with walking skeleton identified -- defines build order
3. **User stories**: 5 fully specified stories (US-01 through US-05) with BDD acceptance criteria -- defines what to build
4. **Shared artifact registry**: Data flow across pages with integration checkpoints -- defines what must stay consistent
5. **Outcome KPIs**: Measurable success criteria -- defines how to know if it works
6. **This document**: Architectural decisions already made in the DISCUSS wave -- reduces decision surface for DESIGN

### What DESIGN needs to decide

- LiveView architecture: single LiveView with components vs multiple LiveViews
- URL routing strategy: nested routes, slug generation for groups
- Database query optimization: how to efficiently aggregate progress per group
- Component extraction: which UI elements to extract as reusable components
- Telemetry instrumentation: how to implement the KPI measurement plan
