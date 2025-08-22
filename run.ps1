# Script PowerShell para executar o sistema de impressão
Write-Host "=== Sistema de Impressão de Pulseiras ===" -ForegroundColor Green
Write-Host ""

# Verifica se Docker está instalado
if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
    Write-Host "Erro: Docker não encontrado. Instale o Docker Desktop primeiro." -ForegroundColor Red
    exit 1
}

# Verifica se Docker está rodando
try {
    docker info | Out-Null
} catch {
    Write-Host "Erro: Docker não está rodando. Inicie o Docker Desktop primeiro." -ForegroundColor Red
    exit 1
}

Write-Host "Docker detectado. Iniciando o sistema..." -ForegroundColor Yellow
Write-Host ""

# Executa o docker-compose
try {
    docker-compose up --build
} catch {
    Write-Host "Erro ao executar docker-compose. Tentando com docker run..." -ForegroundColor Yellow
    
    # Build da imagem
    docker build -t print-bracelets .
    
    # Executa o container
    docker run -it --name print-bracelets-system print-bracelets
}

Write-Host ""
Write-Host "Sistema finalizado." -ForegroundColor Green
