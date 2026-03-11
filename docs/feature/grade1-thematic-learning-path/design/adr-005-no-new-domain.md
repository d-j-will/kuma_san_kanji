# ADR-005: No New Ash Domain for Learning Path

## Status

Accepted

## Context

The learning path composes data from three existing domains: Content (groups, metadata), Domain/Kanji (kanji data), and Domain/SRS (user progress). A new "Learning" domain could encapsulate learning-path-specific business logic.

This decision was made in the DISCUSS wave (Decision 6) and is formalized here.

## Decision

Do not create a new Ash domain. The four new LiveViews orchestrate existing domain resources directly via `ContentContext` and `SRS.Logic`. No new Ash resources, no new domain module.

The orchestration layer is the LiveViews themselves, which:
- Call `ContentContext` for group/kanji data
- Call `SRS.Logic` for progress operations
- Manage page-specific state (quiz pool, current position, feedback)

## Alternatives Considered

### Alternative A: New KumaSanKanji.Learning domain

Create `Learning` domain with resources like `LearningSession`, `GroupProgress`, `LearningEvent`.

- Pro: Encapsulates learning-path business rules. Clean domain boundary. Event sourcing potential.
- Con: Adds 3+ new database tables. Duplicates data already in `UserKanjiProgress`. Forces data synchronization between `Learning.GroupProgress` and `SRS.UserKanjiProgress`. Solo developer project -- maintenance cost exceeds benefit.
- Rejected because: Over-engineering for current scope. "Learned" is simply "has a UserKanjiProgress record." No business logic exists yet that warrants its own domain.

### Alternative B: Learning context module (no domain, but a facade)

Create `KumaSanKanji.Learning` as a plain Elixir module (not Ash domain) that wraps all learning-path queries.

- Pro: Single entry point for all learning path data access.
- Con: Adds an abstraction layer over `ContentContext` which is already a facade. Two-level indirection. The new module would mostly delegate to existing functions.
- Rejected because: `ContentContext` already provides the needed facade. Adding another layer is premature abstraction.

## Consequences

### Positive

- Zero new database tables. Zero migration risk.
- Solo developer has fewer modules to maintain.
- If a Learning domain is needed later, extracting it from LiveViews is straightforward (the data access is already through `ContentContext` and `SRS.Logic`, not scattered SQL).

### Negative

- LiveViews contain some orchestration logic (loading group + progress + computing "next unlearned"). If this logic grows complex, it should be extracted to a service module.
- "Learned" state is conflated between "studied via teach step" and "has any SRS record from any source." Acceptable for walking skeleton. A future `learned_via` attribute on `UserKanjiProgress` can disambiguate if needed.
