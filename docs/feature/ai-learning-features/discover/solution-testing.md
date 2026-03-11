# Solution Testing -- AI Learning Features for Kuma San Kanji

**Phase**: 3 -- Solution Testing
**Status**: Hypotheses Designed with Feasibility Spikes Defined
**Date**: 2026-03-11
**Feature ID**: ai-learning-features
**Evidence Sources**: Phase 2 AI opportunity scores, prior general discovery hypotheses, codebase capabilities, competitive analysis, AI model capability research
**Relationship to Prior Discovery**: These hypotheses extend the general discovery's H1-H7 with AI-specific solution approaches. The general discovery's H6 (First Encounter Learning Flow) remains the highest-priority non-AI hypothesis and should be built BEFORE these AI features.

---

## Overview

This document defines testable hypotheses for the top 3 AI opportunities identified in Phase 2. Each hypothesis includes:
1. The hypothesis statement (what we believe, how we will know)
2. A feasibility spike (can the AI approach actually work for Japanese?)
3. A cost model (can a free product afford this?)
4. A privacy assessment (will the HN audience accept this?)
5. Experiment design (smallest testable thing)

**Critical Sequencing**: The non-AI foundations must be built first. AI augments the core learning experience -- it does not replace it.

```
Priority Order:
1. H6: First Encounter Learning Flow (NO AI -- from general discovery)
2. H4: Sentence-Completion Quiz (NO AI -- from general discovery)
3. AH1: AI Mnemonic Generation (AI augments H6 teaching step)
4. AH2: AI Example Sentence Generation (AI augments H4 sentence data)
5. AH3: AI i+1 Reading Passages (AI-native feature, highest value but highest risk)
```

---

## AI Opportunity 1: AI-Generated i+1 Reading Passages (AO1, Score: 16)

### Hypothesis AH3: AI-Generated Personalized Reading Passages

```
We believe that generating short reading passages (3-5 sentences) using an LLM,
constrained to use only kanji from the learner's mastered set plus exactly one new
kanji with furigana, will bridge the gap from flashcard recall to reading
comprehension for intermediate learners.

We will know this is TRUE when:
- The feasibility spike demonstrates >90% kanji constraint adherence
  (generated text uses only specified kanji)
- >80% of test users attempt to read at least one passage per session
- >60% of test users report passages feel "natural" or "readable"
  (not "robotic" or "AI slop")
- Users spend >2 minutes engaged with passages (not bouncing)
- A Japanese speaker rates >80% of generated passages as grammatically
  correct and natural-sounding

We will know this is FALSE when:
- Kanji constraint adherence is <80% (LLM ignores kanji restrictions)
- Users report passages feel "unnatural" or "machine-generated"
- A Japanese speaker identifies >30% of passages as containing errors
- Users prefer no reading content over AI-generated reading content
- API costs exceed $0.05 per passage at batch generation rates
```

### Feasibility Spike: Japanese Text Generation with Kanji Constraints

**Objective**: Determine if current LLMs can generate natural Japanese text while adhering to strict kanji constraints.

**Spike Design**:
1. Select a test set: 20 kanji from JLPT N5 / Grade 1 (e.g., 日月火水木金土山川田)
2. Prompt an LLM with: "Generate a 3-sentence passage in Japanese using ONLY these kanji: [list]. Use hiragana for all other words. Include exactly one additional kanji [新] with furigana."
3. Evaluate 20 generated passages for:
   - Kanji constraint adherence (automated check: does the text contain only allowed kanji?)
   - Grammatical correctness (manual review or second LLM evaluation)
   - Naturalness rating (1-5 scale, by a Japanese speaker or advanced learner)
   - Content coherence (does it read like a real passage, not random sentences?)

**Models to Test**:
| Model | Cost (per 1K tokens output) | Japanese Quality (estimated) | Constraint Following |
|-------|----------------------------|------------------------------|---------------------|
| Claude Haiku | ~$0.001 | Good | Good for structured constraints |
| GPT-4o-mini | ~$0.0006 | Good | Good |
| Claude Sonnet | ~$0.015 | Very good | Very good |
| Gemini Flash | ~$0.0004 | Good | Moderate |
| Local model (Llama 3) | ~$0 (compute cost) | Moderate for Japanese | Moderate |

**Cost Model for Batch Generation**:
- 80 Grade 1 kanji, 5 passages per kanji = 400 passages
- Average passage: ~100 tokens output, ~200 tokens input
- At GPT-4o-mini rates: 400 x $0.0002 = ~$0.08 total for all Grade 1 content
- At Claude Haiku rates: 400 x $0.0003 = ~$0.12 total
- **Conclusion**: Batch pre-generation is extraordinarily cheap. The cost concern is only relevant for real-time per-request generation.

**Privacy Model**:
- Batch generation: NO user data sent to AI API. Passages are generated from kanji lists, not user profiles.
- Per-user generation: User's mastered kanji list sent to API. This is a privacy concern for the HN audience.
- **Recommendation**: Start with batch generation (zero privacy concern). Only consider per-user generation if batch approach is insufficient.

### Experiment Design

**Smallest Testable Thing**: Generate 20 passages manually using an LLM (no code needed), share with 5+ kanji learners, collect feedback on naturalness and utility.

**Week 1 Experiment**:
1. Using a kanji list of 20 common Grade 1 kanji, prompt Claude/GPT to generate 20 reading passages
2. Manually verify kanji constraints (does each passage use only allowed kanji?)
3. Have a Japanese speaker (or advanced learner) rate each passage for naturalness
4. Share passages with 5+ learners from the HN community that already engaged
5. Collect: engagement (did they read it?), naturalness (did it feel real?), value (did they learn anything?)

**Week 2 (if Week 1 passes)**:
1. Build a minimal Elixir script that calls an LLM API with kanji constraints
2. Generate passages for all 80 Grade 1 kanji
3. Automated kanji constraint verification (regex check against allowed kanji list)
4. Store in Content domain (new association: ReadingPassage belongs_to ThematicGroup)
5. Display behind FunWithFlags flag in a new "Read" tab

**Risks to Address**:
| Risk | Level | Mitigation |
|------|-------|-----------|
| Value: will users read AI passages? | High | Test with manual passages first before building infrastructure |
| Usability: can users navigate a reading interface? | Medium | Simple UI -- passage + furigana toggle + "I know this kanji" button |
| Feasibility: can LLM follow kanji constraints? | Critical | Spike MUST pass before any implementation |
| Viability: API cost for free product | Low (batch) / High (real-time) | Batch pre-generation eliminates per-request cost |
| Trust: will users accept AI-generated learning content? | High | Label as "AI-generated", allow flagging, manual review of samples |

---

## AI Opportunity 2: AI Mnemonic Generation (AO2, Score: 12)

### Hypothesis AH1: AI-Generated Radical-Based Mnemonics

```
We believe that generating mnemonics from radical decomposition data using an LLM
(e.g., 休 = person 亻 + tree 木 = "a person resting against a tree") will help
beginners remember kanji meanings more effectively than encountering the kanji
without a mnemonic.

We will know this is TRUE when:
- >70% of test users find AI-generated mnemonics "helpful" or "memorable"
- 7-day retention rate for kanji learned with mnemonics exceeds kanji without
  (measured via SRS review accuracy)
- Users voluntarily read mnemonics (>60% click/expand rate)
- A Japanese language educator rates >80% of generated mnemonics as
  "accurate" (mnemonic reflects actual meaning, not misleading)

We will know this is FALSE when:
- Users say mnemonics are "confusing" or "don't make sense"
- Mnemonics contain factual errors about kanji meaning or radical composition
- Users skip mnemonics >50% of the time
- No retention difference at 7-day review between mnemonic and non-mnemonic kanji
- WaniKani users say "these are just worse versions of WaniKani mnemonics"
```

### Feasibility Spike: Mnemonic Generation Quality

**Objective**: Determine if LLMs can generate memorable, accurate kanji mnemonics from radical decomposition data.

**Spike Design**:
1. Select 20 Grade 1 kanji with clear radical decomposition
2. For each, provide the LLM with: kanji character, meaning, radical components with their meanings
3. Prompt: "Generate a memorable visual mnemonic for this kanji using its radical components. The mnemonic should be a short, vivid image or story (1-2 sentences) that connects the radicals to the kanji's meaning."
4. Evaluate:
   - Accuracy: does the mnemonic correctly represent the kanji meaning? (binary: yes/no)
   - Memorability: would this help a beginner remember? (1-5 scale)
   - Cultural sensitivity: nothing offensive or misleading about Japanese culture (binary)
   - Differentiation from WaniKani: is it sufficiently different to avoid "worse copy" perception?

**Test Cases**:
| Kanji | Meaning | Radicals | Expected Mnemonic Pattern |
|-------|---------|----------|--------------------------|
| 休 | rest | 亻(person) + 木(tree) | Person leaning against a tree to rest |
| 明 | bright | 日(sun) + 月(moon) | Sun AND moon together = very bright |
| 森 | forest | 木(tree) x 3 | Three trees make a forest |
| 岩 | rock | 山(mountain) + 石(stone) | A stone on a mountain = a big rock |
| 男 | man | 田(rice field) + 力(power) | Power in the rice field = the man |

**Cost Model**:
- 2,136 jouyou kanji, 1 mnemonic each = 2,136 API calls
- Average: ~50 tokens output, ~100 tokens input per mnemonic
- At GPT-4o-mini rates: 2,136 x $0.00005 = ~$0.11 total
- At Claude Haiku rates: 2,136 x $0.00008 = ~$0.17 total
- **Conclusion**: Generating mnemonics for ALL kanji costs less than $0.20. This is a one-time batch operation with trivial cost.

**Privacy Model**: No user data involved. Mnemonics are generated from kanji/radical data, not user behavior. Zero privacy concern.

### Experiment Design

**Smallest Testable Thing**: Generate 20 mnemonics using an LLM prompt, display them alongside kanji on the Explore page, measure engagement.

**Week 1 Experiment**:
1. Generate mnemonics for the 20 most common Grade 1 kanji using Claude/GPT
2. Manually review each for accuracy and memorability
3. Add a "Mnemonic" section to the Explore page (behind FunWithFlags flag)
4. Measure: click/expand rate, time on mnemonic, user feedback

**Week 2 (if Week 1 passes)**:
1. Generate mnemonics for all 80 Grade 1 kanji
2. Store in a new KanjiMnemonic resource in the Content domain
3. A/B test: users with mnemonics vs. without, measure 7-day SRS retention
4. Collect qualitative feedback: "Was this mnemonic helpful?" (yes/no/confusing)

**Risks to Address**:
| Risk | Level | Mitigation |
|------|-------|-----------|
| Value: will users engage with mnemonics? | Medium | WaniKani proves the model works; test engagement rate |
| Usability: how to present without overwhelming? | Low | Collapsible section on Explore page |
| Feasibility: can LLM generate good mnemonics? | Medium | Spike with 20 kanji before scaling |
| Quality: will mnemonics be accurate? | High | Manual review of batch output; flag incorrect ones |
| Differentiation: "just a worse WaniKani" | Medium | Focus on visual/spatial mnemonics (different style) |

---

## AI Opportunity 3: AI-Generated Example Sentences (AO3, Score: 9)

### Hypothesis AH2: AI-Generated Contextual and Disambiguation Sentences

```
We believe that using an LLM to generate additional example sentences -- especially
contrastive pairs for confusable kanji (e.g., 辺 vs 面積 for "area") -- will
improve meaning discrimination and enrich the sentence-completion quiz experience.

We will know this is TRUE when:
- Error rate on ambiguous kanji (those sharing English glosses) decreases >20%
  after exposure to disambiguation sentences
- >70% of users who view contrastive pairs can correctly choose between
  related kanji in a follow-up test
- AI-generated sentences are indistinguishable from curated sentences in a
  blind quality test (>60% cannot tell the difference)
- ExampleSentence coverage increases from current levels to >5 sentences
  per kanji for all Grade 1 kanji

We will know this is FALSE when:
- AI-generated sentences contain grammatical errors detected by review
- Users report AI sentences are "weird" or "unnatural"
- No improvement in disambiguation accuracy after exposure
- Quality reviewers can identify AI sentences >80% of the time (uncanny valley)
```

### Feasibility Spike: Japanese Example Sentence Generation

**Objective**: Determine if LLMs can generate pedagogically appropriate Japanese example sentences at controlled difficulty levels.

**Spike Design**:
1. Select 10 kanji with known disambiguation problems (pairs sharing English glosses)
2. For each pair, prompt the LLM: "Generate 3 example sentences for [kanji] that clearly demonstrate its specific meaning of [specific meaning], distinguishing it from [confusable kanji] which means [other specific meaning]. Sentences should use only JLPT N5 grammar and vocabulary."
3. Evaluate:
   - Grammatical correctness (Japanese speaker review)
   - Level-appropriateness (does it use only N5-level grammar?)
   - Disambiguation clarity (does the sentence clearly show WHY this kanji, not the other?)
   - Naturalness (would a Japanese person actually say/write this?)

**Disambiguation Test Cases**:
| Kanji A | Kanji B | Shared English Gloss | Distinction |
|---------|---------|---------------------|-------------|
| 辺 | 面積 | area | 辺 = vicinity/side; 面積 = surface area (measurement) |
| 見る | 観る | see/watch | 見る = general seeing; 観る = watching attentively (performance/show) |
| 聞く | 聴く | listen/hear | 聞く = general hearing; 聴く = active/attentive listening |
| 上がる | 上げる | raise/go up | 上がる = intransitive (it goes up); 上げる = transitive (I raise it) |

**Cost Model**:
- 80 Grade 1 kanji, average 3 additional sentences each = 240 sentences
- Average: ~80 tokens output, ~150 tokens input per sentence
- At GPT-4o-mini rates: ~$0.04 total
- **Conclusion**: Trivial cost for batch generation.

**Privacy Model**: No user data involved. Sentences generated from kanji/meaning data. Zero privacy concern.

### Experiment Design

**Smallest Testable Thing**: Generate 30 example sentences (3 per kanji for 10 disambiguation pairs), have a Japanese speaker review, insert into ExampleSentence table.

**Week 1 Experiment**:
1. Generate disambiguation sentences for 10 confusable kanji pairs
2. Japanese speaker reviews for accuracy (or post in r/LearnJapanese for community review)
3. Insert passing sentences into ExampleSentence table (tagged as AI-generated via metadata)
4. Enable in sentence-completion quiz (H4) behind FunWithFlags flag

**Week 2 (if Week 1 passes)**:
1. Generate 3 additional sentences for every Grade 1 kanji with <3 existing sentences
2. Quality gate: automated grammar check + sample manual review
3. Measure quiz performance: do users with AI-generated disambiguation sentences perform better on confusable pairs?

**Risks to Address**:
| Risk | Level | Mitigation |
|------|-------|-----------|
| Value: do additional sentences improve learning? | Medium | Measure disambiguation accuracy improvement |
| Feasibility: can LLM generate level-appropriate sentences? | Medium | Constrain to N5 grammar; verify with review |
| Quality: will sentences be natural? | High | Japanese speaker review; blind test vs curated |
| Trust: will users trust AI-generated example sentences? | Medium | Label transparently; allow community flagging |
| Data integrity: AI sentences in same table as curated | Low | Metadata tag distinguishes source |

---

## Cross-Cutting Concerns

### API Provider Strategy

| Concern | Recommendation | Rationale |
|---------|---------------|-----------|
| Provider lock-in | Abstract behind a behavior/protocol module | Swap providers without changing calling code |
| Cost optimization | Batch pre-generate, cache in PostgreSQL | Eliminates per-request cost entirely |
| Latency | Pre-generated content has zero generation latency | Users never wait for AI |
| Quality control | Generate -> verify -> store pipeline | Never serve raw LLM output directly |
| Fallback | If AI content unavailable, fall back to existing curated content | Graceful degradation |

### Technical Architecture (Proposed)

```
KumaSanKanji.AI.ContentGenerator (behavior)
  |
  +-- KumaSanKanji.AI.Providers.Anthropic (implementation)
  +-- KumaSanKanji.AI.Providers.OpenAI (implementation)
  +-- KumaSanKanji.AI.Providers.Local (future: local model)
  |
  +-- KumaSanKanji.AI.Pipeline
        |
        +-- generate(prompt, constraints) -> raw_content
        +-- verify(raw_content, constraints) -> {pass, content} | {fail, reasons}
        +-- store(content, metadata) -> Content domain resource
```

**Key Design Decisions**:
1. All AI content is PRE-GENERATED in batch, not generated per-request
2. All AI content goes through a verification step before storage
3. All AI content is tagged with source metadata (provider, model, generation date)
4. All AI features are behind FunWithFlags flags
5. The AI module is a content pipeline, not a user-facing service

### Privacy Architecture

| Data Flow | User Data Sent to API? | Mitigation |
|-----------|----------------------|-----------|
| Mnemonic generation | NO -- input is kanji + radical data | None needed |
| Example sentence generation | NO -- input is kanji + meaning data | None needed |
| Reading passage generation (batch) | NO -- input is kanji list per level | None needed |
| Reading passage generation (personalized) | YES -- user's mastered kanji list | Defer; use batch approach first |

**Privacy Stance**: The batch pre-generation approach means ZERO user data is sent to any AI API. This is a strong privacy story for the HN audience: "We use AI to generate learning content, but your learning data never leaves our server."

---

## Testing Priority Order

Based on risk scores (highest risk tested first), feasibility, and dependency sequencing:

| Priority | Hypothesis | Rationale |
|----------|-----------|-----------|
| 0 (prerequisite) | H6: First Encounter Learning Flow (non-AI) | Must exist before AI can augment it; highest feasibility, addresses top complaint |
| 1 | AH1: AI Mnemonic Generation | Lowest risk (batch, no user data, cheap), augments H6, quick to test |
| 2 | AH2: AI Example Sentences | Low risk (batch, fills content gaps), augments H4, validates AI sentence quality |
| 3 | AH3: AI i+1 Reading Passages | Highest value but highest risk (kanji constraint adherence, naturalness); test after AH2 validates AI sentence quality for Japanese |

**Rationale for ordering AH1 before AH3**: AH1 (mnemonics) is simpler, cheaper, and lower risk. It tests whether the AI content pipeline works and whether users engage with AI-generated content. AH3 (reading passages) is the flagship feature but depends on validating that AI can generate quality Japanese (tested by AH2's sentence quality verification). Building AH1 first creates the technical infrastructure (AI provider module, batch pipeline, content storage) that AH3 requires.

---

## Gate G3 Evaluation

| Criterion | Target | Actual | Status |
|-----------|--------|--------|--------|
| Users tested | 5+ per iteration | 0 (pre-testing) | NOT YET STARTED |
| Task completion | >80% | N/A | NOT YET STARTED |
| Value perception | >70% "would use" | N/A | NOT YET STARTED |
| Key assumptions validated | >80% proven | 0/3 hypotheses tested | NOT YET STARTED |
| Feasibility spikes | All critical spikes pass | 0/3 spikes conducted | NOT YET STARTED |

### Decision: PENDING -- Hypotheses designed, feasibility spikes defined, testing not yet conducted

### Recommended Testing Plan

**Spike Week (before building anything)**:
- Day 1-2: Run feasibility spike for AH1 (mnemonic generation). Generate 20 mnemonics, review quality.
- Day 3-4: Run feasibility spike for AH2 (example sentences). Generate 30 disambiguation sentences, get Japanese review.
- Day 5: Run feasibility spike for AH3 (reading passages). Generate 10 constrained passages, verify kanji adherence.
- Spike gate: If any spike produces <70% quality rate, deprioritize that feature.

**Build Week 1 (if spikes pass)**:
- Build AI provider abstraction module (behavior + one implementation)
- Build batch generation pipeline (generate -> verify -> store)
- Generate and store mnemonics for 80 Grade 1 kanji
- Add mnemonic display to Explore page (behind flag)

**Build Week 2**:
- Generate disambiguation sentences for confusable kanji pairs
- Insert into ExampleSentence table (tagged as AI-generated)
- Test with 5+ users: engagement, quality perception, learning impact

**Build Week 3-4 (if Weeks 1-2 validate)**:
- Build reading passage generation with kanji constraints
- Implement automated kanji constraint verification
- Generate passages for Grade 1 kanji combinations
- Build minimal reading interface (behind flag)
- Test with 5+ users: engagement, naturalness, reading comprehension

### What "Testing" Means for This Project

Same pragmatic approach as the general discovery:
- Share AI-generated content with the HN community that already engaged
- Post examples in r/LearnJapanese for quality feedback from advanced learners
- Use FunWithFlags to A/B test AI-enhanced vs. standard features
- Measure actual usage data once features ship behind flags
- Target 5+ substantive feedback signals per hypothesis
- Feasibility spikes are internal technical tests, not user-facing

### Go/No-Go Decision Points

| Decision Point | Go Criteria | No-Go Criteria |
|---------------|-------------|----------------|
| After spikes | >70% quality rate on all 3 spikes | <50% quality rate on any spike |
| After AH1 (mnemonics) | >60% user engagement with mnemonics | <30% engagement; "confusing" feedback |
| After AH2 (sentences) | Sentences indistinguishable from curated in blind test | >50% identified as AI; errors found |
| After AH3 (passages) | >80% kanji constraint adherence; positive reading experience | <80% adherence; "unnatural" feedback |
| Overall AI feature suite | 2+ of 3 hypotheses validated | 0-1 validated; cost/quality concerns |
