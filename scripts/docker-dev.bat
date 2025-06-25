@echo off
REM Development scripts for Docker Compose (Windows)

setlocal

if "%1"=="start" (
    echo 🚀 Starting KumaSanKanji development environment...
    docker-compose up -d
    echo ✅ Services started! App available at http://localhost:4000
    goto :eof
)

if "%1"=="stop" (
    echo 🛑 Stopping KumaSanKanji services...
    docker-compose down
    echo ✅ Services stopped!
    goto :eof
)

if "%1"=="restart" (
    echo 🔄 Restarting KumaSanKanji services...
    docker-compose down
    docker-compose up -d
    echo ✅ Services restarted!
    goto :eof
)

if "%1"=="logs" (
    if "%2"=="" (
        echo 📋 Showing all logs...
        docker-compose logs -f
    ) else (
        echo 📋 Showing logs for %2...
        docker-compose logs -f %2
    )
    goto :eof
)

if "%1"=="shell" (
    if "%2"=="" (
        echo 🐚 Opening shell in app container...
        docker-compose exec app bash
    ) else (
        echo 🐚 Opening shell in %2 container...
        docker-compose exec %2 bash
    )
    goto :eof
)

if "%1"=="db" (
    echo 🗄️  Connecting to database...
    docker-compose exec db psql -U kuma_san_kanji -d kuma_san_kanji_dev
    goto :eof
)

if "%1"=="mix" (
    shift
    echo 🧪 Running mix %*...
    docker-compose exec app mix %*
    goto :eof
)

if "%1"=="test" (
    echo 🧪 Running tests...
    docker-compose exec app mix test
    goto :eof
)

if "%1"=="reset" (
    echo 🔄 Resetting database...
    docker-compose exec app mix ecto.reset
    echo ✅ Database reset complete!
    goto :eof
)

if "%1"=="clean" (
    echo 🧹 Cleaning up Docker resources...
    docker-compose down -v --rmi local
    echo ✅ Cleanup complete!
    goto :eof
)

if "%1"=="build" (
    echo 🔨 Building containers...
    docker-compose build
    echo ✅ Build complete!
    goto :eof
)

if "%1"=="rebuild" (
    echo 🔨 Rebuilding containers from scratch...
    docker-compose build --no-cache
    echo ✅ Rebuild complete!
    goto :eof
)

if "%1"=="admin" (
    echo 🔧 Starting with pgAdmin...
    docker-compose --profile admin up -d
    echo ✅ Services started with pgAdmin!
    echo    App: http://localhost:4000
    echo    pgAdmin: http://localhost:5050 ^(admin@kumasankanji.local / admin^)
    goto :eof
)

if "%1"=="prod" (
    echo 🏭 Starting production-like environment...
    docker-compose -f docker-compose.prod.yml up -d
    echo ✅ Production environment started at http://localhost:4000
    goto :eof
)

if "%1"=="status" (
    echo 📊 Service status:
    docker-compose ps
    goto :eof
)

echo KumaSanKanji Docker Development Helper
echo.
echo Usage: %0 ^<command^>
echo.
echo Commands:
echo   start     - Start development environment ^(background^)
echo   stop      - Stop all services
echo   restart   - Restart all services
echo   logs      - Follow logs ^(optionally specify service^)
echo   shell     - Open shell in app container ^(or specify service^)
echo   db        - Connect to PostgreSQL database
echo   mix       - Run mix commands in app container
echo   test      - Run tests
echo   reset     - Reset database ^(drop, create, migrate, seed^)
echo   clean     - Remove containers, volumes, and images
echo   build     - Build containers
echo   rebuild   - Rebuild containers from scratch
echo   admin     - Start with pgAdmin included
echo   prod      - Start production-like environment
echo   status    - Show service status
echo.
echo Examples:
echo   %0 start
echo   %0 logs app
echo   %0 shell db
echo   %0 mix ecto.migrate
echo   %0 test
