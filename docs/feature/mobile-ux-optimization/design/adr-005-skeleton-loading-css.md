# ADR-005: Skeleton Loading States -- CSS-Based Implementation

## Status

Accepted

## Context

Release 4 (Performance) includes skeleton loading states for slow connections. When a mobile user on 3G opens a page, there is a delay between the initial static HTML render (LiveView disconnected state) and the fully interactive page (LiveView connected state with data). During this gap, users see either a blank content area or a flash of incomplete content.

The implementation must:
- Provide visual feedback during the disconnected-to-connected transition
- Not add new JavaScript dependencies or server-side complexity
- Work within Phoenix LiveView's two-phase rendering model
- Be lightweight (this is a performance feature -- it must not degrade performance)

## Decision

Use CSS-based skeleton states with Tailwind's `animate-pulse` class on placeholder elements. The skeletons are rendered in the LiveView's disconnected (static) render and replaced by real content when the LiveView connects and loads data.

This leverages LiveView's existing two-phase render:
1. **Disconnected render** (static HTML, no WebSocket): Renders skeleton placeholder divs with `animate-pulse` class
2. **Connected render** (WebSocket established, data loaded): Replaces skeletons with real content via DOM patching

No additional assigns, JavaScript, or server-side logic is needed. The LiveView `connected?(@socket)` check (already a standard LiveView pattern) determines whether to show skeleton or real content.

## Alternatives Considered

### Alternative A: JavaScript-driven loading states with a spinner library
Use a JavaScript loading indicator library (e.g., nprogress, spin.js) to show loading feedback.

- **Pros**: Rich animation options; can show progress percentage; well-tested libraries
- **Cons**: Adds JavaScript dependency; the existing topbar progress indicator already shows navigation loading; a spinner does not indicate content structure (skeleton does); additional JS adds to bundle size and parse time -- counterproductive for a performance feature
- **Rejection rationale**: Adding JavaScript to improve perceived performance is counterproductive. CSS `animate-pulse` has zero JS overhead. The existing topbar progress bar already handles navigation loading. Skeletons add content-structure hints that spinners cannot.

### Alternative B: Server-side streaming with LiveView async assigns
Use LiveView's `assign_async/3` to stream data progressively, showing partial content as each data source resolves.

- **Pros**: Real progressive rendering; shows actual content as it becomes available; built into LiveView
- **Cons**: Requires restructuring every LiveView's mount to use async assigns; adds complexity to data loading logic; changes from synchronous to asynchronous data patterns across 6+ LiveViews; risk of partial/inconsistent states during loading
- **Rejection rationale**: `assign_async` is appropriate for genuinely expensive operations (external API calls, heavy computation). The kanji app's data loads are fast PostgreSQL queries that complete in < 50ms. The perceived delay is the WebSocket connection establishment, not data loading. Skeleton placeholders during connection establishment are the correct solution for this specific latency source. Restructuring all LiveViews for async assigns is disproportionate.

### Alternative C: No skeleton loading (keep current behavior)
Accept the current disconnected-render-to-connected-render transition without visual enhancement.

- **Pros**: Zero effort; no risk of introducing bugs
- **Cons**: On slow 3G connections, users see a blank or partially rendered page for 1-3 seconds. This degrades perceived performance and may cause users to think the app is broken. KPI #8 (TTI < 3s on 3G) requires perceived performance improvements.
- **Rejection rationale**: The R4 release specifically targets mobile performance perception. Skeleton loading is a well-established pattern for improving perceived performance. The cost (adding `animate-pulse` placeholder divs to templates) is minimal and the benefit (immediate visual feedback on slow connections) is significant.

## Consequences

### Positive
- Zero JavaScript overhead (pure CSS animation)
- Leverages existing LiveView rendering model (no architectural changes)
- Skeleton placeholders hint at content structure, reducing perceived wait time
- Consistent with industry-standard loading patterns (used by Facebook, YouTube, LinkedIn)
- Easy to implement: add placeholder divs with `animate-pulse` to disconnected render path

### Negative
- Skeleton HTML adds to initial page size (minimal: a few extra div elements)
- Skeleton design must match actual content layout to avoid jarring transitions (requires design attention)
- Only addresses the disconnected-to-connected gap, not slow data queries (acceptable: data queries are fast)
