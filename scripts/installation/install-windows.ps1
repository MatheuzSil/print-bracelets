# Script de instalação para Windows
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  Sistema de Impressão de Pulseiras - Instalação" -ForegroundColor Green  
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""

# Configurações
$DockerUser = "matheuzsilva"
$ImageName = "print-bracelets"
$ContainerName = "print-bracelets-system"
$InstallPath = "C:\PrintBracelets"

Write-Host "Verificando requisitos..." -ForegroundColor Blue

# Verifica se Docker está instalado
try {
    docker --version | Out-Null
    Write-Host "Docker encontrado!" -ForegroundColor Green
} catch {
    Write-Host "Docker não encontrado!" -ForegroundColor Red
    Write-Host "Instale o Docker Desktop antes de continuar:" -ForegroundColor Yellow
    Write-Host "https://www.docker.com/products/docker-desktop/" -ForegroundColor White
    exit 1
}

# Verifica se Docker está rodando
try {
    docker info | Out-Null
    Write-Host "Docker está rodando!" -ForegroundColor Green
} catch {
    Write-Host "Docker não está rodando! Inicie o Docker Desktop primeiro." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Configurando sistema de impressão..." -ForegroundColor Blue

# Para containers existentes
Write-Host "Parando containers existentes..." -ForegroundColor Yellow
docker stop $ContainerName watchtower 2>$null
docker rm $ContainerName watchtower 2>$null

# Puxa imagem mais recente
Write-Host "Baixando imagem mais recente..." -ForegroundColor Blue
docker pull "$DockerUser/$ImageName`:latest"

# Cria diretório de instalação
New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
Write-Host "Diretório de instalação criado: $InstallPath" -ForegroundColor Green

# Copiar scripts de desktop (se existirem localmente)
$DesktopScripts = @(
    "menu-principal.bat",
    "configurar.bat",
    "iniciar.bat", 
    "parar.bat",
    "reiniciar.bat",
    "status.bat",
    "logs.bat",
    "desinstalar.bat"
)

Write-Host "Copiando scripts de desktop..." -ForegroundColor Blue
foreach ($script in $DesktopScripts) {
    $scriptPath = "scripts\desktop\$script"
    if (Test-Path $scriptPath) {
        Copy-Item $scriptPath "$InstallPath\$script" -Force
        Write-Host "  ✓ $script" -ForegroundColor Green
    } else {
        # Criar scripts básicos se não existirem
        switch ($script) {
            "menu-principal.bat" {
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
echo   [1] Configurar Sistema (Primeira vez)
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
"@ | Out-File -FilePath "$InstallPath\$script" -Encoding ASCII
                Write-Host "  ✓ $script (criado)" -ForegroundColor Yellow
            }
            "configurar.bat" {
                @"
@echo off
title Sistema de Impressao - Configurar
color 0B
cls
echo Acessando configuracao do sistema...
docker exec -it print-bracelets-system node setup.js
"@ | Out-File -FilePath "$InstallPath\$script" -Encoding ASCII
                Write-Host "  ✓ $script (criado)" -ForegroundColor Yellow
            }
            "iniciar.bat" {
                @"
@echo off
title Sistema de Impressao - Iniciar
color 0A
cls
echo Iniciando sistema de impressao...
docker start print-bracelets-system watchtower
echo Sistema iniciado com sucesso!
"@ | Out-File -FilePath "$InstallPath\$script" -Encoding ASCII
                Write-Host "  ✓ $script (criado)" -ForegroundColor Yellow
            }
            "parar.bat" {
                @"
@echo off
title Sistema de Impressao - Parar
color 0E
cls
echo Parando sistema de impressao...
docker stop print-bracelets-system watchtower
echo Sistema parado com sucesso!
"@ | Out-File -FilePath "$InstallPath\$script" -Encoding ASCII
                Write-Host "  ✓ $script (criado)" -ForegroundColor Yellow
            }
            "status.bat" {
                @"
@echo off
title Sistema de Impressao - Status
color 0D
cls
echo === Status do Sistema ===
docker ps --filter name=print-bracelets-system --filter name=watchtower
echo.
echo === Ultimos logs ===
docker logs --tail 5 print-bracelets-system
"@ | Out-File -FilePath "$InstallPath\$script" -Encoding ASCII
                Write-Host "  ✓ $script (criado)" -ForegroundColor Yellow
            }
            "logs.bat" {
                @"
@echo off
title Sistema de Impressao - Logs
color 0F
cls
echo === Logs em Tempo Real ===
echo Pressione Ctrl+C para sair
docker logs -f print-bracelets-system
"@ | Out-File -FilePath "$InstallPath\$script" -Encoding ASCII
                Write-Host "  ✓ $script (criado)" -ForegroundColor Yellow
            }
            "reiniciar.bat" {
                @"
@echo off
title Sistema de Impressao - Reiniciar
color 0D
cls
echo Reiniciando sistema de impressao...
docker restart print-bracelets-system watchtower
echo Sistema reiniciado com sucesso!
"@ | Out-File -FilePath "$InstallPath\$script" -Encoding ASCII
                Write-Host "  ✓ $script (criado)" -ForegroundColor Yellow
            }
            "desinstalar.bat" {
                @"
@echo off
title Sistema de Impressao - Desinstalar
color 0C
cls
echo ATENCAO: Esta operacao remove completamente o sistema!
set /p confirmacao="Tem certeza? (s/N): "
if /i "%confirmacao%" neq "s" exit /b 0
echo Removendo sistema...
docker stop print-bracelets-system watchtower 2>nul
docker rm print-bracelets-system watchtower 2>nul
docker rmi matheuzsilva/print-bracelets:latest 2>nul
docker system prune -f 2>nul
echo Sistema removido com sucesso!
"@ | Out-File -FilePath "$InstallPath\$script" -Encoding ASCII
                Write-Host "  ✓ $script (criado)" -ForegroundColor Yellow
            }
        }
    }
}

# Cria diretório para logs
$LogDir = "C:\ProgramData\PrintBracelets\logs"
New-Item -ItemType Directory -Path $LogDir -Force | Out-Null

# Inicia sistema principal
Write-Host "Iniciando sistema de impressão..." -ForegroundColor Blue
docker run -d `
    --name $ContainerName `
    --restart unless-stopped `
    --network host `
    -v "$LogDir`:/app/logs" `
    -it `
    --label "com.centurylinklabs.watchtower.enable=true" `
    "$DockerUser/$ImageName`:latest"

# Inicia Watchtower
Write-Host "Configurando atualizações automáticas..." -ForegroundColor Blue
docker run -d `
    --name watchtower `
    --restart unless-stopped `
    -v "//./pipe/docker_engine://./pipe/docker_engine" `
    -e WATCHTOWER_CLEANUP=true `
    -e WATCHTOWER_POLL_INTERVAL=300 `
    -e WATCHTOWER_LABEL_ENABLE=true `
    -e WATCHTOWER_INCLUDE_STOPPED=true `
    -e WATCHTOWER_REVIVE_STOPPED=true `
    containrrr/watchtower:latest `
    --interval 300 --cleanup

# Criar atalho na área de trabalho
Write-Host "Criando atalho na área de trabalho..." -ForegroundColor Blue

$DesktopPath = [Environment]::GetFolderPath('Desktop')
$ShortcutPath = "$DesktopPath\Sistema de Impressao.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "$InstallPath\menu-principal.bat"
$Shortcut.WorkingDirectory = $InstallPath
$Shortcut.Description = "Sistema de Impressao de Pulseiras"
$Shortcut.IconLocation = "shell32.dll,138"  # Ícone de impressora
$Shortcut.Save()

Write-Host ""
Write-Host "✅ Instalação concluída com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "🖱️  Atalho criado na área de trabalho:" -ForegroundColor Blue
Write-Host "   'Sistema de Impressao.lnk'" -ForegroundColor White
Write-Host ""
Write-Host "📁 Scripts instalados em:" -ForegroundColor Blue
Write-Host "   $InstallPath\" -ForegroundColor White
Write-Host ""
Write-Host "🔧 Para começar a usar:" -ForegroundColor Blue
Write-Host "   1. Clique duplo no ícone da área de trabalho" -ForegroundColor White
Write-Host "   2. Escolha 'Configurar Sistema (Primeira vez)'" -ForegroundColor White
Write-Host "   3. Configure o ID do totem e IP da impressora" -ForegroundColor White
Write-Host "   4. O sistema estará pronto!" -ForegroundColor White
Write-Host ""
Write-Host "⚙️  Sistema configurado para:" -ForegroundColor Blue
Write-Host "   • Iniciar automaticamente com o Docker" -ForegroundColor White
Write-Host "   • Atualizar automaticamente a cada 5 minutos" -ForegroundColor White
Write-Host "   • Reiniciar automaticamente em caso de falha" -ForegroundColor White
Write-Host "   • Logs salvos em $LogDir" -ForegroundColor White
Write-Host ""
Write-Host "🎉 Sistema pronto para uso!" -ForegroundColor Green
