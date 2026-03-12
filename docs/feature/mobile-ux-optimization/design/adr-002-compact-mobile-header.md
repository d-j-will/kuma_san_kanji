# ADR-002: Compact Mobile Header Strategy

## Status

Accepted

## Context

The current top navbar (`KumaSanKanjiWeb.Components.Navigation`) is a full-featured desktop navigation bar containing: logo/title, 6+ navigation links (Home, Explore, Learn, Quiz, Settings, Admin), user greeting, and sign-out button. On mobile, it collapses to a hamburger menu.

With the introduction of a bottom tab bar (ADR-001) for primary navigation on mobile, the top navbar becomes redundant for navigation purposes. However, users still need orientation (which page am I on?) and contextual navigation (back to parent page).

The mobile header must:
- Consume minimal vertical space (vertical screen real estate is precious on mobile)
- Provide page context (current page title)
- Provide back navigation for sub-pages (group detail, teach, quiz)
- Fit within the CSS Grid app shell row 1 (auto height)
- Not duplicate the navigation already provided by the bottom tab bar

## Decision

Hide the desktop navbar entirely on mobile viewports (`hidden md:block`). Replace it with a minimal mobile header bar in the app layout that shows:

1. **Page title** from the `@page_title` LiveView assign (already set by every LiveView)
2. **Back arrow** on sub-pages (pages that are deeper than top-level tab destinations)

The mobile header is a compact single-row element (~44-48px height) with left-aligned back arrow (when applicable) and centered page title.

Back arrow routing logic:
- `/learn/:slug` (group detail) -> back to `/learn`
- `/learn/:slug/:position` (teach) -> back to `/learn/:slug`
- `/learn/:slug/quiz` (group quiz) -> back to `/learn/:slug`
- `/radicals/:id` -> back to `/explore`
- Top-level pages (`/learn`, `/explore`, `/quiz`, `/settings`) -> no back arrow (bottom tabs handle navigation)

## Alternatives Considered

### Alternative A: Keep both desktop navbar and bottom tab bar on mobile
Show the existing hamburger-menu navbar at the top AND the bottom tab bar at the bottom.

- **Pros**: No change to existing navbar; access to all navbar items (admin, sign-out) on mobile
- **Cons**: Consumes ~120px of vertical space (64px navbar + 56px bottom nav), leaving significantly less room for content. The hamburger menu duplicates navigation already in the bottom tabs. Two navigation systems create confusion about which to use.
- **Rejection rationale**: Research (35 sources, including Nielsen Norman Group) consistently warns against dual navigation on mobile. Every pixel of vertical space matters on a 667px-height iPhone SE. The bottom tab bar handles primary navigation; admin and sign-out can be accessed through the Profile/Settings tab.

### Alternative B: Simplify desktop navbar for mobile (remove links, keep logo)
Show a simplified version of the desktop navbar on mobile: just the logo/title, no links, no hamburger menu.

- **Pros**: Consistent branding; reuses existing component with conditional rendering
- **Cons**: The current navbar is 64px tall. Even simplified to logo-only, it consumes more space than a minimal page-title header. The logo/branding adds visual noise without functional value on pages the user has already navigated to. The desktop navbar component would accumulate more mobile conditional logic.
- **Rejection rationale**: On mobile, the app name is already known to the user (they opened it). A 64px branded header on every page provides branding at the cost of content space. A 44px page-title header provides orientation (more useful) in less space.

### Alternative C: No mobile header at all (only bottom tab bar)
Remove all top-of-screen UI on mobile. Use only the bottom tab bar for navigation and orientation.

- **Pros**: Maximum content area; cleanest layout
- **Cons**: Users lose page orientation on sub-pages (teach, group quiz). Without a page title or back button, users on `/learn/nature/3` do not know they are learning kanji 3 in the "Nature" group without reading content. No back navigation without browser back button (which conflicts with LiveView navigation and may exit the app on some mobile browsers).
- **Rejection rationale**: Sub-pages need contextual navigation. The teach page (`/learn/:slug/:position`) is 2 levels deep from the Learn tab. Users need a visible "back to group" action. The browser back button behavior is unreliable in LiveView SPAs.

## Consequences

### Positive
- Maximum content area on mobile (44px header vs 64px navbar = 20px saved)
- Clear page context via title
- Intuitive back navigation on sub-pages
- Desktop navbar completely unchanged (conditional class only)
- Admin links and sign-out accessible through Settings page (Profile tab destination)

### Negative
- Some features currently in the navbar (user greeting, direct admin link) are not visible on mobile header -- they are accessible via Settings/Profile page instead
- Back arrow routing logic adds complexity to the app layout template
- Users accustomed to the hamburger menu will need to discover the bottom tab bar (mitigated: bottom tabs are a well-understood mobile pattern)
