@echo off
cls
echo ==========================================
echo       GERENCIADOR DE STACK - INFRA
echo ==========================================

:: --- VERIFICAÇÃO DO DOCKER ---
echo Verificando se o motor do Docker esta ativo...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [AVISO] Docker Desktop esta desligado.
    echo Tentando iniciar o serviço automaticamente...
    
    :: Inicia o executável (ajuste o caminho se o seu Docker estiver em outro local)
    start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    
    echo Aguardando o Docker Engine subir...
    echo (Isso pode levar alguns segundos dependendo do seu PC)
    
    :loop
    timeout /t 3 >nul
    docker info >nul 2>&1
    if %errorlevel% neq 0 (
        echo . . . ainda carregando . . .
        goto loop
    )
    echo [OK] Docker Engine pronto!
    cls
    echo ==========================================
    echo       GERENCIADOR DE STACK - INFRA
    echo ==========================================
)
:: -----------------------------

echo 1. Subir tudo (Postgres, MySQL, Mongo)
echo 2. Apenas Postgres
echo 3. Apenas MySQL
echo 4. Apenas MongoDB
echo ==========================================
set /p opt="Escolha uma opcao: "

cd /d "C:\Users\Usuario\Documents\Projetos\Infra"

if %opt%==1 docker compose --profile pg --profile my --profile mo up -d
if %opt%==2 docker compose --profile pg up -d
if %opt%==3 docker compose --profile my up -d
if %opt%==4 docker compose --profile mo up -d

echo.
echo Status atual dos containers:
docker ps
echo.
pause