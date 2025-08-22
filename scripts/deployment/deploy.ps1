# Script para deploy completo no Docker Hub
param(
    [string]$DockerUser = "matheuzsilva",  # Substitua pelo seu usuário
    [string]$ImageName = "print-bracelets",
    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"
$Timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

Write-Host "Iniciando deploy para Docker Hub..." -ForegroundColor Green
Write-Host "Usuario: $DockerUser" -ForegroundColor Yellow
Write-Host "Imagem: $ImageName" -ForegroundColor Yellow
Write-Host ""

try {
    # Verifica se está logado no Docker
    Write-Host "Verificando login no Docker Hub..." -ForegroundColor Blue
    docker info | Out-Null
    
    # Build da imagem
    Write-Host "Fazendo build da imagem..." -ForegroundColor Blue
    docker build -t $ImageName .
    
    if ($LASTEXITCODE -ne 0) {
        throw "Erro durante o build da imagem"
    }
    
    # Tagging
    Write-Host "Taggeando imagem..." -ForegroundColor Blue
    docker tag $ImageName "$DockerUser/$ImageName`:$Version"
    docker tag $ImageName "$DockerUser/$ImageName`:$Timestamp"
    
    # Push para Docker Hub
    Write-Host "Fazendo push para Docker Hub..." -ForegroundColor Blue
    docker push "$DockerUser/$ImageName`:$Version"
    docker push "$DockerUser/$ImageName`:$Timestamp"
    
    if ($LASTEXITCODE -ne 0) {
        throw "Erro durante o push para Docker Hub"
    }
    
    Write-Host ""
    Write-Host "Deploy concluido com sucesso!" -ForegroundColor Green
    Write-Host "Imagem disponível em: $DockerUser/$ImageName`:$Version" -ForegroundColor Green
    Write-Host "Versão com timestamp: $DockerUser/$ImageName`:$Timestamp" -ForegroundColor Yellow

} catch {
    Write-Host ""
    Write-Host "Erro durante o deploy: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifique se:" -ForegroundColor Yellow
    Write-Host "1. Você está logado no Docker Hub (docker login)" -ForegroundColor White
    Write-Host "2. O Docker Desktop está rodando" -ForegroundColor White
    Write-Host "3. Você tem permissão para push no repositório" -ForegroundColor White
    exit 1
}

Write-Host ""
Write-Host "Para usar com Watchtower, execute:" -ForegroundColor Cyan
Write-Host "docker run -d --name watchtower --restart unless-stopped \" -ForegroundColor White
Write-Host "  -v /var/run/docker.sock:/var/run/docker.sock \" -ForegroundColor White
Write-Host "  containrrr/watchtower:latest \" -ForegroundColor White
Write-Host "  --interval 300 --cleanup" -ForegroundColor White
