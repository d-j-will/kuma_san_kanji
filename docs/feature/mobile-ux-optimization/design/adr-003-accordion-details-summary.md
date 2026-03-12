# ADR-003: Accordion Sections -- Native HTML details/summary

## Status

Accepted

## Context

The Explore page (`ExploreLive`) displays 8+ content sections for each kanji: character display, grade/stroke/JLPT metadata, radical information, thematic groups, educational context, learning tips, meanings, pronunciations, common words, example sentences, and user notes. On mobile, this requires 3-4 screen-heights of scrolling, which overwhelms casual browsing.

DISCUSS decision D5 specifies progressive disclosure via accordion/collapsible sections, with primary information (kanji character, grade, meanings) always visible and secondary sections collapsible.

The implementation must:
- Be accessible (keyboard navigable, screen reader compatible)
- Not add latency for open/close interactions
- Work within the existing LiveView rendering model
- Be consistent with DaisyUI theming

## Decision

Use native HTML `<details>/<summary>` elements, styled with DaisyUI `collapse` utility classes, wrapped in a reusable Phoenix Component (`AccordionSection`).

Primary content sections (kanji character display, grade/stroke/JLPT grid, meanings) remain always visible. Secondary sections (radical, thematic groups, educational context, learning tips, pronunciations, common words, example sentences, user notes) are wrapped in `AccordionSection` components, defaulting to closed on mobile viewports.

On desktop viewports (>= 768px), the accordion sections render with the `open` attribute set, showing all content expanded by default to preserve the current desktop experience.

## Alternatives Considered

### Alternative A: LiveView assigns with conditional rendering
Add a map assign (e.g., `expanded_sections: %{}`) to ExploreLive socket assigns. Each accordion toggle pushes a `"toggle_section"` event to the server, which updates the map and re-renders.

- **Pros**: Server-side state management; state survives DOM patching; can be tracked for analytics
- **Cons**: Every accordion open/close requires a WebSocket round-trip to the server (20-100ms+ latency); adds new event handler and assign management to ExploreLive; increases server load for a purely cosmetic interaction; state resets on page reload (LiveView remount)
- **Rejection rationale**: Accordion open/close is a UI-only interaction with no business logic. Adding server round-trips for cosmetic state is architecturally inappropriate. The latency would be perceptible on mobile networks, degrading the experience this feature aims to improve.

### Alternative B: Alpine.js for client-side accordion state
Add Alpine.js as a lightweight JavaScript framework for client-side toggle state management.

- **Pros**: Clean declarative syntax (`x-show`, `x-transition`); well-integrated with Phoenix/LiveView; rich animation support
- **Cons**: Adds a new JavaScript dependency (~15KB); the project currently has zero frontend framework dependencies beyond Phoenix LiveView essentials; introduces a new paradigm (Alpine directives) alongside LiveView hooks
- **Rejection rationale**: Project constraint is no new dependencies. Native HTML `<details>/<summary>` provides identical functionality for this use case without any JavaScript. Adding Alpine.js for one accordion feature is disproportionate.

### Alternative C: DaisyUI `collapse` with hidden checkbox pattern
Use DaisyUI's `collapse` component with the hidden checkbox pattern (`<input type="checkbox" class="peer">` + `peer-checked:` visibility).

- **Pros**: More animation control than `<details>/<summary>`; DaisyUI-native pattern
- **Cons**: The checkbox pattern is a CSS hack that has accessibility concerns (screen readers may announce "checkbox" instead of "disclosure"); requires more markup boilerplate; `<details>/<summary>` is the semantically correct HTML element for disclosure widgets
- **Rejection rationale**: `<details>/<summary>` is the HTML standard for disclosure. It has built-in accessibility (screen readers announce "expanded"/"collapsed" states, keyboard Enter/Space toggles). The checkbox hack trades semantic correctness for animation flexibility that is not required here.

## Consequences

### Positive
- Zero JavaScript, zero server round-trips for accordion interaction
- Native browser accessibility: keyboard navigation (Enter/Space), screen reader state announcements
- `<details>` element state survives LiveView DOM patching (browser preserves open/closed state)
- Extremely small component (< 15 lines of template code)
- DaisyUI `collapse` classes provide themed transitions consistent with app aesthetic
- Works offline / on poor connections (no server dependency for toggle)

### Negative
- Animation control is limited compared to JavaScript-driven accordions (CSS-only open/close transition)
- Cannot programmatically track which sections users open (no server-side analytics on accordion interaction without additional JS)
- `<details>` element animation support varies slightly across browsers (acceptable: open/close still works, only transition smoothness varies)
