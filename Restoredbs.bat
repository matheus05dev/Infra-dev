@echo off
echo ==========================================
echo       SISTEMA DE RESTORE - INFRA
echo ==========================================

set /p folder_name="Digite o nome da pasta de backup: "
set "target=Backups\%folder_name%"

if not exist "%target%" (
    echo [ERRO] Pasta %target% nao encontrada.
    pause
    exit
)

echo [1/3] Restaurando Postgres...
type "%target%\postgres_full.sql" | docker exec -i postgres_dev psql -U postgres

echo [2/3] Restaurando MySQL...
docker exec -i mysql_dev mysql -u root -padmin < "%target%\mysql_full.sql"

echo [3/3] Restaurando MongoDB...
docker exec -i mongo_dev mongorestore --username admin --password admin --authenticationDatabase admin --drop --archive < "%target%\mongo_backup.archive"

echo.
echo [OK] Restore concluido.
echo ==========================================
pause