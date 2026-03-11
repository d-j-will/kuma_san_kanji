# Kuma San Kanji

Elixir/Phoenix LiveView kanji learning app. Ash Framework 3.x, AshAuthentication (password strategy), PostgreSQL, Docker deployment via GitHub Actions.

## Key Directories

- `lib/kuma_san_kanji/` — domains: Accounts, Kanji, SRS, Content
- `lib/kuma_san_kanji_web/` — LiveView, components, router
- `docs/` — specs, design docs

## Dev Setup

Postgres: `docker run -d --name kuma_postgres -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres -e POSTGRES_DB=kuma_san_kanji_dev -p 5432:5432 postgres:16`

Then: `mix ecto.create && mix ecto.migrate && mix test`

**Never dismiss test failures.** Fix the environment before moving on.

## Project Rules

- All new user-facing features **must** be behind a FunWithFlags flag. Admin UI at `/admin/feature-flags`.
- Never use `rescue _ -> :ok` — every failure must be visible in logs.
- Never use `on_conflict: :nothing` without handling the nil-id ghost struct.
- Docker Compose: never bare `docker pull`, never `build:` in prod compose, always `--force-recreate --no-build --remove-orphans`.

## Commands and Hooks

Use these instead of manual steps — they enforce safety checks:

- `/new-migration` — expand/contract migration with safety checklist
- `/new-feature` — scaffold feature behind a FunWithFlags flag
- `/deploy` — pre-deploy verification then tag and push

Hook scripts in `scripts/hooks/` enforce: no `--no-verify`, no bare docker pull, no `build:` in prod compose, migration safety, CI deploy pattern checks. Hookify rules in `.claude/` warn on: silent rescue, upsert safety, docker `:latest` tags, library API usage without doc verification.
