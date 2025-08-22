# Script para iniciar o sistema de impressão
Write-Host "=== Sistema de Impressão de Pulseiras ===" -ForegroundColor Green
Write-Host ""

# Verifica se Docker está instalado
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Erro: Docker não encontrado. Instale o Docker Desktop primeiro." -ForegroundColor Red
    Read-Host "Pressione Enter para sair..."
    exit 1
}

# Verifica se Docker está rodando
try {
    docker info | Out-Null
    Write-Host "Docker detectado e rodando!" -ForegroundColor Green
} catch {
    Write-Host "Erro: Docker não está rodando. Inicie o Docker Desktop primeiro." -ForegroundColor Red
    Read-Host "Pressione Enter para sair..."
    exit 1
}

Write-Host "Construindo a imagem Docker..." -ForegroundColor Yellow
docker build -t print-bracelets .

if ($LASTEXITCODE -eq 0) {
    Write-Host "Build concluído com sucesso!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Iniciando o sistema..." -ForegroundColor Yellow
    docker run -it --rm --name print-bracelets-system print-bracelets
} else {
    Write-Host "Erro durante o build da imagem!" -ForegroundColor Red
    Read-Host "Pressione Enter para sair..."
}

Write-Host ""
Write-Host "Sistema finalizado." -ForegroundColor Green
Read-Host "Pressione Enter para sair..."
