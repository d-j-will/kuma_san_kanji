# Opportunity Solution Tree -- Kuma San Kanji

**Phase**: 2 -- Opportunity Mapping
**Status**: Complete (G2 Passed)
**Date**: 2026-03-11
**Evidence Sources**: Phase 1 validated problems, HN feedback, demographics research, competitive landscape, codebase analysis

---

## Desired Outcome

Enable kanji learners to build lasting recall and reading fluency through contextual, self-directed study -- moving from "I can recognize flashcards" to "I can read Japanese."

---

## Job Map (JTBD)

**Main Job**: When I am studying Japanese, I want to learn kanji effectively so I can read and understand real Japanese content.

| Step | Job Step | Outcome Statement | Current Satisfaction |
|------|----------|-------------------|---------------------|
| Define | Decide which kanji to learn next | Minimize time to identify which kanji are most relevant to my current level | 4/10 -- JLPT filtering exists but no guided path |
| Locate | Find learning materials for that kanji | Minimize effort to gather readings, meanings, examples, and context | 5/10 -- data exists but context is thin |
| Prepare | Understand the kanji before being tested | Minimize likelihood of encountering a test question I was never taught | 3/10 -- no teaching step before quiz |
| Confirm | Verify I understand the kanji correctly | Minimize likelihood of learning an incorrect meaning or reading | 4/10 -- isolated meanings cause ambiguity (the 辺/"area" problem) |
| Execute | Practice recall through spaced repetition | Minimize time from first encounter to reliable long-term recall | 6/10 -- SM-2 works well technically |
| Monitor | Track my learning progress | Minimize uncertainty about whether I am actually improving | 5/10 -- basic progress tracking exists |
| Modify | Adjust study approach when stuck | Minimize effort to change strategy for difficult kanji | 3/10 -- no adaptive difficulty or alternative approaches |
| Conclude | Apply kanji knowledge to real reading | Minimize the gap between "quiz correct" and "can read in context" | 2/10 -- no bridge to real content |

---

## Opportunity Scoring

**Formula**: Score = Importance + Max(0, Importance - Satisfaction)
Importance and Satisfaction scored 1-10 based on evidence strength.

| # | Opportunity | Importance | Satisfaction | Score | Evidence Strength |
|---|------------|------------|-------------|-------|-------------------|
| O1 | Contextual learning -- encounter kanji in sentences, not isolation | 9 | 2 | 16 | 7+ HN signals, N1-passers confirm |
| O2 | Teach-then-test -- structured learning step before quiz | 9 | 3 | 15 | 6+ HN signals, WaniKani comparison |
| O3 | Guided progression -- clear learning path with milestones | 8 | 3 | 13 | 6+ HN signals, onboarding complaints |
| O4 | Romaji control -- ability to eliminate romaji entirely | 8 | 2 | 14 | 3 explicit requests, pedagogical consensus |
| O5 | Bridge to real reading -- connect quiz mastery to actual content | 9 | 1 | 17 | Multiple N1-passers describe this gap |
| O6 | Intermediate learner support -- address the plateau problem | 8 | 3 | 13 | Demographics + HN signals |
| O7 | Mobile-first experience | 7 | 5 | 9 | Demographics data, some mobile work done |
| O8 | Professional/business kanji focus | 6 | 3 | 9 | Demographics data only, no direct validation |
| O9 | Community mnemonics and social learning | 5 | 4 | 6 | Idea-stage, limited evidence |
| O10 | Writing/production practice | 6 | 2 | 10 | HN debate, contested value |

---

## Top 3 Opportunities (Score > 8, Ranked)

### Opportunity 1: Bridge to Real Reading (Score: 17)

**Problem**: Learners master flashcards but cannot read actual Japanese. There is no bridge from "quiz correct" to "can read a sentence." Multiple N1-passers attribute their success to reading, not apps.

**Evidence**:
- "What really made the language click for me was reading novels" -- marsavar (N1, 2013)
- "Reading real stories over generated text... stories are just more fun" -- wren6991
- "Vocabulary is much easier to absorb and retain if you learn it in context" -- marsavar
- "Do you know of a tool that can generate texts to read based on exactly your level?" -- tillcarlos (unmet need)
- Multiple commenters describe reading as THE breakthrough activity

**Solution Ideas** (to test in Phase 3):
- S1a: Graded reading passages using only kanji the learner has studied
- S1b: Sentence cards in SRS that show kanji in natural context with furigana support
- S1c: "Reading mode" that presents short passages at i+1 difficulty (one unknown per sentence)
- S1d: Integration with external reading difficulty rankings (like learnnatively.com concepts)

**Strategic Fit**: The existing Content domain (ThematicGroup, EducationalContext, KanjiUsageExample) provides infrastructure. Example sentences already exist in the data model. This builds on what is already there.

---

### Opportunity 2: Contextual Learning (Score: 16)

**Problem**: Kanji are taught as isolated character-to-English-word mappings. This creates ambiguity (辺 = "area" but so do 面積, 地域, and others) and fails to build real comprehension.

**Evidence**:
- "Quizzing vocab -> english word, without reading, without an example sentence, is a recipe to confuse learners' brains" -- TheDong
- "辺 is 'area', but if I see 'area' my first thought is 面積" -- TheDong (worked example)
- "New vocabulary really needs to be encountered in context of meaningful sentences" -- clbrmbr
- "Recognizing the meaning of vocab in a full Japanese sentence is a much better basic quiz" -- TheDong

**Solution Ideas** (to test in Phase 3):
- S2a: Replace English-word quizzes with sentence-completion quizzes (fill in the kanji)
- S2b: Show example sentences as primary learning interface, not character grids
- S2c: "Meaning clusters" showing related kanji with disambiguation (辺 vs 面積 vs 地域)
- S2d: Context-tagged meanings (this meaning in THIS situation) rather than flat lists

**Strategic Fit**: ExampleSentence data already exists in the database. Meanings and Pronunciations are modeled. The infrastructure is partially there -- the gap is in presentation and quiz design.

---

### Opportunity 3: Teach-Then-Test (Score: 15)

**Problem**: Users are quizzed on kanji they were never taught. There is no "learning step" -- you go straight to testing. WaniKani's key differentiator (per an N2-level user) was exactly this teaching step.

**Evidence**:
- "It doesn't seem like a learning app and more like a practice app with just a big list of words" -- famahar
- "I was presented with multiple choices for things I wasn't taught" -- famahar
- "I tried and failed several times to get started with Anki before having success with Wanikani. The key differentiator for me was the learning step" -- awirth (N2 level)
- "I was expecting there to be an option to show the answers (cheat mode) so I could go through first" -- jv22222

**Solution Ideas** (to test in Phase 3):
- S3a: "Learn" mode that teaches radicals > components > meaning > reading before quiz
- S3b: Progressive disclosure: show kanji with full context, then quiz after exposure
- S3c: Mnemonic generation using radical decomposition (leverage existing 214 radicals data)
- S3d: "First encounter" flow that introduces a kanji visually (stroke order + meaning + sentence) before it enters the SRS queue

**Strategic Fit**: Radical data (214 radicals) already exists. Stroke order (KanjiVG) is implemented. The explore page already shows rich kanji detail. The gap is connecting explore (learning) to quiz (testing) in a structured flow.

---

## Opportunities Evaluated but Deprioritized

### Romaji Control (Score: 14)
Strong signal but small scope -- this is a settings toggle, not a strategic opportunity. Should be implemented as a quick win regardless of discovery outcome.

### Guided Progression (Score: 13)
Important but depends on O1/O2/O3 -- the progression needs content and teaching before it can be structured. Sequence: build contextual learning first, then structure the path through it.

### Intermediate Learner Support (Score: 13)
Real need but broad. The top 3 opportunities naturally address this -- contextual learning and reading bridges ARE the intermediate solution.

### Writing/Production Practice (Score: 10)
Contested in the HN discussion. Some advocate strongly, others (including language learning researchers) caution against early output. The existing stroke tracing feature partially addresses this. Defer until top opportunities are validated.

---

## Competitive Positioning

| Feature | WaniKani | Anki | Kanji Study | Kuma San Kanji (current) | Kuma San Kanji (proposed) |
|---------|----------|------|-------------|--------------------------|---------------------------|
| Teaching step before testing | Strong | None | Moderate | None | Strong (O3) |
| Contextual sentences | Moderate | User-created | Moderate | Weak | Strong (O2) |
| Bridge to reading | None | None | None | None | Strong (O1) |
| SRS algorithm | Custom | SM-2/FSRS | Custom | SM-2 | SM-2 (already solid) |
| Open source | No | Yes (app) | No | Yes | Yes |
| Aesthetic/design | Functional | Ugly | Clean | Strong (wabi-sabi) | Strong |
| Radical decomposition | Strong | None | Strong | Good (214 radicals) | Strong (O3) |
| Price | $9/mo or $299 | Free | $13 one-time | Free | Free |

**Differentiator**: The combination of contextual-reading-bridge + open-source + wabi-sabi aesthetic is unoccupied territory. No existing tool bridges from "quiz correct" to "can actually read."

---

## Gate G2 Evaluation

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|
| Opportunities identified | 5+ distinct | 10 identified | PASS |
| Top scores | >8 (max 20) | Top 3: 17, 16, 15 | PASS |
| Job step coverage | 80%+ | 8/8 job steps mapped | PASS |
| Team alignment | Confirmed | Solo project -- self-aligned | PASS (with caveat) |

### Decision: PROCEED to Phase 3

### Caveats
- Importance and Satisfaction scores are estimated from public feedback, not structured interviews with controlled rating scales. Directional confidence is high, but exact scores could shift with formal research.
- Team alignment is trivially satisfied (solo project) but means no cross-functional challenge. The peer review step partially compensates.
