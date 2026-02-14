@echo off
echo ==========================================
echo    MONITORAMENTO DE LOGS (REAL-TIME)
echo ==========================================
cd /d "%~dp0"

:: Verifica se o Docker esta rodando
docker info >nul 2>&1 || (echo [ERRO] Docker desligado. Abortando. & pause & exit /b 1)
echo 1. Logs (real-time)
echo 2. Monitoramento de recursos (stats)
echo ==========================================

set /p opt="Escolha uma opcao (1 ou 2): "

:: Jump table — semelhante ao Startardbs.bat
goto :task_%opt% 2>nul || (
	echo [ERRO] Opcao "%opt%" e invalida!
	pause
	goto :eof
)

:task_1
echo Iniciando logs (follow)...
docker ps -q | findstr . >nul || (
	echo [INFO] Nenhum container em execucao. Inicie seus servicos primeiro.
	pause
	goto :eof
)
echo Executando: docker compose logs -f --tail 20
docker compose logs -f --tail 20
if not %errorlevel%==0 (
	echo [ERRO] 'docker compose logs' retornou codigo %errorlevel%.
	pause
)
goto :end_logs

:task_2
echo Iniciando monitoramento de recursos (CTRL+C para sair)...
docker ps -q | findstr . >nul || (
	echo [INFO] Nenhum container em execucao. Inicie seus servicos primeiro.
	pause
	goto :eof
)
echo Executando: docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
if not %errorlevel%==0 (
	echo [ERRO] 'docker stats' retornou codigo %errorlevel%.
	pause
)
goto :end_logs

:end_logs
echo.
echo [AVISO] Monitoramento encerrado pelo user.
pause