@echo off
title Sistema de Impressao - Parar
color 0C
cls

echo ╔══════════════════════════════════════════════════════════╗
echo ║              SISTEMA DE IMPRESSAO DE PULSEIRAS          ║
echo ║                        PARAR                            ║
echo ╚══════════════════════════════════════════════════════════╝
echo.

echo AVISO: Isso vai parar o sistema de impressao!
echo.
set /p confirm=Tem certeza? (s/n): 

if /i not "%confirm%"=="s" (
    echo Operacao cancelada.
    exit /b 0
)

echo.
echo Parando sistema de impressao...
docker stop print-bracelets-system

echo Parando Watchtower...
docker stop watchtower

echo.
echo Sistema parado com sucesso!
echo.
echo Para iniciar novamente, use "Iniciar Sistema"
