# Script de Instalação - Sistema de Impressão de Pulseiras (GitHub)
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  Sistema de Impressão de Pulseiras - Instalação GitHub" -ForegroundColor Green  
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
Write-Host "Instalando sistema com código mais recente do GitHub..." -ForegroundColor Blue

# Configurações
$ContainerName = "print-bracelets-system"
$InstallPath = "C:\PrintBracelets"
$RepoUrl = "https://github.com/MatheuzSil/print-bracelets.git"

# Parar containers existentes
docker stop $ContainerName 2>$null
docker rm $ContainerName 2>$null

# Criar diretório temporário para clone
$TempPath = "$env:TEMP\print-bracelets-build"
if (Test-Path $TempPath) {
    Remove-Item -Recurse -Force $TempPath
}

Write-Host "Clonando repositório do GitHub..." -ForegroundColor Yellow
git clone $RepoUrl $TempPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao clonar repositório!" -ForegroundColor Red
    Write-Host "Verifique se você tem acesso ao repositório ou use a instalação padrão." -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Criar Dockerfile no diretório temporário
Write-Host "Criando Dockerfile..." -ForegroundColor Yellow
$DockerfileContent = @"
# Use uma imagem Node.js oficial
FROM node:18-alpine

# Definir diretório de trabalho
WORKDIR /app

# Copiar package.json e package-lock.json
COPY package*.json ./

# Instalar dependências
RUN npm install --production

# Copiar código fonte
COPY src/ ./
COPY layout.tspl ./
COPY layoutparent.tspl ./

# Criar diretório de configuração
RUN mkdir -p /app/config

# Comando padrão para iniciar o sistema
CMD ["node", "setup.js"]
"@

$DockerfileContent | Out-File -FilePath "$TempPath\Dockerfile" -Encoding UTF8

# Fazer build da imagem
Write-Host "Fazendo build da imagem com código atualizado..." -ForegroundColor Blue
Set-Location $TempPath
docker build -t print-bracelets-github .

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro no build da imagem!" -ForegroundColor Red
    Set-Location $PSScriptRoot
    Remove-Item -Recurse -Force $TempPath
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Voltar ao diretório original e limpar
Set-Location $PSScriptRoot
Remove-Item -Recurse -Force $TempPath

Write-Host "✅ Build concluído com sucesso!" -ForegroundColor Green

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
echo   Sistema de Impressao de Pulseiras [GITHUB]
echo  ================================================
echo.
echo   [1] Configurar Sistema
echo   [2] Ver Status do Sistema
echo   [3] Ver Logs em Tempo Real  
echo   [4] Iniciar Sistema
echo   [5] Parar Sistema
echo   [6] Reiniciar Sistema
echo   [7] Atualizar do GitHub
echo   [8] Desinstalar Sistema
echo   [9] Sair
echo.
echo  ================================================
echo.
set /p opcao=Digite sua opcao (1-9): 

if "%opcao%"=="1" goto CONFIGURAR
if "%opcao%"=="2" goto STATUS  
if "%opcao%"=="3" goto LOGS
if "%opcao%"=="4" goto INICIAR
if "%opcao%"=="5" goto PARAR
if "%opcao%"=="6" goto REINICIAR
if "%opcao%"=="7" goto ATUALIZAR
if "%opcao%"=="8" goto DESINSTALAR
if "%opcao%"=="9" exit
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

:ATUALIZAR
call "C:\PrintBracelets\atualizar.bat"
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
echo Verificando se container existe...
docker ps -aq --filter name=print-bracelets-system | findstr . >nul
if errorlevel 1 (
    echo Container nao existe. Execute a instalacao primeiro.
    exit /b 1
)

echo Verificando se container esta rodando...
docker ps -q --filter name=print-bracelets-system | findstr . >nul
if errorlevel 1 (
    echo Iniciando container...
    docker start print-bracelets-system >nul 2>&1
)

echo.
echo Acessando sistema de configuracao...
echo.
docker exec -it print-bracelets-system node /app/setup.js
echo.
echo Sistema finalizado!
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

# Script de Atualizar do GitHub
@"
@echo off
title Sistema de Impressao - Atualizar
color 0C
cls
echo ========================================
echo   ATUALIZAR DO GITHUB
echo ========================================
echo.
echo Esta operacao ira:
echo - Parar o sistema atual
echo - Baixar codigo mais recente do GitHub
echo - Fazer novo build da imagem
echo - Reiniciar com versao atualizada
echo.
set /p confirmacao="Continuar com a atualizacao? (s/N): "
if /i "%confirmacao%" neq "s" (
    echo Atualizacao cancelada.
    exit /b 0
)
echo.
powershell.exe -ExecutionPolicy Bypass -File "C:\PrintBracelets\update-github.ps1"
echo.
echo Atualizacao concluida!
"@ | Out-File -FilePath "$InstallPath\atualizar.bat" -Encoding ASCII

# Criar script PowerShell de atualização separadamente
$UpdateScriptContent = @'
# Script de Atualização do GitHub
$ContainerName = "print-bracelets-system"
$RepoUrl = "https://github.com/MatheuzSil/print-bracelets.git"

Write-Host "Parando container atual..." -ForegroundColor Yellow
docker stop $ContainerName 2>$null
docker rm $ContainerName 2>$null

$TempPath = "$env:TEMP\print-bracelets-update"
if (Test-Path $TempPath) {
    Remove-Item -Recurse -Force $TempPath
}

Write-Host "Clonando versão mais recente..." -ForegroundColor Blue
git clone $RepoUrl $TempPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "Erro ao clonar repositório!" -ForegroundColor Red
    exit 1
}

$DockerfileContent = @"
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY src/ ./
COPY layout.tspl ./
COPY layoutparent.tspl ./
RUN mkdir -p /app/config
CMD ["node", "setup.js"]
"@

$DockerfileContent | Out-File -FilePath "$TempPath\Dockerfile" -Encoding UTF8

Write-Host "Fazendo build da nova versão..." -ForegroundColor Blue
Set-Location $TempPath
docker build -t print-bracelets-github .

if ($LASTEXITCODE -eq 0) {
    Write-Host "Iniciando sistema atualizado..." -ForegroundColor Green
    
    $ConfigPath = "C:\PrintBracelets\config"
    
    docker run -d --name $ContainerName --restart unless-stopped --network host -it -v "${ConfigPath}:/app/config" print-bracelets-github
    
    Write-Host "✅ Sistema atualizado com sucesso!" -ForegroundColor Green
} else {
    Write-Host "❌ Erro no build!" -ForegroundColor Red
}

Set-Location "C:\PrintBracelets"
Remove-Item -Recurse -Force $TempPath
'@

$UpdateScriptContent | Out-File -FilePath "$InstallPath\update-github.ps1" -Encoding UTF8

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
docker rmi print-bracelets-github 2>nul
docker system prune -f 2>nul
echo.
echo Sistema removido com sucesso!
echo.
echo Para reinstalar, execute o instalador novamente.
"@ | Out-File -FilePath "$InstallPath\desinstalar.bat" -Encoding ASCII

# Criar atalho na área de trabalho
Write-Host "Criando atalho na área de trabalho..." -ForegroundColor Yellow
$DesktopPath = [Environment]::GetFolderPath('Desktop')
$ShortcutPath = "$DesktopPath\Sistema de Impressao [GitHub].lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = "$InstallPath\menu-principal.bat"
$Shortcut.WorkingDirectory = $InstallPath
$Shortcut.Description = "Sistema de Impressao de Pulseiras [GitHub]"
$Shortcut.IconLocation = "shell32.dll,138"
$Shortcut.Save()

# Iniciar sistema
Write-Host "Iniciando sistema..." -ForegroundColor Blue

# Criar pasta de configuração
$ConfigPath = "$InstallPath\config"
New-Item -ItemType Directory -Path $ConfigPath -Force | Out-Null

# Iniciar sistema principal
docker run -d --name $ContainerName --restart unless-stopped --network host -it -v "${ConfigPath}:/app/config" print-bracelets-github

Write-Host ""
Write-Host "✅ INSTALAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host ""
Write-Host "🖱️  ATALHO CRIADO:" -ForegroundColor Blue
Write-Host "   'Sistema de Impressao [GitHub].lnk' na área de trabalho" -ForegroundColor White
Write-Host ""
Write-Host "🎯 PRÓXIMOS PASSOS:" -ForegroundColor Blue
Write-Host "   1. Clique no ícone da área de trabalho" -ForegroundColor White
Write-Host "   2. Escolha 'Configurar Sistema'" -ForegroundColor White
Write-Host "   3. Configure ID do totem e IP da impressora" -ForegroundColor White
Write-Host "   4. Sistema estará pronto!" -ForegroundColor White
Write-Host ""
Write-Host "🔄 ATUALIZAÇÕES:" -ForegroundColor Blue
Write-Host "   Use a opção 'Atualizar do GitHub' no menu" -ForegroundColor White
Write-Host "   para sempre ter a versão mais recente!" -ForegroundColor White
Write-Host ""
Write-Host "📁 Scripts instalados em: $InstallPath" -ForegroundColor Blue
Write-Host ""
Write-Host "🎉 Sistema pronto para uso com código atualizado!" -ForegroundColor Green
Write-Host ""
Read-Host "Pressione Enter para sair"