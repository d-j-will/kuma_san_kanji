Feature: Grade 1 Thematic Learning Path
  As a kanji learner who has been studying with flashcards
  I want a structured learn-then-quiz flow organized by thematic groups
  So that I understand kanji in context instead of memorizing isolated characters

  Background:
    Given the grade1_learning_path feature flag is enabled
    And the 10 Grade 1 thematic groups are seeded with 80 kanji

  # --- Step 1: Browse Thematic Groups ---

  Scenario: Authenticated learner sees all thematic groups
    Given Yuki Tanaka is signed in
    When Yuki navigates to the Learn page
    Then Yuki sees 10 thematic group cards
    And the groups are ordered: Numbers, Directions, Nature, People, Body Parts, Actions, Colors, Time, Places, Objects
    And each card shows the group name and kanji count
    And each card shows a preview of the kanji characters in that group

  Scenario: Thematic group cards show learner progress
    Given Yuki Tanaka is signed in
    And Yuki has learned 3 kanji in the Numbers group
    And Yuki has learned 0 kanji in the Nature group
    When Yuki navigates to the Learn page
    Then the Numbers card shows "3/12 learned"
    And the Nature card shows "Not started"
    And the overall progress shows "3/80 kanji learned"

  Scenario: Unauthenticated visitor cannot access learning path
    Given a visitor is not signed in
    When the visitor navigates to /learn
    Then the visitor is redirected to the sign-in page
    And a flash message says "Sign in to start learning."

  Scenario: Feature flag disabled hides learning path
    Given the grade1_learning_path feature flag is disabled
    And Yuki Tanaka is signed in
    When Yuki looks at the main navigation
    Then there is no "Learn" navigation item
    And navigating directly to /learn redirects to the home page

  # --- Step 2: Enter a Thematic Group ---

  Scenario: Learner opens a thematic group with no prior progress
    Given Yuki Tanaka is signed in
    And Yuki has not learned any kanji in the Numbers group
    When Yuki opens the Numbers group
    Then Yuki sees the heading "Numbers" with description "These form the foundation of the Japanese counting system"
    And Yuki sees a grid of 12 kanji: 一 二 三 四 五 六 七 八 九 十 百 千
    And all kanji are shown as not yet learned
    And "Continue Learning" links to the first kanji 一

  Scenario: Learner opens a partially completed group
    Given Yuki Tanaka is signed in
    And Yuki has learned 一, 二, 三 in the Numbers group
    When Yuki opens the Numbers group
    Then 一, 二, 三 are visually marked as learned
    And 四, 五, 六, 七, 八, 九, 十, 百, 千 are unmarked
    And "Continue Learning" links to 四
    And "Review Learned" is available to quiz on the 3 learned kanji

  Scenario: Learner opens a fully completed group
    Given Yuki Tanaka is signed in
    And Yuki has learned all 12 kanji in the Numbers group
    When Yuki opens the Numbers group
    Then all 12 kanji are marked as learned
    And "Continue Learning" is replaced by "All learned!"
    And "Review All" is available to quiz on all 12 kanji

  # --- Step 3: Learn a Kanji (Teach Step) ---

  Scenario: Learner studies a new kanji in the teach step
    Given Yuki Tanaka is signed in
    And Yuki is learning the Numbers group
    When Yuki opens the learn step for 四
    Then Yuki sees the character 四 displayed prominently
    And Yuki sees the meaning "four"
    And Yuki sees kun readings: よん, よ, よっつ
    And Yuki sees on reading: シ
    And Yuki sees the stroke count: 5
    And Yuki sees an example sentence with translation
    And Yuki sees a "Show stroke order" toggle
    And Yuki sees "I've learned this -- Quiz me!" button

  Scenario: Learner views stroke order animation during teach step
    Given Yuki is on the learn step for 四
    When Yuki clicks "Show stroke order"
    Then an animated stroke order diagram appears for 四
    And the animation shows 5 strokes in correct order

  Scenario: Learner sees learning tips when available
    Given Yuki is on the learn step for 四
    And 四 has a KanjiLearningMeta record with learning tips
    When the page loads
    Then Yuki sees the learning tip section with mnemonic or study hint

  Scenario: Learner navigates between kanji in a group
    Given Yuki is on the learn step for 四 (position 4 of 12)
    When Yuki clicks the next arrow
    Then Yuki sees the learn step for 五 (position 5)
    And when Yuki clicks the previous arrow
    Then Yuki sees the learn step for 四 again

  Scenario: Learner marks a kanji as learned
    Given Yuki is on the learn step for 四
    And Yuki has not previously learned 四
    When Yuki clicks "I've learned this -- Quiz me!"
    Then 四 is recorded as learned in Yuki's progress
    And Yuki is taken to the group quiz scoped to learned kanji

  Scenario: Learner skips a kanji without marking it learned
    Given Yuki is on the learn step for 四
    When Yuki clicks "Skip to next"
    Then 四 is NOT marked as learned
    And Yuki advances to the learn step for 五

  # --- Step 4: Quiz on Learned Kanji ---

  Scenario: Quiz draws only from learned kanji in the group
    Given Yuki has learned 一, 二, 三, 四 in the Numbers group
    When Yuki starts the Numbers group quiz
    Then the quiz presents only 一, 二, 三, 四
    And 五 through 千 do not appear as quiz questions

  Scenario: Learner answers correctly in group quiz
    Given Yuki is quizzing on Numbers group
    And the current question shows 四
    When Yuki types "four" and submits
    Then Yuki sees "Correct!" feedback
    And the feedback shows the example sentence for 四
    And the SRS record for 四 is updated via SM-2 algorithm
    And Yuki can proceed to the next question

  Scenario: Learner answers incorrectly in group quiz
    Given Yuki is quizzing on Numbers group
    And the current question shows 四
    When Yuki types "three" and submits
    Then Yuki sees "Incorrect" feedback
    And the feedback shows the correct meaning "four"
    And the feedback shows readings and example sentence
    And the SRS record for 四 is updated as incorrect

  Scenario: Learner answers with a reading instead of meaning
    Given Yuki is quizzing on Numbers group
    And the current question shows 四
    When Yuki types "よん" and submits
    Then Yuki sees "Correct!" feedback
    And the answer is accepted because readings are valid answers

  Scenario: Learner cannot quiz with zero learned kanji
    Given Yuki has not learned any kanji in the Numbers group
    When Yuki navigates directly to the Numbers quiz URL
    Then Yuki sees "Learn at least one kanji before starting the quiz."
    And a link to "Start with 一" takes Yuki to the first learn step

  # --- Step 5: Group Progress Summary ---

  Scenario: Session results display after quiz completion
    Given Yuki just completed a Numbers quiz session
    And Yuki answered 3 correct and 1 incorrect
    When the quiz session ends
    Then Yuki sees "This session: 3/4 correct"
    And Yuki sees the group progress grid with learned kanji marked
    And "Continue Learning" links to the next unlearned kanji

  Scenario: Overall progress updates across groups
    Given Yuki has learned 12 kanji in Numbers and 3 kanji in Nature
    When Yuki navigates to the Learn page
    Then the Numbers card shows "12/12 learned" with a completion indicator
    And the Nature card shows "3/19 learned"
    And overall progress shows "15/80 kanji learned"

  # --- Error and Edge Cases ---

  Scenario: Thematic group with missing kanji data
    Given the "Colors" thematic group exists
    But no kanji are linked to the Colors group
    When Yuki opens the Colors group
    Then Yuki sees "This group is being prepared. Check back soon."
    And a link back to the groups list

  Scenario: Kanji without example sentences gracefully degrades
    Given Yuki is on the learn step for a kanji that has no example sentences
    When the page loads
    Then the example sentence section is hidden
    And all other information (meaning, readings, stroke count) still displays
