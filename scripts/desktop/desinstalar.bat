@echo off
title Sistema de Impressao - Desinstalar
color 0C
cls

echo ╔══════════════════════════════════════════════════════════╗
echo ║              SISTEMA DE IMPRESSAO DE PULSEIRAS          ║
echo ║                      DESINSTALAR                        ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

echo ATENCAO: Esta operacao ira remover completamente o sistema!
echo Isso incluira:
echo - Containers Docker
echo - Imagens Docker
echo - Dados de configuracao
echo.

set /p confirmacao="Tem certeza que deseja desinstalar? (s/N): "

if /i "%confirmacao%" neq "s" (
    echo Desinstalacao cancelada.
    pause
    exit /b 0
)

echo.
echo Parando containers...
docker stop print-bracelets-system watchtower 2>nul

echo Removendo containers...
docker rm print-bracelets-system watchtower 2>nul

echo Removendo imagens...
docker rmi matheuzsilva/print-bracelets:latest 2>nul
docker rmi containrrr/watchtower:latest 2>nul

echo Limpando recursos nao utilizados...
docker system prune -f 2>nul

echo.
echo Sistema desinstalado com sucesso!
echo.
echo Para reinstalar, execute o script de instalacao novamente.
echo.
