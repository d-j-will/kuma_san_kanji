# Journey: Mobile Learning Experience -- Visual Map

## Persona: Yuki Tanaka

Yuki is a 28-year-old software developer learning Japanese as a hobby. She practices kanji during her train commute (25 minutes each way) on her iPhone 14. She has small hands and holds her phone one-handed while standing on a crowded train. She has learned about 30 kanji so far and visits 3-4 times per week. She wants quick, satisfying study sessions that fit into dead time.

---

## Journey Overview

```
[Open App]  -->  [Dashboard]  -->  [Group Detail]  -->  [Teach]  -->  [Quiz]  -->  [Results]
  |                |                 |                  |             |             |
  Mobile           Bottom nav        Kanji grid         Swipe tabs    Touch         Summary
  viewport         persistent        thumb-zone         progressive   answers       + next
  app shell        orientation       scrollable         disclosure    feedback      action
  |                |                 |                  |             |             |
  Feels:           Feels:            Feels:             Feels:        Feels:        Feels:
  Oriented         Grounded          Curious            Focused       Challenged    Accomplished
```

---

## Emotional Arc

```
Confidence
    ^
    |                                                          * Results
    |                                                     *        (Accomplished)
    |                                               *  Quiz
    |                                          (Challenged)
    |                                     *
    |                               * Teach Tabs
    |                          (Focused, Building)
    |                    *
    |              * Group Detail
    |         (Curious, Exploring)
    |    *
    | * Dashboard
    | (Oriented, Grounded)
    +-----------------------------------------------------------> Time

    Key tension: Quiz moment (will I remember?)
    Resolution: Results screen (I'm making progress!)
```

---

## Step 1: App Shell & Viewport

**Trigger**: Yuki opens kanji.davewil.dev on her iPhone browser during commute

**Current State**: Desktop-oriented layout with top navbar, footer with `pb-32`, `min-h-screen` body, `max-w-7xl` content wrapper. No mobile viewport optimization, no bottom navigation, no safe area insets.

**Target State**:
```
+------------------------------------------+
| <- Kuma-san Kanji        [user avatar]   |  <- Compact header (auto height)
+------------------------------------------+
|                                          |
|                                          |
|          Scrollable Content Area         |  <- flex-1, overflow-y-auto
|          (1fr in CSS Grid)               |
|                                          |
|                                          |
|                                          |
+------------------------------------------+
|  [Learn]  [Explore]  [Quiz]  [Profile]   |  <- Bottom tab bar (auto height)
+------------------------------------------+
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    env(safe-area-inset-bottom) padding
```

**Shared Artifacts**:
- `${current_route}` -- determines active tab highlight
- `${current_user}` -- determines auth state, avatar display
- `${viewport_height}` -- `100dvh` for dynamic viewport

**Emotional State**:
- Entry: Distracted (on train, phone in one hand)
- Exit: Oriented (knows where everything is, thumb can reach nav)

---

## Step 2: Learn Dashboard (Mobile)

**Action**: Yuki taps "Learn" tab in bottom nav

**Current State**: `max-w-4xl mx-auto px-4 py-8`, desktop card grid (`grid-cols-1 sm:grid-cols-2 lg:grid-cols-3`), stats row with small text, progress bar adequate.

**Target State**:
```
+------------------------------------------+
| Learn                              [av]  |
+------------------------------------------+
|                                          |
|  32 of 80 kanji learned                  |
|  [=========>........................]     |
|                                          |
|  12 reviews due  [Start Review]          |
|  5 day streak                            |
|                                          |
|  +------------------------------------+  |
|  | Nature & Weather           7/12   |  |
|  | [=====>....................] 58%   |  |
|  +------------------------------------+  |
|                                          |
|  +------------------------------------+  |
|  | Numbers & Counting        12/12   |  |
|  | [=========================] Done  |  |
|  +------------------------------------+  |
|                                          |
|  +------------------------------------+  |
|  | Body & People              0/10   |  |
|  | [..........................] New   |  |
|  +------------------------------------+  |
|                                          |
+------------------------------------------+
|  [Learn*] [Explore] [Quiz]  [Profile]    |
+------------------------------------------+
```

**Key changes**:
- Single column card stack (no grid on mobile)
- Touch-friendly cards (min 48px tap targets)
- "Start Review" link prominent when reviews due
- Stats row uses larger text for readability on train

**Shared Artifacts**:
- `${groups}` -- thematic group list from ContentContext
- `${progress_map}` -- per-group learned/total counts
- `${reviews_due}` -- SRS review count
- `${study_streak}` -- consecutive days

**Emotional State**:
- Entry: Oriented (from app shell)
- Exit: Curious (sees progress, wants to continue)

---

## Step 3: Group Detail (Mobile)

**Action**: Yuki taps "Nature & Weather" group card

**Current State**: `grid-cols-4 sm:grid-cols-6` kanji grid, small kanji characters (`text-2xl`), breadcrumb-style back link.

**Target State**:
```
+------------------------------------------+
| <- Learn    Nature & Weather             |
+------------------------------------------+
|                                          |
|  7 of 12 learned                         |
|                                          |
|  +------+------+------+------+           |
|  |      |      |      |      |           |
|  |  rain | fire | water| tree |           |
|  |  rain | fire | water| tree |           |
|  |  (*)  |  (*) |  (*) |  (*) |           |
|  +------+------+------+------+           |
|  |      |      |      |      |           |
|  |  sun  | moon | earth| gold |           |
|  |  sun  | moon | earth| gold |           |
|  |  (*)  |  (*) |  (*) |      |           |
|  +------+------+------+------+           |
|  |      |      |      |      |           |
|  | wind  | sky  | stone| flower|          |
|  | wind  | sky  | stone| flower|          |
|  |       |      |      |      |           |
|  +------+------+------+------+           |
|                                          |
|  [  Continue Learning  -->  ]            |
|                                          |
+------------------------------------------+
|  [Learn*] [Explore] [Quiz]  [Profile]    |
+------------------------------------------+

(*) = learned indicator (green dot or checkmark)
Kanji characters displayed at min 48px (3rem)
Each cell is a touch target >= 48x48px
```

**Key changes**:
- Kanji characters minimum 48px for readability
- 4-column grid maintained (fits mobile well)
- Each cell is a generous touch target
- Learned status shown with subtle indicator
- "Continue Learning" CTA is full-width, prominent

**Shared Artifacts**:
- `${group}` -- thematic group with name, slug
- `${kanji_list}` -- ordered kanji in group
- `${learned_kanji_ids}` -- set of learned kanji IDs
- `${next_unlearned_position}` -- position of next unlearned kanji

**Emotional State**:
- Entry: Curious (wants to see what's in this group)
- Exit: Motivated (sees progress, knows where to pick up)

---

## Step 4: Teach Page (Mobile)

**Action**: Yuki taps a kanji or "Continue Learning"

**Current State**: `max-w-3xl mx-auto px-4 py-8`, tab indicators with numbered circles, tab content in `min-h-[300px]`, prev/next navigation arrows at top, "Back"/"Next" buttons at bottom.

**Target State**:
```
+------------------------------------------+
| <- Nature     8 of 12                    |
+------------------------------------------+
|                                          |
|    [1]  [2]  [3]  [4]                    |
|    Char Mng  Read Exmp                   |
|    ^^^^                                  |
|    active (highlighted)                  |
|                                          |
|              +--------+                  |
|              |        |                  |
|              |   rain   |                  |
|              |   rain   |                  |
|              |        |                  |
|              +--------+                  |
|         [Show Stroke Order]              |
|                                          |
|         Strokes: 8    Grade: 1           |
|                                          |
|                                          |
|                                          |
|                                          |
|                                          |
|  [<- Back]              [Next ->]        |
+------------------------------------------+
|  [Learn*] [Explore] [Quiz]  [Profile]    |
+------------------------------------------+

Swipe left/right to change tabs (JS hook)
Tab indicators are touch-friendly (48px targets)
Kanji display: 72-128px for detail view
```

**Key changes**:
- Kanji character displayed at 72-128px (detail/teaching size)
- Tab indicators remain compact but touch-friendly
- Swipe gesture support for tab navigation (LiveView JS hook)
- Prev/next kanji navigation in header (not competing with tab nav)
- "Next" and "Back" buttons are full-width on mobile, min 48px height
- "I've learned this -- Quiz me!" button is prominent, full-width

**Shared Artifacts**:
- `${kanji}` -- current kanji with associations
- `${meta}` -- learning metadata (tips, mnemonics)
- `${position}` -- current position in group
- `${total_kanji}` -- total kanji in group
- `${active_tab}` -- current tab (:character, :meaning, :readings, :examples)

**Emotional State**:
- Entry: Focused (ready to learn)
- Exit: Confident (understood the kanji, ready to be tested)

---

## Step 5: Quiz (Mobile)

**Action**: Yuki taps "I've learned this -- Quiz me!" or navigates to quiz

**Current State**: `max-w-3xl mx-auto px-4 py-8`, text input for answers, small submit button, feedback card, progress bar.

**Target State**:
```
+------------------------------------------+
| <- Nature Quiz                           |
+------------------------------------------+
|                                          |
|  Question 3 of 7                         |
|  [======>........................]        |
|  2 correct | 0 incorrect                 |
|                                          |
|                                          |
|              +--------+                  |
|              |        |                  |
|              |   rain   |                  |
|              |   rain   |                  |
|              |        |                  |
|              +--------+                  |
|                                          |
|  What does this kanji mean?              |
|                                          |
|  +------------------------------------+  |
|  |  Type meaning or reading...        |  |
|  +------------------------------------+  |
|                                          |
|  [          Submit Answer          ]     |
|                                          |
+------------------------------------------+
|  [Learn]  [Explore] [Quiz*] [Profile]    |
+------------------------------------------+

Input field: 16px+ font (prevents iOS zoom)
Submit button: full-width, 48px+ height
After answer:
+------------------------------------------+
|  +------------------------------------+  |
|  |  [checkmark] Correct!              |  |
|  |                                    |  |
|  |  Character: rain                     |  |
|  |  Meanings: rain, ame               |  |
|  |  On'yomi: u                         |  |
|  |  Kun'yomi: ame, ama                 |  |
|  |                                    |  |
|  |  Example:                          |  |
|  |  rain ga furu (It rains)             |  |
|  +------------------------------------+  |
|                                          |
|  [            Next  -->            ]     |
+------------------------------------------+
```

**Key changes**:
- Input field uses 16px+ font to prevent iOS auto-zoom
- Submit and Next buttons are full-width, touch-friendly (48px+ height)
- Feedback card optimized for mobile reading
- Kanji display at 72px+ in quiz context
- Progress bar and score visible without scrolling

**Shared Artifacts**:
- `${current_kanji}` -- kanji being quizzed
- `${quiz_pool}` -- shuffled list of learned kanji
- `${results}` -- running correct/incorrect counts
- `${feedback_type}` -- :success or :error

**Emotional State**:
- Entry: Challenged (will I remember?)
- Exit: Either encouraged (correct!) or motivated to review (incorrect -- shown answer)

---

## Step 6: Quiz Results (Mobile)

**Action**: Yuki completes all quiz questions

**Current State**: Summary with accuracy %, correct/incorrect counts, results table, action buttons in `flex-col sm:flex-row`.

**Target State**:
```
+------------------------------------------+
| Nature & Weather Quiz                    |
+------------------------------------------+
|                                          |
|           Quiz Complete!                 |
|                                          |
|              86%                         |
|           Good job!                      |
|                                          |
|     6 Correct    1 Incorrect    7 Total  |
|                                          |
|  +------------------------------------+  |
|  | Kanji | Answer  | Correct | Result |  |
|  |-------|---------|---------|--------|  |
|  |  rain   | rain    | rain    |   [check]   |  |
|  |  fire   | fire    | fire    |   [check]   |  |
|  |  water   | water   | water   |   [check]   |  |
|  |  tree   | leaf    | tree    |   [x]   |  |
|  +------------------------------------+  |
|                                          |
|  [     Review Mistakes     ]             |
|  [     Back to Nature      ]             |
|  [     Continue Learning   ]             |
|                                          |
+------------------------------------------+
|  [Learn*] [Explore] [Quiz]  [Profile]    |
+------------------------------------------+

Action buttons: stacked vertically, full-width
Table: horizontally scrollable if needed
```

**Key changes**:
- Action buttons stacked vertically (already done with `flex-col`)
- All buttons full-width on mobile
- Results table uses horizontal scroll on small screens
- Celebration moment: large accuracy percentage

**Shared Artifacts**:
- `${results}` -- final correct/incorrect counts
- `${per_kanji_results}` -- per-item breakdown
- `${accuracy}` -- calculated percentage

**Emotional State**:
- Entry: Anticipating (how did I do?)
- Exit: Accomplished (see progress, clear next steps)

---

## Step 7: Explore Page (Mobile)

**Action**: Yuki taps "Explore" in bottom nav

**Current State**: Long scrolling page with all kanji details (meanings, pronunciations, radical, thematic groups, educational context, learning tips, example sentences, common words, user notes). Dense, desktop-oriented layout.

**Target State**:
```
+------------------------------------------+
| Explore Kanji                            |
+------------------------------------------+
|                                          |
|  [  Show New Kanji  ]                    |
|                                          |
|              +--------+                  |
|              |        |                  |
|              |   rain   |                  |
|              |   rain   |                  |
|              |        |                  |
|              +--------+                  |
|         [Show Stroke Order]              |
|                                          |
|  Grade: 1    Strokes: 8    JLPT: N4     |
|                                          |
|  +-- Meanings -----------------------+  |
|  |  rain (primary)                    |  |
|  |  precipitation                     |  |
|  +------------------------------------+  |
|                                          |
|  [v] Pronunciations                      |
|  [v] Radical Information                 |
|  [v] Common Words                        |
|  [v] Example Sentences                   |
|  [v] Thematic Groups                     |
|  [v] My Notes                            |
|                                          |
+------------------------------------------+
|  [Learn]  [Explore*] [Quiz]  [Profile]   |
+------------------------------------------+

Collapsed sections use accordion/disclosure pattern
Each section expands inline on tap
Meanings shown expanded by default (primary info)
```

**Key changes**:
- Accordion/collapsible sections for secondary content
- Primary info (kanji, grade, meanings) always visible
- Secondary info (pronunciations, radical, examples, etc.) collapsed by default
- "Show New Kanji" button prominent at top
- Touch-friendly accordion headers (48px+ targets)

**Shared Artifacts**:
- `${kanji}` -- current kanji with all associations
- `${radical}` -- radical information
- `${thematic_info}` -- group membership
- `${learning_meta}` -- learning tips
- `${usage_examples}` -- common words

**Emotional State**:
- Entry: Curious (browsing, discovering)
- Exit: Delighted (found interesting kanji, learned something new)

---

## Error Paths

### E1: Network Loss During Quiz
- Yuki loses cell signal in a tunnel
- LiveView websocket disconnects
- **Expected**: Reconnection banner at top, quiz state preserved on reconnect
- **Feeling**: Briefly anxious, then relieved when it reconnects

### E2: Slow Load on Poor Connection
- Train enters area with weak signal
- Page loads slowly
- **Expected**: Skeleton loading states for content areas, not blank screens
- **Feeling**: Patient (knows content is coming)

### E3: Accidental Navigation During Quiz
- Yuki accidentally taps bottom nav tab during quiz
- **Expected**: Quiz state preserved if she navigates back within session
- **Feeling**: Annoyed briefly, relieved when quiz state is intact

### E4: iOS Keyboard Covering Input
- Quiz input field covered by iOS keyboard
- **Expected**: Input scrolls into view above keyboard, submit button visible
- **Feeling**: No frustration (just works)

### E5: Safe Area Clipping
- Bottom nav overlaps with iPhone home indicator
- **Expected**: `env(safe-area-inset-bottom)` padding prevents overlap
- **Feeling**: No awareness (seamless)

---

## Integration Checkpoints

1. **App Shell <-> All Pages**: Bottom nav active state must match current route
2. **Learn Dashboard <-> Group Detail**: Progress counts must be consistent
3. **Group Detail <-> Teach**: Position navigation must match kanji order in group
4. **Teach <-> Quiz**: "Mark learned" must initialize SRS progress before quiz starts
5. **Quiz <-> Results**: Results counts must match quiz pool length
6. **All Pages <-> Viewport**: `100dvh` must work with bottom nav on all pages
7. **All Pages <-> Safe Areas**: `env(safe-area-inset-*)` must be applied consistently
