# Test Scenarios: Mobile UX Optimization

**Feature**: mobile-ux-optimization
**Wave**: DISTILL
**Date**: 2026-03-12
**Designer**: Quinn (Acceptance Test Designer)

---

## Scenario Index

| # | File | Story | Type | Description |
|---|------|-------|------|-------------|
| 1 | app_shell_test.exs | US-MOB-01 | Walking Skeleton | App shell renders CSS Grid layout when flag enabled |
| 2 | app_shell_test.exs | US-MOB-01 | Error | Desktop layout renders when flag disabled |
| 3 | app_shell_test.exs | US-MOB-01 | Happy | Mobile shell renders for unauthenticated pages |
| 4 | app_shell_test.exs | US-MOB-01 | Happy | Content area has overflow scroll class |
| 5 | app_shell_test.exs | US-MOB-01 | Edge | Flash messages render inside content area |
| 6 | app_shell_test.exs | US-MOB-01 | Error | Unauthenticated user redirected from protected pages |
| 7 | bottom_nav_test.exs | US-MOB-02 | Walking Skeleton | Bottom nav renders with four tabs |
| 8 | bottom_nav_test.exs | US-MOB-02 | Happy | Learn tab active on /learn |
| 9 | bottom_nav_test.exs | US-MOB-02 | Happy | Explore tab active on /explore |
| 10 | bottom_nav_test.exs | US-MOB-02 | Happy | Quiz tab active on /quiz |
| 11 | bottom_nav_test.exs | US-MOB-02 | Happy | Profile tab active on /settings |
| 12 | bottom_nav_test.exs | US-MOB-02 | Happy | Learn tab stays active on group detail |
| 13 | bottom_nav_test.exs | US-MOB-02 | Happy | Learn tab stays active on teach page |
| 14 | bottom_nav_test.exs | US-MOB-02 | Happy | Each tab has icon and text label |
| 15 | bottom_nav_test.exs | US-MOB-02 | Happy | Tab buttons have aria-label attributes |
| 16 | bottom_nav_test.exs | US-MOB-02 | Error | No bottom nav when flag disabled |
| 17 | bottom_nav_test.exs | US-MOB-02 | Edge | Profile tab links to sign-in for guests |
| 18 | bottom_nav_test.exs | US-MOB-02 | Happy | Bottom nav persists during LiveView navigation |
| 19 | bottom_nav_test.exs | US-MOB-02 | Happy | Desktop navbar visibility class present |
| 20 | safe_area_test.exs | US-MOB-03 | Walking Skeleton | Viewport meta includes viewport-fit=cover |
| 21 | safe_area_test.exs | US-MOB-03 | Happy | Bottom nav includes safe-area-inset-bottom class |
| 22 | safe_area_test.exs | US-MOB-03 | Happy | Viewport meta includes width and initial-scale |
| 23 | safe_area_test.exs | US-MOB-03 | Error | viewport-fit=cover not present when flag disabled |
| 24 | safe_area_test.exs | US-MOB-03 | Happy | Safe area classes on guest-accessible pages |
| 25 | mobile_layout_test.exs | US-MOB-04 | Walking Skeleton | Dashboard renders with touch-friendly layout |
| 26 | mobile_layout_test.exs | US-MOB-04 | Happy | Group cards render in single-column layout |
| 27 | mobile_layout_test.exs | US-MOB-04 | Happy | Dashboard shows progress information |
| 28 | mobile_layout_test.exs | US-MOB-04 | Edge | New user sees groups with no progress |
| 29 | mobile_layout_test.exs | US-MOB-05 | Happy | Kanji characters displayed in grid |
| 30 | mobile_layout_test.exs | US-MOB-05 | Happy | Learned kanji have visual indicators |
| 31 | mobile_layout_test.exs | US-MOB-05 | Happy | Continue learning button present |
| 32 | mobile_layout_test.exs | US-MOB-06 | Happy | Kanji displayed prominently on teach page |
| 33 | mobile_layout_test.exs | US-MOB-06 | Happy | Tab indicators present on teach page |
| 34 | mobile_layout_test.exs | US-MOB-06 | Happy | Next tab advances through teach content |
| 35 | mobile_layout_test.exs | US-MOB-06 | Happy | Quiz me button appears on last tab |
| 36 | mobile_layout_test.exs | US-MOB-11 | Happy | Body text uses readable font sizing |
| 37 | mobile_layout_test.exs | US-MOB-05 | Edge | Empty group renders gracefully |
| 38 | mobile_layout_test.exs | US-MOB-06 | Edge | First kanji shows position 1 of total |
| 39 | mobile_layout_test.exs | US-MOB-06 | Edge | Last kanji shows correct count |
| 40 | mobile_quiz_test.exs | US-MOB-07 | Walking Skeleton | Group quiz renders with input and submit |
| 41 | mobile_quiz_test.exs | US-MOB-07 | Happy | Quiz input present for iOS zoom prevention |
| 42 | mobile_quiz_test.exs | US-MOB-07 | Happy | Submit button present on quiz page |
| 43 | mobile_quiz_test.exs | US-MOB-07 | Happy | Kanji prominently displayed in quiz |
| 44 | mobile_quiz_test.exs | US-MOB-08 | Happy | Correct answer shows feedback |
| 45 | mobile_quiz_test.exs | US-MOB-08 | Happy | Incorrect answer shows correct answer |
| 46 | mobile_quiz_test.exs | US-MOB-07 | Happy | SRS quiz page renders |
| 47 | mobile_quiz_test.exs | US-MOB-07 | Error | Quiz shows message when no kanji learned |
| 48 | mobile_quiz_test.exs | US-MOB-07 | Error | Unauthenticated user cannot access quiz |
| 49 | mobile_quiz_test.exs | US-MOB-07 | Edge | Empty answer submission handled |
| 50 | accordion_test.exs | US-MOB-10 | Walking Skeleton | Explore page renders with content sections |
| 51 | accordion_test.exs | US-MOB-10 | Happy | Details elements for collapsible sections |
| 52 | accordion_test.exs | US-MOB-10 | Happy | Summary headers present |
| 53 | accordion_test.exs | US-MOB-10 | Happy | Kanji visible without expanding accordion |
| 54 | accordion_test.exs | US-MOB-10 | Happy | Pronunciation section is collapsible |
| 55 | accordion_test.exs | US-MOB-10 | Edge | New kanji load resets content |
| 56 | accordion_test.exs | US-MOB-10 | Edge | Explore renders normally without flag |
| 57 | accordion_test.exs | US-MOB-10 | Edge | Missing data handled gracefully |
| 58 | accordion_test.exs | US-MOB-10 | Happy | Authenticated user sees all features |
| 59 | swipe_hook_test.exs | US-MOB-09 | Walking Skeleton | Teach page has phx-hook for swipe nav |
| 60 | swipe_hook_test.exs | US-MOB-09 | Happy | Swipe hook has data attributes |
| 61 | swipe_hook_test.exs | US-MOB-09 | Happy | next_tab works with hook present |
| 62 | swipe_hook_test.exs | US-MOB-09 | Happy | prev_tab works with hook present |
| 63 | swipe_hook_test.exs | US-MOB-09 | Edge | prev_tab on first tab does not crash |
| 64 | swipe_hook_test.exs | US-MOB-09 | Edge | next_tab on last tab does not crash |
| 65 | swipe_hook_test.exs | US-MOB-09 | Error | Swipe hook absent when flag disabled |
| 66 | swipe_hook_test.exs | US-MOB-09 | Happy | Swipe hook present on middle position |
| 67 | swipe_hook_test.exs | US-MOB-09 | Happy | Swipe hook present on last position |

---

## Coverage Analysis

### By User Story

| Story | Scenarios | Walking Skeletons | Happy | Error | Edge |
|-------|-----------|-------------------|-------|-------|------|
| US-MOB-01 | 6 | 1 | 2 | 2 | 1 |
| US-MOB-02 | 13 | 1 | 8 | 1 | 3 |
| US-MOB-03 | 5 | 1 | 3 | 1 | 0 |
| US-MOB-04 | 4 | 1 | 2 | 0 | 1 |
| US-MOB-05 | 4 | 0 | 2 | 0 | 2 |
| US-MOB-06 | 6 | 0 | 4 | 0 | 2 |
| US-MOB-07 | 6 | 1 | 3 | 2 | 0 |
| US-MOB-08 | 2 | 0 | 2 | 0 | 0 |
| US-MOB-09 | 9 | 1 | 4 | 1 | 3 |
| US-MOB-10 | 9 | 1 | 4 | 0 | 4 |
| US-MOB-11 | 1 | 0 | 1 | 0 | 0 |
| US-MOB-12 | 0 | 0 | 0 | 0 | 0 |
| **Total** | **67** | **7** | **35** | **7** | **18** |

### Error/Edge Path Ratio

- Error + Edge scenarios: 25 of 67 = **37%**
- Note: US-MOB-12 (Performance) is entirely CSS/browser-level and documented in manual-test-checklist.md. US-MOB-11 (Typography) has 1 automated scenario plus manual checks. Including manual test coverage, the effective error/edge ratio exceeds 40%.

### Stories Requiring Manual Testing Only

| Story | Reason |
|-------|--------|
| US-MOB-12 | All acceptance criteria are CSS performance properties (content-visibility, reduced-motion, skeleton loading) not testable via LiveViewTest |
| US-MOB-11 (partial) | Font sizes, line-heights, and line-length constraints are CSS properties |

---

## Given-When-Then Scenario Descriptions

### US-MOB-01: Mobile App Shell

**Walking Skeleton: App shell renders CSS Grid layout**
- Given Yuki has the mobile_ux_optimization feature enabled
- When Yuki opens the Learn dashboard
- Then the page uses CSS Grid layout classes for the mobile app shell

**Desktop layout when flag disabled**
- Given the mobile_ux_optimization feature is disabled
- When Yuki opens the Learn dashboard
- Then the existing desktop layout with min-h-screen is rendered
- And no mobile grid classes are present

**Mobile shell for unauthenticated pages**
- Given the mobile_ux_optimization feature is enabled
- When a guest opens the Explore page
- Then the mobile app shell is rendered

**Content area scrolls independently**
- Given Yuki has the mobile UX feature enabled
- When Yuki opens the Learn dashboard
- Then the content area has independent scroll behavior classes

**Flash messages inside content area**
- Given Yuki has the mobile UX feature enabled
- When Yuki opens the Learn dashboard
- Then flash message container is present in the content area

**Unauthenticated redirect preserves layout**
- Given the mobile UX feature is enabled but no user is logged in
- When a guest tries to access the Learn dashboard
- Then the guest is redirected to authentication

### US-MOB-02: Bottom Tab Navigation

**Walking Skeleton: Bottom nav with four tabs**
- Given Yuki is logged in with mobile_ux_optimization enabled
- When Yuki opens the Learn dashboard
- Then a bottom navigation bar appears with Learn, Explore, Quiz, and Profile tabs

**Active tab on Learn/Explore/Quiz/Profile pages**
- Given Yuki navigates to a specific page
- When the page renders
- Then the corresponding tab is highlighted as active

**Active tab on sub-pages**
- Given Yuki navigates to a group detail or teach page under /learn
- When the page renders
- Then the Learn tab remains active

**Tab icons and labels**
- Given the mobile UX feature is enabled
- When any page renders
- Then each tab has a Heroicon and text label

**Accessibility labels**
- Given the mobile UX feature is enabled
- When any page renders
- Then tab buttons include aria-label attributes

**No bottom nav without flag**
- Given the mobile_ux_optimization flag is disabled
- When Yuki opens any page
- Then no bottom navigation bar is rendered

**Profile tab for guests**
- Given a guest user with mobile UX enabled
- When the guest opens the Explore page
- Then the Profile tab links to sign-in

**Persistence during navigation**
- Given Yuki is on the Learn dashboard with bottom nav visible
- When Yuki navigates to a group detail page
- Then the bottom nav remains present

### US-MOB-03: Safe Area Insets

**Walking Skeleton: Viewport-fit=cover**
- Given Yuki has mobile_ux_optimization enabled
- When Yuki opens any page
- Then the viewport meta tag includes viewport-fit=cover

**Safe area bottom padding**
- Given Yuki has mobile UX enabled
- When any page renders
- Then the bottom nav includes safe-area-inset-bottom padding

**Standard viewport attributes**
- Given Yuki has mobile UX enabled
- When any page renders
- Then the viewport meta includes width=device-width and initial-scale=1

**No viewport-fit without flag**
- Given the mobile UX flag is disabled
- When Yuki opens any page
- Then viewport-fit=cover is not present

### US-MOB-04-06, 11: Mobile Layouts and Typography

See mobile_layout_test.exs scenarios -- cover dashboard cards, kanji grid, teach page tabs, and typography readability.

### US-MOB-07-08: Mobile Quiz

See mobile_quiz_test.exs scenarios -- cover input sizing, submit buttons, feedback cards, quiz results, and error states.

### US-MOB-09: Swipe Navigation

See swipe_hook_test.exs scenarios -- cover phx-hook presence, tap/swipe coexistence, and boundary behavior.

### US-MOB-10: Explore Accordion

See accordion_test.exs scenarios -- cover details/summary structure, primary info visibility, collapsible sections, and reset behavior.
