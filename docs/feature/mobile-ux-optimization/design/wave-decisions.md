# Wave Decisions: Mobile UX Optimization (DESIGN)

## Feature Summary

**Feature ID**: mobile-ux-optimization
**Wave**: DESIGN
**Date**: 2026-03-11
**Status**: Complete -- Ready for peer review and DISTILL wave handoff

---

## Architecture Approach

### Style Selection Rationale

This feature is a **presentation-layer-only** change within an existing modular monolith (Phoenix/Ash). No new domains, data models, services, or API contracts are introduced. The architecture decision is therefore not about selecting an application architecture style, but about organizing the presentation-layer changes within the existing structure.

**Approach**: Extend existing component boundaries (layouts, components, CSS, JS hooks) with mobile-responsive behavior, gated behind a single feature flag. All changes are additive -- existing desktop behavior is preserved via CSS responsive classes.

### Why no new domain architecture is needed

1. Zero new database tables or queries
2. Zero new Ash resources or actions
3. Zero new API endpoints or contracts
4. All LiveView event handlers already exist (tab navigation, quiz submission, etc.)
5. The only new server-side code is a new feature flag check function and two new Phoenix Components

---

## Key Decisions

### DA-1: Dual Layout Strategy (CSS Grid Mobile, Flex Desktop)

**Decision**: Apply CSS Grid `grid-rows-[auto_1fr_auto]` with `100dvh` on mobile, preserve existing `min-h-screen flex flex-col` on desktop. Feature flag gates the mobile variant.

**ADR**: ADR-MOB-004

**Rationale**: CSS Grid provides deterministic three-row app shell layout. `100dvh` solves the iOS Safari viewport overflow problem that `100vh` causes. Desktop layout is unchanged, minimizing risk.

### DA-2: DaisyUI `btm-nav` for Bottom Navigation

**Decision**: New `BottomNav` Phoenix Component using DaisyUI `btm-nav` with 4 tabs (Learn, Explore, Quiz, Profile), active tab via route prefix matching.

**ADR**: ADR-MOB-001

**Rationale**: DaisyUI is the existing design system. The `btm-nav` component provides themed active states, proper positioning, and consistency across all 30 configured themes. Building custom duplicates existing capability.

### DA-3: Hide Desktop Navbar, Minimal Mobile Header

**Decision**: Hide existing navbar on mobile (`hidden md:block`). Add compact mobile header (page title + back arrow for sub-pages) consuming ~44px height.

**ADR**: ADR-MOB-005

**Rationale**: Bottom tab bar replaces primary navigation. Keeping both wastes ~120px of vertical space. Minimal header provides page context and back navigation without duplicating tab bar functionality.

### DA-4: Native HTML `<details>/<summary>` for Accordions

**Decision**: New `AccordionSection` Phoenix Component wrapping `<details>/<summary>` elements styled with DaisyUI `collapse` classes.

**ADR**: ADR-MOB-003

**Rationale**: Zero JavaScript, zero server round-trips, built-in keyboard/screen-reader accessibility, state survives LiveView DOM patching. LiveView assigns would add latency for a purely cosmetic interaction. Alpine.js would add a new dependency.

### DA-5: Dedicated SwipeTabNavigation Hook

**Decision**: New JS hook for teach page tab swiping, separate from existing `MobileSwipeGestures` quiz hook. 50px horizontal threshold with vertical-exceeds-horizontal guard.

**ADR**: ADR-MOB-002

**Rationale**: The teach page swipe (tab cycling) and quiz page swipe (kanji skip/next) have different event targets and behavioral semantics. Separate hooks maintain single responsibility. The new hook reuses existing `"next_tab"` / `"prev_tab"` TeachLive event handlers -- zero server-side changes.

### DA-6: No New Dependencies

**Decision**: All mobile UX changes implemented with existing stack: Tailwind CSS, DaisyUI, Phoenix LiveView hooks, Heroicons.

**Rationale**: DaisyUI `btm-nav` and `collapse` components are already available. Heroicons are already bundled. No new JS libraries (rejected Hammer.js, Alpine.js). No new CSS frameworks. This eliminates supply chain risk and keeps the bundle size unchanged.

### DA-7: CSS Additions Only, Never Replacements

**Decision**: All mobile styles use Tailwind responsive prefixes (`md:`, `sm:`, `lg:`) or CSS `@media` queries. No existing desktop CSS rules are modified or removed.

**Rationale**: This guarantees desktop layout stability. If any mobile CSS causes issues, the feature flag rollback restores the original layout with zero side effects. The CSS cascade ensures mobile-first rules do not affect desktop viewports.

### DA-8: Single Feature Flag for All Changes

**Decision**: One flag `mobile_ux_optimization` gates all 4 releases. No per-release or per-story flags.

**Rationale**: Carried forward from DISCUSS decision D7. All mobile changes are designed to work as a coherent system. A single flag enables clean rollout and instant rollback. Per-release flags would create management overhead with no benefit (releases are deployed sequentially, not independently).

---

## Open Questions Resolved

| # | Question | Resolution | ADR |
|---|---------|-----------|-----|
| 1 | DaisyUI `btm-nav` or custom? | DaisyUI `btm-nav` -- consistent theming, less custom CSS | ADR-MOB-001 |
| 2 | Mobile header approach? | Hide desktop navbar, add minimal page-title header with back arrow | ADR-MOB-005 |
| 3 | Accordion: `<details>` or LiveView assigns? | HTML `<details>/<summary>` -- zero latency, native accessibility | ADR-MOB-003 |
| 4 | Swipe threshold? | 50px horizontal, must exceed vertical displacement | ADR-MOB-002 |
| 5 | Skeleton loading states? | CSS `animate-pulse` on disconnected render placeholders (R4) | Architecture doc section 6, Q5 |

---

## New Components Summary

| Component | Type | Release | Purpose |
|-----------|------|---------|---------|
| `BottomNav` | Phoenix Component | R1 | 4-tab bottom navigation bar for mobile |
| `AccordionSection` | Phoenix Component | R3 | Progressive disclosure wrapper for explore sections |
| `SwipeTabNavigation` | JS Hook | R3 | Teach page tab swipe gesture detection |
| `mobile_ux_enabled?/0` | Helper function | R1 | Feature flag check (added to FeatureFlagHelper) |

---

## Components Modified (Not New)

| Component | Change | Release |
|-----------|--------|---------|
| `root.html.heex` | Add mobile CSS Grid body variant, viewport-fit=cover meta | R1 |
| `app.html.heex` | Add BottomNav, mobile header, conditional footer hiding | R1 |
| `Navigation` component | Add `hidden md:block` class | R1 |
| `Footer` component | Add `hidden md:block` class | R1 |
| `LearnLive` template | Single-column cards, touch-friendly sizing | R2 |
| `GroupLive` template | Touch-friendly kanji grid, full-width CTA | R2 |
| `TeachLive` template | Large kanji, touch tabs, swipe hook binding, full-width buttons | R2/R3 |
| `GroupQuizLive` template | Input font 16px+, full-width buttons | R2 |
| `QuizLive` template | Input font 16px+, full-width buttons | R2 |
| `ExploreLive` template | AccordionSection wrappers on secondary sections | R3 |
| `app.css` | Touch target classes, kanji sizing tiers, performance CSS | R2/R4 |
| `app.js` | Register SwipeTabNavigation hook | R3 |

---

## Quality Gates Status

- [x] Requirements traced to components (Section 12 of architecture doc)
- [x] Component boundaries with clear responsibilities (Section 5)
- [x] Technology choices in ADRs with alternatives (5 ADRs, 2+ alternatives each)
- [x] Quality attributes addressed: usability, compatibility, performance, maintainability, reliability, accessibility (Section 9)
- [x] Dependency-inversion compliance: presentation layer depends on domain, not vice versa; JS hooks push events to LiveView, not direct DOM manipulation
- [x] C4 diagrams: L1 System Context + L2 Container + L3 Component (Sections 2, 3, 4)
- [x] Integration patterns specified: feature flag, route matching, LiveView events, layout slots (Section 8)
- [x] OSS preference validated: zero new dependencies, all existing are MIT/Apache 2.0 (Section 7)
- [x] AC behavioral, not implementation-coupled: all user stories specify WHAT users see/do, not HOW it is coded
- [ ] Peer review: pending

---

## Artifacts Produced

| Artifact | Path |
|----------|------|
| Architecture Document | `docs/feature/mobile-ux-optimization/design/architecture.md` |
| ADR-MOB-001: Bottom Nav | `docs/feature/mobile-ux-optimization/design/adr-mob-001-bottom-nav-component.md` |
| ADR-MOB-002: Swipe Hook | `docs/feature/mobile-ux-optimization/design/adr-mob-002-swipe-gesture-hook.md` |
| ADR-MOB-003: Accordion | `docs/feature/mobile-ux-optimization/design/adr-mob-003-accordion-implementation.md` |
| ADR-MOB-004: App Shell | `docs/feature/mobile-ux-optimization/design/adr-mob-004-app-shell-layout.md` |
| ADR-MOB-005: Mobile Header | `docs/feature/mobile-ux-optimization/design/adr-mob-005-mobile-header-strategy.md` |
| Wave Decisions | `docs/feature/mobile-ux-optimization/design/wave-decisions.md` |

---

## DISTILL Wave Handoff

### For Acceptance Designer

The following package is ready for DISTILL wave:

1. **Architecture document** defines all component boundaries, integration patterns, and quality attribute strategies
2. **5 ADRs** document every significant design decision with alternatives and rationale
3. **12 user stories** from DISCUSS wave have been traced to specific components and releases
4. **All 5 open questions** from DISCUSS have been resolved with architectural justification
5. **No new dependencies** -- acceptance tests can focus on behavior, not infrastructure setup

### Key Constraints for DISTILL

- All acceptance criteria must be behavioral (WHAT users see), not implementation-coupled (HOW code works)
- Feature flag `mobile_ux_optimization` gates all changes -- tests should verify behavior with flag ON and OFF
- Desktop layout must not change -- guardrail tests needed
- CSS responsive breakpoint is `md` (768px) -- tests need mobile and desktop viewport assertions
- Swipe gestures degrade gracefully to tap -- tests should verify tap still works even when swipe is available
