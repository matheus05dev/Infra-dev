@echo off
echo ==========================================
echo    ENCERRANDO E LIMPANDO TUDO (FULL WIPE)
echo ==========================================
cd /d "C:\Users\Usuario\Documents\Projetos\Infra"

:: 1. Derruba os containers e tenta limpar o básico
docker compose --profile pg --profile my --profile mo down -v --rmi local --remove-orphans

:: 2. Jargão: 'image prune -a' remove imagens que não estão em uso (limpa o MySQL residual)
echo Removendo imagens pesadas e residuais...
docker image prune -a -f

:: 3. Jargão: 'volume prune' remove volumes órfãos/anônimos (aqueles códigos gigantes)
echo Removendo volumes anonimos...
docker volume prune -f

echo.
echo [OK] Containers, Volumes e Imagens foram eliminados.
echo.
echo Status atual (deve estar tudo vazio):
echo --- Containers ---
docker ps -a
echo --- Volumes ---
docker volume ls
echo --- Imagens ---
docker images
echo.
pause