@echo off
title Sistema de Impressao - Logs
color 0E
cls

echo ╔══════════════════════════════════════════════════════════╗
echo ║              SISTEMA DE IMPRESSAO DE PULSEIRAS          ║
echo ║                    LOGS EM TEMPO REAL                   ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

REM Verifica se container está rodando
docker ps --filter name=print-bracelets-system --format "table {{.Names}}" | findstr print-bracelets-system >nul
if errorlevel 1 (
    echo ❌ Sistema nao esta rodando!
    echo.
    echo Para iniciar o sistema, execute: "Iniciar Sistema.bat"
    echo.
    pause
    exit /b 1
)

echo Mostrando logs em tempo real...
echo Para sair, pressione Ctrl+C
echo.
echo ══════════════════════════════════════════════════════════
echo.

docker logs -f print-bracelets-system
