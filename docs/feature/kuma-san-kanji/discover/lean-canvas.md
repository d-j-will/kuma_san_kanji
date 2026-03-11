# Lean Canvas -- Kuma San Kanji

**Phase**: 4 -- Market Viability
**Status**: Complete (G4 Evaluation Below)
**Date**: 2026-03-11
**Evidence Sources**: All prior phases, demographics data, competitive pricing, HN feedback, codebase analysis

---

## Lean Canvas

### 1. Problem (Phase 1 Validated)

**Top 3 Problems**:

1. **Kanji learned in isolation fail to transfer to reading** -- Learners master flashcards but cannot read real Japanese. Multiple N1-passers attribute breakthroughs to reading, not apps. No existing free tool bridges this gap.

2. **No teaching step before testing** -- Users are quizzed on characters they were never taught. The absence of a "learn" step is the #1 UX complaint. WaniKani's key differentiator (per N2-level user) is exactly this teaching flow.

3. **Ambiguous meaning mappings confuse learners** -- Single-word English translations (辺 = "area") create false mental models. Learners need contextual disambiguation to build accurate understanding.

**Existing Alternatives**:
- WaniKani ($9/mo, $299 lifetime) -- strong teaching step, weak on reading bridge
- Anki (free) -- powerful but requires significant user effort to create good cards
- Kanji Study ($13 one-time) -- clean mobile app, no reading bridge
- Bunpro (subscription) -- grammar-focused, limited kanji depth
- Renshuu (freemium) -- broad but unfocused

---

### 2. Customer Segments (by JTBD)

**Primary Segment**: Self-directed intermediate kanji learners (JLPT N4-N3 level)
- Have tried 2+ tools and hit a plateau
- Motivated by cultural interest (anime, manga, games) -- 40-45% of learners
- Age 19-35 (55-65% of learner population)
- Active in online learning communities (Reddit, HN, Discord)
- Willing to invest time in study but frustrated by lack of progress

**Secondary Segment**: Returning beginners
- Previously tried and abandoned kanji apps
- Need a teaching step to get started (the "Anki is too hard to start with" crowd)
- Looking for structured guidance without high cost

**Underserved Segment** (future): Professional adults 30-50
- Need time-efficient, contextually relevant learning
- Demographics data shows 15-20% of learners, underserved by playful/gamified apps
- Not yet directly validated through user research

---

### 3. Unique Value Proposition

**Single clear message**:

> Learn kanji in context, not in isolation. The open-source kanji learning app that bridges the gap from flashcard recall to real Japanese reading.

**Supporting differentiators**:
- Free and open source (vs. $9-299 for WaniKani)
- Contextual learning with sentence-level SRS (vs. character-level everywhere else)
- Reading bridge feature (no competitor offers this)
- Wabi-sabi aesthetic that respects adult learners (vs. clinical or childish UX)
- Built on proven SM-2 algorithm with rich radical/stroke order data

---

### 4. Solution (Top 3 Features for Top 3 Problems)

| Problem | Solution Feature | Phase 3 Hypothesis | Existing Infrastructure |
|---------|-----------------|--------------------|-----------------------|
| Isolation learning | Sentence-context SRS cards + graded reading passages | H1, H2, H4 | ExampleSentence data, SM-2 algorithm, Content domain |
| No teaching step | First Encounter Learning Flow (radical > meaning > reading > sentence > quiz) | H6 | Explore page, KanjiVG stroke order, 214 radicals, meanings, pronunciations |
| Ambiguous meanings | Sentence-completion quizzes + meaning disambiguation clusters | H4, H5 | ExampleSentence data, Meaning records |

---

### 5. Channels (Path to Customers)

| Channel | Evidence | Cost | Expected Reach |
|---------|----------|------|---------------|
| Hacker News / Show HN | Already posted, received 20+ substantive comments, community engagement proven | Free | 500-2000 initial users per post |
| r/LearnJapanese | ~600K members, active community of exactly the target segment | Free | 200-1000 per post |
| Open source discovery (GitHub) | Elixir/Phoenix community interest, "open source language learning" niche | Free | Organic growth, 50-200/month |
| Japanese learning Discord servers | Multiple large servers (JLPT Study, Kanji Koohii community) | Free | 100-500 per announcement |
| Word of mouth from HN commenters | "Great start!", "I'd love to collaborate", "I'll definitely be trying it out" | Free | Unknown but authentic |

**Channel validation**: The HN post is the strongest evidence -- real users found the product, used it, and provided detailed feedback. This is a validated channel.

---

### 6. Revenue Streams

**Current model**: Free, open source, self-hosted (homelab deployment)

**Potential models** (not yet validated -- viability assumptions):

| Model | Fit | Risk |
|-------|-----|------|
| Completely free / donation-supported | High fit with open source ethos | Sustainability risk |
| Freemium (core free, premium reading content) | Medium fit | Content creation cost |
| Self-hosted with optional managed hosting | High fit with technical audience | Small addressable market |
| Sponsorship / grant (language education foundations) | Medium fit | Unpredictable |

**Viability assessment**: As a homelab project, the primary cost is developer time and hosting (~$0 marginal cost on existing infrastructure). Revenue is not a prerequisite for sustainability at current scale. If the project grows beyond homelab, the freemium model with premium curated reading content is the most natural fit.

---

### 7. Cost Structure

| Cost Category | Current | At Scale (1000+ users) |
|---------------|---------|----------------------|
| Hosting (homelab Proxmox) | ~$0 marginal | $20-50/mo VPS if outgrows homelab |
| Domain + TLS | ~$15/year | ~$15/year |
| Developer time | Primary cost (hobby project) | Primary cost |
| Content creation | None (seed data from open datasets) | Significant if curating reading passages |
| Database (PostgreSQL) | Included in homelab | $20-50/mo managed if scaling |

**Key insight**: The cost structure is extraordinarily lean. PostgreSQL on Docker, Elixir's concurrency model, and homelab hosting mean near-zero marginal cost per user up to hundreds of concurrent users.

---

### 8. Key Metrics

| Metric | What It Measures | Target |
|--------|-----------------|--------|
| Daily Active Learners (DAL) | Engagement | Growth trend |
| Session duration | Depth of engagement | >5 min average |
| Kanji retention at 30 days | Learning effectiveness | >70% (SM-2 should deliver this) |
| Learn-to-quiz conversion | Teaching step effectiveness | >80% complete learn before quiz |
| Reading mode engagement | Bridge-to-reading value | >40% of sessions include reading |
| Return rate (7-day) | Stickiness | >30% |
| Quick wins from HN feedback | Community trust | Track implementation of HN suggestions |

---

### 9. Unfair Advantage

| Advantage | Copyability | Durability |
|-----------|-------------|-----------|
| Open source + free | Easy to copy the model, hard to copy the community | Medium -- community loyalty matters |
| Wabi-sabi aesthetic + adult-respecting design | Design can be copied, philosophy is harder | Medium |
| Elixir/Phoenix LiveView real-time UX | Technical choice, not moat | Low |
| Contextual reading bridge (if validated) | Feature can be copied, execution quality varies | Medium |
| Early mover on "context-first kanji learning" | Philosophy can be copied, brand cannot | Medium-High |
| Direct HN community relationship | Authentic relationship, not easily replicated | High |

**Honest assessment**: There is no strong moat. The advantage is in execution speed (solo developer, lean stack, existing infrastructure) and authentic community relationship. The open-source model itself creates community goodwill that proprietary competitors cannot easily match.

---

## 4 Big Risks Assessment

### Value Risk: Will learners want context-first kanji learning?

| Signal | Direction | Strength |
|--------|-----------|----------|
| 7+ HN commenters describe context/reading as the breakthrough | Positive | Strong |
| N1/N2 passers attribute success to reading, not flashcards | Positive | Strong (past behavior) |
| "Apps don't work for learning Japanese" camp exists | Negative | Moderate |
| No existing tool offers this specific approach | Unknown | Could be opportunity or warning |

**Assessment**: GREEN -- Strong evidence that the value proposition resonates. The "apps don't work" camp actually supports the thesis: they are saying current app approaches (isolated flashcards) do not work. Context-first is the response to their critique.

### Usability Risk: Can learners navigate a learn-then-read-then-quiz flow?

| Signal | Direction | Strength |
|--------|-----------|----------|
| Current onboarding confusion (6+ HN signals) | Negative (current state) | Strong |
| Explore page already shows rich kanji detail | Positive (infrastructure exists) | Strong |
| Mobile improvements already implemented | Positive | Moderate |
| "There's a lot of information on the screen" | Negative (current state) | Moderate |

**Assessment**: YELLOW -- The current UX has known problems, but the infrastructure for a better flow exists. The First Encounter Learning Flow (H6) directly addresses this. Testing required.

### Feasibility Risk: Can we build this with existing infrastructure?

| Component | Status | Risk |
|-----------|--------|------|
| SM-2 SRS algorithm | Implemented, tested (including property-based tests) | Low |
| Kanji data (meanings, readings, sentences) | Loaded (214 radicals, multiple kanji) | Low |
| Stroke order (KanjiVG) | Implemented with SVG sanitization and caching | Low |
| Content domain (ThematicGroup, EducationalContext) | Schema exists, limited content | Medium |
| Sentence-context quiz mode | Not implemented, but QuizLive is extensible | Medium |
| Graded reading passage generation | Not implemented, requires content curation or generation | High |
| User progress tracking | Implemented (UserKanjiProgress) | Low |
| Feature flags | Infrastructure exists (FunWithFlags) but unused in code | Low |
| Authentication and authorization | Implemented (AshAuthentication) | Low |

**Assessment**: GREEN -- The technical foundation is solid. The highest-risk item (graded reading passages) can start with manual curation. The Elixir/Ash/Phoenix stack is well-suited to the incremental feature additions planned.

### Viability Risk: Does this work as a sustainable project?

| Factor | Assessment | Notes |
|--------|-----------|-------|
| Cost to operate | Very low (~$0 on homelab) | Elixir concurrency handles many users cheaply |
| Developer sustainability | Hobby project risk | Solo developer -- bus factor of 1 |
| Content sustainability | Medium risk | Need ongoing content creation for reading passages |
| Community sustainability | Promising | HN engagement + open source contributions |
| Market timing | Good | Self-study segment growing fastest, mobile learning up |

**Assessment**: YELLOW -- Sustainable at hobby scale. The main risk is solo developer burnout and content creation effort. Open source contributions and community engagement mitigate but do not eliminate this.

---

## Gate G4 Evaluation

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|
| Lean Canvas complete | All 9 sections | 9/9 complete | PASS |
| Four big risks assessed | All green or yellow | 2 green, 2 yellow, 0 red | PASS |
| Channel validated | 1+ viable | HN proven, Reddit likely | PASS |
| Unit economics | LTV > 3x CAC | N/A (free product, ~$0 CAC, ~$0 cost) | PASS (trivially) |
| Stakeholder sign-off | Required | Solo project -- self-approved | PASS (with caveat) |

### Decision: CONDITIONAL PROCEED

The Lean Canvas is complete and all risks are at acceptable levels. However, two important caveats:

1. **Phase 3 testing has not been conducted.** Hypotheses are designed but not validated with real users. The G3 gate is not passed. This Lean Canvas should be revisited after Phase 3 testing produces results.

2. **The viability model is "hobby project sustainable" not "business sustainable."** This is appropriate for the current stage but means the canvas would need significant revision if the project aims for broader scale.

---

## Go / No-Go Recommendation

### GO -- with conditions

**Recommended next actions in priority order**:

1. **Implement quick wins immediately** (romaji toggle, select-all for quiz sets, default font fix, timer bug). These build community trust at low cost and are unambiguous improvements.

2. **Build and test H6 (First Encounter Learning Flow)** behind a FunWithFlags flag. This is the highest-signal, lowest-effort experiment. All data exists. Connect the Explore page learning experience to the Quiz entry flow.

3. **Build and test H4 (Sentence-Completion Quiz)** behind a FunWithFlags flag. This tests the contextual learning thesis with existing ExampleSentence data.

4. **Share progress on HN** (Show HN update post or follow-up in original thread). The community has already engaged -- leverage that relationship for Phase 3 feedback.

5. **After H6 + H4 results**: Decide whether to pursue H1 (Graded Reading Passages) as the bridge-to-reading feature. This is the most ambitious and differentiating opportunity but also the highest effort.

### What NOT to build yet

- Social features (no validated demand, high complexity)
- Gamification beyond SRS (no evidence of need)
- Mobile native app (web with mobile improvements is sufficient for now)
- Business/professional kanji modules (no direct user validation)
- AI-driven personalization (premature optimization)

---

## Discovery State Summary

```yaml
current_phase: "4 (complete with caveats)"
discovery_started: "2026-03-11"
evidence_sources:
  - "HN feedback: 20+ substantive comments"
  - "Demographics research: docs/demographics.md"
  - "Competitive analysis: WaniKani, Anki, Kanji Study, Bunpro, Renshuu"
  - "Codebase review: docs/research/project-review.md"
  - "Market analysis: docs/opportunities.md"
  - "Underserved segments: docs/underserved-demos.md"
assumptions_tracked: 10 (A1-A10)
opportunities_identified: 10 (O1-O10)
top_opportunities:
  - "O5: Bridge to Real Reading (17)"
  - "O1: Contextual Learning (16)"
  - "O2: Teach-Then-Test (15)"
hypotheses_designed: 7 (H1-H7)
hypotheses_tested: 0
decision_gates:
  G1: "PASSED -- 20+ signals, >60% problem confirmation"
  G2: "PASSED -- 10 opportunities, top 3 score 15-17"
  G3: "NOT STARTED -- hypotheses designed, testing pending"
  G4: "CONDITIONAL PASS -- canvas complete, risks acceptable, Phase 3 pending"
artifacts_created:
  - "docs/feature/kuma-san-kanji/discover/problem-validation.md"
  - "docs/feature/kuma-san-kanji/discover/opportunity-tree.md"
  - "docs/feature/kuma-san-kanji/discover/solution-testing.md"
  - "docs/feature/kuma-san-kanji/discover/lean-canvas.md"
```
