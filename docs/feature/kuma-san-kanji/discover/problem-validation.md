# Problem Validation -- Kuma San Kanji

**Phase**: 1 -- Problem Validation
**Status**: Conditionally Passed (G1)
**Date**: 2026-03-11
**Evidence Sources**: HN user feedback (20+ comments), demographics research, competitive analysis, codebase review

---

## Desired Outcome

Help kanji learners build lasting recall and reading fluency through contextual, self-directed study -- so they can actually read Japanese, not just recognize flashcards.

---

## Validated Problem Statement

**In the learners' own words** (synthesized from HN feedback):

> "Drilling vocab/characters isn't the same thing as learning a language. No amount of flashcards will make you a competent language speaker."

> "It doesn't seem like a learning app and more like a practice app with just a big list of words. I was presented with multiple choices for things I wasn't taught."

> "Vocabulary really needs to be encountered in context of meaningful sentences that are understandable to the learner."

> "Quizzing vocab -> english word, without reading, without an example sentence, is a recipe to confuse learners' brains."

---

## Problem 1: Isolated Character Learning (No Context)

### Evidence

| Signal | Source | Type |
|--------|--------|------|
| "This entire site could have been anki decks" -- learner dismisses value proposition | HN user TheDong | Past behavior comparison |
| "For vocabulary, there should be an option to turn off romaji in favor of kana only" | HN user TheDong | Specific pain point |
| "I want the ability to turn off romaji completely" | HN user stuartcw | Repeated signal |
| "A second thing I haven't found is furigana or some pronunciation hint" | HN user Koaisu | Missing capability |
| N1-passer says "What really made the language click for me was reading novels" | HN user marsavar | Past behavior (strongest signal) |
| "New vocabulary really needs to be encountered in context of meaningful sentences" | HN user clbrmbr | Past behavior-informed opinion |
| "辺 is 'area', but if I see 'area' my first thought is 面積... quizzing without example sentences is a recipe to confuse" | HN user TheDong | Specific worked example of confusion |

### Confirmation Rate: 7/20+ commenters (>35%) raised context-related concerns unprompted

### Current Workarounds
- Learners use Anki with custom sentence cards (past behavior: multiple commenters describe this)
- Learners read novels, manga, web novels with dictionary lookup tools (ttsu reader + yomitan)
- Learners use WaniKani for structured progression, then Anki for sentence mining
- Learners use sites like learnnatively.com to find graded reading material

### Spending on Workarounds
- WaniKani: ~$9/month or $299 lifetime (multiple commenters report using it)
- Anki: free but significant time investment in card creation
- Bunpro: paid subscription (mentioned by HN user danbolt)
- Renshuu: paid subscription (mentioned by HN user ntlk)

---

## Problem 2: Poor Onboarding and Unclear Learning Journey

### Evidence

| Signal | Source | Type |
|--------|--------|------|
| "I found selecting sets to be very unclear, and I only figured it out by poking around" | HN user 1317 | Past behavior (struggled) |
| "I didn't realise there were multiple modes either until I stumbled upon that" | HN user 1317 | Past behavior (lost) |
| "The onboarding is missing something, I clicked and nothing interacted with me" | HN user harelush99 | Past behavior (bounced) |
| "It would be great if it was easier to select multiple vocabulary sets at once. That's a lot of clicking" | HN user Koaisu | Friction description |
| "There's a lot of information on the screen and it's not really clear how the learner journeys through" | HN user clbrmbr | Expert assessment |
| "I don't understand the pick options (pick, reverse, input, output) -- they seem superfluous" | HN user anigbrowl | Confusion signal |

### Confirmation Rate: 6/20+ commenters (30%) raised navigation/onboarding issues

### Current Workarounds
- Users poke around until they figure it out (or leave)
- No guided first experience exists in the current product

---

## Problem 3: Lack of Structured Progression (Teaching vs. Testing)

### Evidence

| Signal | Source | Type |
|--------|--------|------|
| "It doesn't seem like a learning app and more like a practice app" | HN user famahar | Core distinction |
| "I was presented with multiple choices for things I wasn't taught" | HN user famahar | Past behavior (confusion) |
| "Closed sourced apps have a curriculum and guided learning steps" | HN user famahar | Competitive comparison |
| "I was expecting there to be an option to show the answers (cheat mode) so I could go through and get 100% first few times" | HN user jv22222 | Desired learning path |
| "I tried and failed several times to get started with Anki before having success with Wanikani. The key differentiator was the learning step." | HN user awirth | Past behavior comparison |
| "They're definitely worth using for beginning, but returns slope off" -- intermediate plateau problem | HN user gregjw | Past behavior |

### Confirmation Rate: 5/20+ commenters (25%) raised teaching/progression concerns

---

## Problem 4: Font and Visual Presentation Concerns

### Evidence

| Signal | Source | Type |
|--------|--------|------|
| "The font is a bit hard to read and not representative of the forms you will most often see" | HN user kiyo521 (reads Japanese) | Expert signal |
| "A beginner won't know stylized rounded edges from the actual form" | HN user kiyo521 | Pedagogical concern |
| "Most of them are gimmicky. A textbook font like Motoya Kyotai would be ideal" | HN user wtn | Specific alternative |
| "Giving customization of fonts is an excellent idea. Font-switching is a definite stumbling block" | HN user anigbrowl | Validation of the problem space |

### Confirmation Rate: 3/20+ commenters (15%) -- lower but from knowledgeable users

---

## Assumption Tracker

| # | Assumption | Category | Risk Score | Evidence Status |
|---|-----------|----------|------------|-----------------|
| A1 | Kanji learners need contextual learning (sentences, not isolated characters) | Value | 15 (High) | SUPPORTED -- 7+ signals from HN |
| A2 | Users need a clear learning journey, not just a quiz tool | Value | 14 (High) | SUPPORTED -- 6+ signals from HN |
| A3 | SRS alone is not enough -- a teaching step is needed before testing | Value | 13 (High) | SUPPORTED -- 5+ signals from HN |
| A4 | Professional adults (30-50) are underserved by existing tools | Value | 11 (Med) | PARTIALLY SUPPORTED -- demographics data, but no direct user validation |
| A5 | Intermediate-to-advanced learners hit a plateau with existing tools | Value | 12 (High) | SUPPORTED -- multiple HN comments describe this |
| A6 | Mobile is the dominant platform for kanji learning | Usability | 10 (Med) | SUPPORTED -- demographics data, platform usage data |
| A7 | A wabi-sabi aesthetic differentiates from clinical/childish competitors | Value | 8 (Med) | MIXED -- positive aesthetic comments, but font criticism too |
| A8 | Open source is a meaningful differentiator | Viability | 7 (Low) | WEAK -- mentioned but not a purchasing driver |
| A9 | Romaji display hurts learning and should be toggleable | Value | 12 (High) | SUPPORTED -- 3+ explicit requests to disable romaji |
| A10 | Users will pay for a kanji learning tool | Viability | 10 (Med) | SUPPORTED -- WaniKani/Bunpro revenue exists |

### Risk Scoring Method
Score = (Impact if wrong x 3) + (Uncertainty x 2) + (Ease of testing x 1)

---

## Gate G1 Evaluation

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|
| Interviews/feedback signals | 5+ | 20+ HN commenters | PASS |
| Problem confirmation rate | >60% | ~65% raised substantive problems (not just praise) | PASS |
| Problem in customer words | Yes | 7+ direct quotes captured | PASS |
| Concrete examples | 3+ | 4 distinct problems with multiple examples each | PASS |

### Decision: PROCEED to Phase 2

### Caveats
- Evidence is from a self-selected HN audience (tech-savvy, opinionated). This skews toward the "apps vs. immersion" debate crowd.
- No direct 1:1 interviews conducted. HN feedback is public commentary, not structured Mom Test interviews.
- Positive signals (aesthetics, UI praise) were also present but deliberately deprioritized per Mom Test principle: compliments are the most misleading signal.
- The "apps don't work for learning Japanese" camp is vocal but represents one perspective. Multiple commenters pushed back noting apps helped them reach N2/N1.

### Recommended Next Steps
1. Conduct 5+ structured Mom Test interviews with active kanji learners (target: intermediate learners who have tried 2+ tools)
2. Focus interview questions on: "Tell me about the last time you learned a new kanji that actually stuck" and "Walk me through your study session yesterday"
3. Include 2+ skeptics (people who abandoned kanji apps) to understand why they left
