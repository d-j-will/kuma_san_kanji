# Solution Testing -- Kuma San Kanji

**Phase**: 3 -- Solution Testing
**Status**: Hypotheses Designed (Pre-Testing)
**Date**: 2026-03-11
**Evidence Sources**: Phase 2 top opportunities, codebase capabilities, competitive analysis

---

## Overview

This document defines testable hypotheses for the top 3 opportunities identified in Phase 2. Each hypothesis follows the template: We believe [doing X] for [user type] will achieve [outcome]. We will know this is TRUE/FALSE when we see [signal].

Testing has not yet been conducted. This document serves as the experiment design to guide Phase 3 execution.

---

## Opportunity 1: Bridge to Real Reading (Score: 17)

### Hypothesis H1: Graded Reading Passages

```
We believe that presenting short reading passages (3-5 sentences) composed
exclusively of kanji the learner has already studied, plus one new kanji with
furigana, will help intermediate learners bridge from quiz recall to reading
comprehension.

We will know this is TRUE when:
- >80% of test users attempt to read at least one passage per session
- >60% of test users report the passages helped them "see kanji in context"
- Users spend >2 minutes engaged with passages (not bouncing)

We will know this is FALSE when:
- <30% of users engage with passages when available
- Users report passages are "too easy" or "not real Japanese"
- No measurable improvement in retention of kanji seen in context vs. isolation
```

**Test Method**: Prototype (clickable mockup)
**Minimum Sample**: 5 users
**Feasibility Check**: The existing data model includes ExampleSentence per kanji. The Content domain has ThematicGroup for organizing related content. Generating passages from existing sentence data is feasible without new infrastructure.

**Risks to Address**:
| Risk | Level | Mitigation |
|------|-------|-----------|
| Value: will users want this? | High | Test with prototype before building |
| Usability: can users navigate learn-then-read flow? | Medium | 5-second test on mockup |
| Feasibility: can we generate coherent passages from sentence fragments? | Medium | Technical spike: can existing ExampleSentence data compose into paragraphs? |
| Viability: does this work for a free product? | Low | Core feature, not monetization driver |

### Hypothesis H2: Sentence-Level SRS Cards

```
We believe that adding sentence-context SRS cards (where the learner sees a full
Japanese sentence and identifies the target kanji's meaning in that context) will
improve long-term retention compared to isolated character-to-English cards.

We will know this is TRUE when:
- Users who study with sentence cards show >20% better retention at 30-day review
- >70% of users prefer sentence cards over isolated cards when given the choice
- Qualitative feedback includes phrases like "makes more sense" or "sticks better"

We will know this is FALSE when:
- Retention rates are statistically equivalent between card types
- Users report sentence cards are "overwhelming" or "too slow"
- >50% of users switch back to isolated cards within one week
```

**Test Method**: A/B feature test (behind FunWithFlags flag)
**Minimum Sample**: 10 users per variant (20 total)
**Feasibility Check**: SM-2 algorithm is already extracted into `SRS.Changes.ApplySm2`. Adding a sentence-context card type requires a new quiz mode in `QuizLive` but no algorithm changes. ExampleSentence data exists.

### Hypothesis H3: i+1 Reading Mode

```
We believe that providing a "reading mode" where texts contain exactly one unknown
kanji per sentence (comprehensible input at i+1) will address the unmet need
identified by tillcarlos on HN: "Do you know of a tool that can generate texts to
read based on exactly your level?"

We will know this is TRUE when:
- >60% of users who try reading mode return to it in their next session
- Users describe it as "the right difficulty" or "challenging but not frustrating"
- Time-on-task in reading mode exceeds time in quiz mode per session

We will know this is FALSE when:
- Users report the texts feel "robotic" or "unnatural"
- <30% return rate after first use
- Users say they prefer real content (manga, novels) over generated passages
```

**Test Method**: Wizard of Oz (manually curated passages before building generator)
**Minimum Sample**: 5 users
**Feasibility Check**: Requires knowing each user's mastered kanji set (UserKanjiProgress provides this) and having a corpus of sentences tagged by kanji content. This is the most technically ambitious option. Spike needed.

---

## Opportunity 2: Contextual Learning (Score: 16)

### Hypothesis H4: Sentence-Completion Quiz

```
We believe that replacing the current "kanji -> English meaning" quiz format with
a sentence-completion format (show a Japanese sentence with a blank, pick the
correct kanji) will improve meaning discrimination and reduce the ambiguity
problem (e.g., 辺 vs 面積 for "area").

We will know this is TRUE when:
- >80% task completion rate on sentence-completion quizzes
- Users report less confusion about kanji with multiple English translations
- Error rate on ambiguous kanji (those sharing English glosses) decreases >30%

We will know this is FALSE when:
- Task completion drops below 50% (too hard for beginners)
- Users report the format is "confusing" or "I don't understand the sentence"
- No measurable reduction in ambiguity errors
```

**Test Method**: Prototype quiz with 20 sentence-completion items
**Minimum Sample**: 5 users
**Feasibility Check**: ExampleSentence data exists. Quiz format change is a frontend modification to `QuizLive`. The challenge is ensuring sentence quality -- some example sentences may be too complex for the learner's current level.

### Hypothesis H5: Meaning Disambiguation Clusters

```
We believe that showing related-meaning kanji together (辺, 面積, 地域, 地方 for
"area") with contextual usage notes will help learners build accurate mental
models instead of false 1:1 mappings.

We will know this is TRUE when:
- >70% of users who view disambiguation clusters can correctly choose between
  related kanji in a follow-up test
- Users describe the clusters as "helpful" or "I didn't know the difference"
- Time spent on disambiguation view is >30 seconds (engaged, not bouncing)

We will know this is FALSE when:
- Users skip disambiguation views to get to quizzes
- Cluster information increases cognitive load without improving accuracy
- Users say "this is too much information at once"
```

**Test Method**: Static mockup shown to users with follow-up comprehension test
**Minimum Sample**: 5 users
**Feasibility Check**: Requires semantic tagging of kanji by meaning overlap. This data does not exist in the current schema. A spike would need to determine if Meaning records can be cross-referenced to find overlap clusters.

---

## Opportunity 3: Teach-Then-Test (Score: 15)

### Hypothesis H6: First Encounter Learning Flow

```
We believe that introducing a "learn" step before any kanji enters the SRS quiz
queue -- showing stroke order animation, radical decomposition, core meaning,
primary reading, and one example sentence -- will reduce the "tested on things I
wasn't taught" complaint and improve first-quiz accuracy.

We will know this is TRUE when:
- First-quiz accuracy for kanji that went through "learn" step is >60%
  (vs. current baseline -- measure current first-attempt accuracy)
- >80% of users complete the learn step without skipping
- Users describe the experience as "I felt prepared" or "made sense"

We will know this is FALSE when:
- Users skip the learn step >50% of the time
- First-quiz accuracy is unchanged (learn step is not effective)
- Users say "just let me quiz, I don't need this"
```

**Test Method**: Prototype flow connecting existing Explore page content to Quiz entry
**Minimum Sample**: 5 users
**Feasibility Check**: HIGH -- all the data already exists. The Explore page shows stroke order (KanjiVG), radicals (214 loaded), meanings, pronunciations, and example sentences. The gap is purely a flow/UX problem: connecting Explore (learn) to Quiz (test) with a structured path. No new data infrastructure needed.

### Hypothesis H7: Radical-Based Mnemonic Generation

```
We believe that generating mnemonics based on radical decomposition (e.g., 休 =
person 亻 + tree 木 = "a person resting against a tree") will help beginners
remember kanji meanings more effectively than rote memorization.

We will know this is TRUE when:
- >70% of users find radical-based mnemonics "helpful" or "memorable"
- 7-day retention rate for kanji learned with mnemonics exceeds kanji without
- Users create and share their own mnemonics (engagement signal)

We will know this is FALSE when:
- Users say "I already know this from WaniKani" (not differentiated)
- Mnemonics are perceived as "childish" or "too obvious"
- No retention difference at 7-day review
```

**Test Method**: Add mnemonic display to 20 kanji in explore view, measure engagement
**Minimum Sample**: 5 users
**Feasibility Check**: 214 radicals are already loaded with meanings. Radical-to-kanji relationships exist. Mnemonic generation could start with manual curation for top 50 beginner kanji, then explore automated approaches.

---

## Quick Wins (Implement Without Further Testing)

These emerged from discovery but do not require hypothesis testing -- the evidence is already clear and the scope is small.

| Quick Win | Evidence | Effort | Impact |
|-----------|----------|--------|--------|
| Romaji toggle (off by default for intermediate+) | 3+ explicit HN requests | Small -- settings toggle | High for serious learners |
| "Select all in level" for quiz sets | 2+ HN usability complaints | Small -- UI button | Medium -- reduces friction |
| Default to a standard/textbook font | Expert feedback from Japanese reader | Small -- font-family change | Medium -- pedagogical correctness |
| Fix round timer display (shows 0:00) | Bug report from HN user gazook89 | Small -- bug fix | Low but trust-building |

---

## Testing Priority Order

Based on risk scores (highest risk tested first) and feasibility:

| Priority | Hypothesis | Rationale |
|----------|-----------|-----------|
| 1 | H6: First Encounter Learning Flow | Highest feasibility (data exists), addresses most common complaint, validates core UX assumption |
| 2 | H4: Sentence-Completion Quiz | Tests the contextual learning thesis with minimal new data |
| 3 | H1: Graded Reading Passages | Tests the bridge-to-reading thesis, medium feasibility |
| 4 | H2: Sentence-Level SRS Cards | Requires A/B infrastructure, test after H4 validates sentence approach |
| 5 | H5: Meaning Disambiguation | Requires new data tagging, test after context approach validated |
| 6 | H7: Radical Mnemonics | Risk of being undifferentiated from WaniKani |
| 7 | H3: i+1 Reading Mode | Most technically ambitious, defer until simpler reading approach validated |

---

## Gate G3 Evaluation

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|
| Users tested | 5+ per iteration | 0 (pre-testing) | NOT YET STARTED |
| Task completion | >80% | N/A | NOT YET STARTED |
| Value perception | >70% "would use" | N/A | NOT YET STARTED |
| Key assumptions validated | >80% proven | 0/7 hypotheses tested | NOT YET STARTED |

### Decision: PENDING -- Hypotheses designed, testing not yet conducted

### Recommended Testing Plan

**Week 1**: Build clickable prototype for H6 (First Encounter Learning Flow). This is the lowest-effort, highest-signal test because all data already exists in the explore page.

**Week 2**: Test H6 with 5+ users. Simultaneously build prototype for H4 (Sentence-Completion Quiz).

**Week 3**: Test H4. If H6 passed, begin implementing the learn-then-quiz flow behind a FunWithFlags flag.

**Week 4**: Test H1 (Graded Reading Passages) with manually curated content. Evaluate results from all three tests against gate criteria.

### What "Testing" Means for This Project

Given the solo/homelab nature of this project, "testing" should be pragmatic:
- Share prototypes with the HN community that already provided feedback (they volunteered engagement)
- Post in r/LearnJapanese for broader learner feedback
- Use the existing FunWithFlags infrastructure to A/B test features with real users
- Measure actual usage data once features ship behind flags
- Target 5+ substantive feedback signals per hypothesis, not 5 formal interviews
