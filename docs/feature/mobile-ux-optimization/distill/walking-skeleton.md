# Walking Skeleton Test Plan: Mobile UX Optimization

**Feature**: mobile-ux-optimization
**Wave**: DISTILL
**Date**: 2026-03-12

---

## Walking Skeleton Strategy

Walking skeletons for this feature answer: "Can a mobile learner use the app with the new mobile layout and navigate between sections?" They trace thin vertical slices through the layout templates, feature flag, and LiveView rendering.

Since this is a presentation-layer-only feature, walking skeletons validate that:
1. The feature flag gates the mobile layout correctly
2. The mobile app shell structure renders
3. Navigation works via bottom tabs
4. Content pages render with mobile-optimized markup

---

## Walking Skeletons (7 total, one per test file)

### WS-1: App Shell CSS Grid Layout (R1 -- Core)
**File**: `app_shell_test.exs`
**Story**: US-MOB-01

**User Goal**: Yuki opens the app on her phone and sees a full-viewport layout that fills the screen without overflow or dead zones.

**Scenario**:
- Given Yuki has the mobile_ux_optimization feature enabled
- When Yuki opens the Learn dashboard
- Then the page uses CSS Grid layout classes for the mobile app shell

**Why this is the first skeleton**: The app shell is the foundation. Every other mobile feature depends on the grid layout rendering correctly. If the flag does not activate the layout, nothing else works.

### WS-2: Bottom Navigation Bar (R1 -- Core)
**File**: `bottom_nav_test.exs`
**Story**: US-MOB-02

**User Goal**: Yuki sees a bottom tab bar and can identify the four navigation sections of the app.

**Scenario**:
- Given Yuki is logged in with mobile_ux_optimization enabled
- When Yuki opens the Learn dashboard
- Then a bottom navigation bar appears with Learn, Explore, Quiz, and Profile tabs

**Why**: Bottom nav is the primary navigation mechanism for mobile. Without it, users cannot move between sections.

### WS-3: Safe Area Insets (R1 -- Core)
**File**: `safe_area_test.exs`
**Story**: US-MOB-03

**User Goal**: Yuki's content is not hidden behind her iPhone's notch or home indicator.

**Scenario**:
- Given Yuki has mobile_ux_optimization enabled
- When Yuki opens any page
- Then the viewport meta tag includes viewport-fit=cover

**Why**: Safe areas prevent content from being clipped on modern phones. This is the enabling mechanism.

### WS-4: Mobile Dashboard Layout (R2 -- Content)
**File**: `mobile_layout_test.exs`
**Story**: US-MOB-04

**User Goal**: Yuki opens the Learn tab and sees her groups with touch-friendly layout.

**Scenario**:
- Given Yuki has mobile UX enabled and a group exists
- When Yuki opens the Learn dashboard
- Then the dashboard shows group cards with the Numbers group

### WS-5: Mobile Quiz (R2 -- Content)
**File**: `mobile_quiz_test.exs`
**Story**: US-MOB-07

**User Goal**: Yuki takes a quiz on her phone without iOS auto-zoom disrupting the experience.

**Scenario**:
- Given Yuki has learned at least one kanji and mobile UX is enabled
- When Yuki opens the group quiz
- Then the quiz renders with an input field and the kanji character

### WS-6: Explore Accordion (R3 -- Gesture & Disclosure)
**File**: `accordion_test.exs`
**Story**: US-MOB-10

**User Goal**: Yuki browses kanji on the Explore page and sees primary info immediately without scrolling through everything.

**Scenario**:
- Given the mobile UX feature is enabled
- When a learner opens the Explore page
- Then the explore page renders with kanji content and collapsible sections

### WS-7: Swipe Tab Navigation (R3 -- Gesture & Disclosure)
**File**: `swipe_hook_test.exs`
**Story**: US-MOB-09

**User Goal**: Yuki can swipe between tabs on the teach page like a native app.

**Scenario**:
- Given Yuki has mobile UX enabled and navigates to the teach page
- When the teach page renders
- Then the content area has the SwipeTabNavigation hook binding

---

## Implementation Sequence

The recommended one-at-a-time implementation order follows release dependencies:

### R1: Core Mobile Shell (implement first)
1. **WS-1**: App shell -- enable this test first, implement CSS Grid layout
2. **WS-2**: Bottom nav -- enable after shell works, implement BottomNav component
3. **WS-3**: Safe areas -- enable after nav works, add viewport-fit meta

### R2: Touch-Optimized Content
4. **WS-4**: Mobile dashboard -- enable after R1 complete, add responsive classes
5. **WS-5**: Mobile quiz -- enable after dashboard, add input sizing

### R3: Gesture & Progressive Disclosure
6. **WS-6**: Accordion -- enable after R2, add details/summary to Explore
7. **WS-7**: Swipe hook -- enable after accordion, add JS hook binding

### R4: Performance & Polish
No walking skeletons (CSS-only, manual testing). Enable after R3 complete.

---

## Focused Scenario Counts

| File | Walking Skeletons | Focused Scenarios | Total |
|------|-------------------|-------------------|-------|
| app_shell_test.exs | 1 | 5 | 6 |
| bottom_nav_test.exs | 1 | 12 | 13 |
| safe_area_test.exs | 1 | 4 | 5 |
| mobile_layout_test.exs | 1 | 14 | 15 |
| mobile_quiz_test.exs | 1 | 9 | 10 |
| accordion_test.exs | 1 | 8 | 9 |
| swipe_hook_test.exs | 1 | 8 | 9 |
| **Total** | **7** | **60** | **67** |

Ratio: 7 walking skeletons + 60 focused scenarios. Recommended range: 2-5 skeletons per feature. This feature has 7 because it spans 12 user stories across 4 releases, warranting one skeleton per test file to validate each boundary independently.
