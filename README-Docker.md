# KumaSanKanji Docker Development Guide

This document provides instructions for running KumaSanKanji using Docker Compose for local development and testing.

## Prerequisites

- Docker Desktop (or Docker Engine + Docker Compose)
- Git

## Quick Start

### Development Mode (Default)

The simplest way to get started:

```bash
# Clone and navigate to the project
git clone <your-repo-url>
cd kuma_san_kanji

# Start the development environment
docker-compose up
```

This will:

- Start a PostgreSQL database
- Build and run the Phoenix application in development mode
- Set up the database, run migrations, and seed data
- Enable live reload for code changes
- Make the app available at <http://localhost:4000>

### Available Services

#### Main Services (always running)

- **app**: Phoenix application (<http://localhost:4000>)
- **db**: PostgreSQL database (localhost:5432)

#### Optional Services (use profiles)

- **pgadmin**: Database administration UI (<http://localhost:5050>)
- **app_prod**: Production-like build for testing

## Usage Scenarios

### 1. Regular Development

```bash
# Start development environment
docker-compose up

# Or run in background
docker-compose up -d

# View logs
docker-compose logs -f app

# Stop services
docker-compose down
```

### 2. Development with Database Admin

```bash
# Start with pgAdmin included
docker-compose --profile admin up

# Access pgAdmin at http://localhost:5050
# Login: admin@kumasankanji.local / admin
# Connect to database: db:5432, user: kuma_san_kanji, password: postgres
```

### 3. Production-like Testing

```bash
# Use production compose file
docker-compose -f docker-compose.prod.yml up

# This builds with the production Dockerfile and uses MIX_ENV=prod
# App runs on http://localhost:4000 (different database on port 5433)
```

### 4. Rebuild After Code Changes

```bash
# Force rebuild of app container
docker-compose build app
docker-compose up

# Or rebuild and start in one command
docker-compose up --build
```

## Development Workflow

### Making Code Changes

1. Edit files in your local directory
2. Changes are automatically synced to the container via volume mounts
3. Phoenix live reload will automatically recompile and refresh
4. No need to restart containers for most changes

### Database Operations

```bash
# Access database directly
docker-compose exec db psql -U kuma_san_kanji -d kuma_san_kanji_dev

# Run mix commands in the app container
docker-compose exec app mix ecto.migrate
docker-compose exec app mix test
docker-compose exec app iex -S mix

# Reset database
docker-compose exec app mix ecto.reset
```

### Debugging

```bash
# View application logs
docker-compose logs -f app

# View database logs
docker-compose logs -f db

# Access app container shell
docker-compose exec app bash

# Access database container shell
docker-compose exec db bash
```

## Troubleshooting

### Common Issues

#### Port conflicts

If port 4000 or 5432 are already in use:

```bash
# Stop other services using these ports, or modify docker-compose.yml:
# For app: change "4000:4000" to "4001:4000"
# For db: change "5432:5432" to "5433:5432"
# Remember to update DATABASE_URL if you change the db port
```

#### Database connection issues

```bash
# Ensure database is healthy
docker-compose ps

# Reset database
docker-compose down -v  # This removes volumes too
docker-compose up
```

#### Permission issues (Linux/macOS)

```bash
# If you get permission errors with mounted volumes:
sudo chown -R $(id -u):$(id -g) .
```

#### Build issues

```bash
# Clean rebuild
docker-compose down
docker-compose build --no-cache
docker-compose up
```

### Resetting Everything

```bash
# Stop all services and remove volumes (data will be lost)
docker-compose down -v

# Remove all images
docker-compose down --rmi all

# Start fresh
docker-compose up --build
```

## Environment Variables

You can customize the environment by creating a `.env` file:

```bash
# .env file example
POSTGRES_DB=kuma_san_kanji_dev
POSTGRES_USER=kuma_san_kanji
POSTGRES_PASSWORD=your_secure_password
SECRET_KEY_BASE=your_secret_key_base
PHX_HOST=localhost
PORT=4000
```

## Data Persistence

- Database data is persisted in Docker volumes
- Your code changes are immediately reflected (volume mount)
- `deps` and `_build` are cached in anonymous volumes for performance

## Performance Tips

1. **Use volume caching**: The current setup already uses anonymous volumes for `deps` and `_build` to improve performance
2. **Background mode**: Use `docker-compose up -d` to run in background
3. **Selective rebuilds**: Only rebuild when you change `mix.exs`, `mix.lock`, or Docker files

## Integration with Production

This Docker setup mirrors the production environment:

- Same PostgreSQL version
- Same Elixir/Erlang versions
- Similar environment variables
- Same migration and seeding process

## Next Steps

Once you have the app running locally:

1. Visit <http://localhost:4000> to see the application
2. Make code changes and see them live reload
3. Use pgAdmin (if enabled) to inspect the database
4. Run tests with `docker-compose exec app mix test`
5. Deploy to production using the Fly.io deployment guide
