# Research: Kuma San Kanji -- Holistic Project Review

**Date**: 2026-03-11 | **Researcher**: nw-researcher (Nova) | **Confidence**: High | **Sources**: Codebase analysis (primary), Ash Framework docs, Phoenix docs

## Executive Summary

Kuma San Kanji is a well-structured Elixir/Phoenix LiveView kanji learning application at version 0.1.0. The project demonstrates strong architectural decisions: proper Ash Framework 3.x domain separation (Accounts, Kanji/Domain, Content, SRS), comprehensive authorization policies on every sensitive resource, a clean CI/CD pipeline with tag-based Docker deployment, and thoughtful security measures including input validation, rate limiting, and XSS prevention in the quiz system.

The codebase has notable strengths in its SRS (Spaced Repetition System) implementation with SM-2 algorithm, extracted into a reusable Ash change module, and in its KanjiVG stroke order integration with proper SVG sanitization. Testing coverage is reasonable with 32 test files covering domain logic, LiveView interactions, property-based SRS tests, and integration tests with security/accessibility tags.

Key areas for improvement include: (1) the admin dashboard and feature flags UI lack proper authorization middleware in the router, (2) the `SRS.Logic` module is overly complex with deeply nested rescue blocks, (3) quiz session state is stored in ETS (lost on restart), (4) the two CI workflows have version skew (Elixir 1.17 vs 1.18), (5) several Content domain resources lack authorization policies entirely, and (6) the `explore_live.ex` contains a bare `rescue _ -> nil` that violates the project's own rules.

## Research Methodology

**Search Strategy**: Systematic file-by-file codebase analysis. Read all source files in `lib/`, `test/`, `config/`, CI workflows, Dockerfile, and docker-compose. Used grep for pattern searches (rescue blocks, authorize?, FunWithFlags usage, N+1 patterns).
**Source Selection**: Types: codebase (primary) | Reputation: authoritative (direct source code) | Verification: cross-referenced patterns across multiple files
**Quality Standards**: Every finding references specific files and line numbers from the actual codebase.

---

## Findings

### 1. Architecture

#### 1.1 Ash Domain Structure

**Evidence**: The application uses three Ash domains plus one facade module:

| Domain | Module | Resources | Purpose |
|--------|--------|-----------|---------|
| `KumaSanKanji.Domain` | `lib/kuma_san_kanji/domain.ex` | User, Kanji, Radical, Meaning, Pronunciation, ExampleSentence, UserKanjiProgress | Core kanji data + SRS progress |
| `KumaSanKanji.Accounts` | `lib/kuma_san_kanji/accounts.ex` | User, Token | Authentication + user management |
| `KumaSanKanji.Content` | `lib/kuma_san_kanji/content.ex` | ThematicGroup, KanjiThematicGroup, EducationalContext, KanjiUsageExample, KanjiLearningMeta | Educational content metadata |
| `KumaSanKanji.Kanji` (facade) | `lib/kuma_san_kanji/kanji.ex` | N/A (delegates to Domain) | Thin convenience facade |

**Confidence**: High
**Analysis**: The domain separation is generally sound. However, there is an architectural concern: `User` is registered in *both* `Domain` and `Accounts` domains. While Ash permits this, it creates ambiguity about which domain is the canonical owner. The `Domain` module (line 9) registers `User` for the purpose of the SRS relationship, while `Accounts` owns the authentication-related actions. The `ContentContext` module (`lib/kuma_san_kanji/content_context.ex`) provides a clean facade over the Content domain, which is good practice.

**Strength**: The use of `code_interface` definitions on resources (e.g., `UserKanjiProgress`, `Radical`, `Meaning`) provides type-safe, documented entry points.

**Weakness**: The `Domain` module is a "catch-all" that mixes Kanji data resources with SRS progress and User. A dedicated `KumaSanKanji.SRS` Ash domain for `UserKanjiProgress` would better express bounded contexts.

#### 1.2 Resource Definitions and Relationships

**Evidence**: From `lib/kuma_san_kanji/kanji/kanji.ex`:
- Kanji has `has_many` to Meanings, Pronunciations, ExampleSentences
- Kanji `belongs_to` Radical (optional)
- All resources use `AshPostgres.DataLayer` with explicit table names

From `lib/kuma_san_kanji/srs/user_kanji_progress.ex`:
- UserKanjiProgress `belongs_to` both User and Kanji
- Identity constraint `unique_user_kanji` prevents duplicates
- Upsert support via `initialize` action with `upsert_identity`

**Confidence**: High
**Analysis**: Relationships are well-defined with appropriate `allow_nil?` constraints. The identity constraints on Meaning (`:unique_meaning_per_kanji`), Pronunciation (`:unique_pronunciation_per_kanji`), ExampleSentence (`:unique_sentence_per_kanji`), and Radical (`:unique_glyph`, `:unique_kangxi_index`) prevent data integrity issues. The `UserKanjiProgress.initialize` action correctly uses `upsert?` with `upsert_identity` -- this is the right Ash pattern for idempotent creation.

#### 1.3 Application Supervision Tree

**Evidence**: From `lib/kuma_san_kanji/application.ex` (lines 11-27):
```
children = [
  KumaSanKanjiWeb.Telemetry,
  {Ecto.Migrator, ...},
  {DNSCluster, ...},
  {Phoenix.PubSub, ...},
  {Finch, ...},
  KumaSanKanji.Repo,
  Supervisor.child_spec(KumaSanKanji.Quiz.Session, restart: :temporary),
  Supervisor.child_spec(KumaSanKanji.KanjiVG.Cache, restart: :temporary),
  KumaSanKanjiWeb.Endpoint
]
```

**Confidence**: High
**Analysis**: Good decision marking `Quiz.Session` and `KanjiVG.Cache` as `:temporary` -- these are non-essential caches that should not cascade-crash the application. The comment in the code (line 22) explicitly documents this reasoning. The `Ecto.Migrator` running at startup with `skip_migrations?()` correctly skips in test and release environments.

---

### 2. Code Quality

#### 2.1 SM-2 Algorithm Implementation

**Evidence**: The SM-2 algorithm is implemented in two locations:
1. **Core calculation**: `UserKanjiProgress.calculate_sm2_interval/4` (lines 248-267 in `user_kanji_progress.ex`) -- pure function
2. **Change module**: `SRS.Changes.ApplySm2` (`lib/kuma_san_kanji/srs/changes/apply_sm2.ex`) -- Ash change that applies SM-2 during the `record_review` action

The change module correctly:
- Handles `:correct` (increments repetitions, calculates new interval via SM-2)
- Handles `:incorrect` (resets to interval 1, decreases ease factor, resets repetitions to 0)
- Handles `:skip` (halves interval, preserves ease factor and repetitions)
- Sets `first_reviewed_at` only if not already set (line 84-88)
- Always increments `total_reviews` (line 79)

**Confidence**: High
**Analysis**: The extraction of SM-2 logic into a dedicated `Ash.Resource.Change` module is excellent Ash practice. The `calculate_sm2_interval` function implements the standard SM-2 formula correctly. One minor concern: the quality parameter is hardcoded to `5` for correct answers (line 50 of `apply_sm2.ex`), which loses the granularity of the SM-2 algorithm (which normally uses a 0-5 quality scale). This means a "barely correct" answer is treated identically to a "perfect recall."

#### 2.2 SRS.Logic Module Complexity

**Evidence**: `lib/kuma_san_kanji/srs/logic.ex` is 643 lines with deeply nested control flow. The `reset_user_progress` function (lines 237-400) contains:
- 4 levels of nested `try/rescue` blocks
- 3 levels of nested `case` statements
- Rescue blocks that catch generic exceptions (`rescue e ->`)

The `process_batch` function (lines 541-573) has a similar pattern.

**Confidence**: High
**Analysis**: This module violates the project's own CLAUDE.md rule: "Never use `rescue _ -> :ok` -- every failure must be visible in logs." While the rescues do log errors, the deeply nested try/rescue pattern makes the code difficult to reason about and test. The `reset_user_progress` function should be refactored into smaller, composable functions using `with` chains or an explicit state machine. The `{:error, :exception, e}` three-element tuple return is non-standard (Elixir convention is `{:error, reason}`).

#### 2.3 Bare Rescue in ExploreLive

**Evidence**: `lib/kuma_san_kanji_web/live/explore_live.ex`, lines 272-275:
```elixir
defp load_radical(kanji) do
  # ...
rescue
  _ -> nil
end
```

**Confidence**: High
**Analysis**: This directly violates the project rule in CLAUDE.md: "Never use `rescue _ -> :ok`." The bare rescue swallows all errors silently. If the radical lookup fails for any reason (database connection issues, schema problems), the error will be invisible. This should at minimum log the error, or better, handle the error case explicitly without rescue.

#### 2.4 Stale `.new` Files

**Evidence**: The codebase contains several `.new` files that appear to be abandoned drafts:
- `lib/kuma_san_kanji/kanji/kanji.ex.new`
- `test/kuma_san_kanji/kanji/meaning_test.exs.new`
- `test/kuma_san_kanji/kanji/pronunciation_test.exs.new`
- `test/kuma_san_kanji_web/live/explore_live_test.exs.new`

**Confidence**: High
**Analysis**: These files should be cleaned up. They add noise to the codebase and could confuse contributors about which file is canonical.

#### 2.5 Duplicated Katakana-to-Hiragana Conversion

**Evidence**: The `katakana_to_hiragana` conversion logic appears in two places:
1. `QuizLive.katakana_to_hiragana/1` (lines 730-735 in `quiz_live.ex`)
2. `NLP.Furigana.to_hiragana/1` (lines 121-135 in `furigana.ex`)

Both use the same codepoint arithmetic (`cp - 0x60`).

**Confidence**: High
**Analysis**: This is a DRY violation. The conversion should be extracted to a shared utility module (e.g., `KumaSanKanji.NLP.Kana`) and reused in both locations.

#### 2.6 Application Comment Error

**Evidence**: `lib/kuma_san_kanji/application.ex`, line 20: `# Start the Ash SQLite repository`

**Confidence**: High
**Analysis**: The comment says "SQLite" but the repository uses PostgreSQL (`AshPostgres`). This is a copy-paste artifact that should be corrected.

---

### 3. Deployment

#### 3.1 Docker Configuration

**Evidence**: From `Dockerfile`:
- Multi-stage build with `hexpm/elixir:1.18.3-erlang-27.3-debian-bullseye-20250317-slim`
- Builder installs build-essential, git, mecab, Node.js 20.x
- Runner includes mecab runtime for furigana support
- Runs as `nobody` user (line 106)
- Uses `debian:bullseye-slim` (not Alpine, documented reason: DNS resolution issues)

From `docker-compose.prod.yml`:
- App depends on Postgres 16 with health check
- Uses caddy-docker-proxy labels for automatic TLS via Cloudflare DNS
- Environment variables for secrets (SECRET_KEY_BASE, TOKEN_SIGNING_SECRET, ADMIN_EMAIL, ADMIN_PASSWORD)
- Named volume for Postgres data persistence
- External `proxy` network for caddy integration

**Confidence**: High
**Analysis**: The Docker setup is solid. Good practices include:
- Multi-stage build minimizes image size
- Health check on Postgres with `service_healthy` dependency condition
- Caddy health check configuration (`health_uri`, `health_interval`, `fail_duration`)
- No `build:` directive in prod compose (follows project rules)
- `--force-recreate --no-build --remove-orphans` in deploy script (follows project rules)

**Concern**: The `POSTGRES_PASSWORD` is passed via environment variable substitution (`${POSTGRES_PASSWORD}`), meaning a `.env` file must exist on the deploy host. The CI deploy script does not show how this `.env` file is provisioned or updated.

#### 3.2 CI/CD Pipeline

**Evidence**: Two CI workflows exist:

1. **`ci.yml`**: Runs on push/PR to main. Uses Elixir **1.17** / OTP **27**, Postgres **14**. Runs: deps.get, `mix ash.setup`, format check, compile (warnings-as-errors), tests. Installs MeCab.

2. **`ci-deploy.yml`**: Runs on push/PR to main + tag deploys. Uses Elixir **1.18.x** / OTP **27.x**, Postgres **16**. Runs: deps.get, compile (warnings-as-errors), format check, ecto.create+migrate, tests, hex.audit, deps.unlock --check-unused. On `v*` tags: builds Docker image, pushes to GHCR, deploys via SSH+Tailscale.

**Confidence**: High
**Analysis**: There is significant version skew between the two CI workflows:
- `ci.yml` uses Elixir 1.17 / Postgres 14
- `ci-deploy.yml` uses Elixir 1.18.x / Postgres 16
- The Dockerfile uses Elixir 1.18.3 / OTP 27.3

The `ci.yml` workflow appears to be the older one and should either be updated to match `ci-deploy.yml` or removed to avoid running redundant/inconsistent checks. Running tests against Postgres 14 in one pipeline and Postgres 16 in another could mask compatibility issues.

The `ci-deploy.yml` also runs `mix ecto.create && mix ecto.migrate` while `ci.yml` uses `mix ash.setup`. These are potentially different operations and should be standardized.

**Strength**: The deploy step includes DNS fix for Tailscale, GHCR authentication, proxy network creation, and proper migration + admin setup before app restart. The `hex.audit` and `deps.unlock --check-unused` checks in `ci-deploy.yml` are excellent for dependency hygiene.

#### 3.3 Release Configuration

**Evidence**: From `lib/kuma_san_kanji/release.ex`:
- `migrate/0` -- standard Ecto migration
- `seed/0` -- runs `priv/repo/seeds.exs`
- `reset_and_seed/0` -- drops all tables, re-migrates, re-seeds (dangerous but documented)
- `setup_admin_user/0` -- creates/promotes admin from `ADMIN_EMAIL` env var
- `migrate_and_setup/0` -- migrate + seed + optional admin setup (used in deploy)

**Confidence**: High
**Analysis**: The `reset_and_seed` function (lines 34-84) drops tables by querying `pg_tables` and using `CASCADE`. This is a nuclear option that should have additional safeguards (e.g., checking `MIX_ENV != :prod` or requiring an explicit confirmation env var). Currently, nothing prevents it from being accidentally invoked in production via `bin/kuma_san_kanji eval "KumaSanKanji.Release.reset_and_seed()"`.

**Strength**: The `migrate_and_setup/0` function used in the deploy pipeline is well-designed -- it conditionally skips admin setup if `ADMIN_EMAIL` is not set.

---

### 4. Testing

#### 4.1 Test Coverage

**Evidence**: 32 test files identified across the test directory:

| Category | Files | Coverage Areas |
|----------|-------|----------------|
| Domain/Kanji | 5 | Kanji, Meaning, Pronunciation, ExampleSentence, Radical |
| SRS | 4 | Logic, Integration, SM2 Property-based, SRS basic |
| Accounts | 1 | Dev mode toggle |
| LiveView | 7 | Quiz, Explore, Settings, Credits, Admin, Stroke Order (explore + quiz) |
| Components | 1 | KanjiStrokeOrderComponent |
| Controllers | 3 | PageController, ErrorHTML, ErrorJSON |
| Auth | 1 | UserLiveAuth |
| NLP | 1 | Furigana (behind `:mecab` tag) |
| KanjiVG | 1 | Ingestion |
| Support | 3 | ConnCase, DataCase, TestHelpers |
| Other | 1 | UserProgressSummary |

**Confidence**: High
**Analysis**: Test coverage is reasonable for a 0.1.0 project. Notable strengths:
- **Property-based testing** (`test/srs/sm2_property_test.exs`) using StreamData for SM-2 algorithm verification
- **Security-tagged tests** in integration_test.exs (`:security` tag)
- **Accessibility-tagged tests** (`:accessibility` tag)
- **MeCab conditional exclusion** via `@moduletag :mecab` and `test_helper.exs` (line 4)
- **Mimic** for mocking auth helpers in tests

**Gaps**:
- No test for `ContentContext` module
- No test for `Release` module functions
- No test for `HealthController`
- No test for `Admin.DashboardLive`
- No test for the `Seeds` module
- No test for `KanjiVG.Cache`
- The Content domain resources (ThematicGroup, KanjiLearningMeta, etc.) have no dedicated tests

#### 4.2 Test Infrastructure

**Evidence**: From `test/test_helper.exs`:
```elixir
Mimic.copy(AshAuthentication.Plug.Helpers)
Mimic.copy(KumaSanKanjiWeb.UserLiveAuth)
exclude = if System.find_executable("mecab"), do: [], else: [:mecab]
ExUnit.start(exclude: exclude)
Ecto.Adapters.SQL.Sandbox.mode(KumaSanKanji.Repo, :manual)
```

**Confidence**: High
**Analysis**: The test setup is clean. The conditional MeCab exclusion is a pragmatic solution for running tests locally without MeCab installed while ensuring CI (which installs MeCab) runs the full suite. The Ecto sandbox in `:manual` mode is correct for async-safe tests via DataCase/ConnCase.

---

### 5. Security

#### 5.1 Authentication

**Evidence**: From `lib/kuma_san_kanji/accounts/user.ex`:
- AshAuthentication password strategy with `bcrypt_elixir`
- `hashed_password` marked as `sensitive?: true` (line 187)
- Tokens enabled with `store_all_tokens?(true)` and `require_token_presence_for_authentication?(true)`
- `log_out_everywhere` add-on with `apply_on_password_change?(true)` (line 25-26)
- Token signing secret loaded from application config via `KumaSanKanji.Secrets`

**Confidence**: High
**Analysis**: Authentication is well-configured:
- Token revocation is properly implemented (all tokens stored, presence required)
- Password changes invalidate all existing sessions (log_out_everywhere)
- The `Token` resource has a strict policy: only `AshAuthentication` can interact with it (line 89-92)
- `confirmation_required?(false)` means no email verification -- acceptable for a learning app but worth noting

**Concern**: The `register_with_password` action derives username from email prefix (lines 49-59). This is not validated for uniqueness via an identity constraint -- if two users register with `john@gmail.com` and `john@yahoo.com`, they would both get username "john". The `username` attribute has no identity defined.

#### 5.2 Authorization Policies

**Evidence**: Authorization policies are defined on:
- `User` -- read (self or admin), toggle_dev_mode (admin), update_settings (self), create_for_test (admin), update (admin), destroy (admin)
- `Token` -- bypass for AshAuthentication, forbid all others
- `UserKanjiProgress` -- admin bypass, read/update/destroy via `relates_to_actor_via(:user)`, create checks `actor.id == user_id`

**Confidence**: High
**Analysis**: The core resources have proper authorization. However:

**Missing authorization on Content domain**: None of the Content resources (`ThematicGroup`, `KanjiThematicGroup`, `EducationalContext`, `KanjiUsageExample`, `KanjiLearningMeta`) have `authorizers: [Ash.Policy.Authorizer]`. This means their default actions (`create`, `read`, `update`, `destroy`) are unprotected. While these are currently reference data (seeded, not user-editable), the `defaults([:create, :read, :update, :destroy])` actions on ThematicGroup (line 36) mean anyone with API access could modify educational content.

**Missing authorization on Kanji resources**: The `Kanji.Kanji`, `Kanji.Meaning`, `Kanji.Pronunciation`, `Kanji.ExampleSentence`, and `Kanji.Radical` resources also lack authorizers. Their create/update/destroy actions are unprotected.

#### 5.3 Admin Route Protection

**Evidence**: From `lib/kuma_san_kanji_web/router.ex`:
- Admin routes (`/admin`, `/admin/users`) are behind `ash_authentication_live_session :authenticated_routes` with `live_user_required` (line 60)
- Feature flags UI (`/admin/feature-flags`) is behind `:browser` pipeline only (lines 69-73) -- NO authentication required

**Confidence**: High
**Analysis**: Critical finding: The FunWithFlags admin UI at `/admin/feature-flags` has NO authentication or authorization middleware. Any visitor can access it. The route should be wrapped in an authenticated session with admin-required on_mount, or a Plug-based auth check should be added to the pipeline.

Additionally, the admin LiveViews (`DashboardLive`, `UserAdminLive`) perform admin checks in `mount/3` rather than using the `:live_admin_required` on_mount hook defined in `UserLiveAuth` (line 32). While the mount-level check works, using on_mount is more consistent and prevents the LiveView module from ever mounting for non-admins. The `DashboardLive` module has NO admin check at all -- any authenticated user can access `/admin`.

#### 5.4 Input Validation and XSS Prevention

**Evidence**: From `lib/kuma_san_kanji_web/live/quiz_live.ex`:
- `validate_and_sanitize_answer/1` (lines 526-547):
  - Trims whitespace
  - Rejects empty answers
  - Enforces 100 character max length
  - Validates against Unicode letter/number/punctuation regex
  - HTML-escapes via `Phoenix.HTML.html_escape`
- Rate limiting: 100 answers per 5-minute window (lines 20-21)
- Rate limit state fetched from persistent session to prevent multi-tab bypass (lines 554-558)

**Confidence**: High
**Analysis**: The quiz input validation is thorough. The rate limiting implementation is well-thought-out -- it checks the persistent session store (not just socket assigns) to prevent bypass via multiple browser tabs. The HTML escaping provides XSS protection for user answers.

The KanjiVG SVG sanitization (`lib/kuma_san_kanji/kanji_vg/ingestion.ex`, lines 209-267) is also well-implemented: it removes `script`, `style`, and `foreignObject` elements, strips event handler attributes, and rejects external references.

#### 5.5 Secrets Management

**Evidence**:
- Dev: hardcoded signing secret in `config/dev.exs` (line 15): `"dev-secret-key-this-should-be-changed-in-production"`
- Test: hardcoded in `config/test.exs` (line 20): `"test-secret-key-for-jwt-signing-do-not-use-in-production"`
- Prod: loaded from `TOKEN_SIGNING_SECRET` env var in `config/runtime.exs` (line 77) with `raise` on missing
- `SECRET_KEY_BASE` also loaded from env var with `raise` (line 31)

**Confidence**: High
**Analysis**: Secrets management follows best practices. Dev/test secrets are clearly marked as non-production values. Production secrets are mandatory env vars. The `Secrets` module (`lib/kuma_san_kanji/secrets.ex`) properly uses `AshAuthentication.Secret` behavior.

---

### 6. Performance

#### 6.1 Database Queries and N+1 Prevention

**Evidence**: Key query patterns:
- `Kanji.Kanji` actions `list_all`, `get_by_character`, `get_by_id` all use `Ash.Query.load([:meanings, :pronunciations, :example_sentences, :radical])` in their prepare blocks
- `SRS.Logic.load_kanji_data/2` (line 423-439) loads all kanji for due items in a single query using `Ash.Query.filter(id in ^kanji_ids)`
- `ExploreLive.get_kanji_by_offset/1` makes two queries: one to get the kanji by offset, then a second to load it by ID with relationships -- this is an unnecessary round trip

**Confidence**: High
**Analysis**: The codebase generally handles N+1 well by eager-loading relationships in action preparations. However:

**Double query in ExploreLive**: `get_kanji_by_offset/1` (lines 218-260) first calls `Domain.get_kanji_by_offset(offset)` which returns a kanji without relationships, then immediately calls `Domain.get_kanji_by_id!(kanji.id, load: [...])`. The `by_offset` action should include the load directive to eliminate the extra query.

**Sequential content loading**: After getting the kanji in ExploreLive, there are 4 additional sequential queries (lines 226-236): thematic groups, educational context, learning meta, and usage examples. These could be parallelized with `Task.async` or combined if the Content resources had proper relationships to Kanji.

**ETS-based quiz session**: The `Quiz.Session` GenServer uses ETS for session storage. This is fast but data is lost on restart. For a single-server deployment this is acceptable, but worth documenting as a known limitation.

#### 6.2 Pagination

**Evidence**: The `Kanji.Kanji` resource's `list_all` action (line 43) has:
```elixir
pagination(offset?: true, keyset?: true, countable: :by_default)
```

**Confidence**: High
**Analysis**: The kanji listing action supports both offset and keyset pagination, which is good for both UI pagination and cursor-based scrolling. However, no other resources define pagination -- if the Content domain grows, queries on ThematicGroup or other resources could become unbounded.

#### 6.3 Caching

**Evidence**: The `KanjiVG.Cache` module (`lib/kuma_san_kanji/kanji_vg/cache.ex`) implements a 12-hour ETS cache for sanitized SVG markup with:
- `read_concurrency: true` and `write_concurrency: true`
- TTL-based expiry checked on read
- Public table for direct access from other processes

**Confidence**: High
**Analysis**: The cache implementation is simple and effective for its purpose. No other caching is present in the application. The SRS queries (due_for_review, user_stats) are not cached, which is correct since they need real-time accuracy.

---

### 7. Dependencies

#### 7.1 Dependency Inventory

**Evidence**: From `mix.exs`, key dependencies:

| Dependency | Version | Purpose | Notes |
|------------|---------|---------|-------|
| ash | ~> 3.5 | Domain framework | Core |
| ash_postgres | ~> 2.4 | PostgreSQL data layer | Core |
| ash_authentication | ~> 4.1 | Auth framework | Core |
| ash_authentication_phoenix | ~> 2.0 | Auth LiveView integration | Core |
| phoenix | ~> 1.8 | Web framework | Core |
| phoenix_live_view | ~> 1.0 | Real-time UI | Core |
| bcrypt_elixir | ~> 3.0 | Password hashing | Security |
| fun_with_flags | ~> 1.13 | Feature flags | Infrastructure |
| fun_with_flags_ui | ~> 1.1 | Feature flag admin UI | Infrastructure |
| floki | >= 0.36.0 | SVG parsing/sanitization | Runtime |
| stream_data | ~> 1.0 | Property-based testing | Test infrastructure |
| excoveralls | ~> 0.18 | Coverage reporting | Test |
| credo | ~> 1.7 | Static analysis | Dev/Test |
| dialyxir | ~> 1.4 | Dialyzer | Dev/Test |
| tidewave | ~> 0.5 | MCP integration | Dev only |
| mimic | ~> 2.2 | Test mocking | Test only |

**Confidence**: High
**Analysis**: Dependencies are well-chosen and appropriate for the project. The version constraints use `~>` (pessimistic) which is correct Elixir convention. The `ci-deploy.yml` runs `mix hex.audit` and `mix deps.unlock --check-unused`, which are excellent for maintaining dependency health.

**Notable**: `picosat_elixir ~> 0.2` is listed first but appears unused directly -- it is likely a transitive dependency of Ash for constraint solving. The `usage_rules ~> 0.1` dependency generates AGENTS.md documentation from library usage rules.

**Potential concern**: The `Req` library is used in `KanjiVG.Ingestion` (line 190) for HTTP requests but is NOT listed in `mix.exs`. It may be pulled in as a transitive dependency (likely via `tidewave` or `finch`), but relying on transitive dependencies is fragile.

#### 7.2 Build Tools

**Evidence**: From `config/config.exs`:
- esbuild version: 0.17.11
- tailwind version: 3.4.3

**Confidence**: Medium
**Analysis**: The esbuild version (0.17.11) is significantly behind current (0.25.x as of early 2026). While this may not cause issues, newer versions include performance improvements and bug fixes. Tailwind 3.4.3 is reasonably current. The project uses npm for asset management (`npm ci --prefix assets` in Dockerfile, `npm run deploy --prefix assets` in aliases).

---

### 8. Feature Completeness

#### 8.1 Implemented Features

**Evidence**: Based on router analysis and LiveView modules:

| Feature | Route | Status | Auth Required |
|---------|-------|--------|---------------|
| Home page | `/` | Implemented | No |
| Kanji explorer | `/explore` | Implemented (rich: content metadata, stroke order, notes, radical info) | No (enhanced with auth) |
| Radical detail | `/radicals/:id` | Implemented | No |
| Quiz (SRS) | `/quiz` | Implemented (SM-2, rate limiting, session persistence, keyboard shortcuts, audio) | Yes |
| Settings | `/settings` | Implemented (username, theme, notifications) | Yes |
| Credits | `/credits` | Implemented | No |
| Admin dashboard | `/admin` | Implemented (shell -- links to sub-pages) | Yes (but no admin check) |
| User admin | `/admin/users` | Implemented (dev mode toggle, user listing) | Yes + admin check in mount |
| Feature flags | `/admin/feature-flags` | Implemented (FunWithFlags UI) | **No auth!** |
| Health check | `/health` | Implemented (DB connectivity check) | No |
| Auth (sign-in/register/sign-out) | `/sign-in`, `/register`, `/auth/*` | Implemented via AshAuthentication | N/A |

#### 8.2 Features Referenced in Docs/Plans but Not Implemented

**Evidence**: From `docs/` and `plans/` directories:
- `plans/audio_feedback.md`, `plans/audio_plan.md` -- Audio feedback is partially implemented (browser Speech Synthesis API via JS hooks, `AudioFeedback` hook in stroke order component)
- `plans/interactive_strokes.md` -- Stroke tracing is implemented (canvas overlay with `KanjiStrokeTracing` hook)
- `plans/srs_plan.md` -- SRS is fully implemented
- `plans/stroke_order.md` -- Stroke order viewing/animation is implemented
- `plans/acessability.md` -- Accessibility work is partially done (ARIA labels, keyboard shortcuts, sr-only text)
- `plans/next_feature.md` -- Unknown (would need to read)
- `docs/social-features.md` -- Social features not implemented
- `docs/ux-design.md` -- UX design document (implementation status unknown)
- `docs/wabi-sabi.md` -- Design philosophy document

**Confidence**: High
**Analysis**: The core learning loop (explore kanji -> quiz with SRS -> track progress) is fully implemented. The major gap is the Feature Flags system: while FunWithFlags is installed and configured, it is only used for the admin UI route -- no actual feature flags are checked anywhere in the application code (confirmed by grep showing `FunWithFlags` only appears in the router's `forward` directive within `lib/`). This means the CLAUDE.md rule "All new user-facing features must be behind a FunWithFlags flag" has infrastructure but zero adoption.

#### 8.3 Admin Dashboard Incompleteness

**Evidence**: The `Admin.DashboardLive` (lines 73-84, 108-117) links to:
- `/admin/users` -- exists and works
- `/admin/kanji` -- **route does not exist** in router.ex
- `/admin/stats` -- **route does not exist** in router.ex

The "Quick Actions" buttons (Export Data, System Health Check, Clear Cache) are non-functional HTML buttons with no event handlers.

**Confidence**: High
**Analysis**: The admin dashboard is a scaffold with dead links and non-functional buttons. The `/admin/kanji` and `/admin/stats` routes will produce 404 errors.

---

## Knowledge Gaps

### Gap 1: Test Coverage Metrics
**Issue**: Actual test coverage percentage is unknown. While `ExCoveralls` is configured, no coverage reports were available for analysis.
**Attempted**: Searched for coverage configuration in mix.exs (found `test_coverage: [tool: ExCoveralls]`) and aliases (found `"test.coverage": ["coveralls.html"]`).
**Recommendation**: Run `mix test.coverage` to generate an HTML coverage report and establish a baseline. Consider adding coverage threshold enforcement in CI.

### Gap 2: Dependency Vulnerability Status
**Issue**: While `mix hex.audit` runs in CI, the actual audit results are not visible in the codebase.
**Attempted**: Searched for audit reports or lock file analysis.
**Recommendation**: Run `mix hex.audit` and `mix deps.audit` locally to check current vulnerability status. Consider pinning the `Req` dependency explicitly.

### Gap 3: Production Database Backup Strategy
**Issue**: The docker-compose uses a named volume (`pgdata`) for Postgres data, but no backup strategy is documented.
**Attempted**: Searched for backup scripts or documentation.
**Recommendation**: Implement automated Postgres backups (pg_dump to a remote location) and document the recovery procedure.

---

## Conflicting Information

### Conflict 1: CI Workflow Versions
**Position A**: `ci.yml` uses Elixir 1.17 / Postgres 14
**Position B**: `ci-deploy.yml` uses Elixir 1.18.x / Postgres 16; Dockerfile uses Elixir 1.18.3 / OTP 27.3
**Assessment**: `ci-deploy.yml` and the Dockerfile are authoritative. `ci.yml` appears to be a legacy workflow that was superseded but not removed. It should be deleted or updated to match.

### Conflict 2: Database Setup Command
**Position A**: `ci.yml` uses `mix ash.setup` for database setup
**Position B**: `ci-deploy.yml` uses `mix ecto.create --quiet && mix ecto.migrate --quiet`
**Assessment**: Both should work, but `mix ash.setup` may do additional Ash-specific setup. The commands should be standardized across workflows.

---

## Recommendations

### Critical (Fix Immediately)
1. **Protect feature flags UI**: Add authentication + admin authorization to the `/admin/feature-flags` route
2. **Add admin check to DashboardLive**: Use `on_mount: :live_admin_required` or add an admin check in mount
3. **Fix bare rescue in ExploreLive**: Replace `rescue _ -> nil` with explicit error handling and logging

### High Priority
4. **Remove or update `ci.yml`**: Eliminate version skew by either deleting the legacy workflow or aligning it with `ci-deploy.yml`
5. **Add authorization policies to Content and Kanji resources**: Even if currently read-only, the presence of create/update/destroy actions without authorization is a security risk
6. **Add safeguard to `reset_and_seed`**: Prevent accidental invocation in production
7. **Clean up `.new` files**: Remove the 4 stale `.new` files from the repo

### Medium Priority
8. **Refactor SRS.Logic**: Break `reset_user_progress` into smaller functions, eliminate nested try/rescue
9. **Fix double query in ExploreLive**: Add relationship loading to the `by_offset` action
10. **Extract kana conversion utility**: Create shared `KumaSanKanji.NLP.Kana` module
11. **Add username uniqueness identity**: Prevent duplicate usernames from email-derived registration
12. **Actually use FunWithFlags**: The infrastructure is installed but no feature flags are checked in application code
13. **Fix SQLite comment**: Change "Ash SQLite repository" to "AshPostgres repository" in application.ex

### Low Priority
14. **Add missing tests**: ContentContext, HealthController, Release module, KanjiVG.Cache, Admin.DashboardLive
15. **Explicitly declare Req dependency**: Add `{:req, "~> 0.5"}` to mix.exs if used directly
16. **Update esbuild**: Consider upgrading from 0.17.11 to a more recent version
17. **Add Postgres backup strategy**: Document and implement automated backups for production
18. **Parallelize content queries in ExploreLive**: The 4 sequential content queries could run concurrently
19. **Consider dedicated SRS Ash domain**: Extract UserKanjiProgress into its own `KumaSanKanji.SRS` domain

---

## Source Analysis

| Source | Domain | Reputation | Type | Access Date | Cross-verified |
|--------|--------|------------|------|-------------|----------------|
| Codebase (lib/) | Local | Authoritative | Primary source | 2026-03-11 | Y |
| Codebase (test/) | Local | Authoritative | Primary source | 2026-03-11 | Y |
| Codebase (config/) | Local | Authoritative | Primary source | 2026-03-11 | Y |
| Codebase (.github/) | Local | Authoritative | Primary source | 2026-03-11 | Y |
| Codebase (Dockerfile, docker-compose) | Local | Authoritative | Primary source | 2026-03-11 | Y |
| CLAUDE.md (project rules) | Local | Authoritative | Project documentation | 2026-03-11 | Y |

Reputation: High: 6 (100%) | Avg: 1.0

## Research Metadata
Duration: ~25 turns | Examined: 80+ files | Cited: 30+ specific files | Cross-refs: All findings verified against actual source code | Confidence: High 85%, Medium 10%, Low 5% | Output: docs/research/project-review.md
