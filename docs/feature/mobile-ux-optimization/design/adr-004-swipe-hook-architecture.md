# ADR-004: Swipe Gesture JS Hook Architecture

## Status

Accepted

## Context

The teach page (TeachLive) uses a 4-tab interface (Character, Meaning, Readings, Examples) with existing server-side event handlers for tab navigation (`"next_tab"`, `"prev_tab"`, `"select_tab"`). On mobile, users should be able to swipe left/right to navigate between tabs, matching native app interaction patterns.

The app already has a `MobileSwipeGestures` JS hook used on the QuizLive page for skip/next kanji gestures. The new swipe hook must not conflict with the existing one.

Key constraints:
- Must integrate with existing TeachLive event handlers (no new server-side code)
- Must not interfere with vertical scrolling within tab content
- Must not conflict with existing MobileSwipeGestures hook on quiz pages
- Must follow the existing JS hook pattern established in `assets/js/app.js`

## Decision

Create a new `SwipeTabNavigation` JS hook, registered in the global `Hooks` object in `app.js`. The hook:

1. Listens for `touchstart` and `touchend` events on the element it is bound to
2. Calculates horizontal and vertical displacement
3. Triggers tab navigation only when horizontal displacement > 50px AND horizontal > vertical
4. Pushes existing LiveView events: `"next_tab"` (swipe left) or `"prev_tab"` (swipe right)
5. Is bound via `phx-hook="SwipeTabNavigation"` on the teach page tab content container

The 50px threshold is a constant within the hook (not configurable at runtime).

## Alternatives Considered

### Alternative A: Extend existing MobileSwipeGestures hook with configurable events
Add configuration to the existing `MobileSwipeGestures` hook via `data-` attributes so it can push different events on different pages.

- **Pros**: Reuses existing hook; single swipe implementation to maintain
- **Cons**: The existing hook has quiz-specific logic (checks `data-showFeedback` for feedback mode branching). Adding teach-page logic creates a multi-purpose hook with growing conditional complexity. The two use cases have different event targets (`next_kanji`/`skip_kanji` vs `next_tab`/`prev_tab`) and different behavioral semantics (quiz: swipe = advance/skip; teach: swipe = tab left/right).
- **Rejection rationale**: Combining two different behavioral patterns into one hook violates single responsibility and makes the hook harder to understand and test. The hooks are small (< 30 lines each) so duplication cost is minimal.

### Alternative B: Use a third-party gesture library (e.g., Hammer.js)
Import a gesture recognition library to handle swipe detection with more sophisticated gesture recognition (velocity, direction angle, multi-touch).

- **Pros**: Battle-tested gesture recognition; handles edge cases like diagonal swipes, velocity thresholds
- **Cons**: Adds a new JavaScript dependency (~7KB gzipped); the project has zero npm dependencies beyond Phoenix/LiveView essentials; overkill for a single horizontal swipe gesture; would need to be integrated with LiveView's hook lifecycle
- **Rejection rationale**: The project constraint is no new dependencies. A 20-line touch event handler is sufficient for the horizontal swipe use case. Hammer.js solves problems this feature does not have (pinch, rotate, press, multi-finger gestures).

### Alternative C: CSS scroll-snap with horizontal tab container
Use CSS `scroll-snap-type: x mandatory` on a horizontal scroll container holding all 4 tab content panels, with `scroll-snap-align: start` on each panel.

- **Pros**: Pure CSS, no JavaScript; native momentum scrolling; browser-optimized scroll performance
- **Cons**: All 4 tab content panels must be rendered simultaneously (wasted DOM and potential layout cost); conflicts with LiveView's server-rendered conditional tab content (`case @active_tab do`); would require a fundamental restructure of how TeachLive renders tab content; scroll position and active tab assign would need synchronization logic
- **Rejection rationale**: The existing TeachLive renders only the active tab's content via a `case` statement on `@active_tab`. CSS scroll-snap requires all panels in the DOM simultaneously, which would require restructuring the LiveView rendering model. The architectural change is disproportionate to the benefit.

## Consequences

### Positive
- Clean separation: each hook has a single behavioral responsibility
- Integrates with existing TeachLive event handlers -- zero server-side changes needed
- Follows established project hook pattern (registered in `Hooks` object, uses `this.pushEvent`)
- Graceful degradation: if JavaScript fails, tap-based tab navigation (existing buttons) still works
- Small code footprint (~20 lines)

### Negative
- Two swipe hooks with similar structure (minor code duplication)
- Swipe threshold (50px) is hardcoded -- if user testing reveals a better threshold, a code change is required (acceptable: this is a well-researched standard value)
- Does not detect diagonal swipes or swipe velocity (acceptable: not needed for tab switching)
