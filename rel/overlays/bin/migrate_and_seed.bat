@echo off
cd /d "%~dp0"

echo Starting database migration and seeding...

rem Run migrations
echo Running migrations...
call kuma_san_kanji.bat eval "KumaSanKanji.Release.migrate()"

rem Run seeding
echo Running seeding...
call kuma_san_kanji.bat eval "KumaSanKanji.Release.seed()"

echo Migration and seeding completed!
