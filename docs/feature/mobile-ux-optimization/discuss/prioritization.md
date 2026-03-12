# Prioritization: Mobile UX Optimization

## Release Priority

| Priority | Release | Target Outcome | KPI | Value | Urgency | Effort | Score | Rationale |
|----------|---------|---------------|-----|-------|---------|--------|-------|-----------|
| 1 | Walking Skeleton | Mobile users can access all pages without layout breaks | Zero viewport overflow, zero clipped content | 5 | 5 | 3 | 8.3 | Foundation -- without this, nothing else works on mobile |
| 2 | R1: Core Mobile Shell | Mobile users navigate fluidly with bottom tab bar | Session completion rate on mobile > 60% | 5 | 5 | 3 | 8.3 | App shell + nav is prerequisite for all other mobile work |
| 3 | R2: Touch-Optimized Content | Zero mis-taps, zero readability issues | Zero iOS auto-zoom events, all targets >= 48px | 5 | 4 | 3 | 6.7 | Directly addresses largest mobile usability pain points |
| 4 | R3: Gesture & Progressive Disclosure | Mobile interaction feels native | Swipe adoption > 40% of tab navigations | 4 | 3 | 3 | 4.0 | Elevates from usable to pleasant; explore page becomes manageable |
| 5 | R4: Performance & Polish | Mobile experience feels fast, accessible | TTI < 3s on 3G, zero scroll jank | 3 | 2 | 2 | 3.0 | Polish layer; existing performance acceptable but improvable |

## Riskiest Assumptions

| # | Assumption | Risk Level | Validation Method | Release |
|---|-----------|-----------|-------------------|---------|
| 1 | Bottom tab bar works well inside Phoenix LiveView layout system | HIGH | Prototype app shell with real LiveView navigation | R1 |
| 2 | `100dvh` + CSS Grid layout does not conflict with LiveView flash messages | HIGH | Test with flash messages on multiple iOS/Android devices | R1 |
| 3 | Safe area insets work correctly across iPhone models (notch, Dynamic Island, home bar) | MEDIUM | Device testing on iPhone SE, 14, 15 Pro | R1 |
| 4 | Swipe gesture JS hook does not conflict with LiveView event handling | MEDIUM | Build hook prototype, test with tab navigation | R3 |
| 5 | Accordion state management in Explore page works with LiveView assigns | LOW | Standard LiveView pattern, well-understood | R3 |
| 6 | `content-visibility: auto` does not cause layout shift on kanji sections | LOW | Test on real content with variable heights | R4 |

## Backlog Suggestions

| Story | Release | Priority | Outcome Link | Dependencies |
|-------|---------|----------|-------------|--------------|
| US-MOB-01: Mobile App Shell | WS/R1 | P1 | Mobile session completion | None |
| US-MOB-02: Bottom Tab Navigation | WS/R1 | P1 | Mobile navigation success rate | US-MOB-01 |
| US-MOB-03: Safe Area Insets | R1 | P1 | Zero content clipping on notched devices | US-MOB-01 |
| US-MOB-04: Mobile Learn Dashboard | R2 | P2 | Dashboard engagement on mobile | US-MOB-01, US-MOB-02 |
| US-MOB-05: Touch-Friendly Kanji Grid | R2 | P2 | Zero mis-taps on group detail | US-MOB-01 |
| US-MOB-06: Mobile Teach Page | R2 | P2 | Teach page completion rate on mobile | US-MOB-01 |
| US-MOB-07: Mobile Quiz Experience | R2 | P2 | Quiz completion rate on mobile, zero iOS zoom | US-MOB-01 |
| US-MOB-08: Mobile Quiz Results | R2 | P2 | Post-quiz action engagement on mobile | US-MOB-07 |
| US-MOB-09: Swipe Tab Navigation | R3 | P3 | Swipe adoption rate > 40% | US-MOB-06 |
| US-MOB-10: Explore Accordion Sections | R3 | P3 | Explore page bounce rate decrease | US-MOB-01 |
| US-MOB-11: Mobile Typography & Readability | R2 | P2 | Zero pinch-to-zoom events | US-MOB-01 |
| US-MOB-12: Mobile Performance Optimization | R4 | P4 | TTI < 3s on 3G | US-MOB-01 |

> **Note**: Story IDs (US-MOB-01 through US-MOB-12) are preliminary. Final IDs assigned in user-stories.md after full requirements crafting.

## Decision Log

| # | Decision | Rationale | Alternatives Considered |
|---|---------|-----------|----------------------|
| 1 | 4-item bottom tab bar (Learn, Explore, Quiz, Profile) | Research shows 3-5 items optimal for thumb-zone accessibility. 4 covers primary user goals. | 5 items (add Settings) -- rejected: Profile can contain settings. 3 items (no Profile) -- rejected: auth and preferences need a home. |
| 2 | Walking skeleton includes R1 (not separate) | App shell and bottom nav are inseparable -- cannot meaningfully test one without the other | Separate skeleton (just viewport) -- rejected: untestable in isolation |
| 3 | Accordion for Explore, not for Teach | Teach uses progressive disclosure tabs (existing pattern works well). Explore has 6+ sections that overwhelm on mobile scroll. | Tabs for Explore -- rejected: too many sections for tab bar. Bottom sheet -- rejected: more complex, less standard. |
| 4 | Swipe gestures in R3, not R2 | Swipe is enhancement over tap. R2 must work perfectly with tap-only interaction. Adding swipe later is additive, not breaking. | Swipe in R2 -- rejected: increases risk of R2 scope, JS hook complexity delays core mobile fixes |
| 5 | Feature flag: `mobile_ux_optimization` | All changes behind a single feature flag. Allows gradual rollout and instant rollback if mobile layout causes issues. | Per-release flags -- rejected: too granular, creates flag management overhead |
