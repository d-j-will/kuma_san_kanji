# Outcome KPIs: Mobile UX Optimization

## Feature: mobile-ux-optimization

### Objective

Mobile learners complete satisfying kanji study sessions on their phones with the same ease as on desktop, eliminating layout frustrations, touch target misses, and readability issues that currently degrade the mobile experience.

### Outcome KPIs

| # | Who | Does What | By How Much | Baseline | Measured By | Type |
|---|-----|-----------|-------------|----------|-------------|------|
| 1 | Mobile users (< 768px) | Complete a full study session (dashboard -> teach -> quiz -> results) | > 60% session completion rate | Unknown (no mobile tracking) | Analytics: session flow funnel on mobile | Leading |
| 2 | Mobile users on iOS | Complete quiz without triggering auto-zoom | Zero zoom events per session | Estimated 60%+ sessions trigger zoom (input < 16px) | Viewport scale change detection via JS | Leading |
| 3 | Mobile users | Navigate between sections using bottom tab bar | > 90% of inter-section navigation via tabs | 0% (no bottom nav exists) | Navigation event tracking (tab taps vs. other) | Leading |
| 4 | Mobile users | Tap intended targets without mis-taps | < 5% mis-tap rate | Unknown | Tap-then-immediate-back pattern analysis | Leading |
| 5 | Mobile users | Read all text without pinch-to-zoom | Zero pinch-to-zoom events on text | Unknown | Viewport scale change + gesture detection | Leading |
| 6 | Mobile users on teach page | Complete all 4 tabs for a kanji | > 85% tab completion rate on mobile | Estimated 60% (small touch targets) | Tab change event tracking per session | Leading |
| 7 | Mobile users on explore page | Find specific kanji information | 50%+ reduction in scroll depth | 3-4 screen-heights scroll depth | Scroll depth tracking on explore page | Leading |
| 8 | Mobile users on 3G | Experience fast page loads | Time to interactive < 3 seconds | Unknown (untested on 3G) | Lighthouse mobile + WebPageTest 3G profile | Leading |

### Metric Hierarchy

- **North Star**: Mobile session completion rate (KPI #1) -- the ONE metric that matters most. If mobile users complete full study sessions, the mobile UX is working.
- **Leading Indicators**:
  - Zero iOS auto-zoom events (KPI #2) -- signals input sizing is correct
  - Bottom tab navigation adoption > 90% (KPI #3) -- signals nav is discoverable and usable
  - Tab completion rate > 85% (KPI #6) -- signals teach page touch targets work
- **Guardrail Metrics** (must NOT degrade):
  - Desktop session completion rate must remain stable (mobile changes must not break desktop)
  - Page load time on desktop must not increase
  - Existing test suite must continue to pass
  - Accessibility score (WCAG AA compliance) must not decrease

### Measurement Plan

| KPI | Data Source | Collection Method | Frequency | Owner |
|-----|------------|-------------------|-----------|-------|
| Session completion | LiveView telemetry | Track mount/unmount events across Learn -> Teach -> Quiz -> Results | Continuous | Product |
| iOS auto-zoom | Client-side JS | Listen for viewport scale changes via VisualViewport API | Per-session | Engineering |
| Tab navigation | LiveView events | Count bottom nav tab click events vs. browser back/URL navigation | Continuous | Product |
| Mis-tap rate | LiveView navigation | Detect tap on group kanji followed by immediate back navigation within 2s | Weekly analysis | Product |
| Pinch-to-zoom | Client-side JS | Listen for touchmove with 2+ touches on text content areas | Per-session | Engineering |
| Tab completion | LiveView events | Track active_tab changes: count sessions reaching tab 4 / total teach sessions | Continuous | Product |
| Explore scroll depth | Client-side JS | IntersectionObserver on explore page sections | Continuous | Product |
| TTI on 3G | Lighthouse CI | Automated Lighthouse run with 3G throttling in CI pipeline | Per-deploy | Engineering |

### Hypothesis

We believe that implementing a mobile-optimized app shell with bottom tab navigation, touch-friendly sizing (48px+ targets, 72-128px kanji), readable typography (16px+ text), and progressive disclosure (accordion sections) for mobile users of Kuma San Kanji will achieve a mobile session completion rate above 60%.

We will know this is true when mobile users (screen width < 768px) complete full study sessions (dashboard through quiz results) at a rate above 60%, iOS auto-zoom events drop to zero, and bottom tab navigation accounts for 90%+ of inter-section navigation on mobile.

### Story-to-KPI Mapping

| Story | Primary KPI | Secondary KPIs |
|-------|------------|----------------|
| US-MOB-01: App Shell | #1 (session completion) | #8 (TTI) |
| US-MOB-02: Bottom Tab Nav | #3 (tab navigation) | #1 (session completion) |
| US-MOB-03: Safe Area Insets | #4 (mis-tap rate) | #1 (session completion) |
| US-MOB-04: Mobile Dashboard | #1 (session completion) | #5 (no zoom) |
| US-MOB-05: Kanji Grid | #4 (mis-tap rate) | #5 (no zoom) |
| US-MOB-06: Mobile Teach | #6 (tab completion) | #1 (session completion) |
| US-MOB-07: Mobile Quiz | #2 (no iOS zoom) | #1 (session completion) |
| US-MOB-08: Quiz Results | #1 (session completion) | -- |
| US-MOB-09: Swipe Navigation | #6 (tab completion) | -- |
| US-MOB-10: Explore Accordion | #7 (scroll depth) | #5 (no zoom) |
| US-MOB-11: Typography | #5 (no zoom) | #4 (mis-tap rate) |
| US-MOB-12: Performance | #8 (TTI) | #1 (session completion) |
