Feature: Mobile Learning Experience
  As Yuki Tanaka, a commuter learning kanji on her iPhone,
  I want the app to feel native and comfortable on my phone
  So that I can study effectively during my 25-minute train ride

  Background:
    Given Yuki Tanaka is signed in on her iPhone 14
    And the screen width is 390px (iPhone 14 viewport)
    And the feature flag "grade1_learning_path" is enabled

  # ── Step 1: App Shell & Mobile Viewport ──

  Scenario: Full-viewport app shell with bottom navigation
    When Yuki opens the app on her mobile browser
    Then the page fills the full dynamic viewport height using 100dvh
    And a persistent bottom tab bar is visible with 4 items: Learn, Explore, Quiz, Profile
    And the bottom tab bar respects safe area insets on notched devices
    And the content area scrolls independently of the header and bottom nav

  Scenario: Bottom nav highlights active tab
    When Yuki is on the Learn dashboard at "/learn"
    Then the "Learn" tab in the bottom nav is highlighted as active
    When Yuki navigates to "/explore"
    Then the "Explore" tab is highlighted as active
    And only one tab is highlighted at a time

  Scenario: Safe area insets on notched iPhone
    Given Yuki is using an iPhone with a home indicator bar
    When any page loads
    Then the bottom navigation has padding equal to env(safe-area-inset-bottom)
    And no content is clipped by the home indicator
    And the viewport meta tag includes viewport-fit=cover

  # ── Step 2: Learn Dashboard (Mobile) ──

  Scenario: Learn dashboard displays as mobile-optimized single column
    Given Yuki has learned 32 of 80 kanji across 8 thematic groups
    When Yuki views the Learn dashboard on her phone
    Then the group cards are displayed in a single column stack
    And each group card shows the group name, progress fraction, and progress bar
    And each group card has a minimum tap target of 48x48 pixels
    And the overall progress shows "32 of 80 kanji learned"

  Scenario: Reviews due callout is prominent on mobile
    Given Yuki has 12 kanji reviews due
    When Yuki views the Learn dashboard
    Then the reviews due count "12" is displayed in large text
    And a "Start Review" link is visible without scrolling
    And the review link tap target is at least 48px tall

  Scenario: Study streak displays on mobile dashboard
    Given Yuki has a 5-day study streak
    When Yuki views the Learn dashboard
    Then the streak "5" is displayed alongside the reviews due
    And the stats row text is at least 16px for readability

  # ── Step 3: Group Detail (Mobile) ──

  Scenario: Kanji grid uses touch-friendly sizing
    Given the "Nature & Weather" group has 12 kanji
    And Yuki has learned 7 of them
    When Yuki taps the "Nature & Weather" card on the dashboard
    Then the kanji grid displays in a 4-column layout
    And each kanji character is displayed at minimum 48px (3rem) font size
    And each grid cell is a tap target of at least 48x48 pixels
    And learned kanji show a visual indicator (green border or checkmark)

  Scenario: Continue Learning button is touch-friendly
    Given Yuki has learned 7 of 12 kanji in "Nature & Weather"
    When Yuki views the group detail page
    Then a "Continue Learning" button is visible
    And the button is full-width on mobile
    And the button has a minimum height of 48px
    And tapping the button navigates to kanji at position 8

  Scenario: Back navigation from group detail
    When Yuki is viewing the "Nature & Weather" group detail
    Then a back navigation element links to the Learn dashboard
    And the back navigation tap target is at least 48px

  # ── Step 4: Teach Page (Mobile) ──

  Scenario: Kanji character displays at teaching size on mobile
    Given Yuki is learning the kanji for "rain" at position 8 in "Nature & Weather"
    When the Character tab is active
    Then the kanji character is displayed at 72-128px font size
    And the stroke count "8" and grade "1" are visible
    And the "Show Stroke Order" link has a tap target of at least 48px

  Scenario: Tab navigation is touch-friendly
    Given Yuki is on the teach page for a kanji
    When Yuki views the tab indicators (Character, Meaning, Readings, Examples)
    Then each tab indicator has a tap target of at least 48px
    And the active tab is visually distinct
    And tab labels are visible (not hidden on mobile)

  Scenario: Swipe gestures navigate between tabs
    Given Yuki is on the Character tab of the teach page
    When Yuki swipes left on the content area
    Then the Meaning tab becomes active
    When Yuki swipes left again
    Then the Readings tab becomes active
    When Yuki swipes right
    Then the Meaning tab becomes active again

  Scenario: Tab navigation buttons are full-width on mobile
    Given Yuki is on the Meaning tab (not first, not last)
    Then a "Back" button is visible on the left
    And a "Next" button is visible on the right
    And both buttons have minimum height of 48px

  Scenario: Quiz me button is prominent on last tab
    Given Yuki has reached the Examples tab (last tab)
    Then an "I've learned this -- Quiz me!" button is displayed
    And the button is full-width on mobile
    And the button has a minimum height of 48px
    And the button is visually prominent (accent color)

  Scenario: Prev/next kanji navigation on mobile
    Given Yuki is viewing kanji at position 8 of 12
    Then the header shows "8 of 12"
    And a back arrow and forward arrow are visible in the header
    And each arrow has a tap target of at least 48px

  # ── Step 5: Quiz (Mobile) ──

  Scenario: Quiz input field prevents iOS auto-zoom
    Given Yuki starts a quiz for "Nature & Weather"
    When the quiz question is displayed
    Then the answer input field has a font size of at least 16px
    And tapping the input field does not trigger iOS viewport zoom

  Scenario: Quiz submit button is touch-friendly
    Given Yuki is answering a quiz question
    Then the "Submit Answer" button is full-width
    And the button has a minimum height of 48px
    And the button is below the input field with adequate spacing

  Scenario: Quiz kanji display is large on mobile
    Given Yuki is viewing a quiz question
    Then the kanji character is displayed at minimum 72px font size
    And the progress bar and score are visible without scrolling

  Scenario: Quiz feedback card is readable on mobile
    Given Yuki submits the answer "rain" for the kanji meaning "rain"
    When the feedback card appears showing "Correct!"
    Then the feedback card displays the kanji character, meanings, and readings
    And the "Next" button is full-width with minimum 48px height
    And the feedback content is readable without horizontal scrolling

  Scenario: Quiz input is visible above keyboard
    Given Yuki taps the answer input field on her iPhone
    When the iOS virtual keyboard appears
    Then the input field scrolls into view above the keyboard
    And the submit button remains accessible

  # ── Step 6: Quiz Results (Mobile) ──

  Scenario: Quiz results display with mobile-friendly layout
    Given Yuki completed a quiz with 6 correct and 1 incorrect out of 7
    When the quiz results screen displays
    Then the accuracy "86%" is shown in large text
    And the encouragement message "Good job!" is displayed
    And the correct, incorrect, and total counts are visible

  Scenario: Results action buttons are stacked on mobile
    Given Yuki is viewing quiz results with 1 mistake
    Then three action buttons are displayed in a vertical stack
    And each button is full-width
    And each button has a minimum height of 48px
    And the buttons are: "Review Mistakes", "Back to Nature & Weather", "Continue Learning"

  Scenario: Results breakdown table is scrollable on mobile
    Given Yuki completed a quiz with 7 questions
    When the results breakdown table displays
    Then the table is horizontally scrollable if wider than the viewport
    And the kanji characters in the table are at least 24px font size

  # ── Step 7: Explore Page (Mobile) ──

  Scenario: Explore page uses accordion sections on mobile
    Given Yuki taps the Explore tab in the bottom nav
    When the explore page loads showing the kanji for "rain"
    Then the kanji character is displayed at 72-128px
    And the primary info (grade, strokes, JLPT, meanings) is always visible
    And secondary sections are collapsed by default: Pronunciations, Radical, Common Words, Example Sentences, Thematic Groups, My Notes
    And each accordion header has a tap target of at least 48px

  Scenario: Accordion sections expand on tap
    Given Yuki is viewing the explore page for a kanji
    When Yuki taps the "Pronunciations" accordion header
    Then the Pronunciations section expands showing kun and on readings
    And other sections remain collapsed
    When Yuki taps "Pronunciations" again
    Then the section collapses

  Scenario: Show New Kanji button is touch-friendly
    Given Yuki is on the explore page
    Then the "Show New Kanji" button is prominently displayed
    And the button has a minimum height of 48px
    And tapping the button loads a different kanji

  # ── Error Paths ──

  Scenario: Network reconnection during quiz preserves state
    Given Yuki is on question 4 of 7 in a quiz with 3 correct answers
    When the WebSocket connection drops temporarily
    Then a reconnection banner appears at the top of the page
    When the connection is restored
    Then the quiz resumes at question 4 of 7
    And the score shows 3 correct

  Scenario: Skeleton loading on slow connection
    Given Yuki has a slow mobile connection (3G equivalent)
    When Yuki navigates to the Learn dashboard
    Then placeholder loading states appear for the content area
    And the bottom navigation and header render immediately
    And content replaces placeholders as data arrives

  # ── Cross-Cutting: Typography & Readability ──

  Scenario: Body text meets mobile readability standards
    When any page loads on Yuki's mobile device
    Then body text is at least 16px font size
    And line height is at least 1.5
    And text content has a maximum line length of 40 characters on mobile

  Scenario: Kanji text uses appropriate sizing by context
    When Yuki views kanji characters across the app
    Then kanji in list/grid views are at least 48px (3rem)
    And kanji in detail/teaching views are 72-128px
    And kanji in quiz views are at least 72px

  # ── Cross-Cutting: Performance ──

  Scenario: Content visibility optimization for long pages
    Given the explore page has multiple sections
    When Yuki scrolls through the page
    Then off-screen sections use content-visibility auto for performance
    And scrolling feels smooth without jank

  Scenario: Reduced motion preference respected
    Given Yuki has enabled "Reduce Motion" in her iOS settings
    When Yuki navigates between pages or tabs
    Then transitions use reduced or no animation
    And the prefers-reduced-motion media query is respected
