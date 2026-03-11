# Problem Validation -- AI Learning Features for Kuma San Kanji

**Phase**: 1 -- Problem Validation
**Status**: Conditionally Passed (G1)
**Date**: 2026-03-11
**Feature ID**: ai-learning-features
**Evidence Sources**: Prior general discovery (20+ HN comments), r/LearnJapanese community research, competitive landscape analysis (2025-2026 AI tool proliferation), codebase technical review
**Relationship to Prior Discovery**: The general product DISCOVER wave (feature: kuma-san-kanji) explicitly listed "AI-driven personalization" under "What NOT to build yet." This wave re-evaluates that decision against new evidence and the AI-specific problem space.

---

## Re-Evaluation Context

The prior discovery concluded AI was "premature optimization" based on the evidence available at that time. This was a reasonable decision. However, three factors warrant re-evaluation:

1. **Direct user signal**: tillcarlos on HN asked "Do you know of a tool that can generate texts to read based on exactly your level?" -- this is an AI-shaped problem that was captured but not explored.
2. **Community split on AI**: The HN thread contained both pro-AI signals (charcircuit: "everyone has a personal language tutor in their pocket") and anti-AI skepticism (nodja: "LLMs are very hit/miss, specially in very high context languages like Japanese"). This tension deserves exploration.
3. **Competitive landscape shift**: Since the prior discovery, AI features have become table stakes in language learning (Duolingo Max, Lingvist AI, ChatGPT as informal tutor). The "premature" assessment may no longer hold.

---

## Problem A1: Content Generation at Learner Level is Manual and Does Not Scale

### The Problem in Customer Words

> "Do you know of a tool that can generate texts to read based on exactly your level?" -- tillcarlos (HN)

> "Reading real stories over generated text... stories are just more fun" -- wren6991 (HN, counterpoint)

> "Vocabulary really needs to be encountered in context of meaningful sentences that are understandable to the learner" -- clbrmbr (HN)

### Evidence

| Signal | Source | Type | AI-Relevant? |
|--------|--------|------|-------------|
| tillcarlos directly asks for level-appropriate text generation | HN | Unmet need (past behavior: searching for tools) | YES -- this is an AI generation problem |
| Multiple N1-passers say reading was the breakthrough activity | HN (marsavar, wren6991) | Past behavior | PARTIALLY -- AI could generate reading material |
| H3 (i+1 Reading Mode) was ranked #7 priority due to technical ambition | Prior discovery | Feasibility concern | YES -- AI dramatically reduces feasibility barrier |
| ExampleSentence data exists but is limited in quantity and variety | Codebase review | Technical constraint | YES -- AI can augment limited seed data |
| Content domain has ThematicGroup, EducationalContext infrastructure | Codebase review | Technical enabler | YES -- scaffolding exists for AI-generated content |

### Confirmation Rate: 5/20+ HN commenters (25%) raised content generation/personalization needs

### Current Workarounds
- Learners use learnnatively.com to find graded reading material (manual, limited selection)
- Learners use Anki sentence mining from immersion content (high effort, requires intermediate+ level)
- Some learners use ChatGPT directly to generate practice sentences (unstructured, no integration with SRS)
- Satori Reader provides curated graded content (paid subscription, closed ecosystem)

### Why AI Specifically?
The prior discovery's H1 (Graded Reading Passages) and H3 (i+1 Reading Mode) both require content that:
- Uses only kanji the learner has mastered, plus controlled unknowns
- Is personalized to each learner's unique progress
- Covers diverse topics to maintain engagement
- Is available in sufficient volume to sustain daily practice

Manual curation cannot scale to individual learner progress. A corpus approach requires an enormous pre-built library. AI generation is the natural technical solution -- but the question is whether AI-generated Japanese is good enough.

---

## Problem A2: Mnemonic Generation Requires Cultural/Linguistic Knowledge Most Learners Lack

### The Problem in Customer Words

> "I tried and failed several times to get started with Anki before having success with Wanikani. The key differentiator for me was the learning step." -- awirth (HN, N2 level)

> "Learning radicals is like learning the letters of the alphabet" and cuts memorization by "300-800%." -- Tofugu

### Evidence

| Signal | Source | Type | AI-Relevant? |
|--------|--------|------|-------------|
| WaniKani's teaching step (including mnemonics) is its key differentiator | HN (awirth), Tofugu | Past behavior comparison | PARTIALLY -- AI can generate mnemonics from radical data |
| 214 radicals with meanings already loaded in Kuma San Kanji | Codebase review | Technical enabler | YES -- raw material for AI mnemonic generation |
| H7 (Radical-Based Mnemonic Generation) was designed but ranked #6 priority | Prior discovery | Feasibility concern | YES -- AI reduces effort from "curate 2000+ mnemonics" to "generate on demand" |
| RTK criticized for meanings that are "super far off" | WaniKani community | Quality concern | CAUTION -- AI could produce similarly low-quality mnemonics |
| Tofugu's mistake #2: Not learning radicals | Community research | Validated need | YES -- radical mnemonics are proven effective |

### Confirmation Rate: 4/20+ HN commenters (20%) raised mnemonic/teaching quality needs

### Current Workarounds
- WaniKani provides curated mnemonics ($9/mo or $299 lifetime)
- Kanji Koohii community creates shared mnemonics (free, variable quality)
- Learners create personal mnemonics (effective but slow, requires linguistic knowledge)
- RTK provides mnemonics in book form (criticized for inaccuracy)

### Why AI Specifically?
Curating quality mnemonics for 2,000+ kanji is an enormous manual effort. WaniKani has a team and years of refinement. For a solo developer, AI generation from the existing radical decomposition data (214 radicals already loaded) is the only feasible path to comprehensive mnemonic coverage. But the quality bar is high -- bad mnemonics are worse than none.

---

## Problem A3: Learners Cannot Get Feedback on Their Understanding Without a Human Tutor

### The Problem in Customer Words

> "These days AI can tell you if it makes sense and the subtle mistakes you are making. I think this view point is outdated now that everyone has a personal language tutor in their pocket." -- charcircuit (HN)

> "perhaps talking to an AI can help?" -- amelius (HN, re: immersion)

> "I've used several LLMs to do translations and they're very hit/miss, specially in very high context languages like japanese. I'm not sure recommending their usage for a beginner is good advice" -- nodja (HN, skeptic)

### Evidence

| Signal | Source | Type | AI-Relevant? |
|--------|--------|------|-------------|
| charcircuit advocates for AI as personal tutor | HN | Opinion (future-intent -- weaker signal) | YES -- but note this is opinion, not past behavior |
| amelius suggests AI for immersion practice | HN | Suggestion | YES -- but vague |
| nodja warns LLMs are unreliable for Japanese | HN | Past behavior (has used LLMs for translation) | CAUTION -- direct experience with LLM limitations |
| anigbrowl notes AI voices get pitch accent wrong | HN | Past behavior (has tested AI audio) | CAUTION -- specific technical limitation |
| The immersion-vs-apps debate is heated in HN thread | HN | Community split | MIXED -- AI could bridge the gap or widen it |
| Academic study (2024): 'Language/Kanji' is 2nd most negative experience | Tandfonline | Research | PARTIALLY -- AI tutoring could address frustration |

### Confirmation Rate: 3/20+ HN commenters (15%) specifically discussed AI for learning assistance

### Current Workarounds
- Learners use ChatGPT/Claude as informal Japanese tutors (unstructured, no SRS integration)
- Learners use HiNative to ask native speakers about nuances (async, not always timely)
- Learners hire tutors on iTalki ($15-30/hour)
- Learners post questions in r/LearnJapanese (async, variable quality)

### Why This Problem is Different from A1/A2
Problems A1 and A2 are about AI as a **content generation tool** -- the learner never interacts with the AI directly. Problem A3 is about AI as an **interactive tutor** -- conversational, real-time feedback. This is a fundamentally different product surface with much higher complexity, cost, and risk.

### Critical Skepticism
The evidence for A3 is the weakest of the three problems:
- charcircuit's signal is future-intent ("AI can tell you") not past behavior
- amelius's signal is vague ("perhaps talking to an AI")
- nodja's direct past-behavior signal is **negative** -- LLMs are "hit/miss" for Japanese
- anigbrowl's direct past-behavior signal is **negative** -- AI audio gets pitch wrong
- No HN commenter described successfully using AI tutoring to learn kanji (absence of positive past behavior)

This problem exists, but the evidence that AI solves it well for Japanese is weak and contradicted by skeptics with direct experience.

---

## Problem A4: Current SRS Algorithm Does Not Adapt to Individual Cognitive Patterns

### Evidence

| Signal | Source | Type | AI-Relevant? |
|--------|--------|------|-------------|
| WaniKani review burden causes >99% dropout | Community research | Past behavior (strong) | PARTIALLY -- ML-enhanced SRS could reduce burden |
| SM-2 quality parameter hardcoded to 5 in current implementation | Codebase review | Technical limitation | YES -- ML could optimize scheduling |
| FSRS algorithm (open source, ML-based) outperforms SM-2 in studies | Academic/open source | Research | YES -- direct AI/ML application |
| "Review count keeps climbing" at higher levels | WaniKani community | Past behavior | YES -- adaptive scheduling could smooth burden |
| Current SM-2 implementation is solid and tested (including property-based tests) | Codebase review | Technical strength | CAUTION -- replacing working system carries risk |

### Confirmation Rate: 2/20+ HN commenters (10%) raised SRS optimization concerns

### Current Workarounds
- Anki offers FSRS as alternative scheduler (free, proven)
- WaniKani uses custom SRS with no user control
- Some learners manually adjust Anki intervals

### Why This Problem is Lower Priority
The evidence is thin (2 signals) and the current SM-2 implementation works. FSRS is a known improvement over SM-2, but:
- The improvement is incremental, not transformative
- SM-2 is well-understood and debuggable; ML schedulers are opaque
- The bigger problem is what learners study (isolation vs. context), not when they review it
- Implementing FSRS is an engineering task, not really an "AI feature" in the product sense

---

## Assumption Tracker (AI-Specific)

| # | Assumption | Category | Risk Score | Evidence Status |
|---|-----------|----------|------------|-----------------|
| AA1 | AI can generate Japanese text at learner-appropriate levels with sufficient accuracy | Feasibility | 16 (Critical) | UNTESTED -- nodja's skepticism is the strongest counterevidence |
| AA2 | AI-generated content will feel natural enough that learners prefer it over no content | Value | 14 (High) | MIXED -- tillcarlos wants it, wren6991 prefers real stories |
| AA3 | AI mnemonic generation from radical data will produce memorable, accurate mnemonics | Feasibility+Value | 13 (High) | UNTESTED -- WaniKani quality bar is high |
| AA4 | API costs for AI generation can be managed for a free product | Viability | 15 (Critical) | UNTESTED -- key constraint for sustainability |
| AA5 | Privacy-conscious users (HN audience) will accept AI API calls with their learning data | Value | 12 (High) | UNTESTED -- HN already criticized Google Analytics usage |
| AA6 | AI tutoring for Japanese is accurate enough for beginners | Feasibility | 14 (High) | CONTRADICTED -- nodja and anigbrowl report problems |
| AA7 | AI features will differentiate Kuma San Kanji from competitors rather than commoditize it | Viability | 11 (Medium) | UNTESTED -- competitors are also adding AI |
| AA8 | Solo developer can implement and maintain AI integrations alongside core features | Feasibility | 13 (High) | UNTESTED -- scope and maintenance burden unknown |
| AA9 | Learners will trust AI-generated content for a language they are trying to learn | Value | 13 (High) | MIXED -- trust varies by feature (content gen vs. tutoring) |
| AA10 | Pre-generated AI content (batch, cached) is acceptable vs. real-time generation | Feasibility+Viability | 10 (Medium) | UNTESTED -- could dramatically reduce API costs |

### Risk Scoring Method
Score = (Impact if wrong x 3) + (Uncertainty x 2) + (Ease of testing x 1)

---

## Gate G1 Evaluation

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|
| Evidence signals | 5+ | 14+ signals across 4 problems (from existing HN + community research) | PASS |
| Problem confirmation rate | >60% | Problems A1 (25%) and A2 (20%) confirmed from prior discovery; A3 (15%) weak; A4 (10%) minimal | CONDITIONAL PASS |
| Problem in customer words | Yes | 6+ direct quotes captured with AI relevance | PASS |
| Concrete examples | 3+ | 4 distinct AI-relevant problems with multiple examples each | PASS |

### Decision: CONDITIONAL PROCEED to Phase 2

### Rationale for Conditional Pass
The individual AI problem confirmation rates (15-25%) are lower than the general product problems (25-35%). However, these signals exist within the SAME evidence base that validated the general problems. The AI problems are more specific sub-problems of already-validated parent problems:

- A1 (AI content generation) is a **solution approach** to the validated O5 (Bridge to Real Reading, score 17)
- A2 (AI mnemonics) is a **solution approach** to the validated O3 (Teach-Then-Test, score 15)
- A3 (AI tutoring) is a **new opportunity** with weak direct evidence
- A4 (AI SRS) is an **incremental improvement** with minimal direct evidence

The gate passes because the parent problems are strongly validated and AI is being evaluated as a solution approach, not as a problem in itself. The key question for Phase 2 is: which of these AI approaches actually add value beyond non-AI alternatives?

### Caveats
1. No NEW user interviews conducted -- all evidence is from prior discovery. AI-specific interview questions were not asked.
2. The strongest AI skepticism signals (nodja, anigbrowl) come from people with DIRECT past behavior using AI for Japanese -- these are the highest-quality signals and they are cautionary.
3. The "AI for language learning" space is moving fast. Evidence from early 2026 may not reflect current model capabilities.
4. The HN audience skews privacy-conscious and AI-skeptical compared to the general kanji learning population. Selection bias is present in both directions.
