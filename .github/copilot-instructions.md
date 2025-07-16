# KumaSanKanji Copilot Instructions

## Project Overview
KumaSanKanji is an Elixir/Phoenix application for Japanese kanji learning with spaced repetition (SRS). Built on **Ash Framework** - an opinionated domain modeling framework that organizes code around resources and domains rather than traditional Phoenix contexts.

## Architecture & Key Components

### Core Framework: Ash Framework
- **Domain-driven design**: Code organized around `KumaSanKanji.Domain` with resources, not Phoenix contexts
- **Resource-based**: Each entity (Kanji, User, etc.) is an Ash resource with declarative actions
- **Code interfaces**: Use domain functions like `KumaSanKanji.Domain.get_kanji_by_id/1` instead of direct Ash calls
- **Always follow the existing Ash patterns** found in `.github/instructions/ash-rules.instructions.md`

### Key Domains & Resources
```elixir
# Main domain boundary in lib/kuma_san_kanji/domain.ex
KumaSanKanji.Domain
├── Accounts.User (authentication via ash_authentication)
├── Kanji.Kanji (main content with relationships)
├── Kanji.Meaning, Pronunciation, ExampleSentence (related data)
└── SRS.UserKanjiProgress (spaced repetition tracking)
```

### Authentication & Authorization
- **AshAuthentication**: Handles user auth with JWT tokens
- **Live session routing**: 
  - `:public_routes` (/, /explore) - optional auth with `live_user_optional`
  - `:authenticated_routes` (/quiz, /admin) - requires auth with `live_user_required`
- **Admin users**: Created via seeds with `ADMIN_EMAIL` environment variable

### Spaced Repetition System (SRS)
- **SM-2 Algorithm**: Implemented in `KumaSanKanji.SRS.Logic`
- **Quiz sessions**: Stateful LiveView in `quiz_live.ex` with rate limiting
- **Progress tracking**: `UserKanjiProgress` resource manages review intervals and performance

## Development Workflows

### Setup & Dependencies
```powershell
# Complete dev setup (Windows PowerShell)
.\scripts\setup_dev.ps1 -AdminEmail "admin@example.com"

# Manual setup
mix deps.get
mix ecto.setup  # Creates DB and runs seeds
mix phx.server  # Start development server
```

### Database & Migrations
- **PostgreSQL**: Primary database via AshPostgres
- **Ash codegen**: Run `mix ash.codegen migration_name` after resource changes
- **Seeds**: Admin user creation via `priv/repo/seeds.exs` with ADMIN_EMAIL env var

### Testing
- **Mimic**: Used for mocking (see `test_helper.exs`)
- **Sandbox**: Ecto sandbox mode for test isolation
- Run with: `mix test`

## Code Patterns & Conventions

### Ash Resource Structure
```elixir
defmodule MyApp.Domain.Resource do
  use Ash.Resource, domain: MyApp.Domain, data_layer: AshPostgres.DataLayer
  
  attributes do
    uuid_primary_key(:id)
    # attributes here
  end
  
  relationships do
    # relationships here
  end
  
  actions do
    defaults([:read, :create, :update, :destroy])
    # custom actions here
  end
end
```

### LiveView Patterns
- **Authentication mounting**: Use `on_mount {KumaSanKanjiWeb.UserLiveAuth, :mount_type}`
- **Domain calls**: Use code interfaces, not direct `Ash.read!` calls
- **Rate limiting**: Implement in sensitive LiveViews (see `quiz_live.ex`)

### File Organization
```
lib/kuma_san_kanji/
├── domain.ex           # Main Ash domain with code interfaces
├── accounts/           # User authentication resources
├── kanji/             # Core kanji learning content
├── srs/               # Spaced repetition logic
└── content/           # Additional content management

lib/kuma_san_kanji_web/
├── router.ex          # Route organization by auth requirements
├── live/              # LiveView modules
└── user_live_auth.ex  # Authentication helpers
```

## Deployment & Environment

### Production Deployment
- **Fly.io**: Primary deployment target with PostgreSQL
- **Scripts**: Use `.\scripts\deploy_prod.ps1` for deployment
- **Secrets**: Set `DATABASE_URL` and admin email via Fly secrets
- **Docker**: Multi-stage builds with `Dockerfile` and `docker-compose.yml`

### Key Environment Variables
- `ADMIN_EMAIL`: Admin user email for seeds
- `DATABASE_URL`: PostgreSQL connection string
- `SECRET_KEY_BASE`: Phoenix secret key

### Development Dependencies
- **Tidewave**: MCP integration (dev only)
- **LiveReload**: Hot reloading in development
- **Observer**: Elixir runtime inspection

## Common Tasks

### Adding New Resources
1. Create resource file in appropriate domain directory
2. Add to `domain.ex` with code interfaces
3. Run `mix ash.codegen migration_name` for database changes
4. Update seeds if needed

### Authentication Changes
- Modify `user_live_auth.ex` for mount behaviors
- Update router live sessions for route protection
- Use `authorize?: false` for admin operations

### SRS/Quiz Features
- Extend `KumaSanKanji.SRS.Logic` for algorithm changes
- Update `quiz_live.ex` for UI/UX modifications
- Modify `UserKanjiProgress` resource for data model changes

Remember: This is an **Ash Framework application** - always use Ash patterns for data operations, resource definitions, and domain boundaries rather than traditional Phoenix/Ecto patterns.
