@echo off
setlocal enabledelayedexpansion

:: Jargão: Timestamp para organizar as pastas de backup
set "data=%date:/=-%"
set "folder=Backups\Backup_%data%"

echo ==========================================
echo       SISTEMA DE BACKUP - INFRA
echo ==========================================

if not exist "%folder%" mkdir "%folder%"

echo [1/3] Exportando Postgres...
docker exec postgres_dev pg_dumpall -U postgres > "%folder%\postgres_full.sql"

echo [2/3] Exportando MySQL...
docker exec mysql_dev mysqldump -u root -padmin --all-databases > "%folder%\mysql_full.sql"

echo [3/3] Exportando MongoDB...
:: Jargão: 'mongodump' cria um bkp binário compactado
docker exec mongo_dev mongodump --username admin --password admin --authenticationDatabase admin --archive > "%folder%\mongo_backup.archive"

echo.
echo %green%[OK] Backup concluido em: %folder%%reset%
echo ==========================================
pause