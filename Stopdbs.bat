@echo off
cls
echo ==========================================
echo    ENCERRANDO E LIMPANDO TUDO (FULL WIPE)
echo ==========================================

:: Jargão: 'Context Awareness' - Garante que o script rode na pasta certa
cd /d "%~dp0"

echo [AVISO] Esta acao ira destruir:
echo - Todos os Containers da stack
echo - Todos os Volumes (DADOS PERDIDOS)
echo - Imagens locais e residuos de rede
echo.
set /p confirm="Tem certeza que deseja prosseguir? (S/N): "
if /i "%confirm%" neq "S" (
    echo [INFO] Operacao cancelada pelo usuario.
    pause
    exit /b 0
)

echo.
echo [1/3] Derrubando stack e removendo volumes...
:: Jargão: 'Orphan Removal' - Limpa containers que sobraram de versões antigas do compose
docker compose --profile pg --profile my --profile mo --profile redis down -v --rmi local --remove-orphans

echo [2/3] Executando Deep Clean de imagens...
:: Remove imagens que não estão em uso para liberar espaço real no SSD
docker image prune -a -f

echo [3/3] Removendo volumes anonimos residuais...
docker volume prune -f

:: Limpeza opcional de logs para manter a casa organizada
if exist "logs" (
    echo Limpando logs de execucao...
    del /q "logs\*.log" >nul 2>&1
)

echo.
echo ==========================================
echo [OK] O ambiente foi sanitizado (Tabula Rasa).
echo ==========================================
echo.
echo Status atual:
echo --- Containers ---
docker ps -a
echo.
pause