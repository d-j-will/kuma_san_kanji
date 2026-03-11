# ADR-001: LiveView Structure -- Separate LiveViews per Page

## Status

Accepted

## Context

The learning path feature requires four distinct pages: group list, group detail, teach step, and group quiz. Each has different data requirements, event handling, and state management.

The existing codebase uses one LiveView per page (ExploreLive, QuizLive, SettingsLive). The QuizLive is already ~800 lines with session management, rate limiting, and complex state. This project is maintained by a solo developer.

**Quality attributes prioritized**: maintainability, testability, time-to-market.

## Decision

Use four separate LiveViews (`LearnLive`, `GroupLive`, `TeachLive`, `GroupQuizLive`), each with a colocated `.html.heex` template. Navigation between them uses standard `navigate` (full mount) rather than `patch` (handle_params).

## Alternatives Considered

### Alternative A: Single LiveView with handle_params

One `LearnLive` handling all sub-routes via `handle_params/3`, switching rendered content based on URL.

- Pro: Shared state across pages (e.g., group data persists when navigating to teach step).
- Con: Monolithic socket assigns. Quiz state management mixed with teach step. Harder to test each page independently. Violates the pattern already established in the codebase.
- Rejected because: Complexity grows non-linearly. Solo developer needs each page to be independently understandable and testable.

### Alternative B: Live components within a single parent

One parent LiveView with `live_component` for each sub-page.

- Pro: Shared state via parent assigns.
- Con: Parent becomes a router with complex state forwarding. Live components have awkward event bubbling. Testing requires parent context.
- Rejected because: Adds indirection without meaningful benefit over separate LiveViews.

## Consequences

### Positive

- Each LiveView is independently testable with standard `Phoenix.LiveViewTest`.
- Each file stays small (estimated 50-150 lines each).
- Follows established codebase pattern.
- Easy to reason about -- each page has its own mount, assigns, and events.

### Negative

- Navigation between pages causes full LiveView mounts (not patches). For this feature, this is acceptable -- the quiz flow is linear, not tab-switching.
- Group data is re-fetched on each page mount. Acceptable given the small data sizes (max 19 kanji per group).
- Session results from quiz must be passed via URL params (not shared socket state) when returning to group detail.
