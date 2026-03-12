<!-- markdownlint-disable MD024 -->
# User Stories: Mobile UX Optimization

## US-MOB-01: Mobile App Shell

### Problem
Yuki Tanaka is a 28-year-old developer who studies kanji on her iPhone during her train commute. She finds that the app uses a desktop-oriented layout with `min-h-screen`, a top navbar that wastes space, and a footer with `pb-32` bottom padding that pushes content offscreen. On her iPhone 14, the browser chrome (address bar, toolbar) consumes viewport space unpredictably, causing content to overflow or leave dead zones. She has to pinch, scroll, and fight the layout instead of studying.

### Who
- Mobile learner | Commuting on phone (one-handed) | Wants content to fill available screen without overflow or dead zones

### Solution
A full-viewport app shell using `100dvh` with CSS Grid (`grid-template-rows: auto 1fr auto`) that creates a fixed header, independently scrollable content area, and persistent bottom navigation -- maximizing usable screen real estate on mobile browsers.

### Domain Examples
#### 1: Yuki opens the app on iPhone 14 in portrait mode
Yuki opens kanji.davewil.dev in Safari on her iPhone 14 (390x844 viewport). The app fills the full visible area. The header sits at the top, content scrolls in the middle, and a bottom nav bar sits above the home indicator. No content is hidden behind the Safari toolbar or home indicator.

#### 2: Yuki on iPhone SE (small screen) in Safari
Yuki borrows her friend Kenji's iPhone SE (375x667 viewport). The same app shell adapts -- the header is compact, the content area takes remaining space, the bottom nav sits flush above the screen bottom. Nothing overflows.

#### 3: Yuki rotates to landscape on her iPad
Yuki tries the app on her iPad in landscape. The app shell still works -- `100dvh` adjusts to the landscape viewport, the bottom nav remains anchored, and content fills the wider view. The `max-w-4xl` content constraint prevents overly wide lines.

### UAT Scenarios (BDD)
#### Scenario: App shell fills dynamic viewport height
Given Yuki opens the app on her iPhone 14 in Safari
When the page loads
Then the app shell height equals 100dvh (dynamic viewport height)
And no vertical scrollbar appears on the body element
And the content area scrolls independently of the header and bottom nav

#### Scenario: App shell adapts to browser chrome changes
Given Yuki is scrolling content on the Learn dashboard in mobile Safari
When the Safari address bar collapses (scroll down) or expands (scroll up)
Then the app shell resizes smoothly to fill the new viewport
And no content jumps or layout shifts occur

#### Scenario: App shell works on small viewport
Given Kenji opens the app on an iPhone SE (375x667)
When the page loads
Then the header, content area, and bottom nav all fit within 667px height
And the content area has at least 400px of scrollable space

#### Scenario: CSS Grid layout with three rows
Given Yuki opens any page in the app on mobile
When the page renders
Then the root layout uses CSS Grid with grid-template-rows: auto 1fr auto
And the header row has auto height
And the content row fills remaining space (1fr)
And the bottom nav row has auto height

### Acceptance Criteria
- [ ] Root layout uses `100dvh` height with CSS Grid `grid-template-rows: auto 1fr auto`
- [ ] Content area scrolls independently (overflow-y: auto) without body scroll
- [ ] No vertical scrollbar on body element
- [ ] Layout adapts when mobile browser chrome expands/collapses
- [ ] Works on viewports from 375px to 1440px+ width

### Outcome KPIs
- **Who**: Mobile visitors (screen width < 768px)
- **Does what**: Complete a page load without encountering viewport overflow or dead zones
- **By how much**: From unknown baseline to 100% of mobile page loads with correct viewport fill
- **Measured by**: Absence of body scroll overflow; automated visual regression tests
- **Baseline**: Current layout uses min-h-screen + pb-32, causing overflow on mobile

### Technical Notes
- Requires changes to `root.html.heex` layout template
- `100dvh` has broad browser support (Safari 15.4+, Chrome 108+)
- Must coexist with LiveView flash message rendering
- Desktop layout should remain largely unchanged (CSS Grid is additive)
- Behind feature flag: `mobile_ux_optimization`

---

## US-MOB-02: Bottom Tab Navigation

### Problem
Yuki Tanaka navigates the app using a top navbar designed for desktop mouse interaction. On her phone held one-handed on a crowded train, the top navbar is in the hardest-to-reach zone (Fitts's Law -- top of screen requires thumb stretch). She has to shift her grip or use two hands to tap navigation links, which is awkward and sometimes causes her to drop her phone.

### Who
- Mobile learner | One-handed phone use on transit | Wants to switch between Learn, Explore, Quiz, and Profile without stretching

### Solution
A persistent bottom tab bar with 4 items (Learn, Explore, Quiz, Profile) positioned in the natural thumb zone, using DaisyUI `btm-nav` component patterns. The top navbar is hidden on mobile viewports.

### Domain Examples
#### 1: Yuki switches from Learn to Explore while standing on train
Yuki is reviewing the Learn dashboard. She wants to explore a random kanji. She taps the "Explore" tab at the bottom of the screen with her right thumb without shifting her grip. The explore page loads and the Explore tab highlights.

#### 2: Kenji checks his profile after a quiz
Kenji finishes a quiz and wants to see his settings. He taps the "Profile" tab at the bottom right. The profile/settings page loads, showing his account info and theme preferences.

#### 3: Yuki navigates to Quiz from Explore
Yuki is browsing kanji on the Explore page. She remembers she has reviews due. She taps the "Quiz" tab. The SRS review quiz loads. The Quiz tab highlights as active.

### UAT Scenarios (BDD)
#### Scenario: Bottom tab bar renders on mobile
Given Yuki opens the app on her iPhone 14
When any page loads
Then a bottom tab bar is visible with exactly 4 items: Learn, Explore, Quiz, Profile
And each tab has an icon and a text label
And the tab bar is fixed to the bottom of the viewport

#### Scenario: Active tab reflects current page
Given Yuki is on the Learn dashboard at /learn
Then the Learn tab is highlighted as active
When Yuki taps the Explore tab
Then the app navigates to /explore
And the Explore tab becomes highlighted as active
And the Learn tab is no longer highlighted

#### Scenario: Tab bar hidden on desktop
Given Yuki opens the app on her desktop browser (viewport width 1280px)
When any page loads
Then the bottom tab bar is not visible
And the top navbar is visible

#### Scenario: Tab targets meet touch accessibility standards
Given Yuki views the bottom tab bar on mobile
Then each tab item has a minimum tap target of 48x48 pixels
And tabs are evenly distributed across the screen width

#### Scenario: Tab bar persists during navigation
Given Yuki is on the Learn dashboard
When she navigates to a group detail page at /learn/nature
Then the bottom tab bar remains visible
And the Learn tab remains active

### Acceptance Criteria
- [ ] Bottom tab bar with 4 items: Learn, Explore, Quiz, Profile
- [ ] Each tab has icon + text label
- [ ] Active tab visually highlighted based on current route
- [ ] Tab bar fixed to bottom, persists across all page navigations
- [ ] Each tab tap target >= 48x48px
- [ ] Tab bar hidden on desktop viewports (>= 768px)
- [ ] Top navbar hidden on mobile viewports (< 768px)

### Outcome KPIs
- **Who**: Mobile users
- **Does what**: Navigate between app sections using bottom tabs
- **By how much**: 90%+ of mobile navigation uses bottom tabs (vs. browser back, URL typing)
- **Measured by**: Navigation event tracking (tab clicks vs. other navigation)
- **Baseline**: Currently 0% bottom tab usage (does not exist)

### Technical Notes
- Bottom nav component likely in `app.html.heex` or a new layout component
- Must integrate with Phoenix LiveView navigation (`navigate` or `patch`)
- Active tab determined by comparing `@current_route` or socket assigns to tab paths
- Quiz tab may link to `/quiz` (SRS reviews) or show a quiz selection -- clarify in DESIGN
- Profile tab links to `/settings` for authenticated users, `/sign-in` for guests
- Behind feature flag: `mobile_ux_optimization`

---

## US-MOB-03: Safe Area Insets

### Problem
Yuki Tanaka uses an iPhone 14 which has a notch and a home indicator bar at the bottom. Without safe area inset handling, the bottom tab navigation overlaps with the home indicator, making the bottom-most tab items difficult to tap. Content near the top can also be clipped by the notch/Dynamic Island.

### Who
- Mobile learner | iPhone with notch or Dynamic Island | Wants all UI elements fully visible and tappable

### Solution
Apply `env(safe-area-inset-*)` CSS environment variables to the app shell, ensuring the bottom nav, header, and content respect device-specific safe areas. Add `viewport-fit=cover` to the viewport meta tag.

### Domain Examples
#### 1: Yuki on iPhone 14 (notch + home indicator)
Yuki opens the app. The bottom tab bar has extra padding below it equal to the home indicator height (~34px). She can tap all 4 tabs without her thumb hitting the home indicator gesture area.

#### 2: Kenji on iPhone 15 Pro (Dynamic Island)
Kenji opens the app in Safari. The header content does not overlap with the Dynamic Island. The status bar area is properly padded.

#### 3: Yuki on Android phone (no notch)
Yuki tries the app on her friend's Samsung Galaxy. The safe area insets are zero, so no extra padding is added. The layout looks identical to a standard mobile layout.

### UAT Scenarios (BDD)
#### Scenario: Bottom nav respects safe area on iPhone
Given Yuki opens the app on her iPhone 14
When the bottom tab bar renders
Then the tab bar has bottom padding equal to env(safe-area-inset-bottom)
And all tab items are fully visible above the home indicator

#### Scenario: Viewport meta tag includes viewport-fit
Given Yuki opens the app on any device
When the HTML document loads
Then the viewport meta tag includes viewport-fit=cover
And the viewport meta tag includes width=device-width, initial-scale=1

#### Scenario: Safe areas have no effect on non-notched devices
Given Kenji opens the app on a device without a notch or home indicator
When the page loads
Then env(safe-area-inset-bottom) resolves to 0
And no extra padding is added to the bottom nav

### Acceptance Criteria
- [ ] Viewport meta tag includes `viewport-fit=cover`
- [ ] Bottom nav padding-bottom includes `env(safe-area-inset-bottom)`
- [ ] Header padding-top includes `env(safe-area-inset-top)` where appropriate
- [ ] Safe area values default to 0 on devices without notch/home indicator
- [ ] All 4 bottom tabs remain fully tappable on notched devices

### Outcome KPIs
- **Who**: Mobile users on notched devices (iPhone X and later)
- **Does what**: Tap bottom navigation tabs without interference from home indicator
- **By how much**: 100% of bottom nav taps register correctly (no dead zones)
- **Measured by**: Manual device testing + automated viewport tests
- **Baseline**: Currently untested on notched devices (no bottom nav exists)

### Technical Notes
- Changes to `root.html.heex` (viewport meta tag) and CSS
- `env(safe-area-inset-*)` requires `viewport-fit=cover` to activate
- Tailwind custom utilities may be needed for safe area classes
- Behind feature flag: `mobile_ux_optimization`

---

## US-MOB-04: Mobile Learn Dashboard

### Problem
Yuki Tanaka views the Learn dashboard on her phone and sees group cards in a multi-column grid (`grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`). On her 390px-wide iPhone, the single-column layout works, but the stats row text is small, the "Start Review" link is tiny, and the overall padding wastes space. The card tap targets feel cramped and the progress information is hard to scan quickly during a bumpy train ride.

### Who
- Mobile learner | Quick glance at progress during commute | Wants to see progress and find next action at a glance

### Solution
Optimize the Learn dashboard for mobile: larger stats text, prominent review CTA, touch-friendly card targets, reduced padding for screen efficiency, and readable typography.

### Domain Examples
#### 1: Yuki checks her progress on the train
Yuki opens the Learn tab. She sees "32 of 80 kanji learned" with a progress bar, "12 reviews due" in large text with a prominent "Start Review" link, and "5 day streak." She can read all this at arm's length on a bouncing train.

#### 2: Kenji sees he has no reviews due
Kenji opens the dashboard. The reviews due shows "0" and no "Start Review" link appears. The streak shows "0 day streak." The group cards are still prominently displayed with "Continue Learning" as the implied action.

#### 3: Yuki taps a group card with her thumb
Yuki taps the "Nature & Weather" card. The entire card is a tap target -- she does not need to hit a specific small link. The card responds with visual feedback and navigates to the group detail.

### UAT Scenarios (BDD)
#### Scenario: Dashboard stats readable on mobile
Given Yuki has 12 reviews due and a 5-day streak
When Yuki views the Learn dashboard on her iPhone
Then the reviews due count "12" is displayed at minimum 24px font size
And the streak count "5" is displayed at minimum 24px font size
And the "Start Review" link has a tap target of at least 48px

#### Scenario: Group cards are touch-friendly
Given there are 8 thematic groups on the dashboard
When Yuki views the dashboard on mobile
Then each group card is full-width (single column)
And each card has a minimum height of 72px
And each card's entire area is tappable (not just the text)

#### Scenario: Dashboard content fits without excessive scrolling
Given Yuki is on the Learn dashboard with 8 groups
When the page loads on a 390x844 viewport
Then the stats row (progress, reviews, streak) is visible without scrolling
And at least 2 group cards are visible without scrolling

#### Scenario: Empty dashboard state on mobile
Given Yuki is a new user with no progress
When she views the Learn dashboard
Then the overall progress shows "0 of 80 kanji learned"
And "0 reviews due" is displayed without a review link
And group cards show "Not started" with empty progress bars

### Acceptance Criteria
- [ ] Stats row text (reviews due, streak) at minimum 24px for counts
- [ ] "Start Review" link tap target >= 48px when reviews due > 0
- [ ] Group cards single-column on mobile, each full-width
- [ ] Group card entire area is tappable, minimum 72px height
- [ ] Body text minimum 16px, line-height 1.5
- [ ] Stats and at least 2 group cards visible without scrolling on iPhone 14

### Outcome KPIs
- **Who**: Mobile users on Learn dashboard
- **Does what**: Identify their current progress and choose next action
- **By how much**: Time to first tap (group card or review link) under 5 seconds
- **Measured by**: Session recording analysis on mobile devices
- **Baseline**: Current mobile dashboard requires careful reading of small text

### Technical Notes
- Changes to `learn_live.ex` render function
- Tailwind responsive classes (existing `sm:` breakpoints may need adjustment)
- Behind feature flag: `mobile_ux_optimization`
- Dependency: US-MOB-01 (app shell), US-MOB-02 (bottom nav)

---

## US-MOB-05: Touch-Friendly Kanji Grid

### Problem
Yuki Tanaka views the group detail page on her phone and sees kanji characters in a 4-column grid. The characters are displayed at `text-2xl` (24px) which is legible but small for a learning context -- research recommends minimum 48px for kanji in list views. The grid cells are small tap targets, and on a bumpy train, she sometimes taps the wrong kanji.

### Who
- Mobile learner | Selecting specific kanji from a grid | Wants to tap the right kanji without mis-taps on a moving train

### Solution
Increase kanji character size to minimum 48px (3rem) in the grid, ensure each grid cell meets 48x48px touch target minimum, and add clear visual indicators for learned vs. unlearned kanji.

### Domain Examples
#### 1: Yuki selects a kanji from the Nature & Weather group
Yuki sees 12 kanji in a 4x3 grid. Each character is large and clear. She taps the rain kanji with confidence -- the cell is big enough that she hits it on the first try despite the train swaying.

#### 2: Kenji identifies which kanji he has already learned
Kenji sees the grid for "Numbers & Counting." The 5 kanji he has learned show a green border and subtle checkmark. The 7 unlearned kanji have a neutral border. He can instantly see his progress at a glance.

#### 3: Yuki navigates from the last unlearned kanji
Yuki sees that kanji at positions 1-7 are learned (green) and positions 8-12 are unlearned. The "Continue Learning" button below the grid says it will take her to position 8.

### UAT Scenarios (BDD)
#### Scenario: Kanji characters sized for mobile readability
Given the "Nature & Weather" group has 12 kanji
When Yuki views the group detail on her iPhone
Then each kanji character in the grid is displayed at minimum 48px (3rem) font size
And the grid uses a 4-column layout on mobile

#### Scenario: Grid cells meet touch target minimums
Given the kanji grid is displayed on mobile
Then each grid cell has a minimum tap target of 48x48 pixels
And there is adequate spacing between cells to prevent accidental taps

#### Scenario: Learned indicators are visible on mobile
Given Yuki has learned 7 of 12 kanji in the group
When she views the grid on mobile
Then the 7 learned kanji show a distinct visual indicator (green border or checkmark)
And the 5 unlearned kanji have a neutral appearance
And the indicators are visible without squinting

#### Scenario: Continue Learning button is prominent
Given Yuki has learned 7 of 12 kanji (next unlearned is position 8)
When she views the group detail page on mobile
Then a "Continue Learning" button is displayed below the grid
And the button is full-width on mobile
And the button has minimum 48px height

### Acceptance Criteria
- [ ] Kanji characters in grid displayed at minimum 48px (3rem) font size
- [ ] Each grid cell tap target >= 48x48px
- [ ] 4-column grid layout on mobile
- [ ] Learned kanji have clear visual indicator (green border, checkmark, or both)
- [ ] "Continue Learning" button full-width on mobile, >= 48px height
- [ ] Adequate spacing between grid cells (at least 8px gap)

### Outcome KPIs
- **Who**: Mobile users on group detail page
- **Does what**: Tap intended kanji without mis-taps
- **By how much**: Mis-tap rate below 5% (estimated by tap-then-immediate-back navigation)
- **Measured by**: Navigation pattern analysis (tap group kanji -> immediate back = likely mis-tap)
- **Baseline**: Unknown; current grid cells are small for one-handed mobile use

### Technical Notes
- Changes to `group_live.ex` render function
- Kanji font size increase via CSS class change
- Grid gap and cell padding adjustments
- Behind feature flag: `mobile_ux_optimization`
- Dependency: US-MOB-01 (app shell)

---

## US-MOB-06: Mobile Teach Page

### Problem
Yuki Tanaka is learning a kanji on the teach page on her phone. The kanji character in the Character tab is displayed at a reasonable size in a 128px container, but the tab indicators use small numbered circles that are hard to tap with one hand. The "Back" and "Next" navigation buttons at the bottom are small and not optimized for thumb reach. She cannot swipe between tabs like she would in a native app -- she has to precisely tap small targets.

### Who
- Mobile learner | Studying individual kanji during commute | Wants to flow through Character > Meaning > Readings > Examples without precise tapping

### Solution
Optimize the teach page for mobile: ensure kanji display at 72-128px, enlarge tab indicators to 48px+ touch targets, make Next/Back buttons full-width with 48px+ height, and position the "Quiz me!" CTA prominently.

### Domain Examples
#### 1: Yuki studies the rain kanji on the Character tab
Yuki sees the rain character displayed large and clear (approximately 96px). Below it, "Show Stroke Order" is a tappable link. The tab indicators (1, 2, 3, 4) are large enough to tap without precision. She taps tab 2 (Meaning) comfortably.

#### 2: Yuki advances from Meaning to Readings
Yuki is on the Meaning tab. She taps the "Next" button which spans the full width of the screen and is easy to reach with her thumb. The Readings tab content appears.

#### 3: Yuki reaches the last tab and wants to be quizzed
Yuki is on the Examples tab (tab 4, the last one). Instead of "Next," she sees "I've learned this -- Quiz me!" as a large, full-width, accent-colored button. She taps it confidently and is taken to the quiz.

### UAT Scenarios (BDD)
#### Scenario: Kanji display at teaching size on mobile
Given Yuki is viewing the Character tab for the rain kanji
When the teach page renders on mobile
Then the kanji character is displayed at between 72px and 128px font size
And the character is centered horizontally

#### Scenario: Tab indicators are touch-friendly on mobile
Given Yuki is on the teach page
When she views the tab indicators
Then each tab indicator has a tap target of at least 48px
And tab labels are visible on mobile (not hidden)
And the active tab is visually distinct from inactive tabs

#### Scenario: Navigation buttons are full-width on mobile
Given Yuki is on the Meaning tab (middle tab)
Then the "Back" button is on the left side
And the "Next" button is on the right side
And both buttons have minimum 48px height
And both buttons are easy to reach in the thumb zone

#### Scenario: Quiz me button is prominent on last tab
Given Yuki is on the Examples tab (last tab)
Then an "I've learned this -- Quiz me!" button is displayed
And the button is full-width on mobile
And the button has minimum 48px height
And the button uses the accent color for visual prominence

#### Scenario: Prev/next kanji arrows are touch-friendly
Given Yuki is viewing kanji at position 8 of 12
Then the header shows "8 of 12"
And both the previous and next arrows have tap targets of at least 48px

### Acceptance Criteria
- [ ] Kanji character displayed at 72-128px in teach context
- [ ] Tab indicators have tap targets >= 48px each
- [ ] Tab labels visible on mobile
- [ ] Next/Back buttons full-width on mobile, >= 48px height
- [ ] "Quiz me!" button full-width, >= 48px height, accent color
- [ ] Prev/next kanji arrows tap targets >= 48px
- [ ] Content area does not overlap with bottom nav

### Outcome KPIs
- **Who**: Mobile users on teach page
- **Does what**: Complete all 4 tabs (Character through Examples) for a kanji
- **By how much**: Tab completion rate increases from estimated 60% to 85%+ on mobile
- **Measured by**: Tracking active_tab changes per teach page session
- **Baseline**: Unknown; estimated based on current small touch targets

### Technical Notes
- Changes to `teach_live.ex` render function
- Tab indicator sizing via Tailwind classes
- Button sizing via responsive Tailwind classes
- Behind feature flag: `mobile_ux_optimization`
- Dependency: US-MOB-01 (app shell)

---

## US-MOB-07: Mobile Quiz Experience

### Problem
Yuki Tanaka takes a quiz on her phone. When she taps the text input field to type her answer, iOS Safari zooms in because the input font size is below 16px. After zooming, she has to pinch-zoom back out to see the full layout. The submit button is not full-width and requires precise tapping. On her bouncing train, this makes the quiz frustrating rather than fun.

### Who
- Mobile learner | Taking quiz with virtual keyboard active | Wants to type answers and submit without fighting the interface

### Solution
Set quiz input font size to 16px+ (preventing iOS auto-zoom), make submit and next buttons full-width with 48px+ height, ensure the kanji character is large (72px+), and handle keyboard interaction so the input remains visible.

### Domain Examples
#### 1: Yuki answers a quiz question correctly
Yuki sees the rain kanji displayed large (72px+). She taps the input field -- no zoom occurs. She types "rain" with her iPhone keyboard. She taps the full-width "Submit Answer" button. A green feedback card shows "Correct!" with the kanji details. She taps the full-width "Next" button.

#### 2: Kenji submits an incorrect answer
Kenji sees the fire kanji. He types "water" and taps Submit. A red feedback card shows "Incorrect" with his answer and the correct meanings. The Next button is prominent and full-width. He taps it to continue without frustration.

#### 3: Yuki's keyboard covers the input field
Yuki taps the input field. The iOS keyboard slides up. The page scrolls so the input field is visible above the keyboard. The submit button is also visible. She can type and submit without dismissing the keyboard first.

### UAT Scenarios (BDD)
#### Scenario: Input field does not trigger iOS zoom
Given Yuki taps the quiz answer input field on her iPhone
When the keyboard appears
Then the viewport does not zoom in
And the input field font size is at least 16px

#### Scenario: Quiz kanji is large on mobile
Given Yuki is viewing a quiz question on mobile
Then the kanji character is displayed at minimum 72px font size
And the progress bar and score are visible without scrolling

#### Scenario: Submit button is touch-friendly
Given Yuki has typed an answer in the input field
Then the "Submit Answer" button is full-width
And the button has minimum 48px height
And the button is positioned below the input with adequate spacing

#### Scenario: Feedback card and Next button are mobile-friendly
Given Yuki submitted the correct answer "rain" for the rain kanji
When the feedback card appears
Then the card content (kanji, meanings, readings) is readable without horizontal scrolling
And the "Next" button below the card is full-width with minimum 48px height

#### Scenario: Input visible above keyboard
Given Yuki taps the answer input field on her iPhone
When the iOS virtual keyboard appears
Then the input field is visible above the keyboard
And the submit button is accessible without dismissing the keyboard

### Acceptance Criteria
- [ ] Quiz input font size >= 16px (prevents iOS auto-zoom)
- [ ] Kanji character >= 72px in quiz context
- [ ] "Submit Answer" button full-width, >= 48px height
- [ ] "Next" button full-width, >= 48px height
- [ ] Feedback card readable without horizontal scroll on 375px width
- [ ] Input field visible above virtual keyboard when keyboard is active
- [ ] Progress bar and score visible without scrolling before answer

### Outcome KPIs
- **Who**: Mobile users taking quizzes
- **Does what**: Complete quizzes without encountering auto-zoom or input frustration
- **By how much**: Zero iOS auto-zoom events during quiz (from estimated 60%+ sessions with zoom)
- **Measured by**: Viewport scale change detection via JavaScript
- **Baseline**: Current input font likely < 16px (inherits from form-input-wabi class)

### Technical Notes
- Changes to `group_quiz_live.ex` render function
- Input font size set explicitly in CSS/Tailwind
- Keyboard avoidance may need `scroll-padding-bottom` or `scrollIntoView` in JS hook
- Behind feature flag: `mobile_ux_optimization`
- Dependency: US-MOB-01 (app shell)

---

## US-MOB-08: Mobile Quiz Results

### Problem
Yuki Tanaka finishes a quiz and sees the results screen. The action buttons ("Review Mistakes", "Back to Nature & Weather", "Continue Learning") are in a `flex-col sm:flex-row` layout which works on mobile, but the buttons are not full-width and feel cramped. The results breakdown table overflows horizontally on her 390px screen, requiring awkward horizontal scrolling to see all columns.

### Who
- Mobile learner | Reviewing quiz performance | Wants to see results clearly and choose next action easily

### Solution
Make all results action buttons full-width with 48px+ height on mobile, add horizontal scroll wrapper to the results table, and ensure the celebration moment (accuracy percentage) is prominent.

### Domain Examples
#### 1: Yuki sees her 86% accuracy result
Yuki finishes a 7-question quiz. She sees "86%" in large text (36px+), "Good job!" as encouragement, and her score breakdown (6 correct, 1 incorrect, 7 total). The action buttons are stacked vertically, each spanning the full screen width.

#### 2: Kenji reviews his 100% perfect score
Kenji aces a quiz. He sees "100%" and "Excellent!" No "Review Mistakes" button appears (no mistakes to review). "Back to Numbers" and "Continue Learning" are full-width buttons.

#### 3: Yuki scrolls the results breakdown table
Yuki swipes the results table horizontally to see the "Result" column on her narrow screen. The table scrolls smoothly within its container without affecting the page scroll.

### UAT Scenarios (BDD)
#### Scenario: Accuracy displayed prominently
Given Yuki completed a quiz with 6 correct and 1 incorrect
When the results screen displays
Then "86%" is shown at minimum 36px font size
And "Good job!" is displayed as encouragement text
And the correct/incorrect/total counts are visible

#### Scenario: Action buttons are stacked and full-width
Given Yuki is viewing results with 1 mistake
Then three buttons are displayed in a vertical stack
And each button is full-width on mobile
And each button has minimum 48px height

#### Scenario: No Review Mistakes button when perfect score
Given Kenji completed a quiz with 0 mistakes
When the results screen displays
Then no "Review Mistakes" button is shown
And only "Back to group" and "Continue Learning" are displayed

#### Scenario: Results table scrolls horizontally
Given the results breakdown has 4 columns (Kanji, Answer, Correct, Result)
When the table is wider than the 390px viewport
Then the table container scrolls horizontally
And the page does not scroll horizontally

### Acceptance Criteria
- [ ] Accuracy percentage displayed at >= 36px font size
- [ ] Action buttons stacked vertically, full-width, >= 48px height each
- [ ] "Review Mistakes" only shown when mistakes exist
- [ ] Results table in horizontally scrollable container (overflow-x-auto)
- [ ] Table does not cause page-level horizontal scroll

### Outcome KPIs
- **Who**: Mobile users viewing quiz results
- **Does what**: Choose a post-quiz action (review, back, continue) without struggle
- **By how much**: Post-quiz action rate > 80% (user taps a button vs. using browser back)
- **Measured by**: Click tracking on results page action buttons
- **Baseline**: Unknown; current button layout may cause some users to use browser back instead

### Technical Notes
- Changes to `group_quiz_live.ex` quiz_summary component
- Already has `flex-col sm:flex-row` -- needs full-width on mobile variant
- Table already has `overflow-x-auto` -- verify it works correctly
- Behind feature flag: `mobile_ux_optimization`
- Dependency: US-MOB-07 (mobile quiz)

---

## US-MOB-09: Swipe Tab Navigation

### Problem
Yuki Tanaka is on the teach page studying a kanji. She naturally tries to swipe left on the content area to advance to the next tab, as she does in native iOS apps and other learning apps (Duolingo, Anki). Nothing happens. She has to tap the small tab indicators or the Next button. Swiping feels like the natural gesture on mobile and its absence makes the app feel web-clunky rather than app-like.

### Who
- Mobile learner | Navigating teach page tabs | Wants tab navigation to feel native with swipe gestures

### Solution
Add a LiveView JS hook that detects horizontal swipe gestures on the teach page content area and triggers tab advance (swipe left) or retreat (swipe right).

### Domain Examples
#### 1: Yuki swipes left to advance from Character to Meaning
Yuki is on the Character tab. She swipes left on the kanji display area. The tab smoothly transitions to the Meaning tab. The tab indicator updates to show tab 2 as active.

#### 2: Yuki swipes right to go back from Readings to Meaning
Yuki is on the Readings tab. She swipes right. The Meaning tab content appears. She can review the meaning before going back to readings.

#### 3: Yuki swipes left on the last tab (Examples)
Yuki is on the Examples tab. She swipes left. Nothing happens (already on the last tab). No error, no jarring behavior -- the gesture is simply ignored.

### UAT Scenarios (BDD)
#### Scenario: Swipe left advances tab
Given Yuki is on the Character tab of the teach page on mobile
When Yuki swipes left on the content area (horizontal distance > 50px, speed > threshold)
Then the Meaning tab becomes active
And the tab indicator updates to show tab 2

#### Scenario: Swipe right retreats tab
Given Yuki is on the Readings tab (tab 3)
When Yuki swipes right on the content area
Then the Meaning tab (tab 2) becomes active

#### Scenario: Swipe on first tab left boundary
Given Yuki is on the Character tab (first tab)
When Yuki swipes right on the content area
Then nothing happens (already on first tab)
And no error or visual glitch occurs

#### Scenario: Swipe on last tab right boundary
Given Yuki is on the Examples tab (last tab)
When Yuki swipes left on the content area
Then nothing happens (already on last tab)

#### Scenario: Tap navigation still works alongside swipe
Given swipe gestures are enabled on the teach page
When Yuki taps tab indicator 3 (Readings)
Then the Readings tab becomes active
And both swipe and tap navigation coexist without conflict

### Acceptance Criteria
- [ ] Swipe left on teach content area advances to next tab
- [ ] Swipe right on teach content area retreats to previous tab
- [ ] Swipe ignored at tab boundaries (first tab right-swipe, last tab left-swipe)
- [ ] Minimum swipe distance threshold prevents accidental triggers (50px+)
- [ ] Tap navigation continues to work alongside swipe
- [ ] Arrow key navigation continues to work on desktop
- [ ] Swipe does not interfere with vertical scrolling

### Outcome KPIs
- **Who**: Mobile users on teach page
- **Does what**: Use swipe gestures to navigate tabs
- **By how much**: Swipe accounts for > 40% of tab navigation events on mobile
- **Measured by**: Event tracking (swipe vs. tap vs. button tab changes)
- **Baseline**: 0% swipe usage (not implemented)

### Technical Notes
- Requires new LiveView JS hook (e.g., `SwipeNavigation`)
- Hook attaches touch event listeners to content area
- Must distinguish horizontal swipe from vertical scroll
- Hook pushes `next_tab` or `prev_tab` events to LiveView
- Behind feature flag: `mobile_ux_optimization`
- Dependency: US-MOB-06 (mobile teach page)

---

## US-MOB-10: Explore Accordion Sections

### Problem
Yuki Tanaka visits the Explore page on her phone to browse random kanji. The page shows all information at once -- meanings, pronunciations, radical information, thematic groups, educational context, learning tips, common words, example sentences, and user notes -- in a single long scroll. On her 390px-wide phone, this requires extensive scrolling (estimated 3-4 full screen-heights of content). She often just wants to see the character and its meaning, but has to scroll past everything else.

### Who
- Mobile learner | Browsing kanji casually | Wants to see primary info instantly and expand details on demand

### Solution
Reorganize the Explore page on mobile using accordion/collapsible sections. Primary info (kanji character, grade, strokes, JLPT, meanings) is always visible. Secondary sections (pronunciations, radical, common words, example sentences, thematic groups, notes) are collapsed by default and expand on tap.

### Domain Examples
#### 1: Yuki browses a kanji and only checks the meaning
Yuki sees the rain kanji displayed large, with "Grade 1, 8 strokes, JLPT N4" and meanings "rain, precipitation" always visible. She is satisfied and taps "Show New Kanji" without expanding any sections.

#### 2: Yuki expands Pronunciations to check readings
Yuki sees a kanji and wants to know its readings. She taps the "Pronunciations" accordion header. It expands showing kun and on readings. Other sections remain collapsed. She collapses it and taps "Common Words" next.

#### 3: Kenji expands My Notes to add a mnemonic
Kenji taps "My Notes" at the bottom of the accordion list. The notes section expands showing a textarea. He types a mnemonic and saves. The section remains expanded while he types.

### UAT Scenarios (BDD)
#### Scenario: Primary info always visible on mobile
Given Yuki views the explore page for the rain kanji on mobile
Then the kanji character is displayed at 72-128px
And grade, stroke count, and JLPT level are visible
And meanings are visible without any accordion interaction

#### Scenario: Secondary sections collapsed by default
Given Yuki views the explore page on mobile
Then the following sections are collapsed: Pronunciations, Radical, Common Words, Example Sentences, Thematic Groups, My Notes
And each collapsed section shows only its header with a disclosure indicator

#### Scenario: Tapping accordion header expands section
Given the "Pronunciations" section is collapsed
When Yuki taps the "Pronunciations" header
Then the section expands showing its content
And the disclosure indicator changes to indicate expanded state

#### Scenario: Accordion headers are touch-friendly
Given Yuki views the accordion section headers
Then each header has a tap target of at least 48px height
And headers are visually distinct from content

#### Scenario: Accordion state resets on new kanji
Given Yuki has expanded "Pronunciations" and "Common Words" sections
When Yuki taps "Show New Kanji"
Then a new kanji loads
And all accordion sections are collapsed by default

### Acceptance Criteria
- [ ] Primary info (kanji, grade, strokes, JLPT, meanings) always visible on mobile
- [ ] 6 secondary sections collapsed by default on mobile
- [ ] Tap accordion header toggles section open/closed
- [ ] Accordion headers have tap targets >= 48px
- [ ] Disclosure indicator shows open/closed state
- [ ] All sections collapse when new kanji loads
- [ ] Desktop view continues showing all sections expanded (no accordion on desktop)

### Outcome KPIs
- **Who**: Mobile users on explore page
- **Does what**: Find specific kanji information without excessive scrolling
- **By how much**: Average scroll depth on explore page decreases by 50%+
- **Measured by**: Scroll depth tracking on explore page
- **Baseline**: Current explore page requires 3-4 full screen-heights of scrolling on mobile

### Technical Notes
- Changes to `explore_live.ex` and `explore_live.html.heex`
- Accordion state managed via LiveView assigns (map of section -> open/closed)
- Desktop media query skips accordion behavior (shows all sections)
- Can use `<details>/<summary>` HTML elements or LiveView assigns + conditional rendering
- Behind feature flag: `mobile_ux_optimization`
- Dependency: US-MOB-01 (app shell)

---

## US-MOB-11: Mobile Typography and Readability

### Problem
Yuki Tanaka reads text on the app during her bumpy train commute. Some text elements use sizes below 16px (e.g., info text, labels, metadata), and line heights are inconsistent. On a moving train at arm's length, small text requires squinting. Long text lines run the full width of the 390px screen (minus small padding), exceeding the recommended 30-40 character line length for mobile readability.

### Who
- Mobile learner | Reading on a moving train | Wants all text to be comfortably readable without zooming or squinting

### Solution
Enforce minimum 16px body text, 1.5 line-height, and appropriate line length constraints across all mobile views. Ensure kanji sizing follows the context-based hierarchy (48px lists, 72-128px detail, 72px+ quiz).

### Domain Examples
#### 1: Yuki reads a learning tip on the Meaning tab
Yuki sees a mnemonic hint on the Meaning tab. The text is 16px with 1.5 line-height. The text block is constrained to approximately 35 characters per line on her 390px screen. She reads it easily without strain.

#### 2: Kenji reads example sentences with furigana
Kenji reads Japanese example sentences with furigana annotations on the Examples tab. The sentence text is 18px to accommodate the small furigana above kanji. Line height is generous enough that furigana does not overlap with the line above.

#### 3: Yuki reads the quiz feedback card
After answering a quiz question, Yuki reads the feedback card showing meanings, readings, and an example sentence. All text is at least 16px. The card content does not require horizontal scrolling.

### UAT Scenarios (BDD)
#### Scenario: Body text meets minimum size
Given Yuki views any page on mobile
Then all body text is at least 16px font size
And line-height is at least 1.5 for body text

#### Scenario: Text line length is appropriate for mobile
Given Yuki views text content on her 390px wide screen
Then body text lines contain no more than approximately 40 characters
And text content has adequate horizontal padding (16px minimum each side)

#### Scenario: Kanji sizing follows context hierarchy
Given Yuki views kanji across the app on mobile
Then kanji in grid/list views are at least 48px (3rem)
And kanji in detail/teach views are 72-128px
And kanji in quiz questions are at least 72px

### Acceptance Criteria
- [ ] All body text >= 16px on mobile
- [ ] Line-height >= 1.5 for body text
- [ ] Text line length approximately 30-40 characters on mobile
- [ ] Horizontal padding >= 16px on each side of text content
- [ ] Kanji sizing: 48px+ (list), 72-128px (detail/teach), 72px+ (quiz)
- [ ] Furigana text size proportional and non-overlapping

### Outcome KPIs
- **Who**: Mobile users reading text content
- **Does what**: Read all text content without pinch-to-zoom
- **By how much**: Zero pinch-to-zoom events on text content
- **Measured by**: Viewport scale change detection
- **Baseline**: Unknown; current typography may trigger zoom for small text

### Technical Notes
- May need Tailwind `@apply` or custom CSS for consistent text sizing
- Furigana sizing needs special attention (ruby annotations)
- Line-length constraint via `max-w-prose` or custom max-width
- Behind feature flag: `mobile_ux_optimization`
- Dependency: US-MOB-01 (app shell)

---

## US-MOB-12: Mobile Performance Optimization

### Problem
Yuki Tanaka accesses the app on her phone during her commute. In some areas, her mobile connection drops to 3G speeds. The Explore page, with its dense content (radical info, thematic groups, multiple sections), loads slowly on poor connections. During load, she sees blank content areas rather than loading indicators, which makes her wonder if the app is broken. Some pages have scroll jank when many DOM elements are present.

### Who
- Mobile learner | Variable connection quality during commute | Wants the app to feel fast and responsive regardless of connection

### Solution
Add performance CSS optimizations (`content-visibility: auto`, `overscroll-behavior: contain`), respect `prefers-reduced-motion`, and provide skeleton loading states for content areas.

### Domain Examples
#### 1: Yuki loads the Learn dashboard on 3G
Yuki opens the app on a slow connection. The app shell (header, bottom nav) renders immediately. The content area shows placeholder skeleton shapes where group cards will appear. Cards render one by one as data arrives.

#### 2: Yuki scrolls the Explore page with many sections
Yuki scrolls through the explore page. Off-screen sections use `content-visibility: auto`, so the browser skips rendering them until they are near the viewport. Scrolling feels smooth.

#### 3: Kenji has Reduce Motion enabled on iOS
Kenji has enabled "Reduce Motion" in iOS Accessibility settings. When he navigates between pages, there are no transitions or animations. Tab changes happen instantly without slide effects.

### UAT Scenarios (BDD)
#### Scenario: Skeleton loading on slow connection
Given Yuki has a slow mobile connection
When she navigates to the Learn dashboard
Then the app shell renders immediately (header + bottom nav)
And placeholder loading states appear for the content area
And content replaces placeholders as data arrives

#### Scenario: Content visibility optimization
Given the explore page has multiple accordion sections
When Yuki scrolls through the page
Then off-screen sections use content-visibility auto
And scrolling does not exhibit visible jank

#### Scenario: Reduced motion respected
Given Kenji has enabled "Reduce Motion" in iOS settings
When Kenji navigates between pages or tabs
Then transitions use instant swaps instead of animations
And the prefers-reduced-motion CSS media query is applied

#### Scenario: Overscroll containment
Given Yuki is scrolling the content area on the Learn dashboard
When she scrolls past the top or bottom of the content
Then the page does not exhibit bounce/overscroll behavior that affects the app shell
And overscroll-behavior: contain is applied to the scrollable area

### Acceptance Criteria
- [ ] Skeleton loading states for content areas on initial page load
- [ ] `content-visibility: auto` applied to off-screen sections on explore page
- [ ] `overscroll-behavior: contain` on main scrollable content area
- [ ] `prefers-reduced-motion` media query reduces/removes animations
- [ ] App shell (header + bottom nav) renders before content data
- [ ] No visible scroll jank on any page

### Outcome KPIs
- **Who**: Mobile users on variable connections
- **Does what**: Experience fast-feeling page loads and smooth scrolling
- **By how much**: Time to interactive under 3 seconds on 3G connections
- **Measured by**: Lighthouse performance score on mobile, WebPageTest on 3G profile
- **Baseline**: Unknown; current performance untested on 3G

### Technical Notes
- CSS-only changes for content-visibility, overscroll-behavior, prefers-reduced-motion
- Skeleton loading may need LiveView-specific approach (assign loading states)
- content-visibility: auto can cause layout shift if heights are not estimated
- Behind feature flag: `mobile_ux_optimization`
- Dependency: US-MOB-01 (app shell)
