@echo off
title Sistema de Impressao de Pulseiras
color 0A

echo =============================================
echo   Sistema de Impressao de Pulseiras
echo =============================================
echo.

REM Verifica se Docker esta disponivel
docker --version >nul 2>&1
if errorlevel 1 (
    color 0C
    echo ERRO: Docker nao encontrado!
    echo Instale o Docker Desktop primeiro.
    echo.
    pause
    exit /b 1
)

REM Verifica se Docker esta rodando
docker info >nul 2>&1
if errorlevel 1 (
    color 0C
    echo ERRO: Docker nao esta rodando!
    echo Inicie o Docker Desktop primeiro.
    echo.
    pause
    exit /b 1
)

echo Docker detectado e rodando!
echo.

echo Construindo a imagem Docker...
docker build -t print-bracelets .

if errorlevel 1 (
    color 0C
    echo ERRO durante o build da imagem!
    echo.
    pause
    exit /b 1
)

echo.
echo Build concluido com sucesso!
echo.
echo Iniciando o sistema...
echo.

docker run -it --rm --name print-bracelets-system print-bracelets

echo.
echo Sistema finalizado.
pause
