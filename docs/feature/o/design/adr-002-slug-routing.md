# ADR-002: URL Routing -- Slugs for ThematicGroup

## Status

Accepted

## Context

Learning path routes need to identify thematic groups in URLs. The current `ThematicGroup` resource has `id` (UUID) and `name` (string like "Numbers"). Routes need to be human-readable (`/learn/numbers` not `/learn/a1b2c3d4-...`) and stable.

## Decision

Add a `slug` attribute to `ThematicGroup` (e.g., `"numbers"`, `"nature"`, `"body-parts"`). Use slugs in all learning path routes: `/learn/:slug`, `/learn/:slug/:position`, `/learn/:slug/quiz`.

Slugs are generated from the group name at seed time (lowercase, spaces/special chars replaced with hyphens). A unique database index enforces uniqueness. A `by_slug` read action is added to the resource.

## Alternatives Considered

### Alternative A: Use UUID in URLs

Routes like `/learn/a1b2c3d4-e5f6-...`.

- Pro: No schema change needed. Guaranteed unique.
- Con: URLs are ugly and meaningless. Not bookmarkable by humans. Poor UX.
- Rejected because: User-facing URLs should be readable. This is a learning app where users may share links.

### Alternative B: Use name with URL encoding

Routes like `/learn/Abstract%20Concepts%20%26%20Others`.

- Pro: No schema change needed.
- Con: URL encoding makes names ugly. Special characters in names cause issues. Name changes break bookmarks.
- Rejected because: Fragile and ugly. Slugs are the standard solution for human-readable URLs.

### Alternative C: Use order_index as route parameter

Routes like `/learn/1`, `/learn/2`.

- Pro: No schema change. Simple integer.
- Con: Meaningless to users. If group ordering changes, bookmarks break. Collides with position parameter in teach step routes.
- Rejected because: Ambiguous (is `/learn/3/4` group 3 position 4, or something else?) and fragile.

## Consequences

### Positive

- Clean, readable, bookmarkable URLs.
- Stable -- slugs do not change when group order changes.
- Standard web pattern understood by all developers.

### Negative

- Requires a database migration (expand phase, non-breaking).
- Requires backfilling slugs for existing groups.
- Slug generation logic must handle edge cases (the existing group "Abstract Concepts & Others" becomes "abstract-concepts-others").
