# Script de Instalação Simplificada - Sistema de Impressão de Pulseiras
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  Sistema de Impressão de Pulseiras - Instalação" -ForegroundColor Green  
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""

# Verificar se Docker está instalado e rodando
Write-Host "Verificando Docker..." -ForegroundColor Blue
try {
    docker --version | Out-Null
    Write-Host "✓ Docker encontrado" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker não encontrado!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Por favor, instale o Docker Desktop primeiro:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop/" -ForegroundColor White
    Write-Host ""
    Read-Host "Pressione Enter para sair"
    exit 1
}

try {
    docker info | Out-Null
    Write-Host "✓ Docker está rodando" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker não está rodando!" -ForegroundColor Red
    Write-Host "Inicie o Docker Desktop e execute este script novamente." -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit 1
}

Write-Host ""
Write-Host "Instalando sistema..." -ForegroundColor Blue

# Configurações
$ContainerName = "print-bracelets-system"
$InstallPath = "C:\PrintBracelets"

# Parar containers existentes
docker stop $ContainerName watchtower 2>$null
docker rm $ContainerName watchtower 2>$null

# Baixar imagem
Write-Host "Baixando imagem do sistema..." -ForegroundColor Yellow
docker pull matheuzsilva/print-bracelets:latest

# Criar diretório de instalação
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null

# Criar scripts básicos
Write-Host "Criando scripts de controle..." -ForegroundColor Yellow

# Menu Principal
@"
@echo off
title Sistema de Impressao - Menu Principal
color 0A

:MENU
cls
echo.
echo  ================================================
echo   Sistema de Impressao de Pulseiras
echo  ================================================
echo.
echo   [1] Configurar Sistema
echo   [2] Ver Status do Sistema
echo   [3] Ver Logs em Tempo Real  
echo   [4] Iniciar Sistema
echo   [5] Parar Sistema
echo   [6] Reiniciar Sistema
echo   [7] Desinstalar Sistema
echo   [8] Sair
echo.
echo  ================================================
echo.
set /p opcao=Digite sua opcao (1-8): 

if "%opcao%"=="1" goto CONFIGURAR
if "%opcao%"=="2" goto STATUS  
if "%opcao%"=="3" goto LOGS
if "%opcao%"=="4" goto INICIAR
if "%opcao%"=="5" goto PARAR
if "%opcao%"=="6" goto REINICIAR
if "%opcao%"=="7" goto DESINSTALAR
if "%opcao%"=="8" exit
goto MENU

:CONFIGURAR
call "C:\PrintBracelets\configurar.bat"
pause
goto MENU

:STATUS
call "C:\PrintBracelets\status.bat"
pause
goto MENU

:LOGS
call "C:\PrintBracelets\logs.bat"
goto MENU

:INICIAR
call "C:\PrintBracelets\iniciar.bat"
pause
goto MENU

:PARAR
call "C:\PrintBracelets\parar.bat"
pause
goto MENU

:REINICIAR
call "C:\PrintBracelets\reiniciar.bat"
pause
goto MENU

:DESINSTALAR
call "C:\PrintBracelets\desinstalar.bat"
pause
goto MENU
"@ | Out-File -FilePath "$InstallPath\menu-principal.bat" -Encoding ASCII

# Script de Configuração
@"
@echo off
title Sistema de Impressao - Configurar
color 0B
cls
echo ========================================
echo   Configuracao do Sistema
echo ========================================
echo.
echo Acessando configuracao interativa...
echo.
docker exec -it print-bracelets-system node setup.js
echo.
echo Configuracao concluida!
"@ | Out-File -FilePath "$InstallPath\configurar.bat" -Encoding ASCII

# Script de Status
@"
@echo off
title Sistema de Impressao - Status
color 0D
cls
echo ========================================
echo   Status do Sistema
echo ========================================
echo.
docker ps --filter name=print-bracelets-system --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo.
echo ========================================
echo   Ultimos 5 logs do sistema:
echo ========================================
docker logs --tail 5 print-bracelets-system 2>nul
echo.
"@ | Out-File -FilePath "$InstallPath\status.bat" -Encoding ASCII

# Script de Logs
@"
@echo off
title Sistema de Impressao - Logs
color 0F
cls
echo ========================================
echo   Logs em Tempo Real
echo ========================================
echo.
echo Pressione Ctrl+C para sair
echo.
docker logs -f print-bracelets-system
"@ | Out-File -FilePath "$InstallPath\logs.bat" -Encoding ASCII

# Script de Iniciar
@"
@echo off
title Sistema de Impressao - Iniciar
color 0A
cls
echo ========================================
echo   Iniciando Sistema
echo ========================================
echo.
echo Verificando se sistema ja esta rodando...
docker ps -q --filter name=print-bracelets-system | findstr . >nul
if errorlevel 1 (
    echo Iniciando sistema de impressao...
    docker start print-bracelets-system 2>nul
    if errorlevel 1 (
        echo Container nao existe. Execute a instalacao primeiro.
    ) else (
        echo Sistema iniciado!
    )
) else (
    echo Sistema ja esta rodando!
)
echo.
echo Sistema pronto para uso!
"@ | Out-File -FilePath "$InstallPath\iniciar.bat" -Encoding ASCII

# Script de Parar
@"
@echo off
title Sistema de Impressao - Parar
color 0E
cls
echo ========================================
echo   Parando Sistema
echo ========================================
echo.
set /p confirmacao="Tem certeza que deseja parar o sistema? (s/N): "
if /i "%confirmacao%" neq "s" (
    echo Operacao cancelada.
    exit /b 0
)
echo.
echo Parando sistema de impressao...
docker stop print-bracelets-system 2>nul
echo Sistema parado!
"@ | Out-File -FilePath "$InstallPath\parar.bat" -Encoding ASCII

# Script de Reiniciar
@"
@echo off
title Sistema de Impressao - Reiniciar
color 0D
cls
echo ========================================
echo   Reiniciando Sistema
echo ========================================
echo.
echo Reiniciando sistema de impressao...
docker restart print-bracelets-system 2>nul
echo Sistema reiniciado!
"@ | Out-File -FilePath "$InstallPath\reiniciar.bat" -Encoding ASCII

# Script de Desinstalar
@"
@echo off
title Sistema de Impressao - Desinstalar
color 0C
cls
echo ========================================
echo   DESINSTALAR SISTEMA
echo ========================================
echo.
echo ATENCAO: Esta operacao ira remover:
echo - Todos os containers
echo - Todas as imagens Docker
echo - Configuracoes do sistema
echo.
set /p confirmacao="Tem CERTEZA que deseja desinstalar? (s/N): "
if /i "%confirmacao%" neq "s" (
    echo Desinstalacao cancelada.
    exit /b 0
)
echo.
echo Removendo sistema...
docker stop print-bracelets-system 2>nul
docker rm print-bracelets-system 2>nul  
docker rmi matheuzsilva/print-bracelets:latest 2>nul
docker system prune -f 2>nul
echo.
echo Sistema removido com sucesso!
echo.
echo Para reinstalar, execute o instalador novamente.
"@ | Out-File -FilePath "$InstallPath\desinstalar.bat" -Encoding ASCII

# Criar atalho na área de trabalho
Write-Host "Criando atalho na área de trabalho..." -ForegroundColor Yellow
$DesktopPath = [Environment]::GetFolderPath('Desktop')
$ShortcutPath = "$DesktopPath\Sistema de Impressao.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "$InstallPath\menu-principal.bat"
$Shortcut.WorkingDirectory = $InstallPath
$Shortcut.Description = "Sistema de Impressao de Pulseiras"
$Shortcut.IconLocation = "shell32.dll,138"
$Shortcut.Save()

# Iniciar sistema
Write-Host "Iniciando sistema..." -ForegroundColor Blue

# Iniciar sistema principal
docker run -d `
    --name $ContainerName `
    --restart unless-stopped `
    --network host `
    -it `
    --label "com.centurylinklabs.watchtower.enable=true" `
    matheuzsilva/print-bracelets:latest

# Iniciar Watchtower
docker run -d `
    --name watchtower `
    --restart unless-stopped `
    -v "//./pipe/docker_engine://./pipe/docker_engine" `
    -e WATCHTOWER_CLEANUP=true `
    -e WATCHTOWER_POLL_INTERVAL=300 `
    -e WATCHTOWER_LABEL_ENABLE=true `
    containrrr/watchtower:latest `
    --interval 300 --cleanup

Write-Host ""
Write-Host "✅ INSTALAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host ""
Write-Host "🖱️  ATALHO CRIADO:" -ForegroundColor Blue
Write-Host "   'Sistema de Impressao.lnk' na área de trabalho" -ForegroundColor White
Write-Host ""
Write-Host "🎯 PRÓXIMOS PASSOS:" -ForegroundColor Blue
Write-Host "   1. Clique no ícone da área de trabalho" -ForegroundColor White
Write-Host "   2. Escolha 'Configurar Sistema (Primeira vez)'" -ForegroundColor White
Write-Host "   3. Configure ID do totem e IP da impressora" -ForegroundColor White
Write-Host "   4. Sistema estará pronto!" -ForegroundColor White
Write-Host ""
Write-Host "📁 Scripts instalados em: $InstallPath" -ForegroundColor Blue
Write-Host ""
Write-Host "🎉 Sistema pronto para uso!" -ForegroundColor Green
Write-Host ""
Read-Host "Pressione Enter para sair"
