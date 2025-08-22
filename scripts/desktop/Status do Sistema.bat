@echo off
title Sistema de Impressao - Status
color 0B
cls

echo ╔══════════════════════════════════════════════════════════╗
echo ║              SISTEMA DE IMPRESSAO DE PULSEIRAS          ║
echo ║                        STATUS                           ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

echo Verificando status do sistema...
echo.

REM Status dos containers
echo ═══════════════ CONTAINERS ═══════════════
docker ps --filter name=print-bracelets-system --filter name=watchtower --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>nul

REM Verifica se sistema está rodando
docker ps --filter name=print-bracelets-system --format "table {{.Names}}" | findstr print-bracelets-system >nul
if errorlevel 1 (
    echo.
    echo ❌ SISTEMA PARADO
    echo.
    echo Para iniciar o sistema, execute: "Iniciar Sistema.bat"
) else (
    echo.
    echo ✅ SISTEMA FUNCIONANDO
    echo.
    echo ═══════════════ ULTIMAS ATUALIZACOES ═══════════════
    docker logs --tail 5 watchtower 2>nul
)

echo.
echo ═══════════════ INFORMACOES DO SISTEMA ═══════════════
echo Imagem: matheuzsilva/print-bracelets:latest
echo Rede: Host (acesso direto a impressora)
echo Atualizacoes: Automaticas (5 minutos)
echo Logs: docker logs print-bracelets-system

echo.
echo ═══════════════ COMANDOS DISPONIVEIS ═══════════════
echo "Configurar Sistema.bat" - Configurar impressora
echo "Ver Logs.bat"           - Ver atividade em tempo real  
echo "Reiniciar Sistema.bat"  - Reiniciar servico
echo "Parar Sistema.bat"      - Parar servico
echo "Iniciar Sistema.bat"    - Iniciar servico

echo.
pause
