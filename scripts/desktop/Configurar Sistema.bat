@echo off
title Sistema de Impressao - Configurar
color 0A
cls

echo ╔══════════════════════════════════════════════════════════╗
echo ║              SISTEMA DE IMPRESSAO DE PULSEIRAS          ║
echo ║                     CONFIGURACAO                        ║  
echo ╚══════════════════════════════════════════════════════════╝
echo.

REM Verifica se container existe
docker ps -a --filter name=print-bracelets-system --format "table {{.Names}}" | findstr print-bracelets-system >nul
if errorlevel 1 (
    echo ERRO: Sistema nao encontrado!
    echo Execute primeiro a instalacao.
    echo.
    pause
    exit /b 1
)

REM Verifica se está rodando
docker ps --filter name=print-bracelets-system --format "table {{.Names}}" | findstr print-bracelets-system >nul
if errorlevel 1 (
    echo Iniciando sistema...
    docker start print-bracelets-system >nul 2>&1
    timeout /t 3 >nul
)

echo Sistema pronto para configuracao!
echo.
echo Abrindo interface de configuracao...
echo (Para sair, pressione Ctrl+C)
echo.

REM Executa configuração interativa
docker exec -it print-bracelets-system node setup.js

echo.
echo Configuracao concluida!
pause
