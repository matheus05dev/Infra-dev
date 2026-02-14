@echo off
echo ==========================================
echo       SISTEMA DE RESTORE - INFRA
echo ==========================================
setlocal

:: Usa o diretório do script como base
set "BASE_DIR=%~dp0"

:: Profiles (variaveis) para dicas de logs
set "PROFILE_REDIS=--profile redis"

echo Pastas de Backup disponiveis:
dir /b /ad "%BASE_DIR%Backups" 2>nul || echo (nenhuma pasta encontrada)
echo.
set /p folder_name="Copie e cole o nome da pasta desejada: "
set "target=%BASE_DIR%Backups\%folder_name%"

if not exist "%target%" (
    echo [ERRO] Pasta %target% nao encontrada.
    pause
    exit /b 1
)

echo [1/4] Restaurando Postgres...
type "%target%\postgres_full.sql" | docker exec -i postgres_dev psql -U postgres

echo [2/4] Restaurando MySQL...
docker exec -i mysql_dev mysql -u root -padmin < "%target%\mysql_full.sql"

echo [3/4] Restaurando MongoDB...
docker exec -i mongo_dev mongorestore --username admin --password admin --authenticationDatabase admin --drop --archive < "%target%\mongo_backup.archive"

echo [4/4] Restaurando Redis (se houver dump)...
if exist "%target%\redis_dump.rdb" (
    echo Encontrado redis_dump.rdb em %target%. Procedendo com restore...

    echo Aviso: remover o container Redis pode desconectar aplicacoes que estao usando-o agora.
    set /p confirm="Deseja continuar e forcar a remocao do container redis_dev? (S/N): "
    if /i "%confirm%"=="N" (
        echo Pulando restore do Redis conforme solicitado pelo usuario.
        goto :skip_redis_restore
    )

    echo Parando e removendo container redis_dev (se existir)...
    docker rm -f redis_dev >nul 2>&1 || echo ok

    echo Criando container Redis (sem iniciar) via docker compose...
    docker compose --profile redis create >nul 2>&1

    echo Copiando dump para dentro do container...
    docker cp "%target%\redis_dump.rdb" redis_dev:/data/dump.rdb >nul 2>&1
    if %errorlevel% neq 0 (
        echo [ERRO] Falha ao copiar redis_dump.rdb para o container.
        echo [INFO] Consulte logs em %~dp0logs\ ou verifique o status com: docker ps -a

        :: grava no log de restore
        set "LOG_DIR=%~dp0logs"
        if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
        set "LOG_FILE=%LOG_DIR%\restore_failures.log"
        echo %date% %time% - Falha ao restaurar Redis do backup %folder_name%>> "%LOG_FILE%"
    ) else (
        echo [OK] Dump copiado, iniciando container Redis...
        docker compose %PROFILE_REDIS% start >nul 2>&1
        echo Redis iniciado. Aguarde alguns segundos para carregar o RDB.
        :: grava  
        set "LOG_DIR=%~dp0logs"
        if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
        set "LOG_FILE=%LOG_DIR%\restore_success.log"
        echo %date% %time% - Redis restaurado a partir de %target%>> "%LOG_FILE%"
    )
)

:skip_redis_restore

echo.
echo [OK] Restore concluido.
echo ==========================================
pause