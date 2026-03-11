# Wave Decisions -- DISCOVER: AI Learning Features

**Feature ID**: ai-learning-features
**Wave**: DISCOVER
**Date**: 2026-03-11
**Status**: Complete (Conditional Proceed)
**Decision**: CONDITIONAL GO -- AI as batch content generation pipeline, not real-time interactive feature

---

## Executive Summary

This DISCOVER wave evaluated whether AI features should be added to Kuma San Kanji, specifically re-examining the prior general discovery's conclusion that "AI-driven personalization" was "premature optimization."

**Finding**: The prior decision was partially correct and partially wrong.

- **Still premature**: AI conversational tutoring, AI writing correction, real-time per-user AI generation, AI adaptive SRS, AI audio/TTS
- **Now warranted**: AI batch content generation (reading passages, mnemonics, example sentences)

The key insight is architectural: **batch pre-generation** decouples AI cost from user count, eliminates privacy concerns (no user data sent to APIs), and solves a content scaling problem that no manual approach can address for a solo developer. The total cost for generating ALL AI content for the Grade 1 curriculum is under $1.

---

## Phase Summary

### Phase 1: Problem Validation -- CONDITIONAL PASS (G1)

**Evidence base**: 20+ HN comments, r/LearnJapanese community research (13 sources), codebase technical review. No new interviews conducted -- all evidence from prior general discovery, re-evaluated through AI lens.

**4 AI-relevant problems identified**:
| Problem | Confirmation | Parent Opportunity | AI Value |
|---------|-------------|-------------------|----------|
| A1: Content generation at learner level does not scale | 25% (5/20+ HN signals) | O5: Bridge to Real Reading (17) | HIGH -- AI solves the personalization/scale problem |
| A2: Mnemonic coverage infeasible for solo dev | 20% (4/20+ HN signals) | O2: Teach-Then-Test (15) | HIGH -- AI makes comprehensive coverage achievable |
| A3: No feedback without human tutor | 15% (3/20+ HN signals, 1 skeptic) | NEW | LOW -- evidence weak, skeptics have direct experience |
| A4: SRS does not adapt to individual patterns | 10% (2/20+ HN signals) | Engineering task | LOW -- incremental, SM-2 works |

**Gate decision**: Conditional pass. Individual AI confirmation rates are lower than general problems, but AI problems are sub-problems of already-validated parent opportunities with strong scores (15-17).

### Phase 2: Opportunity Mapping -- PASS (G2)

**8 AI opportunities scored**, top 3 selected:
| Rank | Opportunity | Score | Parent |
|------|-----------|-------|--------|
| 1 | AO1: AI-generated i+1 reading passages | 16 | O5 (17) |
| 2 | AO2: AI mnemonic generation from radicals | 12 | O2 (15) |
| 3 | AO3: AI contextual/disambiguation sentences | 9 | O1 (16) |

**Critical finding from AI vs. Non-AI analysis**: AI is not a replacement for the top non-AI solutions -- it is an augmentation. The non-AI foundations (H6: First Encounter Learning Flow, H4: Sentence-Completion Quiz) must be built FIRST. AI enhances them.

**Deprioritized**: AI conversational tutor (8), AI writing correction (7), AI content curation (9 but infeasible), AI adaptive SRS (6), AI audio/TTS (5).

### Phase 3: Solution Testing -- HYPOTHESES DESIGNED, TESTING PENDING

**3 hypotheses with feasibility spikes defined**:
| Hypothesis | Test | Key Risk | Spike Required |
|-----------|------|----------|---------------|
| AH1: AI mnemonics from radicals | Generate 20, review quality | Mnemonic accuracy and memorability | YES -- quality evaluation |
| AH2: AI disambiguation sentences | Generate 30, Japanese speaker review | Grammatical correctness, naturalness | YES -- sentence quality |
| AH3: AI i+1 reading passages | Generate 10, verify kanji constraints | Kanji constraint adherence, text naturalness | YES -- constrained generation |

**Sequencing**: AH1 (lowest risk) -> AH2 (validates AI sentence quality) -> AH3 (highest value, depends on AH2 validation).

**No testing has been conducted.** Feasibility spikes must pass before implementation.

### Phase 4: Market Viability -- CONDITIONAL PASS (G4)

**4 Big Risks**:
| Risk | Assessment | Key Factor |
|------|-----------|-----------|
| Value | YELLOW | Strong for reading passages; skepticism from users with direct AI experience |
| Usability | GREEN | AI features augment existing flows, not new product surfaces |
| Feasibility | YELLOW | Technical infrastructure is low risk; AI generation QUALITY is the critical unknown |
| Viability | GREEN | Batch pre-generation costs $3/year; zero privacy concern; manageable scope |

**Cost model**: $0.80 one-time generation, $2/year maintenance. Batch approach eliminates the cost-per-user problem that makes AI features expensive for free products.

---

## Key Decisions

### Decision 1: AI Features Are an Augmentation Layer, Not a Product Pivot

AI does not change what Kuma San Kanji is. It remains a kanji learning app with SRS, contextual learning, and a teach-then-test flow. AI enhances the content pipeline:
- More mnemonics (AI-generated vs. none)
- More example sentences (AI fills gaps in existing data)
- Personalized reading passages (impossible without AI)

This is NOT an "AI learning app." It is a learning app that uses AI to generate better content.

### Decision 2: Batch Pre-Generation Only (No Real-Time AI)

All AI content will be generated in batch, verified, and stored in PostgreSQL before any user sees it. No real-time API calls during user sessions. This decision:
- Eliminates API cost concerns ($3/year vs. $10-50/month)
- Eliminates privacy concerns (no user data sent to APIs)
- Eliminates latency concerns (pre-generated content serves instantly)
- Limits personalization (batch covers level-based, not individual-based content)

The personalization limitation is acceptable: batch generation by JLPT level / Grade level covers 90%+ of use cases. True per-user personalization is deferred until the batch approach is validated and the scale warrants it.

### Decision 3: Feasibility Spikes Before Any Code

No AI implementation code will be written until all three feasibility spikes pass (>70% quality rate). The spikes can be run in a single day using manual LLM prompting -- no engineering investment required. If spikes fail, the AI feature set is deprioritized with zero wasted effort.

### Decision 4: Non-AI Foundations First

Implementation order:
1. H6: First Encounter Learning Flow (NO AI)
2. H4: Sentence-Completion Quiz (NO AI)
3. AI infrastructure + AH1: Mnemonics
4. AH2: Example Sentences
5. AH3: Reading Passages

AI features augment steps 1-2. Building them first ensures AI has something to augment.

### Decision 5: Open Source AI Pipeline

The AI generation code, verification logic, and content pipeline will be open source. API keys are secrets (not committed), but the pipeline itself is inspectable. This:
- Builds trust with the privacy-conscious HN audience
- Enables community contributions to the verification logic
- Differentiates from closed-source AI features (Duolingo Max)

---

## Artifacts Produced

| Artifact | Path | Status |
|----------|------|--------|
| Problem Validation | `docs/feature/ai-learning-features/discover/problem-validation.md` | Complete |
| Opportunity Tree | `docs/feature/ai-learning-features/discover/opportunity-tree.md` | Complete |
| Solution Testing | `docs/feature/ai-learning-features/discover/solution-testing.md` | Complete |
| Lean Canvas | `docs/feature/ai-learning-features/discover/lean-canvas.md` | Complete |
| Wave Decisions | `docs/feature/ai-learning-features/discover/wave-decisions.md` | Complete (this document) |

---

## Gate Checklist (All Phases)

- [x] G1: Problem validated (14+ evidence signals from prior discovery, >60% confirmation on parent problems, customer words captured)
- [x] G2: Opportunities prioritized (8 identified, top 3 scored 9-16, job step coverage 100%)
- [ ] G3: Solution tested (hypotheses designed, feasibility spikes defined, TESTING NOT YET CONDUCTED)
- [x] G4: Viability confirmed (Lean Canvas complete, 4 risks at green/yellow, batch cost model validated)

**G3 is incomplete.** This is documented and accepted as a conditional proceed. The feasibility spikes are the next action and require zero code investment.

---

## Handoff Readiness

### For DISCUSS Wave (product-owner)

This discovery package is ready for handoff with the following conditions:

1. **Feasibility spikes must pass before user stories are written.** The product-owner should not create stories for AI features until the spikes validate that AI generation quality is sufficient for Japanese learning content.

2. **Non-AI features (H6, H4) should proceed to DISCUSS immediately.** These are fully validated by the general discovery and do not depend on AI spike results.

3. **AI features should be written as enhancement stories, not core stories.** The learning flow and quiz format are the core; AI content is an enhancement that can be added or removed without breaking the core experience.

4. **FunWithFlags is mandatory for ALL AI features.** Each AI content type (mnemonics, sentences, passages) must be independently flaggable.

### Recommended Story Sequencing for Product Owner

```
Epic: Contextual Learning Experience
  |
  +-- Story: First Encounter Learning Flow (H6) -- NO AI dependency
  |     Priority: P1 (highest)
  |
  +-- Story: Sentence-Completion Quiz Mode (H4) -- NO AI dependency
  |     Priority: P1
  |
  +-- Story: AI Content Pipeline Infrastructure -- FunWithFlags gated
  |     Priority: P2 (after H6+H4 shipped)
  |     Blocked by: Feasibility spike results
  |
  +-- Story: AI Mnemonic Generation (AH1) -- Enhances H6
  |     Priority: P2
  |     Blocked by: AI pipeline + spike results
  |
  +-- Story: AI Example Sentences (AH2) -- Enhances H4
  |     Priority: P3
  |     Blocked by: AI pipeline + spike results
  |
  +-- Story: AI Reading Passages (AH3) -- New feature surface
        Priority: P3
        Blocked by: AH2 quality validation + AI pipeline
```

---

## Risk Register (Carried Forward)

| Risk ID | Risk | Severity | Likelihood | Mitigation | Owner |
|---------|------|----------|-----------|------------|-------|
| R1 | AI-generated Japanese text contains grammatical errors | High | Medium | Feasibility spike + Japanese speaker review + community flagging | Developer |
| R2 | LLM ignores kanji constraints in generated text | High | Medium | Automated kanji verification in pipeline; reject non-compliant | Developer |
| R3 | Users perceive AI content as "AI slop" and distrust the app | High | Low-Medium | Quality gating, transparent labeling, community review | Developer |
| R4 | API provider changes pricing or terms | Medium | Low | Provider abstraction module; batch cache means low API dependency | Developer |
| R5 | Solo developer scope creep from AI features | Medium | Medium | Strict prioritization; batch approach minimizes maintenance; AI is augmentation not core | Developer |
| R6 | Privacy-conscious users reject AI features despite batch approach | Low | Low | Clear documentation; open source pipeline; FunWithFlags opt-out | Developer |
| R7 | WaniKani users perceive AI mnemonics as inferior copy | Medium | Medium | Different mnemonic style (visual/spatial); acknowledge WaniKani's quality | Developer |

---

## What Changed from the Prior Discovery

| Prior Discovery Conclusion | This Discovery Finding | Change |
|---------------------------|----------------------|--------|
| "AI-driven personalization (premature optimization)" | Batch AI content generation is cheap ($3/year) and warranted | REVISED: batch AI is not premature |
| H3 (i+1 Reading) ranked #7 due to technical ambition | AI generation eliminates the corpus requirement, making H3 feasible | UPGRADED: AH3 is now the flagship AI feature |
| H7 (Radical Mnemonics) ranked #6 due to curation effort | AI generation makes comprehensive coverage achievable for solo dev | UPGRADED: AH1 is the first AI feature to ship |
| No AI features in recommended build order | AI features added as augmentation layer (positions 3-5) | ADDED: conditional on feasibility spikes |
| All solutions assumed manual/curated content | Batch AI pipeline produces content at negligible cost | NEW APPROACH: AI as content pipeline |
| Privacy not explicitly addressed for AI | Batch pre-generation means zero user data to APIs | RESOLVED: privacy-by-architecture |
