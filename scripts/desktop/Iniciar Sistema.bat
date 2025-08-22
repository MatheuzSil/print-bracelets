@echo off
title Sistema de Impressao - Iniciar
color 0A
cls

echo ╔══════════════════════════════════════════════════════════╗
echo ║              SISTEMA DE IMPRESSAO DE PULSEIRAS          ║
echo ║                       INICIAR                           ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

echo Verificando status atual...

REM Verifica se container existe
docker ps -a --filter name=print-bracelets-system --format "table {{.Names}}" | findstr print-bracelets-system >nul
if errorlevel 1 (
    echo ❌ Sistema nao instalado!
    echo.
    echo Execute a instalacao primeiro.
    pause
    exit /b 1
)

REM Verifica se já está rodando
docker ps --filter name=print-bracelets-system --format "table {{.Names}}" | findstr print-bracelets-system >nul
if not errorlevel 1 (
    echo ✅ Sistema ja esta rodando!
    echo.
    pause
    exit /b 0
)

echo 🔄 Iniciando sistema de impressao...
docker start print-bracelets-system

if errorlevel 1 (
    echo ❌ Erro ao iniciar sistema!
    echo.
    pause
    exit /b 1
)

echo 🔄 Iniciando Watchtower (atualizacoes automaticas)...
docker start watchtower

echo.
echo ✅ Sistema iniciado com sucesso!
echo.
echo O sistema agora esta:
echo • Aguardando mensagens de impressao
echo • Verificando atualizacoes automaticamente
echo • Pronto para configuracao
echo.
echo Use "Status do Sistema.bat" para verificar funcionamento
echo Use "Configurar Sistema.bat" para configurar impressora

pause
