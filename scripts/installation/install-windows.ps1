# Script de instalação para Windows Server
param(
    [switch]$InstallDocker = $false
)

Write-Host "======================================================" -ForegroundColor Green
Write-Host "  Sistema de Impressão de Pulseiras - Instalação" -ForegroundColor Green  
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""

# Configurações
$DockerUser = "matheuzsilva"
$ImageName = "print-bracelets"
$ContainerName = "print-bracelets-system"

Write-Host "Verificando requisitos..." -ForegroundColor Blue

# Verifica se Docker está instalado
try {
    docker --version | Out-Null
    Write-Host "Docker encontrado!" -ForegroundColor Green
} catch {
    if ($InstallDocker) {
        Write-Host "Instalando Docker Desktop..." -ForegroundColor Yellow
        
        # Download Docker Desktop
        $url = "https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe"
        $output = "$env:TEMP\DockerInstaller.exe"
        
        Write-Host "Baixando Docker Desktop..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $url -OutFile $output
        
        Write-Host "Executando instalador..." -ForegroundColor Yellow
        Start-Process -FilePath $output -Wait
        
        Write-Host "Docker Desktop instalado! Reinicie o sistema e execute o script novamente." -ForegroundColor Green
        exit 0
    } else {
        Write-Host "Docker não encontrado!" -ForegroundColor Red
        Write-Host "Execute com -InstallDocker para instalar automaticamente:" -ForegroundColor Yellow
        Write-Host "  .\install-windows.ps1 -InstallDocker" -ForegroundColor White
        exit 1
    }
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

# Cria scripts de controle
Write-Host "Criando scripts de controle..." -ForegroundColor Blue

$ScriptDir = "C:\PrintBracelets"
$DesktopPath = [Environment]::GetFolderPath("Desktop")
$DesktopScriptsDir = "$DesktopPath\Sistema Impressao"

New-Item -ItemType Directory -Path $ScriptDir -Force | Out-Null
New-Item -ItemType Directory -Path $DesktopScriptsDir -Force | Out-Null

# Baixar scripts da área de trabalho do GitHub
$scriptsToDownload = @(
    "Configurar Sistema.bat",
    "Status do Sistema.bat", 
    "Ver Logs.bat",
    "Iniciar Sistema.bat",
    "Parar Sistema.bat",
    "Reiniciar Sistema.bat"
)

foreach ($script in $scriptsToDownload) {
    $url = "https://raw.githubusercontent.com/MatheuzSil/print-bracelets/main/scripts/desktop/$($script -replace ' ', '%20')"
    $output = "$DesktopScriptsDir\$script"
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $output
        Write-Host "  ✓ $script" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ Erro ao baixar $script" -ForegroundColor Red
    }
}

# Script de logs (compatibilidade)
@"
@echo off
title Print Bracelets - Logs
echo === Logs do Sistema de Impressao ===
docker logs -f print-bracelets-system
pause
"@ | Out-File -FilePath "$ScriptDir\logs.bat" -Encoding ASCII

# Script de restart  
@"
@echo off
title Print Bracelets - Restart
echo Reiniciando sistema de impressao...
docker restart print-bracelets-system
echo Sistema reiniciado!
pause
"@ | Out-File -FilePath "$ScriptDir\restart.bat" -Encoding ASCII

# Script de stop
@"
@echo off
title Print Bracelets - Stop
echo Parando sistema de impressao...
docker stop print-bracelets-system watchtower
echo Sistema parado!
pause
"@ | Out-File -FilePath "$ScriptDir\stop.bat" -Encoding ASCII

# Script de start
@"
@echo off
title Print Bracelets - Start  
echo Iniciando sistema de impressao...
docker start print-bracelets-system watchtower
echo Sistema iniciado!
pause
"@ | Out-File -FilePath "$ScriptDir\start.bat" -Encoding ASCII

# Script de status
@"
@echo off
title Print Bracelets - Status
echo === Status do Sistema ===
docker ps --filter name=print-bracelets-system --filter name=watchtower
echo.
echo === Ultimas atualizacoes ===
docker logs --tail 10 watchtower
pause
"@ | Out-File -FilePath "$ScriptDir\status.bat" -Encoding ASCII

Write-Host ""
Write-Host "Instalação concluída com sucesso!" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Scripts criados na área de trabalho:" -ForegroundColor Blue
Write-Host "   $DesktopScriptsDir\" -ForegroundColor White
Write-Host ""
Write-Host "🖱️  Scripts disponíveis (duplo clique para usar):" -ForegroundColor Blue
Write-Host "  • Configurar Sistema.bat  - Configurar impressora" -ForegroundColor White
Write-Host "  • Status do Sistema.bat   - Ver status atual" -ForegroundColor White
Write-Host "  • Ver Logs.bat           - Ver atividade em tempo real" -ForegroundColor White
Write-Host "  • Iniciar Sistema.bat    - Iniciar sistema" -ForegroundColor White
Write-Host "  • Parar Sistema.bat      - Parar sistema" -ForegroundColor White
Write-Host "  • Reiniciar Sistema.bat  - Reiniciar sistema" -ForegroundColor White
Write-Host ""
Write-Host "📋 Scripts de compatibilidade em: C:\PrintBracelets\" -ForegroundColor Blue
Write-Host ""
Write-Host "Sistema configurado para:" -ForegroundColor Blue
Write-Host "  • Iniciar automaticamente com o Docker" -ForegroundColor White
Write-Host "  • Atualizar automaticamente a cada 5 minutos" -ForegroundColor White
Write-Host "  • Reiniciar automaticamente em caso de falha" -ForegroundColor White
Write-Host "  • Logs salvos em C:\ProgramData\PrintBracelets\logs" -ForegroundColor White
Write-Host ""
Write-Host "Para interagir com o sistema (configurar impressora):" -ForegroundColor Yellow
Write-Host "  docker exec -it print-bracelets-system cmd" -ForegroundColor White
Write-Host ""
Write-Host "Sistema pronto para uso!" -ForegroundColor Green
