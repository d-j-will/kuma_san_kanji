# ADR-001: Bottom Navigation -- DaisyUI btm-nav Component

## Status

Accepted

## Context

The mobile UX optimization requires a persistent bottom tab navigation bar with 4 items (Learn, Explore, Quiz, Profile). The app uses Tailwind CSS with DaisyUI as its component library and has an existing top navbar built as a custom Phoenix Component (`KumaSanKanjiWeb.Components.Navigation`).

The bottom nav must:
- Be fixed to the bottom of the viewport
- Highlight the active tab based on current route
- Provide 48px+ tap targets
- Respect safe area insets on notched devices
- Be hidden on desktop viewports (>= 768px)
- Work within Phoenix LiveView navigation (`navigate` attribute)

## Decision

Use DaisyUI `btm-nav` component as the base, implemented as a new Phoenix Component (`KumaSanKanjiWeb.Components.BottomNav`). The component receives `current_path` as an attribute and uses prefix matching to determine the active tab.

The component is rendered in `app.html.heex` with `md:hidden` to restrict it to mobile viewports. Safe area bottom padding is applied via `pb-[env(safe-area-inset-bottom)]`.

## Alternatives Considered

### Alternative A: Fully custom HTML/CSS bottom nav
Build the bottom nav entirely from scratch using raw Tailwind utility classes without DaisyUI's `btm-nav` component.

- **Pros**: Full control over markup, no dependency on DaisyUI component API
- **Cons**: Duplicates work DaisyUI already provides; risk of theme inconsistency (active states, color tokens, transitions would need manual alignment); more CSS to maintain; DaisyUI theme switching (30 themes are configured) would require manual token mapping
- **Rejection rationale**: DaisyUI is the design system. The `btm-nav` component already handles themed active states, positioning, and transitions. Building custom is unnecessary work that risks diverging from the established theme system.

### Alternative B: Extend existing top navbar with bottom positioning on mobile
Reposition the existing `Navigation` component to the bottom on mobile via CSS (position: fixed; bottom: 0).

- **Pros**: Reuses existing component; fewer new files
- **Cons**: The existing navbar has desktop-oriented markup (hamburger menu, sign-out button, admin links, user greeting) that does not translate to a 4-tab mobile pattern. Trying to make one component serve both patterns creates a fragile, hard-to-maintain conditional rendering tree.
- **Rejection rationale**: The desktop navbar and mobile bottom nav have fundamentally different information architecture. The navbar has 6+ items, user greeting, sign-out button. The bottom nav has exactly 4 items with icons. Forcing both into one component violates single responsibility.

### Alternative C: DaisyUI `dock` component (DaisyUI 5.x)
DaisyUI 5.x introduced a `dock` component designed for bottom navigation.

- **Pros**: Newer API, designed for modern mobile patterns
- **Cons**: Requires DaisyUI 5.x upgrade; the project currently uses DaisyUI 4.x; upgrading DaisyUI is a separate concern with potential breaking changes across all existing UI
- **Rejection rationale**: Upgrading DaisyUI is out of scope for this feature. The existing `btm-nav` in DaisyUI 4.x meets all requirements.

## Consequences

### Positive
- Consistent with existing DaisyUI theme system (all 30 configured themes work automatically)
- Active state styling provided by DaisyUI, reducing custom CSS
- Standard pattern recognized by developers familiar with DaisyUI
- Component is small, focused, and testable in isolation

### Negative
- Adds a new component file to the components directory
- Tab-to-route mapping is hardcoded in the component (acceptable for 4 stable tabs)
- If DaisyUI deprecates `btm-nav` in a future version, the component will need updating
