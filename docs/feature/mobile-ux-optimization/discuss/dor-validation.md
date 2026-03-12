# Definition of Ready Validation: Mobile UX Optimization

## US-MOB-01: Mobile App Shell

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Desktop-oriented layout with min-h-screen, top navbar wastes space, pb-32 pushes content offscreen" -- specific, domain language |
| User/persona identified | PASS | Yuki Tanaka, 28yo developer, iPhone 14, one-handed commute use |
| 3+ domain examples | PASS | iPhone 14 portrait (390x844), iPhone SE (375x667), iPad landscape -- 3 distinct scenarios |
| UAT scenarios (3-7) | PASS | 4 scenarios: dynamic viewport, browser chrome, small viewport, CSS Grid layout |
| AC derived from UAT | PASS | 5 AC items derived directly from scenario outcomes |
| Right-sized | PASS | 1-2 days effort, 4 scenarios, single layout change |
| Technical notes | PASS | root.html.heex, 100dvh browser support, LiveView flash coexistence, feature flag |
| Dependencies tracked | PASS | No dependencies (foundation story) |
| Outcome KPIs defined | PASS | KPI #1 (session completion), KPI #8 (TTI) |

### DoR Status: PASSED

---

## US-MOB-02: Bottom Tab Navigation

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Top navbar in hardest-to-reach zone, thumb stretch, drops phone" -- specific pain |
| User/persona identified | PASS | Yuki Tanaka, one-handed phone use on crowded train |
| 3+ domain examples | PASS | Yuki Learn-to-Explore, Kenji quiz-to-Profile, Yuki Explore-to-Quiz -- 3 real scenarios |
| UAT scenarios (3-7) | PASS | 5 scenarios: render, active tab, desktop hidden, target sizes, persistence |
| AC derived from UAT | PASS | 7 AC items covering each scenario outcome |
| Right-sized | PASS | 2-3 days effort, 5 scenarios, single component |
| Technical notes | PASS | app.html.heex, LiveView navigation integration, route matching, feature flag |
| Dependencies tracked | PASS | Depends on US-MOB-01 (app shell) |
| Outcome KPIs defined | PASS | KPI #3 (tab navigation adoption > 90%) |

### DoR Status: PASSED

---

## US-MOB-03: Safe Area Insets

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Bottom tab overlaps home indicator, top clipped by notch/Dynamic Island" |
| User/persona identified | PASS | Yuki on iPhone 14 (notch), Kenji on iPhone 15 Pro (Dynamic Island) |
| 3+ domain examples | PASS | iPhone 14 (notch + home), iPhone 15 Pro (Dynamic Island), Android (no notch) |
| UAT scenarios (3-7) | PASS | 3 scenarios: iPhone safe area, viewport meta, non-notched devices |
| AC derived from UAT | PASS | 5 AC items derived from scenarios |
| Right-sized | PASS | 1 day effort, 3 scenarios, CSS + meta tag change |
| Technical notes | PASS | root.html.heex, env() CSS, viewport-fit=cover, Tailwind custom utilities |
| Dependencies tracked | PASS | Depends on US-MOB-01 (app shell) |
| Outcome KPIs defined | PASS | KPI #4 (mis-tap rate < 5%) |

### DoR Status: PASSED

---

## US-MOB-04: Mobile Learn Dashboard

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Stats text small, Start Review link tiny, cards feel cramped on bumpy train" |
| User/persona identified | PASS | Yuki Tanaka, quick glance at progress during commute |
| 3+ domain examples | PASS | Yuki checks progress (32/80), Kenji no reviews (0 due), Yuki taps card (touch target) |
| UAT scenarios (3-7) | PASS | 4 scenarios: stats readability, touch-friendly cards, fit without scroll, empty state |
| AC derived from UAT | PASS | 6 AC items derived from scenarios |
| Right-sized | PASS | 1-2 days effort, 4 scenarios, single page adjustment |
| Technical notes | PASS | learn_live.ex, responsive Tailwind classes, feature flag |
| Dependencies tracked | PASS | Depends on US-MOB-01, US-MOB-02 |
| Outcome KPIs defined | PASS | KPI #1 (session completion), time to first tap under 5s |

### DoR Status: PASSED

---

## US-MOB-05: Touch-Friendly Kanji Grid

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Characters at text-2xl (24px) too small, grid cells small targets, taps wrong kanji on bumpy train" |
| User/persona identified | PASS | Yuki, selecting kanji from grid on moving train |
| 3+ domain examples | PASS | Yuki selects from Nature grid, Kenji identifies learned kanji, Yuki navigates to unlearned |
| UAT scenarios (3-7) | PASS | 4 scenarios: character sizing, cell targets, learned indicators, continue button |
| AC derived from UAT | PASS | 6 AC items derived from scenarios |
| Right-sized | PASS | 1 day effort, 4 scenarios, CSS sizing changes |
| Technical notes | PASS | group_live.ex, font size and padding adjustments, feature flag |
| Dependencies tracked | PASS | Depends on US-MOB-01 |
| Outcome KPIs defined | PASS | KPI #4 (mis-tap rate < 5%) |

### DoR Status: PASSED

---

## US-MOB-06: Mobile Teach Page

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Tab indicators small, Back/Next buttons not optimized for thumb, cannot swipe like native app" |
| User/persona identified | PASS | Yuki, studying individual kanji during commute, one-handed |
| 3+ domain examples | PASS | Yuki on Character tab, Yuki advances Meaning-to-Readings, Yuki on last tab quiz CTA |
| UAT scenarios (3-7) | PASS | 5 scenarios: kanji size, tab targets, button sizing, quiz CTA, prev/next arrows |
| AC derived from UAT | PASS | 7 AC items derived from scenarios |
| Right-sized | PASS | 2 days effort, 5 scenarios, single page |
| Technical notes | PASS | teach_live.ex, Tailwind responsive classes, feature flag |
| Dependencies tracked | PASS | Depends on US-MOB-01 |
| Outcome KPIs defined | PASS | KPI #6 (tab completion > 85%) |

### DoR Status: PASSED

---

## US-MOB-07: Mobile Quiz Experience

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "iOS Safari zooms on input tap because font < 16px, submit button not full-width, frustrating on train" |
| User/persona identified | PASS | Yuki, taking quiz with virtual keyboard on moving train |
| 3+ domain examples | PASS | Yuki correct answer, Kenji incorrect answer, Yuki keyboard covers input |
| UAT scenarios (3-7) | PASS | 5 scenarios: no iOS zoom, kanji size, submit button, feedback card, keyboard visibility |
| AC derived from UAT | PASS | 7 AC items derived from scenarios |
| Right-sized | PASS | 2 days effort, 5 scenarios, single page |
| Technical notes | PASS | group_quiz_live.ex, font-size fix, scrollIntoView JS, feature flag |
| Dependencies tracked | PASS | Depends on US-MOB-01 |
| Outcome KPIs defined | PASS | KPI #2 (zero iOS zoom events) |

### DoR Status: PASSED

---

## US-MOB-08: Mobile Quiz Results

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Buttons not full-width, results table overflows horizontally on 390px screen" |
| User/persona identified | PASS | Yuki reviewing quiz performance on mobile |
| 3+ domain examples | PASS | Yuki 86% result, Kenji 100% (no mistakes), Yuki scrolls results table |
| UAT scenarios (3-7) | PASS | 4 scenarios: accuracy display, stacked buttons, no review on perfect, scrollable table |
| AC derived from UAT | PASS | 5 AC items derived from scenarios |
| Right-sized | PASS | 1 day effort, 4 scenarios, CSS adjustments |
| Technical notes | PASS | group_quiz_live.ex quiz_summary, flex/width adjustments, feature flag |
| Dependencies tracked | PASS | Depends on US-MOB-07 |
| Outcome KPIs defined | PASS | KPI #1, post-quiz action rate > 80% |

### DoR Status: PASSED

---

## US-MOB-09: Swipe Tab Navigation

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Swipe does nothing, has to tap small targets, feels web-clunky vs native" |
| User/persona identified | PASS | Yuki, expects native-like swipe gestures from Duolingo/Anki experience |
| 3+ domain examples | PASS | Swipe left to advance, swipe right to retreat, swipe on boundary (last tab) |
| UAT scenarios (3-7) | PASS | 5 scenarios: swipe left, swipe right, first boundary, last boundary, coexistence with tap |
| AC derived from UAT | PASS | 7 AC items including distance threshold, scroll non-interference |
| Right-sized | PASS | 2 days effort, 5 scenarios, JS hook + LiveView integration |
| Technical notes | PASS | New JS hook, touch event listeners, push_event to LiveView, feature flag |
| Dependencies tracked | PASS | Depends on US-MOB-06 (teach page mobile) |
| Outcome KPIs defined | PASS | Swipe adoption > 40% of tab navigations |

### DoR Status: PASSED

---

## US-MOB-10: Explore Accordion Sections

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "All info at once, 3-4 screen-heights of scrolling, just wants character and meaning" |
| User/persona identified | PASS | Yuki, casual kanji browsing on mobile |
| 3+ domain examples | PASS | Yuki checks only meaning, Yuki expands Pronunciations, Kenji expands Notes |
| UAT scenarios (3-7) | PASS | 5 scenarios: primary always visible, collapsed default, expand on tap, touch targets, reset on new kanji |
| AC derived from UAT | PASS | 7 AC items including desktop pass-through behavior |
| Right-sized | PASS | 2-3 days effort, 5 scenarios, explore page restructure |
| Technical notes | PASS | explore_live.ex/heex, details/summary or assigns, desktop skip, feature flag |
| Dependencies tracked | PASS | Depends on US-MOB-01 |
| Outcome KPIs defined | PASS | KPI #7 (scroll depth -50%) |

### DoR Status: PASSED

---

## US-MOB-11: Mobile Typography and Readability

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Some text < 16px, inconsistent line heights, long lines exceed 30-40 char mobile optimum" |
| User/persona identified | PASS | Yuki reading on a bumpy train at arm's length |
| 3+ domain examples | PASS | Learning tip on Meaning tab, example sentences with furigana, quiz feedback card |
| UAT scenarios (3-7) | PASS | 3 scenarios: minimum size, line length, kanji hierarchy |
| AC derived from UAT | PASS | 6 AC items covering typography, line length, kanji sizing hierarchy |
| Right-sized | PASS | 1-2 days effort, 3 scenarios, CSS adjustments across pages |
| Technical notes | PASS | Tailwind @apply or custom CSS, ruby annotations, max-w-prose, feature flag |
| Dependencies tracked | PASS | Depends on US-MOB-01 |
| Outcome KPIs defined | PASS | KPI #5 (zero pinch-to-zoom) |

### DoR Status: PASSED

---

## US-MOB-12: Mobile Performance Optimization

| DoR Item | Status | Evidence/Issue |
|----------|--------|----------------|
| Problem statement clear | PASS | "Slow load on 3G, blank areas during load, scroll jank with many DOM elements" |
| User/persona identified | PASS | Yuki on variable connection during commute |
| 3+ domain examples | PASS | 3G dashboard load (skeleton), explore scroll (content-visibility), Kenji reduce motion |
| UAT scenarios (3-7) | PASS | 4 scenarios: skeleton loading, content-visibility, reduced motion, overscroll |
| AC derived from UAT | PASS | 6 AC items derived from scenarios |
| Right-sized | PASS | 2 days effort, 4 scenarios, CSS + optional JS changes |
| Technical notes | PASS | CSS-only for most changes, LiveView loading states, content-visibility layout shift risk |
| Dependencies tracked | PASS | Depends on US-MOB-01 |
| Outcome KPIs defined | PASS | KPI #8 (TTI < 3s on 3G) |

### DoR Status: PASSED

---

## Summary

| Story | DoR Status | Items Passed | Items Failed |
|-------|-----------|-------------|-------------|
| US-MOB-01: Mobile App Shell | PASSED | 9/9 | 0 |
| US-MOB-02: Bottom Tab Navigation | PASSED | 9/9 | 0 |
| US-MOB-03: Safe Area Insets | PASSED | 9/9 | 0 |
| US-MOB-04: Mobile Learn Dashboard | PASSED | 9/9 | 0 |
| US-MOB-05: Touch-Friendly Kanji Grid | PASSED | 9/9 | 0 |
| US-MOB-06: Mobile Teach Page | PASSED | 9/9 | 0 |
| US-MOB-07: Mobile Quiz Experience | PASSED | 9/9 | 0 |
| US-MOB-08: Mobile Quiz Results | PASSED | 9/9 | 0 |
| US-MOB-09: Swipe Tab Navigation | PASSED | 9/9 | 0 |
| US-MOB-10: Explore Accordion Sections | PASSED | 9/9 | 0 |
| US-MOB-11: Mobile Typography & Readability | PASSED | 9/9 | 0 |
| US-MOB-12: Mobile Performance Optimization | PASSED | 9/9 | 0 |

All 12 stories pass the 9-item Definition of Ready gate. Ready for DESIGN wave handoff.
