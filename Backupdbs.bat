@echo off
setlocal enabledelayedexpansion

:: Profiles (variaveis) para dicas de logs
set "PROFILE_REDIS=--profile redis"

:: Diretório base do script (garante criar Backups na mesma pasta do .bat)
set "BASE_DIR=%~dp0"
:: Jargão: Timestamp para organizar as pastas de backup
set "data=%date:/=-%"
set "folder=%BASE_DIR%Backups\Backup_%data%"

echo ==========================================
echo       SISTEMA DE BACKUP - INFRA
echo ==========================================

:: Verifica se o Docker esta rodando antes de comecar
docker info >nul 2>&1 || (echo [ERRO] Docker desligado. Abortando. & pause & exit /b 1)

if not exist "%folder%" mkdir "%folder%"

echo [1/4] Exportando Postgres...
docker exec -i postgres_dev pg_dumpall -U postgres > "%folder%\postgres_full.sql" 2>nul

echo [2/4] Exportando MySQL...
docker exec -i mysql_dev mysqldump -u root -padmin --all-databases > "%folder%\mysql_full.sql" 2>nul

echo [3/4] Exportando MongoDB (Binary Archive)...
:: mongodump --archive envia o dump para stdout quando sem caminho
docker exec mongo_dev mongodump --username admin --password admin --authenticationDatabase admin --archive > "%folder%\mongo_backup.archive" 2>nul

echo [4/4] Exportando Redis (RDB)...
:: Usa redis-cli --rdb para gerar o dump e redirecionar para o host
docker exec redis_dev redis-cli --rdb - > "%folder%\redis_dump.rdb" 2>nul
if %errorlevel% neq 0 (
	echo [WARN] Falha ao gerar dump do Redis via redis-cli --rdb. Tentando copia do arquivo interno...
	docker exec redis_dev redis-cli BGSAVE >nul 2>&1
	timeout /t 1 >nul
	docker cp redis_dev:/data/dump.rdb "%folder%\redis_dump.rdb" >nul 2>&1
	if %errorlevel% neq 0 (
		echo [ERRO] Nao foi possivel exportar o dump do Redis.
		echo [INFO] Consulte logs em %~dp0logs\ ou verifique o status com: docker ps -a
	) else (
		echo [OK] Dump do Redis copiado para %folder%\redis_dump.rdb
	)
)

echo.
echo %green%[OK] Backup concluido em: %folder%%reset%
echo ==========================================
pause