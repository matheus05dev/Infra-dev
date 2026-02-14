@echo off
echo ==========================================
echo    MONITORAMENTO DE LOGS (REAL-TIME)
echo ==========================================
cd /d "C:\Users\Usuario\Documents\Projetos\Infra"

:: Usando 'docker compose' (V2) e limitando as últimas linhas
:: O jargão '--tail 20' evita que o terminal cuspa 500 linhas antigas na sua cara
docker compose logs -f --tail 20

echo.
echo [AVISO] Monitoramento encerrado pelo user.
pause