# Wave Decisions: Mobile UX Optimization (DISCUSS)

## Feature Summary

**Feature ID**: mobile-ux-optimization
**Wave**: DISCUSS
**Date**: 2026-03-11
**Status**: Complete -- Ready for DESIGN wave handoff

---

## Discovery Summary

### Approach

This feature was driven by comprehensive research (35 sources) documented in `docs/research/mobile-ui-ux-patterns.md`. Discovery was conducted by analyzing the existing codebase (5 LiveView pages, 2 layout templates, router) against research findings from W3C, web.dev, MDN, Nielsen Norman Group, and platform-specific guidance. JTBD was skipped per configuration -- the user motivation is clear: study kanji comfortably on a phone during commute.

### Persona

**Yuki Tanaka** -- 28-year-old software developer learning Japanese as a hobby. Studies kanji during her 25-minute train commute on her iPhone 14. Holds phone one-handed while standing on a crowded train. Has learned ~30 kanji, visits 3-4 times per week. Wants quick, satisfying study sessions that fit into dead time.

### Current State Analysis

The app currently uses a desktop-first layout:
- **Root layout**: `min-h-screen flex flex-col pb-32` body with top navbar and footer
- **Content wrapper**: `max-w-7xl` with `px-4 py-8 sm:px-6 lg:px-8` padding
- **Navigation**: Top navbar only (hardest to reach on mobile)
- **No mobile-specific**: No bottom nav, no safe area handling, no touch target optimization
- **Text sizing**: Some elements below 16px, kanji at `text-2xl` (24px) in grids
- **Explore page**: All sections expanded, 3-4 screen-heights of scrolling on mobile
- **Quiz input**: Font size likely inherits < 16px, triggering iOS auto-zoom

---

## Key Decisions

### D1: App Shell Architecture

**Decision**: Full-viewport app shell using `100dvh` + CSS Grid (`grid-template-rows: auto 1fr auto`)

**Rationale**: Research unanimously recommends this pattern for mobile web apps. Dynamic viewport height (`dvh`) handles mobile browser chrome correctly (Safari toolbar collapse). CSS Grid with three rows (header auto, content 1fr, nav auto) ensures content fills available space without overflow.

**Alternatives considered**:
- `100vh` (static viewport) -- rejected: does not account for mobile browser chrome, causes overflow on iOS Safari
- Flexbox column layout -- rejected: CSS Grid provides more precise control over the three-row app shell
- No app shell (keep current) -- rejected: current layout wastes space and does not support bottom nav

### D2: Bottom Tab Navigation (4 items)

**Decision**: 4-item bottom tab bar: Learn, Explore, Quiz, Profile

**Rationale**: Research shows 3-5 items optimal for thumb-zone accessibility. 4 covers the primary user goals. Learn and Explore are the main content areas. Quiz provides direct access to SRS reviews. Profile consolidates settings and account.

**Alternatives considered**:
- 5 items (add Settings separately) -- rejected: Profile can contain settings, 5 is the upper bound and feels crowded
- 3 items (no Profile) -- rejected: auth and preferences need a discoverable home
- Hamburger menu for secondary items -- rejected: hamburger menus have low discoverability on mobile
- Keep top navbar only -- rejected: top of screen is hardest to reach one-handed (Fitts's Law)

### D3: Touch Target Minimum (48px)

**Decision**: All interactive elements minimum 48x48px on mobile

**Rationale**: Google Material Design recommends 48x48dp. WCAG 2.2 recommends minimum 24x24 CSS pixels but notes 44x44 is better. Research consensus is 48px for mobile touch targets. This is especially important for one-handed use on a moving train.

**Alternatives considered**:
- 44x44px (Apple/WCAG recommendation) -- rejected: 48px is marginally larger with significant usability benefit for the commute context
- 24x24px (WCAG minimum) -- rejected: too small for one-handed mobile use

### D4: Kanji Sizing Hierarchy

**Decision**: Three-tier kanji sizing: 48px (list/grid), 72-128px (detail/teach), 72px+ (quiz)

**Rationale**: Research recommends minimum 48px for kanji in list contexts (readability for complex characters). Teaching/detail views need 72-128px for stroke study and character recognition training. Quiz needs 72px+ for clear display while leaving room for input and feedback.

**Alternatives considered**:
- Single size for all contexts -- rejected: list views cannot afford 128px per character, detail views need > 48px
- Smaller sizes (24-36px in lists) -- rejected: complex kanji characters become illegible at small sizes, especially on mobile

### D5: Explore Page Progressive Disclosure

**Decision**: Accordion/collapsible sections for secondary content on mobile; primary info (kanji, grade, meanings) always visible

**Rationale**: The explore page currently has 8+ content sections requiring 3-4 screen-heights of scrolling. Research recommends progressive disclosure for information-dense pages on mobile. Accordion pattern reduces initial cognitive load while keeping all information accessible on demand.

**Alternatives considered**:
- Tabs (like teach page) -- rejected: explore has 6+ sections, too many for a tab bar
- Bottom sheet -- rejected: more complex to implement, less standard pattern for this content type
- Keep scrolling layout -- rejected: 3-4 screen-heights is too much for casual browsing
- Pagination of sections -- rejected: breaks the single-kanji-at-a-glance mental model

### D6: iOS Auto-Zoom Prevention

**Decision**: Quiz input font size explicitly set to 16px+

**Rationale**: iOS Safari auto-zooms the viewport when a user taps an input field with font-size below 16px. This is the single most common mobile UX complaint for form-heavy web apps. Setting font-size >= 16px on inputs prevents this behavior entirely.

**Alternatives considered**:
- `maximum-scale=1` on viewport meta -- rejected: breaks user accessibility (prevents intentional zoom)
- JavaScript to reset zoom after input focus -- rejected: hacky, causes visible jank
- Accept the zoom behavior -- rejected: destroys quiz UX, user must pinch-zoom back out after every question

### D7: Feature Flag Strategy

**Decision**: Single feature flag `mobile_ux_optimization` for all changes

**Rationale**: All mobile changes are CSS/layout adjustments that should be deployed together for a coherent experience. A single flag enables gradual rollout and instant rollback if issues arise.

**Alternatives considered**:
- Per-release flags (R1, R2, R3, R4) -- rejected: too granular, creates flag management overhead
- No feature flag -- rejected: project rules require all user-facing features behind flags
- Per-story flags -- rejected: 12 flags is unmanageable

### D8: Release Slicing Strategy

**Decision**: 4 releases sliced by mobile impact: Shell -> Touch -> Gesture -> Performance

**Rationale**: Each release delivers independently valuable mobile improvements. R1 (Shell) is the foundation. R2 (Touch) addresses the most painful usability issues. R3 (Gesture) elevates from usable to pleasant. R4 (Performance) is polish.

**Alternatives considered**:
- Feature-based slicing (all of Learn, then all of Explore, etc.) -- rejected: no end-to-end value until late
- Single big-bang release -- rejected: too risky, no incremental feedback
- 2 releases (foundation + everything else) -- rejected: R2/R3/R4 split enables meaningful testing between releases

---

## Artifacts Produced

| Artifact | Path | Description |
|----------|------|-------------|
| Journey Visual | `journey-mobile-learning-visual.md` | ASCII flow diagrams, emotional arc, TUI mockups for each step, error paths |
| Journey Schema | `journey-mobile-learning.yaml` | Structured YAML schema with steps, shared artifacts, emotional states, integration validation |
| Gherkin Scenarios | `journey-mobile-learning.feature` | 28 BDD scenarios covering all 7 journey steps + error paths + cross-cutting concerns |
| Story Map | `story-map.md` | Backbone with 7 activities, walking skeleton, 4 release slices |
| Prioritization | `prioritization.md` | Release priority matrix, riskiest assumptions, backlog suggestions, decision log |
| User Stories | `user-stories.md` | 12 LeanUX user stories with problem, persona, 3+ examples, BDD scenarios, AC, KPIs |
| Shared Artifacts Registry | `shared-artifacts-registry.md` | 15 tracked artifacts with sources, consumers, risks, integration checkpoints |
| Outcome KPIs | `outcome-kpis.md` | 8 outcome KPIs with metric hierarchy, measurement plan, story-to-KPI mapping |
| DoR Validation | `dor-validation.md` | 9-item DoR validation for all 12 stories -- all PASSED |
| Wave Decisions | `wave-decisions.md` | This document -- 8 key decisions with rationale and alternatives |

---

## DESIGN Wave Handoff

### For Solution Architect

The following package is ready for DESIGN wave:

1. **Journey artifacts** define the complete mobile user experience across all 7 pages
2. **12 user stories** are DoR-validated with BDD acceptance criteria
3. **Shared artifacts registry** documents all data flow and integration risks
4. **Outcome KPIs** define measurable success criteria for each release
5. **Prioritization** recommends 4 release slices with dependency ordering

### Key Constraints for DESIGN

- All changes behind `mobile_ux_optimization` feature flag
- Must not break desktop layout (CSS additions, not replacements)
- Must coexist with LiveView flash messages and socket reconnection
- `100dvh` requires Safari 15.4+ (acceptable for target audience)
- Swipe gesture JS hook must not conflict with LiveView event handling
- Tailwind CSS and DaisyUI are the design system (no new dependencies)

### Open Questions for DESIGN

1. Should the bottom nav use DaisyUI `btm-nav` component or a custom component?
2. How should the compact mobile header differ from the desktop navbar? Hide entirely or simplify?
3. Should accordion sections use `<details>/<summary>` HTML or LiveView assigns with conditional rendering?
4. What is the right swipe distance threshold for the JS hook (50px suggested by research)?
5. How should skeleton loading states be implemented in LiveView (assign-based or CSS-based)?

---

## Risk Summary

| Risk | Level | Mitigation |
|------|-------|------------|
| Bottom nav conflicts with LiveView layout | HIGH | Prototype in R1, test with real LiveView navigation before proceeding |
| `100dvh` + CSS Grid conflicts with flash messages | HIGH | Test with flash messages on multiple devices |
| Safe area insets vary across iPhone models | MEDIUM | Test on iPhone SE, 14, 15 Pro (physical devices or BrowserStack) |
| Swipe hook conflicts with LiveView events | MEDIUM | Build hook prototype in isolation, test with tab navigation |
| `content-visibility: auto` causes layout shift | LOW | Test with real content, provide explicit height hints |
| Accordion state management complexity | LOW | Standard LiveView pattern, well-understood |
