# Outcome KPIs: Grade 1 Thematic Learning Path

## Objective

Learners feel prepared before being tested and build lasting kanji recall through a structured, contextual learning flow -- moving from "tested on things I wasn't taught" to "I studied this and I know it."

---

## Outcome KPIs

| # | Who | Does What | By How Much | Baseline | Measured By | Type |
|---|-----|-----------|-------------|----------|-------------|------|
| 1 | Learners who visit /learn | Click into a thematic group (activation) | >60% within first session | N/A (new feature) | LiveView event: group card click | Leading |
| 2 | Learners in teach step | Mark kanji as "learned" rather than skipping | >80% learned vs <20% skipped | N/A (new feature) | LiveView events: "learned" vs "skip" buttons | Leading |
| 3 | Learners who complete teach step | Answer correctly on first quiz attempt | >60% first-attempt accuracy | Measure current first-attempt rate in existing QuizLive | SRS record_review result where repetitions == 0 | Leading (primary) |
| 4 | Learners who finish a quiz session | Click "Continue Learning" to study next kanji | >40% immediate continuation | N/A (new feature) | LiveView event: "Continue Learning" click after quiz | Leading |
| 5 | Learners with 7+ days of use | Retain kanji learned through teach step at 7-day review | >70% correct at 7-day interval | Measure 7-day retention in existing SRS for comparison | SRS record_review result where interval >= 7 | Leading |

---

## Metric Hierarchy

- **North Star**: KPI #3 -- First-attempt quiz accuracy for taught kanji. This directly measures whether the teach step works. If learners answer correctly after studying, the core hypothesis (H6) is validated.
- **Leading Indicators**: KPI #1 (activation), KPI #2 (teach step engagement), KPI #4 (session continuation)
- **Guardrail Metrics**:
  - Existing quiz completion rate must not decrease (learning path should complement, not cannibalize)
  - Page load time for /learn and teach step must stay under 500ms (LiveView render)
  - No increase in sign-out rate or bounce rate from existing pages

---

## Measurement Plan

| KPI | Data Source | Collection Method | Frequency | Owner |
|-----|------------|-------------------|-----------|-------|
| #1 Activation | LiveView socket events | Track `phx-click` on group cards, log to telemetry | Per session | Developer (telemetry module) |
| #2 Teach engagement | LiveView socket events | Track "learned" vs "skip" button clicks, log to telemetry | Per event | Developer (telemetry module) |
| #3 First-attempt accuracy | UserKanjiProgress records | Query records where `total_reviews == 1`, calculate correct rate | Weekly | Developer (admin dashboard query) |
| #4 Continuation rate | LiveView socket events | Track "Continue Learning" clicks after quiz-to-group-page transition | Per session | Developer (telemetry module) |
| #5 7-day retention | UserKanjiProgress records | Query records where `interval >= 7` and `last_result`, calculate correct rate | Weekly | Developer (admin dashboard query) |
| Guardrail: quiz completion | Existing QuizLive telemetry | Monitor existing quiz session completion rate for regression | Weekly | Developer |
| Guardrail: page load | Phoenix.LiveDashboard | Monitor LiveView mount times for /learn routes | Continuous | Existing infrastructure |

---

## Hypothesis

We believe that providing a **teach step before quiz** (showing meaning, readings, and example sentences) for **Grade 1 kanji learners** will achieve **higher first-attempt quiz accuracy and better 7-day retention** compared to the current quiz-only approach.

We will know this is true when learners who study kanji through the teach step **answer correctly on first attempt >60% of the time** (KPI #3) and **retain kanji at 7-day review >70% of the time** (KPI #5).

We will know this is false when first-attempt accuracy is statistically equivalent to the existing quiz (no teach step) or when >50% of learners skip the teach step entirely.
