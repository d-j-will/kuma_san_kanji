# Prioritization: Grade 1 Thematic Learning Path

## Release Priority

| Priority | Release | Target Outcome | KPI | Rationale |
|----------|---------|---------------|-----|-----------|
| 1 | Walking Skeleton (R1) | Learner can study-then-quiz within a thematic group | >60% first-attempt accuracy on taught kanji | Validates H6 (teach-before-test hypothesis) -- the core value proposition. All data infrastructure exists. |
| 2 | Content Completeness (R3) | All 80 Grade 1 kanji available in learning path | 10/10 groups populated with correct kanji | Without full content, the learning path is incomplete. Data work can run in parallel with R1. |
| 3 | Polish and Navigation (R2) | Learner navigates fluidly with enriched teach step | >40% session continuation rate | Enriches the experience proven in R1. Stroke order and tips add depth. |

### Why R3 before R2 in execution

Even though R2 (polish) has a higher story map position, R3 (content seeding) should be prioritized alongside R1 because:

- R1 UI works but shows incomplete groups without R3 data
- R3 is independent data work that can proceed in parallel
- R2 polish is only valuable once the content is complete enough for real use

**Recommended parallel tracks**: R1 (UI) + R3 (data) simultaneously, then R2 (polish).

---

## Backlog Suggestions

| Story | Release | Priority | Outcome Link | Dependencies | Effort |
|-------|---------|----------|-------------|--------------|--------|
| US-01: Browse thematic groups | R1 (WS) | P1 | Activation: learner enters a group | None | 1-2 days |
| US-02: Teach step for a kanji | R1 (WS) | P1 | Engagement: learner studies before quiz | US-01 | 1-2 days |
| US-03: Mark kanji as learned | R1 (WS) | P1 | Transition: learn-to-quiz bridge | US-02 | 0.5-1 day |
| US-04: Group-scoped quiz | R1 (WS) | P1 | Accuracy: first-attempt correct rate | US-03 | 1-2 days |
| US-05: Group progress view | R1 (WS) | P1 | Retention: continue to next kanji | US-04 | 1 day |
| US-11: Seed all 80 kanji | R3 | P1 | Content: full curriculum available | None | 2 days |
| US-12: Seed thematic assignments | R3 | P1 | Content: groups populated | US-11 | 1 day |
| US-13: Seed learning metadata | R3 | P2 | Enrichment: tips available | US-11 | 2 days |
| US-06: Navigate within group | R2 | P2 | Navigation: browse without friction | US-02 | 1 day |
| US-07: Stroke order in teach step | R2 | P2 | Depth: visual learning aid | US-02 | 1 day |
| US-08: Learning tips display | R2 | P2 | Depth: mnemonic support | US-02, US-13 | 0.5 day |
| US-09: Overall progress on /learn | R2 | P2 | Motivation: see total progress | US-01, US-05 | 0.5 day |
| US-10: Review learned quiz mode | R2 | P3 | Retention: revisit mastered kanji | US-04 | 1 day |

> **Note**: Story IDs (US-01 through US-13) are assigned in the DISCUSS wave. These are stable identifiers for handoff to DESIGN.

---

## Value / Effort Matrix

|  | Low Effort (< 1 day) | Medium Effort (1-2 days) | High Effort (2+ days) |
|--|----------------------|--------------------------|----------------------|
| **High Value** | US-03 (mark learned), US-08 (tips), US-09 (overall progress) | US-01 (browse groups), US-02 (teach step), US-04 (scoped quiz), US-05 (group progress) | US-11 (seed kanji) |
| **Medium Value** | US-06 (navigate), US-07 (stroke order) | US-12 (seed assignments), US-13 (seed metadata) | |
| **Low Value** | | US-10 (review mode) | |

**Quick wins** (high value, low effort): US-03, US-08, US-09 -- these should be combined with their parent stories to avoid overhead of separate deployments.

---

## Riskiest Assumptions

| Rank | Assumption | Risk if Wrong | How R1 Tests It |
|------|-----------|---------------|-----------------|
| 1 | A teach step before quiz improves first-attempt accuracy | Core value proposition fails -- app remains "just a quiz tool" | Compare first-attempt accuracy for taught kanji (R1) vs untaught kanji (existing quiz) |
| 2 | Learners will complete groups rather than cherry-pick individual kanji | Group structure is wasted effort | Track group completion rates vs abandonment |
| 3 | Thematic grouping helps retention more than random order | Grouping adds complexity without benefit | Measure retention at 7-day review for group-learned vs existing quiz |
