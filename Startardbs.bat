@echo off
cls
echo ==========================================
echo       INICIADOR DE STACK - INFRA
echo ==========================================

:: --- VERIFICAÇÃO DO DOCKER (isolada) ---
echo Verificando se o motor do Docker esta ativo...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [AVISO] Docker Desktop esta desligado.
    echo Tentando iniciar o servico automaticamente...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo Aguardando o Docker Engine subir...
    echo (Isso pode levar alguns segundos dependendo do seu PC)
    :_wait_docker
    timeout /t 3 >nul
    docker info >nul 2>&1
    if %errorlevel% neq 0 (
        echo . . . ainda carregando . . .
        goto _wait_docker
    )
)
echo [OK] Docker Engine pronto!
:: --- Profiles (variaveis) ---
set "PROFILE_PG=--profile pg"
set "PROFILE_MY=--profile my"
set "PROFILE_MO=--profile mo"
set "PROFILE_REDIS=--profile redis"
set "PROFILES_ALL=%PROFILE_PG% %PROFILE_MY% %PROFILE_MO% %PROFILE_REDIS%"

:: Flags de falha (0 = ok, 1 = falhou)
set "FAIL_POSTGRES=0"
set "FAIL_MYSQL=0"
set "FAIL_MONGO=0"
set "FAIL_REDIS=0"

:inicio
cls
goto :menu

:menu
echo 1. Subir tudo (Postgres, MySQL, Mongo, Redis)
echo 2. Apenas Postgres
echo 3. Apenas MySQL
echo 4. Apenas MongoDB
echo 5. Apenas Redis
echo ==========================================
set /p opt="Escolha uma opcao: "

cd /d "%~dp0"

:: Jargao: Jump Table (simula switch/case)
goto :task_%opt% 2>nul || (
    echo [ERRO] Opcao "%opt%" e invalida!
    pause
    cls
    goto :inicio
)

:task_1
    docker compose %PROFILES_ALL% up -d
    call :wait_postgres
    if %errorlevel% neq 0 (set "FAIL_POSTGRES=1" & goto :finalizar)
    call :wait_mysql
    if %errorlevel% neq 0 (set "FAIL_MYSQL=1" & goto :finalizar)
    call :wait_mongo
    if %errorlevel% neq 0 (set "FAIL_MONGO=1" & goto :finalizar)
    call :wait_redis
    if %errorlevel% neq 0 (set "FAIL_REDIS=1" & goto :finalizar)
    goto :finalizar

:task_2
    docker compose %PROFILE_PG% up -d
    call :wait_postgres
    if %errorlevel% neq 0 (set "FAIL_POSTGRES=1" & goto :finalizar)
    goto :finalizar

:task_3
    docker compose %PROFILE_MY% up -d
    call :wait_mysql
    if %errorlevel% neq 0 (set "FAIL_MYSQL=1" & goto :finalizar)
    goto :finalizar

:task_4
    docker compose %PROFILE_MO% up -d
    call :wait_mongo
    if %errorlevel% neq 0 (set "FAIL_MONGO=1" & goto :finalizar)
    goto :finalizar

:task_5
    docker compose %PROFILE_REDIS% up -d
    call :wait_redis
    if %errorlevel% neq 0 (set "FAIL_REDIS=1" & goto :finalizar)
    goto :finalizar

:finalizar
echo.
echo ======= Resumo de inicializacao =======
set "__anyfailed=0"
if "%FAIL_POSTGRES%"=="1" (
    echo - Postgres: FALHOU
    set "__anyfailed=1"
) else (
    echo - Postgres: OK
)
if "%FAIL_MYSQL%"=="1" (
    echo - MySQL: FALHOU
    set "__anyfailed=1"
) else (
    echo - MySQL: OK
)
if "%FAIL_MONGO%"=="1" (
    echo - MongoDB: FALHOU
    set "__anyfailed=1"
) else (
    echo - MongoDB: OK
)
if "%FAIL_REDIS%"=="1" (
    echo - Redis: FALHOU
    set "__anyfailed=1"
) else (
    echo - Redis: OK
)

if "%__anyfailed%"=="0" (
    echo.
    echo [OK] Todos os servicos iniciados com sucesso.
) else (
    echo.
    echo [ERRO] Um ou mais servicos falharam ao iniciar. Verifique logs:

    :: Prepara diretorio/arquivo de log e informa caminho com aspas para evitar erros de sintaxe
    set "LOG_DIR=%~dp0logs"
    if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
    set "LOG_FILE=%LOG_DIR%\start_failures.log"
    echo [INFO] Consulte "%LOG_FILE%" para detalhes e verifique o status com: docker ps -a

    :: Registra falhas em logs/start_failures.log
    echo %date% %time% - Falhas ao iniciar:>> "%LOG_FILE%"
    if "%FAIL_POSTGRES%"=="1" echo Postgres>> "%LOG_FILE%"
    if "%FAIL_MYSQL%"=="1" echo MySQL>> "%LOG_FILE%"
    if "%FAIL_MONGO%"=="1" echo MongoDB>> "%LOG_FILE%"
    if "%FAIL_REDIS%"=="1" echo Redis>> "%LOG_FILE%"
    echo -------------------------------- >> "%LOG_FILE%"
)

echo.
echo Status atual dos containers:
docker ps
pause
exit /b 0

:check_docker
echo Verificando se o motor do Docker esta ativo...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [AVISO] Docker Desktop esta desligado.
    echo Tentando iniciar o servico automaticamente...
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    echo Aguardando o Docker Engine subir...
    echo (Isso pode levar alguns segundos dependendo do seu PC)
    :_wait_docker
    timeout /t 3 >nul
    docker info >nul 2>&1
    if %errorlevel% neq 0 (
        echo . . . ainda carregando . . .
        goto _wait_docker
    )
)
echo [OK] Docker Engine pronto!
goto :eof

:: ----------------------
:: Labels de espera (retornam com goto :eof)
:wait_postgres
setlocal
set /a __tries=0
:wait_postgres_loop
docker exec postgres_dev pg_isready -U postgres >nul 2>&1
if %errorlevel%==0 (
    echo Postgres esta pronto para receber conexoes
    endlocal & exit /b 0
)
set /a __tries+=1
if %__tries% geq 3 (
    echo [ERRO] Postgres nao respondeu apos %__tries% tentativas.
    endlocal & exit /b 1
)
echo Aguardando Postgres ficar pronto... (tentativa %__tries%/3)
timeout /t 10 >nul
goto wait_postgres_loop

:wait_mysql
setlocal
set /a __tries=0
:wait_mysql_loop
docker exec mysql_dev mysqladmin ping -uroot -padmin >nul 2>&1
if %errorlevel%==0 (
    echo MySQL esta pronto para receber conexoes
    endlocal & exit /b 0
)
set /a __tries+=1
if %__tries% geq 3 (
    echo [ERRO] MySQL nao respondeu apos %__tries% tentativas.
    endlocal & exit /b 1
)
echo Aguardando MySQL ficar pronto... (tentativa %__tries%/3)
timeout /t 10 >nul
goto wait_mysql_loop

:wait_mongo
setlocal
set /a __tries=0
:wait_mongo_loop
docker exec mongo_dev mongosh --eval "db.runCommand({ping:1})" >nul 2>&1
if %errorlevel%==0 (
    echo MongoDB esta pronto para receber conexoes
    endlocal & exit /b 0
)
set /a __tries+=1
if %__tries% geq 3 (
    echo [ERRO] MongoDB nao respondeu apos %__tries% tentativas.
    endlocal & exit /b 1
)
echo Aguardando MongoDB ficar pronto... (tentativa %__tries%/3)
timeout /t 10 >nul
goto wait_mongo_loop

:wait_redis
setlocal
set /a __tries=0
:wait_redis_loop
docker exec redis_dev redis-cli ping >nul 2>&1
if %errorlevel%==0 (
    echo Redis esta pronto para receber conexoes
    endlocal & exit /b 0
)
set /a __tries+=1
if %__tries% geq 3 (
    echo [ERRO] Redis nao respondeu apos %__tries% tentativas.
    endlocal & exit /b 1
)
echo Aguardando Redis ficar pronto... (tentativa %__tries%/3)
timeout /t 10 >nul
goto wait_redis_loop
