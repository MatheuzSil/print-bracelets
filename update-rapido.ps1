# Script de Atualização Rápida do GitHub
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  Atualizando Sistema do GitHub" -ForegroundColor Green  
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""

$ContainerName = "print-bracelets-system"
$RepoUrl = "https://github.com/MatheuzSil/print-bracelets.git"

Write-Host "Parando container atual..." -ForegroundColor Yellow
docker stop $ContainerName 2>$null
docker rm $ContainerName 2>$null

# Criar diretório temporário para clone
$TempPath = "$env:TEMP\print-bracelets-update"
if (Test-Path $TempPath) {
    Remove-Item -Recurse -Force $TempPath
}

Write-Host "Baixando código mais recente do GitHub..." -ForegroundColor Blue
git clone $RepoUrl $TempPath

if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Erro ao clonar repositório!" -ForegroundColor Red
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Criar Dockerfile
$DockerfileContent = @"
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY src/ ./
COPY layout.tspl ./
RUN mkdir -p /app/config
CMD ["node", "setup.js"]
"@

$DockerfileContent | Out-File -FilePath "$TempPath\Dockerfile" -Encoding UTF8

Write-Host "Fazendo build da nova versão..." -ForegroundColor Blue
Set-Location $TempPath
docker build -t print-bracelets-github .

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Build concluído!" -ForegroundColor Green
    
    Write-Host "Iniciando sistema atualizado..." -ForegroundColor Blue
    
    $ConfigPath = "C:\PrintBracelets\config"
    
    docker run -d --name $ContainerName --restart unless-stopped --network host -it -v "${ConfigPath}:/app/config" print-bracelets-github
    
    Write-Host ""
    Write-Host "✅ SISTEMA ATUALIZADO COM SUCESSO!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🎯 O sistema agora está rodando com:" -ForegroundColor Blue
    Write-Host "   ✓ Código mais recente do GitHub" -ForegroundColor White
    Write-Host "   ✓ Suporte ao parentName atualizado" -ForegroundColor White
    Write-Host "   ✓ Todas as correções implementadas" -ForegroundColor White
    Write-Host ""
} else {
    Write-Host "❌ Erro no build da imagem!" -ForegroundColor Red
}

Set-Location $PSScriptRoot
Remove-Item -Recurse -Force $TempPath

Write-Host ""
Read-Host "Pressione Enter para sair"