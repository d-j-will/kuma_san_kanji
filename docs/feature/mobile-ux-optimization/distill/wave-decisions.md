# Wave Decisions: DISTILL -- Mobile UX Optimization

**Feature**: mobile-ux-optimization
**Wave**: DISTILL
**Date**: 2026-03-12
**Designer**: Quinn (Acceptance Test Designer)

---

## D1: Test Framework Selection

**Decision**: Use ExUnit with Phoenix.LiveViewTest, not Cucumber/pytest-bdd.

**Rationale**: The project uses Elixir/Phoenix with ExUnit as the standard test framework. All existing tests follow the `use KumaSanKanjiWeb.ConnCase` pattern with `Phoenix.LiveViewTest`. Introducing a BDD framework would add a dependency, split test tooling, and fight the ecosystem. The Given-When-Then structure is expressed through descriptive `describe` and `test` block names with inline comments, matching the existing `mark_learned_test.exs` pattern.

---

## D2: Test Scope -- HTML Structure vs Visual Rendering

**Decision**: Acceptance tests validate HTML structure, CSS class presence, and component attributes. Visual rendering (pixel sizes, layout behavior, animation) is documented in a manual test checklist.

**Rationale**: Phoenix.LiveViewTest renders HTML but does not execute CSS or JavaScript. Testing CSS-dependent properties (48px touch targets, 100dvh viewport fill, iOS auto-zoom prevention) through LiveViewTest would produce false assertions. Instead:
- **Automated tests** verify: markup present, classes applied, hooks bound, flag gating works
- **Manual checklist** covers: pixel sizes, gesture behavior, viewport adaptation, performance

This split ensures automated tests are reliable (never flaky due to rendering) while still documenting all acceptance criteria.

---

## D3: Feature Flag Testing Strategy

**Decision**: Each test file includes both flag-enabled and flag-disabled scenarios. Tests use `async: false` because FunWithFlags is global state.

**Rationale**: The `mobile_ux_optimization` feature flag is the primary gate for all mobile UX changes. Testing both states ensures:
1. Flag ON: mobile markup renders correctly
2. Flag OFF: existing desktop layout is unchanged (no regression)

This matches the existing `feature_flag_test.exs` pattern from the learning path feature.

---

## D4: Test Helper Architecture

**Decision**: Create `MobileUxHelpers` module in `test/support/` following the `LearningPathHelpers` pattern. Import both helpers in mobile tests since many pages require learning path flag + data.

**Rationale**: Mobile tests need to:
- Enable/disable the `mobile_ux_optimization` flag
- Create authenticated users (reuse `LearningPathHelpers.create_authenticated_learner/2`)
- Create test data for pages (reuse `LearningPathHelpers.create_numbers_group/0`)
- Enable the learning path flag (required for /learn routes)

Extracting mobile-specific helpers avoids duplicating flag management logic across 7 test files.

---

## D5: Walking Skeleton Count

**Decision**: 7 walking skeletons (one per test file) instead of the typical 2-3.

**Rationale**: This feature spans 12 user stories across 4 releases with distinct boundaries (layout, navigation, safe areas, content, quiz, accordion, swipe). Each test file targets a different component boundary. One walking skeleton per file ensures each boundary is independently validated before focused scenarios expand coverage. The total of 7 is justified by the feature's breadth.

---

## D6: US-MOB-12 (Performance) -- No Automated Tests

**Decision**: US-MOB-12 has zero automated acceptance tests. All criteria documented in manual-test-checklist.md.

**Rationale**: Every acceptance criterion for US-MOB-12 is a CSS property or browser behavior:
- `content-visibility: auto` (CSS rendering optimization)
- `overscroll-behavior: contain` (CSS scroll behavior)
- `prefers-reduced-motion` (CSS media query)
- Skeleton loading (`animate-pulse` CSS class)

None of these are observable through LiveViewTest HTML rendering. Asserting class names would be Testing Theater -- the class could be present but misspelled or overridden, giving false confidence.

---

## D7: One-at-a-Time Implementation Sequence

**Decision**: Tests should be enabled in release order (R1 -> R2 -> R3 -> R4), one walking skeleton at a time within each release.

**Recommended sequence**:
1. WS-1: App shell (foundation for everything)
2. WS-2: Bottom nav (primary mobile navigation)
3. WS-3: Safe areas (device compatibility)
4. WS-4: Mobile dashboard (first content page)
5. WS-5: Mobile quiz (second content page)
6. WS-6: Accordion (progressive disclosure)
7. WS-7: Swipe hook (gesture enhancement)

Each walking skeleton should pass before enabling the next. Focused scenarios within a file can be enabled in batches after the walking skeleton passes.

---

## Handoff Artifacts

| Artifact | Location |
|----------|----------|
| Test helper | `test/support/mobile_ux_helpers.ex` |
| App shell tests | `test/kuma_san_kanji_web/live/mobile/app_shell_test.exs` |
| Bottom nav tests | `test/kuma_san_kanji_web/live/mobile/bottom_nav_test.exs` |
| Safe area tests | `test/kuma_san_kanji_web/live/mobile/safe_area_test.exs` |
| Mobile layout tests | `test/kuma_san_kanji_web/live/mobile/mobile_layout_test.exs` |
| Mobile quiz tests | `test/kuma_san_kanji_web/live/mobile/mobile_quiz_test.exs` |
| Accordion tests | `test/kuma_san_kanji_web/live/mobile/accordion_test.exs` |
| Swipe hook tests | `test/kuma_san_kanji_web/live/mobile/swipe_hook_test.exs` |
| Scenario index | `docs/feature/mobile-ux-optimization/distill/test-scenarios.md` |
| Walking skeleton plan | `docs/feature/mobile-ux-optimization/distill/walking-skeleton.md` |
| Manual test checklist | `docs/feature/mobile-ux-optimization/distill/manual-test-checklist.md` |
| Wave decisions | `docs/feature/mobile-ux-optimization/distill/wave-decisions.md` |
