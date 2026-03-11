# Story Map: Grade 1 Thematic Learning Path

## User: Yuki Tanaka

34-year-old software developer. JLPT N5. Knows ~30 kanji from flashcard apps but cannot read sentences. Frustrated by the gap between "quiz correct" and "can actually read."

## Goal: Learn Grade 1 kanji through a structured teach-then-test flow organized by thematic groups

---

## Backbone

| Choose a Group | Learn a Kanji | Quiz on Learned | Track Progress |
|----------------|---------------|-----------------|----------------|
| See all 10 thematic groups | See meaning, readings, example sentence | Answer meaning or reading | See group completion |
| See progress per group | See stroke order animation | Get contextual feedback | See next steps |
| Pick a group to start | See learning tips/mnemonics | SRS records review result | See overall progress |
| Resume where left off | Mark as "learned" | Quiz only learned kanji | Review learned kanji |
| | Navigate between kanji | Skip question | |
| | Skip without marking learned | | |

---

### Walking Skeleton

The thinnest end-to-end slice that proves the learn-then-test flow works:

| Choose a Group | Learn a Kanji | Quiz on Learned | Track Progress |
|----------------|---------------|-----------------|----------------|
| See all groups as cards with kanji count | See character, meaning, readings, one example sentence | Answer meaning for one kanji | See X/Y learned per group |
| Pick a group | Mark as "learned" | Get correct/incorrect feedback | "Continue Learning" to next kanji |

**What this validates**: The core hypothesis (H6) that a teach step before quiz improves the learning experience. One group (Numbers), basic kanji display, mark-as-learned, scoped quiz, group progress count.

---

### Release 1: Walking Skeleton -- Teach-Then-Test Core

**Outcome**: Learner can study a kanji, mark it learned, and quiz only on learned kanji within a thematic group.

**Stories**:

- US-01: Browse thematic groups (see group cards with name, kanji preview, count)
- US-02: View kanji in teach step (character, meaning, readings, example sentence)
- US-03: Mark kanji as learned and trigger group quiz
- US-04: Quiz scoped to learned kanji in a group (reuse existing answer-checking)
- US-05: View group progress (X/Y learned, continue learning link)

**Feature flag**: `:grade1_learning_path`

**What it proves**: Does the learn-before-quiz flow feel better than jumping straight to quiz? Do learners complete groups or abandon partway?

---

### Release 2: Polish and Navigation -- Confident Learning

**Outcome**: Learner can navigate fluidly within and across groups, with stroke order and tips enriching the learning step.

**Stories**:

- US-06: Navigate between kanji within a group (next/previous)
- US-07: Show stroke order animation in teach step (reuse existing StrokeOrderEvents)
- US-08: Display learning tips and mnemonics from KanjiLearningMeta
- US-09: Overall progress across all groups on /learn page (X/80 learned)
- US-10: "Review Learned" quiz mode for already-completed kanji in a group

**What it proves**: Do enriched learn steps (stroke order, tips) increase completion rates? Do learners return to review completed groups?

---

### Release 3: Content Completeness -- Full Grade 1 Coverage

**Outcome**: All 80 Grade 1 kanji are seeded with thematic group assignments, example sentences, and learning metadata.

**Stories**:

- US-11: Seed all 80 Grade 1 kanji into the database (currently only a subset exists)
- US-12: Seed all 10 thematic group assignments via KanjiThematicGroup
- US-13: Seed learning tips/mnemonics for Grade 1 kanji in KanjiLearningMeta

**Note**: This is data/content work, not UI work. It can proceed in parallel with Release 1 UI development. Without it, Release 1 works but with incomplete groups.

---

## Activities Not in Scope (Future)

These emerged in discovery but are explicitly deferred:

| Activity | Why Deferred |
|----------|-------------|
| Sentence-completion quiz format (H4) | Validate basic teach-then-test first; sentence quiz is a separate experiment |
| Graded reading passages (H1) | Requires content generation pipeline; validate simpler context approach first |
| Meaning disambiguation clusters (H5) | Requires semantic tagging data that does not exist yet |
| Radical-based mnemonic generation (H7) | Risk of being undifferentiated from WaniKani; manual tips first |
