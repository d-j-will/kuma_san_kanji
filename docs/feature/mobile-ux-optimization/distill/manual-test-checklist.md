# Manual Test Checklist: Mobile UX Optimization

**Feature**: mobile-ux-optimization
**Wave**: DISTILL
**Date**: 2026-03-12

---

## Why Manual Testing Is Required

Phoenix.LiveViewTest renders HTML but does NOT:
- Execute CSS (no computed styles, no pixel measurements)
- Execute JavaScript (no hook behavior, no touch events)
- Simulate viewport sizes (no responsive breakpoint testing)
- Simulate browser chrome (no Safari toolbar, no Dynamic Island)

The following tests MUST be performed manually on real devices or device emulators.

---

## Devices for Testing

| Device | Viewport | Key Feature |
|--------|----------|-------------|
| iPhone SE | 375x667 | Small screen, no notch |
| iPhone 14 | 390x844 | Notch, home indicator |
| iPhone 15 Pro | 393x852 | Dynamic Island |
| iPad (portrait) | 810x1080 | Tablet viewport |
| Samsung Galaxy S24 | 412x915 | Android, no notch |
| Desktop Chrome | 1440x900 | Desktop reference |

---

## R1: Core Mobile Shell

### US-MOB-01: App Shell

- [ ] **DVH-001**: App fills 100dvh on iPhone 14 in Safari -- no vertical scrollbar on body
- [ ] **DVH-002**: App adapts when Safari address bar collapses/expands -- no content jump
- [ ] **DVH-003**: CSS Grid has 3 rows (header auto, content 1fr, nav auto) -- verify in DevTools
- [ ] **DVH-004**: Content area scrolls independently -- header and bottom nav remain fixed
- [ ] **DVH-005**: App shell works on iPhone SE (375x667) -- all three rows fit
- [ ] **DVH-006**: Fallback `100vh` works on older browsers (test by removing dvh)
- [ ] **DVH-007**: LiveView reconnection banner renders inside content area, not overlapping nav

### US-MOB-02: Bottom Tab Navigation

- [ ] **NAV-001**: Tab bar fixed to bottom of viewport on iPhone 14
- [ ] **NAV-002**: Each tab tap target is at minimum 48x48px (measure in DevTools)
- [ ] **NAV-003**: Tabs evenly distributed across screen width
- [ ] **NAV-004**: Tab bar hidden on desktop viewport (>= 768px width)
- [ ] **NAV-005**: Top navbar hidden on mobile viewport (< 768px width)
- [ ] **NAV-006**: Tab bar visible on all pages during navigation
- [ ] **NAV-007**: Active tab highlight visible and matches current page
- [ ] **NAV-008**: Tab icons render as expected Heroicons (academic-cap, magnifying-glass, pencil-square, user)

### US-MOB-03: Safe Area Insets

- [ ] **SAFE-001**: Bottom nav has extra padding on iPhone 14 -- tabs above home indicator
- [ ] **SAFE-002**: Bottom nav flush on Samsung Galaxy (no notch, safe area = 0)
- [ ] **SAFE-003**: Header content does not overlap Dynamic Island on iPhone 15 Pro
- [ ] **SAFE-004**: Content does not go behind status bar on any device

---

## R2: Touch-Optimized Content

### US-MOB-04: Mobile Dashboard

- [ ] **DASH-001**: Stats text (reviews due, streak) at minimum 24px -- readable at arm's length
- [ ] **DASH-002**: "Start Review" link tap target >= 48px
- [ ] **DASH-003**: Group cards single-column on mobile (no side-by-side)
- [ ] **DASH-004**: Group card entire area is tappable, minimum 72px height
- [ ] **DASH-005**: Stats and at least 2 group cards visible without scrolling on iPhone 14

### US-MOB-05: Touch-Friendly Kanji Grid

- [ ] **GRID-001**: Kanji characters in grid displayed at minimum 48px (3rem)
- [ ] **GRID-002**: Each grid cell tap target >= 48x48px
- [ ] **GRID-003**: 4-column grid layout on mobile
- [ ] **GRID-004**: Adequate spacing between grid cells (at least 8px gap)
- [ ] **GRID-005**: Learned kanji have visible indicator (green border/checkmark)
- [ ] **GRID-006**: "Continue Learning" button full-width on mobile, >= 48px height
- [ ] **GRID-007**: No mis-taps when tapping grid cells on moving platform (subjective)

### US-MOB-06: Mobile Teach Page

- [ ] **TEACH-001**: Kanji character displayed at 72-128px on Character tab
- [ ] **TEACH-002**: Tab indicators have tap targets >= 48px each
- [ ] **TEACH-003**: Active tab visually distinct from inactive tabs
- [ ] **TEACH-004**: Next/Back buttons full-width on mobile, >= 48px height
- [ ] **TEACH-005**: "Quiz me!" button full-width, >= 48px height, accent color
- [ ] **TEACH-006**: Prev/next kanji arrows tap targets >= 48px
- [ ] **TEACH-007**: Content area does not overlap with bottom nav

### US-MOB-07: Mobile Quiz

- [ ] **QUIZ-001**: Input field does NOT trigger iOS auto-zoom when tapped (font >= 16px)
- [ ] **QUIZ-002**: Kanji character displayed at minimum 72px in quiz
- [ ] **QUIZ-003**: "Submit Answer" button full-width, >= 48px height
- [ ] **QUIZ-004**: "Next" button full-width, >= 48px height
- [ ] **QUIZ-005**: Input field visible above iOS virtual keyboard
- [ ] **QUIZ-006**: Submit button accessible without dismissing keyboard
- [ ] **QUIZ-007**: Progress bar and score visible without scrolling before answer

### US-MOB-08: Quiz Results

- [ ] **RESULT-001**: Accuracy percentage displayed at >= 36px font size
- [ ] **RESULT-002**: Action buttons stacked vertically, full-width, >= 48px each
- [ ] **RESULT-003**: "Review Mistakes" only shown when mistakes exist
- [ ] **RESULT-004**: Results table scrolls horizontally without page-level scroll
- [ ] **RESULT-005**: Feedback card readable without horizontal scroll on 375px

### US-MOB-11: Typography

- [ ] **TYPO-001**: All body text at least 16px on mobile
- [ ] **TYPO-002**: Line-height at least 1.5 for body text
- [ ] **TYPO-003**: Text lines no more than ~40 characters on 390px screen
- [ ] **TYPO-004**: Horizontal padding >= 16px on each side
- [ ] **TYPO-005**: Furigana text proportional and non-overlapping
- [ ] **TYPO-006**: No text requires pinch-to-zoom to read

---

## R3: Gesture & Progressive Disclosure

### US-MOB-09: Swipe Navigation

- [ ] **SWIPE-001**: Swipe left on teach content area advances to next tab
- [ ] **SWIPE-002**: Swipe right on teach content area retreats to previous tab
- [ ] **SWIPE-003**: Swipe ignored at tab boundaries (no error on first/last tab)
- [ ] **SWIPE-004**: Short swipes (< 50px) do not trigger tab change
- [ ] **SWIPE-005**: Vertical scrolling still works (swipe does not interfere)
- [ ] **SWIPE-006**: Tap navigation works alongside swipe
- [ ] **SWIPE-007**: Swipe feedback is immediate (no perceivable lag)

### US-MOB-10: Explore Accordion

- [ ] **ACC-001**: Accordion headers have tap targets >= 48px height
- [ ] **ACC-002**: Disclosure indicator (chevron/arrow) changes on expand/collapse
- [ ] **ACC-003**: Expand/collapse animation is smooth (if any)
- [ ] **ACC-004**: Desktop view shows all sections expanded (no accordion)
- [ ] **ACC-005**: Keyboard users can toggle accordion with Enter/Space
- [ ] **ACC-006**: Screen reader announces expanded/collapsed state

---

## R4: Performance & Polish

### US-MOB-12: Performance Optimization

- [ ] **PERF-001**: Skeleton loading placeholders appear before content on slow connection (3G throttle in DevTools)
- [ ] **PERF-002**: App shell (header + bottom nav) renders before content data
- [ ] **PERF-003**: content-visibility: auto applied to off-screen explore sections (verify in DevTools)
- [ ] **PERF-004**: overscroll-behavior: contain on main scrollable area (no bounce-through)
- [ ] **PERF-005**: Reduce Motion enabled in iOS: no transitions or animations
- [ ] **PERF-006**: prefers-reduced-motion media query verified in DevTools
- [ ] **PERF-007**: No visible scroll jank on any page (60fps scrolling)
- [ ] **PERF-008**: Lighthouse mobile performance score > 90

---

## Test Execution Notes

1. Test with both `mobile_ux_optimization` flag ON and OFF to verify no desktop regression
2. Test both authenticated (Learn, Quiz, Settings) and unauthenticated (Explore) flows
3. Test in both Safari (iOS) and Chrome (Android) for cross-browser coverage
4. For iOS auto-zoom testing: Settings > Accessibility > Zoom must be OFF
5. Use Chrome DevTools device emulation for initial passes, then real devices for validation
