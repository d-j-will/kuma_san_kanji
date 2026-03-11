# Lean Canvas -- AI Learning Features for Kuma San Kanji

**Phase**: 4 -- Market Viability
**Status**: Complete (G4 Evaluation Below)
**Date**: 2026-03-11
**Feature ID**: ai-learning-features
**Evidence Sources**: All prior phases, AI cost analysis, competitive AI landscape, privacy architecture, codebase technical review
**Relationship to Prior Discovery**: This Lean Canvas extends the general product canvas (feature: kuma-san-kanji) with AI-specific viability analysis. It does NOT replace the general canvas -- AI features are an augmentation layer on top of the core product.

---

## Lean Canvas

### 1. Problem (Phase 1 Validated -- AI-Specific Lens)

**Top 3 AI-Relevant Problems**:

1. **Content generation at learner level does not scale manually** -- The #1 opportunity from the general discovery (Bridge to Real Reading, score 17) requires reading passages personalized to each learner's mastered kanji set. Manual curation cannot produce content for the combinatorial space of individual learner progress states. AI generation is the only feasible approach for a solo developer.

2. **Mnemonic coverage is infeasible without AI** -- Quality mnemonics for 2,000+ kanji require years of manual effort (WaniKani has a dedicated team). The existing 214 radicals with meanings provide structured input for AI generation. Without AI, the "teach before test" opportunity (score 15) can only be partially addressed.

3. **Example sentence data has gaps that limit contextual learning** -- The ExampleSentence table has uneven coverage. Some kanji have multiple sentences; others have few or none. Disambiguation pairs (kanji sharing English glosses) lack contrastive examples. AI can fill these gaps at near-zero cost.

**Existing Alternatives (AI-Specific)**:
- ChatGPT/Claude as informal Japanese tutor ($20/mo for premium, unstructured, no SRS integration)
- Duolingo Max with AI features ($7/mo, not kanji-focused, not open source)
- Anki + manual sentence mining from immersion (free but enormous user effort)
- WaniKani with curated mnemonics ($9/mo or $299 lifetime, closed source)
- No tool offers AI-generated content personalized to individual kanji progress

---

### 2. Customer Segments (by JTBD -- Same as General Canvas, AI-Refined)

**Primary Segment**: Self-directed intermediate kanji learners (JLPT N4-N3 level)
- Have tried 2+ tools and hit a plateau
- Want to bridge from flashcard recall to reading ability
- **AI-specific need**: Want personalized reading material at their exact level
- **AI-specific willingness**: Moderate -- will use AI content if quality is high; skeptical of "AI slop"

**Secondary Segment**: Returning beginners who need the teaching step
- Previously abandoned apps that tested without teaching
- **AI-specific need**: Want mnemonics to make kanji stick
- **AI-specific willingness**: High -- less likely to evaluate AI quality critically

**Anti-Segment** (important for AI): Privacy absolutists
- Will not use any product that sends data to AI APIs
- **Mitigation**: Batch pre-generation means ZERO user data sent to APIs. Privacy story: "AI generates content offline; your learning data stays on our server."

---

### 3. Unique Value Proposition (AI-Augmented)

**Single clear message**:

> Learn kanji in context with AI-generated reading passages that match exactly what you know. The open-source kanji learning app where AI serves your learning, not the other way around.

**AI-specific differentiators**:
- **Personalized to your kanji**: AI generates reading material using only kanji you have mastered (no competitor does this)
- **AI that respects privacy**: All content pre-generated in batch; no user data sent to AI providers
- **Quality-gated AI**: Every AI-generated mnemonic and sentence is verified before you see it (not raw LLM output)
- **Free AI features**: Batch pre-generation costs pennies, not monthly subscriptions
- **Open source AI pipeline**: The generation and verification code is open -- inspect, modify, self-host

---

### 4. Solution (Top 3 AI Features for Top 3 Problems)

| Problem | AI Solution Feature | Phase 3 Hypothesis | Existing Infrastructure | Build Order |
|---------|--------------------|--------------------|------------------------|-------------|
| Content does not scale | AI-generated i+1 reading passages personalized to learner's mastered kanji set | AH3 | UserKanjiProgress, Content domain, ThematicGroup | 3rd (highest value, highest risk) |
| Mnemonic coverage infeasible | AI-generated radical-based mnemonics for all kanji | AH1 | 214 radicals with meanings, Explore page, KanjiVG stroke order | 1st (lowest risk, builds AI infrastructure) |
| Sentence data has gaps | AI-generated contextual and disambiguation example sentences | AH2 | ExampleSentence schema, Meaning records, sentence-completion quiz (H4) | 2nd (validates AI sentence quality) |

**What is NOT an AI feature** (critical boundary):
- H6: First Encounter Learning Flow -- this is a UX flow connecting existing pages, not AI
- H4: Sentence-Completion Quiz -- this is a quiz format change using existing data, not AI
- SM-2 SRS algorithm -- this is proven, working, tested; no AI replacement needed
- Stroke order animation -- KanjiVG is complete; AI adds nothing here
- User authentication, admin, feature flags -- infrastructure, not AI

---

### 5. Channels (Path to Customers -- AI-Specific Messaging)

| Channel | AI-Specific Message | Expected Response |
|---------|-------------------|-------------------|
| Hacker News (Show HN update) | "We added AI-generated reading passages that use only kanji you've mastered. Your data never leaves the server." | High interest -- privacy angle resonates with HN; AI-skeptics can inspect open source code |
| r/LearnJapanese | "AI-generated graded reading material personalized to your kanji progress -- free and open source" | Mixed -- community is split on AI for Japanese; quality will be scrutinized |
| GitHub / open source community | "Open source AI content pipeline for Japanese learning" | Moderate -- technical audience interested in the architecture |
| Japanese learning Discord servers | Feature announcement with example passages | Moderate -- users care about quality, not technology |

**Channel validation**: The HN channel is already validated from the initial Show HN post. The AI angle (especially the privacy-respecting batch approach) adds a compelling technical story for this audience.

---

### 6. Revenue Streams

**Current model**: Free, open source, self-hosted (unchanged by AI features)

**AI cost impact on free model**:

| AI Feature | Generation Cost | Ongoing Cost | Impact on Free Model |
|-----------|----------------|-------------|---------------------|
| Mnemonics (2,136 kanji) | ~$0.20 one-time | $0 (cached) | Negligible |
| Example sentences (1,000 sentences) | ~$0.10 one-time | $0 (cached) | Negligible |
| Reading passages -- batch (2,000 passages) | ~$0.50 one-time | ~$0.50/quarter for refresh | Negligible |
| Reading passages -- personalized (per-user) | N/A (deferred) | ~$0.01-0.05/user/month | Potential concern at scale |
| **Total (batch approach)** | **~$0.80** | **~$2/year** | **Zero impact on sustainability** |

**Key insight**: The batch pre-generation approach makes AI features essentially free to operate. The total cost of generating ALL AI content for the entire Grade 1 curriculum is less than $1. Even generating content for all 2,136 jouyou kanji would cost under $5. This is not a revenue model problem -- it is a one-time content generation expense.

**If the project scales beyond hobby**:
- Per-user personalized generation (deferred) could cost $0.01-0.05/user/month
- At 1,000 users: $10-50/month -- manageable via donations or optional paid tier
- The batch approach handles 90%+ of use cases without per-user generation

---

### 7. Cost Structure (AI-Augmented)

| Cost Category | Current | With AI (Batch) | With AI (At Scale) |
|---------------|---------|----------------|-------------------|
| Hosting (homelab Proxmox) | ~$0 marginal | ~$0 marginal | $20-50/mo VPS |
| Domain + TLS | ~$15/year | ~$15/year | ~$15/year |
| Developer time | Primary cost | Primary cost + AI pipeline | Primary cost + AI pipeline maintenance |
| AI API costs | $0 | ~$2/year (batch) | $10-50/month (if per-user) |
| Content creation | None | ~$1 one-time generation | ~$5/quarter for refresh |
| Database (PostgreSQL) | Included in homelab | Included (AI content in same DB) | $20-50/mo managed |
| **Total incremental AI cost** | -- | **~$3/year** | **$120-600/year** |

**Conclusion**: AI features add approximately $3/year in direct costs at the current hobby scale. This is the strongest viability argument -- batch pre-generation turns a potentially expensive AI feature into a trivially cheap content pipeline.

---

### 8. Key Metrics (AI-Specific)

| Metric | What It Measures | Target | Measurement Method |
|--------|-----------------|--------|-------------------|
| Mnemonic engagement rate | Do users read AI mnemonics? | >60% click/expand | FunWithFlags A/B, track expand events |
| Mnemonic retention impact | Do mnemonics improve SRS recall? | >10% improvement at 7-day review | Compare SRS accuracy: mnemonic group vs. control |
| Sentence quality score | Are AI sentences indistinguishable from curated? | >60% cannot tell in blind test | Community review, blind comparison |
| Disambiguation accuracy | Do contrastive sentences help? | >20% improvement on confusable kanji pairs | Quiz accuracy on disambiguation items |
| Reading passage engagement | Do users read AI passages? | >40% of sessions include reading | Track reading mode opens |
| Reading passage naturalness | Do passages feel natural? | >60% rate as "natural" or "readable" | User survey after reading |
| Kanji constraint adherence | Does AI follow kanji restrictions? | >90% of passages use only allowed kanji | Automated verification |
| AI content flag rate | How often do users flag AI content as wrong? | <5% of AI content flagged | Track flag events |
| Cost per content piece | Is batch generation economically sustainable? | <$0.001 per sentence/mnemonic | API billing divided by content count |

---

### 9. Unfair Advantage (AI-Specific)

| Advantage | Copyability | Durability |
|-----------|-------------|-----------|
| Personalized-to-kanji-progress AI content | Medium -- requires SRS integration + AI pipeline; competitors could build but most have not | Medium-High -- the combination of open SRS data + AI generation + kanji-level personalization is novel |
| Privacy-respecting AI (batch, no user data to API) | Easy to claim, harder to implement; most AI features are real-time | Medium -- this is an architectural choice that limits features but gains trust |
| Open source AI pipeline | Can be forked/copied; but the community and brand travel with the original | Medium -- open source creates community goodwill and scrutiny |
| Cost structure ($3/year for AI) | Hard to match with real-time AI features (Duolingo Max costs much more to operate) | High -- batch pre-generation is a structural cost advantage |
| Quality-gated AI content (verified, not raw) | Easy to copy the concept; execution quality varies | Low-Medium -- the quality gate is only as good as the verification pipeline |

**Honest assessment**: The unfair advantage is in the ARCHITECTURE, not the AI itself. Any competitor can call the same LLM APIs. The advantage is:
1. Deep integration with per-kanji progress tracking (SRS data shapes AI input)
2. Batch pre-generation (cost structure advantage)
3. Open source (trust advantage)
4. Privacy by architecture (batch = no user data to APIs)

None of these are defensible moats. They are execution advantages that compound over time through community trust and content quality.

---

## 4 Big Risks Assessment (AI-Specific)

### Value Risk: Will learners want AI-generated kanji learning content?

| Signal | Direction | Strength |
|--------|-----------|----------|
| tillcarlos (HN) directly asks for level-appropriate text generation | Positive | Strong (unmet need, past behavior: searching for tools) |
| Multiple N1-passers attribute success to reading, not apps | Positive (for reading passages) | Strong (past behavior) |
| wren6991 (HN) prefers "real stories over generated text" | Negative (for AI content) | Moderate (preference, not past behavior) |
| WaniKani's mnemonics are its key differentiator (per N2-level user) | Positive (for AI mnemonics) | Strong (past behavior comparison) |
| nodja (HN) warns LLMs are "hit/miss" for Japanese | Cautionary | Strong (past behavior with LLMs) |
| Community research: contextual learning is #1 recommendation | Positive (for any contextual content, including AI) | Strong |

**Assessment**: YELLOW -- The value proposition is strong for the reading passage use case (tillcarlos's explicit ask, N1-passers confirming reading matters). Mnemonic value is validated by WaniKani's success. But the "AI-generated" aspect specifically faces skepticism from users who have directly used LLMs for Japanese (nodja, anigbrowl). Quality is the deciding factor: if AI content quality is high, value is clearly positive. If quality is mediocre, value is negative (worse than no content). The feasibility spikes will determine which way this goes.

### Usability Risk: Can learners navigate AI-augmented learning flows?

| Signal | Direction | Strength |
|--------|-----------|----------|
| Current Explore page already shows rich kanji detail | Positive | Strong (infrastructure exists) |
| Mnemonics would be an addition to existing Explore page | Positive (incremental, not new flow) | Strong |
| Reading passages require a new "Read" interface | Neutral-Caution | Medium (new UI surface to design) |
| Current onboarding confusion (6+ HN signals) | Negative (current state) | Strong |

**Assessment**: GREEN -- AI features are augmentations to existing flows, not new products. Mnemonics add to the Explore page. Example sentences add to the existing quiz. Reading passages are the only new interface, and it is a straightforward text display. The usability risk is in the CORE product (onboarding, navigation) not in the AI additions.

### Feasibility Risk: Can AI generate quality Japanese learning content?

| Component | Status | Risk |
|-----------|--------|------|
| LLM Japanese text quality | Untested for constrained generation | HIGH -- this is the critical unknown |
| Kanji constraint adherence | Untested | HIGH -- LLMs may ignore character restrictions |
| Mnemonic generation from radical data | Untested but structurally simple | MEDIUM -- input is structured, output is creative text |
| Example sentence generation | Untested for pedagogical quality | MEDIUM -- grammar must be correct for learners |
| AI provider abstraction (Elixir) | No existing library chosen | LOW -- HTTP API calls, well-understood |
| Batch generation pipeline | Not built | LOW -- standard ETL pattern |
| Content storage in existing schema | ExampleSentence exists; mnemonic/passage resources needed | LOW -- schema extension |
| Automated kanji verification | Not built | LOW -- regex/character set check |
| FunWithFlags integration | Infrastructure exists, unused | LOW -- already installed |

**Assessment**: YELLOW -- The technical infrastructure risk is low (Elixir HTTP clients, PostgreSQL storage, FunWithFlags). The AI QUALITY risk is the critical unknown. LLMs are generally good at Japanese, but constrained generation (use ONLY these specific kanji) and pedagogical accuracy (correct grammar at a specific level) are untested claims. The feasibility spikes are designed to answer this specific question before any implementation begins.

### Viability Risk: Does AI work for a free, open-source, solo-developer product?

| Factor | Assessment | Notes |
|--------|-----------|-------|
| AI API cost | GREEN ($3/year batch) | Batch pre-generation eliminates cost concern entirely |
| Developer maintenance burden | YELLOW | AI pipeline adds complexity; but pipeline is simple (batch generate, verify, store) |
| Content quality maintenance | YELLOW | AI content may need periodic regeneration as models improve or errors are found |
| Privacy compliance | GREEN | Batch generation sends no user data to APIs |
| Open source compatibility | GREEN | AI pipeline code is open; API keys are secrets, not code |
| Competitive sustainability | YELLOW | Competitors can build same features; execution advantage, not moat |
| Solo developer scope | YELLOW | AI features add scope; batch approach minimizes ongoing burden |

**Assessment**: GREEN -- The batch pre-generation approach makes AI features viable for a free, solo-developer product. The total annual cost is under $5. The implementation is a one-time pipeline build, not ongoing infrastructure. The main risk is developer time/scope, not financial or operational viability.

---

## Gate G4 Evaluation

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|
| Lean Canvas complete | All 9 sections | 9/9 complete | PASS |
| Four big risks assessed | All green or yellow | 1 green, 3 yellow, 0 red | PASS |
| Channel validated | 1+ viable | HN proven, Reddit likely | PASS |
| Unit economics | LTV > 3x CAC | N/A (free product, ~$3/year AI cost, ~$0 CAC) | PASS (trivially) |
| Stakeholder sign-off | Required | Solo project -- self-approved | PASS (with caveat) |

### Decision: CONDITIONAL PROCEED

The Lean Canvas is complete and all risks are at acceptable levels. Critical conditions:

1. **Feasibility spikes MUST pass before implementation begins.** The AI quality risk (can LLMs generate constrained Japanese text?) is the single most important unknown. No code should be written until spikes validate this.

2. **Non-AI foundations MUST be built first.** H6 (First Encounter Learning Flow) and H4 (Sentence-Completion Quiz) are higher priority, lower risk, and provide the foundation that AI features augment.

3. **Batch pre-generation is the ONLY approved approach initially.** Per-user real-time generation is deferred until batch approach is validated and the privacy/cost implications are fully evaluated.

---

## Go / No-Go Recommendation

### CONDITIONAL GO -- AI features as augmentation layer, not core product

**Recommended implementation order**:

1. **Run feasibility spikes (1 week, no code)**
   - Generate 20 mnemonics, 30 disambiguation sentences, 10 reading passages using LLM prompts
   - Evaluate quality with Japanese speaker review
   - If <70% quality rate on any spike: deprioritize that specific AI feature
   - Cost: $0 (manual prompting with existing LLM access)

2. **Build non-AI foundations (from general discovery)**
   - H6: First Encounter Learning Flow (connect Explore to Quiz)
   - H4: Sentence-Completion Quiz (using existing ExampleSentence data)
   - Both behind FunWithFlags flags

3. **Build AI infrastructure (1 week)**
   - AI provider behavior module with one implementation (Claude or OpenAI)
   - Batch generation pipeline (generate -> verify -> store)
   - Automated kanji constraint verification
   - Content tagging for AI-generated content

4. **Ship AH1: AI Mnemonics (1 week)**
   - Batch generate mnemonics for 80 Grade 1 kanji
   - Manual quality review
   - Add mnemonic display to Explore page / First Encounter Flow
   - Behind FunWithFlags flag
   - Measure engagement

5. **Ship AH2: AI Example Sentences (1 week)**
   - Batch generate disambiguation sentences for confusable kanji pairs
   - Japanese speaker quality review
   - Insert into ExampleSentence table (tagged as AI-generated)
   - Enable in sentence-completion quiz
   - Measure disambiguation accuracy improvement

6. **Ship AH3: AI Reading Passages (2 weeks)**
   - Batch generate i+1 passages for Grade 1 kanji combinations
   - Automated kanji constraint verification + manual quality review
   - Build minimal reading interface
   - Behind FunWithFlags flag
   - Measure engagement, naturalness, reading comprehension

### What NOT to build

- AI conversational tutor (weak evidence, enormous complexity, high ongoing cost)
- AI writing correction (contested need, high accuracy requirement)
- AI adaptive SRS (incremental improvement, not AI product feature)
- AI audio/TTS (quality not ready for Japanese pitch accent)
- Real-time per-user AI generation (privacy concern, cost concern, defer)
- Any AI feature without a preceding feasibility spike

### Re-Evaluation of Prior Decision

The general discovery concluded "AI-driven personalization (premature optimization)" under "What NOT to build yet." This AI-specific discovery finds:

**The prior decision was PARTIALLY correct**:
- AI personalization (per-user real-time generation) IS still premature -- defer
- AI tutoring/conversation IS premature -- weak evidence, high risk
- AI adaptive SRS IS premature -- working system, incremental improvement

**The prior decision was PARTIALLY wrong**:
- AI batch content generation is NOT premature -- it is cheap ($0.80 total), addresses the #1 validated opportunity, and solves a scaling problem that no non-AI approach can solve for a solo developer
- AI mnemonic generation is NOT premature -- it enables a validated teaching step at a scale that manual curation cannot achieve
- The key insight the prior discovery missed: batch pre-generation decouples AI cost from user count, making AI features viable for a free product

**Updated position**: AI as a batch content generation pipeline is viable and warranted. AI as a real-time interactive feature is still premature.

---

## Discovery State Summary

```yaml
current_phase: "4 (complete with conditions)"
discovery_started: "2026-03-11"
feature_id: "ai-learning-features"
relationship_to_general_discovery: "Augmentation layer on top of validated core opportunities"
evidence_sources:
  - "Prior general discovery: all 4 phases (feature: kuma-san-kanji)"
  - "HN feedback: 20+ substantive comments with AI-specific signals"
  - "r/LearnJapanese community research: 13 sources"
  - "Codebase review: technical feasibility assessment"
  - "AI cost analysis: API pricing models"
  - "Competitive landscape: Duolingo Max, WaniKani, ChatGPT"
ai_assumptions_tracked: 10 (AA1-AA10)
ai_opportunities_identified: 8 (AO1-AO8)
top_ai_opportunities:
  - "AO1: AI-Generated i+1 Reading Passages (16)"
  - "AO2: AI Mnemonic Generation (12)"
  - "AO3: AI Example Sentences (9)"
ai_hypotheses_designed: 3 (AH1-AH3)
ai_hypotheses_tested: 0
feasibility_spikes_designed: 3
feasibility_spikes_conducted: 0
decision_gates:
  G1: "CONDITIONAL PASS -- AI problems are sub-problems of validated parent problems"
  G2: "PASSED -- 8 opportunities, top 3 score 9-16"
  G3: "NOT STARTED -- hypotheses designed, spikes defined, testing pending"
  G4: "CONDITIONAL PASS -- canvas complete, risks yellow, spikes must pass first"
artifacts_created:
  - "docs/feature/ai-learning-features/discover/problem-validation.md"
  - "docs/feature/ai-learning-features/discover/opportunity-tree.md"
  - "docs/feature/ai-learning-features/discover/solution-testing.md"
  - "docs/feature/ai-learning-features/discover/lean-canvas.md"
key_finding: "AI as batch content pipeline is viable ($3/year). AI as real-time interactive feature is premature."
prior_decision_reassessment: "Partially correct: real-time AI is premature; batch AI content generation is warranted and cheap."
```
