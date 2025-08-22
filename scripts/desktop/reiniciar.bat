@echo off
title Sistema de Impressao - Reiniciar
color 0D
cls

echo ╔══════════════════════════════════════════════════════════╗
echo ║              SISTEMA DE IMPRESSAO DE PULSEIRAS          ║
echo ║                      REINICIAR                          ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

echo Reiniciando sistema de impressao...
docker restart print-bracelets-system

if errorlevel 1 (
    echo ERRO ao reiniciar sistema!
    exit /b 1
)

echo Reiniciando Watchtower...
docker restart watchtower

echo.
echo Sistema reiniciado com sucesso!
echo.
echo O sistema foi reiniciado e esta funcionando normalmente.
echo Use "Ver Logs" para acompanhar a atividade.
