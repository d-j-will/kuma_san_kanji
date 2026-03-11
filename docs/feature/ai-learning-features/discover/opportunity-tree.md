# Opportunity Solution Tree -- AI Learning Features for Kuma San Kanji

**Phase**: 2 -- Opportunity Mapping
**Status**: Complete (G2 Passed)
**Date**: 2026-03-11
**Feature ID**: ai-learning-features
**Evidence Sources**: Phase 1 AI problem validation, prior general discovery (all phases), r/LearnJapanese research, competitive landscape, codebase technical review
**Relationship to Prior Discovery**: This OST evaluates AI-specific opportunities as potential solution approaches to the already-validated top opportunities from the general discovery (O5: Bridge to Real Reading, O1: Contextual Learning, O2: Teach-Then-Test).

---

## Desired Outcome

Enable kanji learners to bridge from flashcard recall to real Japanese reading through AI-augmented content and learning support -- where AI solves specific problems that manual curation and static content cannot address at scale.

---

## Job Map (JTBD) -- AI-Specific Overlay

The general discovery mapped the full job. This overlay identifies where AI specifically adds value at each job step.

**Main Job**: When I am studying Japanese, I want to learn kanji effectively so I can read and understand real Japanese content.

| Step | Job Step | AI Value Add | AI Risk | Net Assessment |
|------|----------|-------------|---------|----------------|
| Define | Decide which kanji to learn next | LOW -- existing JLPT/frequency ordering works; AI adds marginal value | Over-engineering simple sequencing | Skip AI |
| Locate | Find learning materials for that kanji | MEDIUM -- AI can generate contextual examples beyond seed data | Generated examples may contain errors | Consider AI |
| Prepare | Understand the kanji before being tested | HIGH -- AI mnemonic generation from radical decomposition | Bad mnemonics worse than none | Strong AI candidate |
| Confirm | Verify I understand the kanji correctly | MEDIUM -- AI can generate disambiguation examples | Requires high accuracy for pedagogical trust | Consider AI |
| Execute | Practice recall through spaced repetition | LOW -- FSRS is algorithmic, not really "AI" in the product sense | Replacing working SM-2 is risky | Skip AI (or treat as separate engineering task) |
| Monitor | Track my learning progress | LOW -- analytics/visualization, not AI | N/A | Skip AI |
| Modify | Adjust study approach when stuck | MEDIUM -- AI could suggest alternative approaches for difficult kanji | Generic suggestions may not help | Consider AI |
| Conclude | Apply kanji knowledge to real reading | HIGH -- AI can generate i+1 reading passages personalized to learner progress | Generated text may feel unnatural; accuracy concerns for Japanese | Strong AI candidate |

**Key Insight**: AI value concentrates at two job steps -- **Prepare** (mnemonic generation) and **Conclude** (reading passage generation). These map directly to the top validated opportunities from the general discovery. The other job steps either do not benefit from AI or the AI risk outweighs the benefit.

---

## Opportunity Scoring

**Formula**: Score = Importance + Max(0, Importance - Satisfaction)
Importance and Satisfaction scored 1-10 based on evidence strength.

**Scoring Note**: These scores evaluate the AI-SPECIFIC opportunity, not the parent opportunity. A high parent score (e.g., O5=17) does not automatically make the AI approach high-scoring -- the AI approach must be independently evaluated for importance (does the user need AI specifically?) and satisfaction (how well do current non-AI approaches serve this need?).

| # | AI Opportunity | Importance | Satisfaction | Score | Evidence Strength | Parent Opportunity |
|---|---------------|------------|-------------|-------|-------------------|--------------------|
| AO1 | AI-generated i+1 reading passages personalized to learner's mastered kanji set | 9 | 2 | 16 | Strong: tillcarlos direct ask, N1-passers confirm reading gap, no tool does this | O5: Bridge to Real Reading (17) |
| AO2 | AI mnemonic generation from radical decomposition data | 8 | 4 | 12 | Moderate: WaniKani proves mnemonics work, 214 radicals loaded, manual curation infeasible for solo dev | O2: Teach-Then-Test (15) |
| AO3 | AI-generated contextual example sentences for disambiguation | 7 | 5 | 9 | Moderate: ExampleSentence data exists but limited; AI can fill gaps | O1: Contextual Learning (16) |
| AO4 | AI conversational tutor for immersion-lite practice | 6 | 4 | 8 | Weak: 3 HN signals (1 skeptic with direct negative experience), high complexity | NEW (no parent) |
| AO5 | AI-powered adaptive SRS (FSRS-style ML scheduling) | 6 | 6 | 6 | Weak: 2 HN signals, current SM-2 works, incremental improvement | Engineering improvement |
| AO6 | AI writing correction / feedback on learner output | 5 | 3 | 7 | Weak: community prefers reading-first, writing contested, accuracy concerns for Japanese | NEW (no parent) |
| AO7 | AI-powered content curation (recommend real content at learner level) | 7 | 5 | 9 | Moderate: learnnatively.com concept but automated; requires external content index | O5: Bridge to Real Reading (17) |
| AO8 | AI audio generation (TTS for pronunciation) | 5 | 5 | 5 | Weak: anigbrowl reports AI gets pitch accent wrong; browser Speech Synthesis already partially implemented | Engineering improvement |

---

## Top 3 AI Opportunities (Score > 8, Ranked)

### AI Opportunity 1: AI-Generated i+1 Reading Passages (Score: 16)

**Problem it solves**: The #1 validated opportunity from the general discovery (O5, score 17) -- learners master flashcards but cannot read. The prior discovery's H3 (i+1 Reading Mode) was ranked #7 priority because it was "the most technically ambitious option" requiring knowing each user's mastered kanji set and having a tagged sentence corpus. AI generation eliminates the corpus requirement entirely.

**Why AI is the right approach**:
- Each learner has a unique set of mastered kanji (tracked in UserKanjiProgress)
- Generating passages that use ONLY those kanji plus controlled unknowns is a combinatorial problem
- Manual curation cannot scale to individual progress states
- A pre-built corpus would need to cover every possible combination of mastered kanji
- AI generation solves this personalization problem naturally

**Evidence**:
- tillcarlos (HN): "Do you know of a tool that can generate texts to read based on exactly your level?" -- direct unmet need
- marsavar (HN, N1): "What really made the language click for me was reading novels" -- reading is the breakthrough
- Community research: "Whatever fancy cool way to remember all those >2,000 kanji you use, you still need to read Japanese for hundreds of hours" -- reading hours are irreducible
- Prior discovery rated O5 at score 17 -- highest of all opportunities
- No existing free tool generates personalized reading passages from a learner's known kanji set

**Critical Risk**: AI-generated Japanese text quality. nodja (HN) warns "LLMs are very hit/miss, specially in very high context languages like Japanese." This is the single most important assumption to test (AA1).

**Solution Ideas** (to test in Phase 3):
- S-AO1a: Batch-generate passages offline using LLM with strict kanji constraints, human-review a sample, cache in Content domain
- S-AO1b: Real-time generation with quality guardrails (kanji verification, grammar checking)
- S-AO1c: Hybrid approach -- AI generates candidate passages, automated kanji-constraint verification, flagged for quality
- S-AO1d: "Constrained generation" -- provide the LLM with the exact kanji list and sentence templates to maximize accuracy

**Strategic Fit**: UserKanjiProgress tracks mastered kanji. Content domain (ThematicGroup, EducationalContext) provides the content structure. FunWithFlags enables gradual rollout. The gap is the generation layer -- an AI service that takes a kanji set and produces reading passages.

---

### AI Opportunity 2: AI Mnemonic Generation from Radical Decomposition (Score: 12)

**Problem it solves**: The #3 validated opportunity from the general discovery (O2, score 15) -- users need a teaching step before testing. The prior discovery's H7 (Radical-Based Mnemonic Generation) was designed but ranked #6 because manual curation for 2,000+ kanji is infeasible for a solo developer. AI generation makes comprehensive mnemonic coverage achievable.

**Why AI is the right approach**:
- 214 radicals with meanings are already loaded in the database
- Radical-to-kanji decomposition relationships exist
- WaniKani's curated mnemonics are its key differentiator (per N2-level user awirth)
- Manually writing quality mnemonics for 2,000+ kanji requires years of effort (WaniKani has a team)
- AI can generate candidate mnemonics from radical meanings in seconds
- Quality filtering (community voting, manual review of top kanji) handles the accuracy concern

**Evidence**:
- awirth (HN, N2): "I tried and failed several times to get started with Anki before having success with WaniKani. The key differentiator for me was the learning step." -- mnemonics are part of the teaching step
- Tofugu: "Learning radicals is like learning the letters of the alphabet" and cuts memorization by "300-800%"
- Community research: Not learning radicals is mistake #2 on Tofugu's list
- 214 radicals already loaded in Kuma San Kanji -- the raw material exists
- H7 was designed but not prioritized due to feasibility -- AI changes the feasibility calculus

**Critical Risk**: Mnemonic quality. RTK was criticized for meanings that are "super far off." AI-generated mnemonics could be worse. The quality bar is "memorable AND accurate" -- meeting both simultaneously is harder than either alone.

**Solution Ideas** (to test in Phase 3):
- S-AO2a: Generate mnemonics for the 80 Grade 1 / JLPT N5 kanji as a pilot, using radical meanings as input
- S-AO2b: Generate multiple candidate mnemonics per kanji, let users vote on effectiveness
- S-AO2c: Use the pattern "component1 + component2 = visual story" (e.g., 休 = person + tree = "a person resting against a tree")
- S-AO2d: Pre-generate and cache all mnemonics (batch process, no per-request API cost)

**Strategic Fit**: 214 radicals with meanings provide the structured input. The existing Explore page shows radical decomposition. Adding a mnemonic display is a UI change, not an architecture change. Batch generation means near-zero ongoing API cost.

---

### AI Opportunity 3: AI-Generated Contextual Example Sentences (Score: 9)

**Problem it solves**: The #2 validated opportunity from the general discovery (O1, score 16) -- kanji taught in isolation need sentence context. The existing ExampleSentence data is limited. AI can fill content gaps for kanji that lack good example sentences, and generate disambiguation examples for confusing kanji pairs (the 辺/面積 problem).

**Why AI is the right approach**:
- ExampleSentence records exist but coverage is uneven -- some kanji have many, some have few or none
- The disambiguation problem (multiple kanji sharing an English gloss) requires carefully crafted contrastive sentences
- Manual creation of contrastive sentence pairs for all ambiguous kanji sets is labor-intensive
- AI can generate targeted examples: "Show 辺 used in a sentence where 面積 would be wrong"

**Evidence**:
- TheDong (HN): "辺 is 'area', but if I see 'area' my first thought is 面積... quizzing without example sentences is a recipe to confuse" -- specific disambiguation need
- clbrmbr (HN): "New vocabulary really needs to be encountered in context of meaningful sentences" -- sentence context is critical
- Prior discovery H4 (Sentence-Completion Quiz) and H5 (Meaning Disambiguation) both depend on having sufficient sentence data
- ExampleSentence schema exists in the database -- AI-generated sentences fit the existing data model

**Critical Risk**: Sentence accuracy. A pedagogical example sentence that contains a grammatical error or unnatural usage teaches the wrong thing. For beginners, this is actively harmful. Quality verification is essential.

**Solution Ideas** (to test in Phase 3):
- S-AO3a: Identify kanji with fewer than 3 example sentences, batch-generate additional sentences with level constraints
- S-AO3b: For confusable kanji pairs (same English gloss), generate contrastive sentence pairs showing correct usage
- S-AO3c: Tag AI-generated sentences separately from curated sentences, allow community flagging
- S-AO3d: Use LLM to generate, then validate with a second LLM call or rule-based grammar checker

**Strategic Fit**: ExampleSentence schema and Content domain already exist. AI-generated sentences would populate existing data structures. No new architecture needed -- this is a content pipeline enhancement.

---

## Opportunities Evaluated but Deprioritized

### AI Conversational Tutor (Score: 8)
Evidence is weak (3 HN signals, 1 skeptic with direct negative experience). The complexity is enormous: real-time LLM interaction, conversation management, Japanese accuracy at production quality, per-request API costs for a free product. The community is split on whether AI tutoring works for Japanese. Most critically, this is a DIFFERENT PRODUCT -- adding a conversational AI to a kanji learning app changes the product surface fundamentally. Defer until the core learning experience is validated.

### AI-Powered Content Curation (Score: 9)
Interesting but depends on an external content index. Recommending real Japanese content at the learner's level is valuable, but:
- learnnatively.com already does this well
- Building a content recommendation engine is a large project
- The AI value-add is in matching content difficulty to learner level, which requires a difficulty scoring model
- This is better pursued as a partnership/integration than a built feature
Score is 9 but feasibility is low for a solo developer. Deprioritize.

### AI Writing Correction (Score: 7)
Community consensus is reading-first, writing optional. The prior discovery already noted "Writing/Production Practice (Score: 10) -- contested in the HN discussion." AI writing correction doubles down on a contested need with a high-accuracy requirement. Japanese writing correction is a Hard Problem -- particles, honorifics, context-dependent formality levels. Deprioritize.

### AI Adaptive SRS / FSRS (Score: 6)
Current SM-2 works and is well-tested (including property-based tests). FSRS is a known improvement but:
- The improvement is incremental (better scheduling, not a new capability)
- It is an engineering optimization, not a user-facing AI feature
- Implementing FSRS does not require an AI API -- it is an algorithm change
- The bigger problem is WHAT learners study, not WHEN they review
Treat as a separate engineering task, not an AI product feature.

### AI Audio / TTS (Score: 5)
anigbrowl (HN) reports "Japanese AI voices still seem to get pitch shapes and timing wrong sometimes." Browser Speech Synthesis is already partially implemented. The risk of teaching incorrect pronunciation to beginners is high. Deprioritize until TTS quality for Japanese improves.

---

## AI vs. Non-AI Decision Matrix

For each top opportunity from the general discovery, evaluate whether AI is the best approach or if a non-AI solution is superior.

| General Opportunity | Non-AI Solution | AI Solution | Winner | Rationale |
|--------------------|-----------------|-------------|--------|-----------|
| O5: Bridge to Real Reading (17) | H1: Manually curated graded passages | AO1: AI-generated i+1 passages | **AI** | Manual curation cannot personalize to individual learner progress; combinatorial problem |
| O1: Contextual Learning (16) | H4: Sentence-completion quiz with existing data; H5: Manually curated disambiguation | AO3: AI-generated example sentences + disambiguation | **Hybrid** | Existing sentences for core quiz; AI fills gaps and generates disambiguation pairs |
| O2: Teach-Then-Test (15) | H6: First Encounter Learning Flow (connect Explore to Quiz) | AO2: AI mnemonic generation | **Non-AI first, AI augments** | H6 (connecting existing pages) is highest-signal, lowest-effort; AI mnemonics enhance it |

**Critical Finding**: AI is not a replacement for the top non-AI solutions -- it is an AUGMENTATION. The highest-priority action from the general discovery (H6: First Encounter Learning Flow) requires ZERO AI. The AI opportunities enhance already-validated solutions:

1. Build H6 (teach-then-test flow) first -- no AI needed
2. Add AO2 (AI mnemonics) to enrich the teaching step
3. Build H4 (sentence quiz) with existing data -- no AI needed
4. Add AO3 (AI example sentences) to fill content gaps
5. Build AO1 (AI reading passages) as the capstone feature -- this IS the AI-native feature

---

## Competitive Positioning (AI-Specific)

| Feature | Duolingo | WaniKani | Anki | ChatGPT (direct) | Kuma San Kanji (proposed) |
|---------|----------|----------|------|-------------------|---------------------------|
| AI-generated content | Yes (Duolingo Max, paid) | No | No (user-created) | Yes (unstructured) | Targeted: i+1 passages + mnemonics |
| AI tutoring | Yes (paid tier) | No | No | Yes (generic) | No (deprioritized) |
| Personalized to known kanji | No (course-level, not kanji-level) | No (fixed curriculum) | No (user manages) | No (user must specify) | YES -- tracks UserKanjiProgress |
| Radical-based mnemonics | No | Yes (manually curated) | No | Can generate (unstructured) | AI-generated from real radical data |
| SRS integration | Custom | Custom | SM-2/FSRS | None | SM-2 (FSRS future) |
| Privacy | Tracking-heavy | Account-based | Local-first | OpenAI data policy | Open source, homelab, privacy-focused |
| Price for AI features | Paid tier ($7/mo) | N/A | N/A | $20/mo (ChatGPT Plus) | Free (batch-generated, cached) |
| Open source | No | No | Yes (app) | No | Yes |

**Differentiator**: The unique position is AI-generated content that is:
1. **Personalized to the individual learner's mastered kanji set** (no competitor does this)
2. **Integrated with SRS** (ChatGPT cannot do this)
3. **Free and open source** (Duolingo Max charges for AI)
4. **Privacy-respecting** (batch-generated, cached, no per-request user data sent to AI APIs)
5. **Quality-gated** (pre-generated and reviewed, not raw LLM output)

---

## Gate G2 Evaluation

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|
| Opportunities identified | 5+ distinct | 8 identified (AO1-AO8) | PASS |
| Top scores | >8 (max 20) | Top 3: 16, 12, 9 | PASS |
| Job step coverage | 80%+ | 8/8 job steps evaluated for AI relevance | PASS |
| Team alignment | Confirmed | Solo project -- self-aligned | PASS (with caveat) |

### Decision: PROCEED to Phase 3

### Caveats
1. The top AI opportunity (AO1, score 16) has the SAME parent as the top general opportunity (O5, score 17). This is convergent validation -- both AI and non-AI analysis point to "bridge to real reading" as the core problem.
2. AO2 (score 12) and AO3 (score 9) are augmentations to already-validated non-AI solutions, not standalone features. Their value depends on the non-AI foundations being built first.
3. The gap between AO1 (16) and AO2 (12) is significant. AO1 is the clear flagship AI feature; AO2 and AO3 are supporting enhancements.
4. The deprioritized opportunities (AI tutoring, content curation, writing correction, adaptive SRS, TTS) represent significant scope that should NOT be reconsidered without new evidence. The temptation to build "AI everything" must be resisted -- the evidence supports targeted, specific AI applications, not an AI-powered product.
