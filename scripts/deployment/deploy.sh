#!/bin/bash

# Script para deploy completo no Docker Hub
set -e

# Configurações
DOCKER_USER="matheuzsilva"  # ALTERE PARA SEU USUÁRIO
IMAGE_NAME="print-bracelets"
VERSION="latest"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

echo "🚀 Iniciando deploy para Docker Hub..."
echo "Usuario: $DOCKER_USER"
echo "Imagem: $IMAGE_NAME"
echo ""

# Verifica se Docker está rodando
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker não está rodando!"
    exit 1
fi

# Build da imagem
echo "🐳 Fazendo build da imagem..."
docker build -t $IMAGE_NAME .

# Tagging
echo "🏷️ Taggeando imagem..."
docker tag $IMAGE_NAME $DOCKER_USER/$IMAGE_NAME:$VERSION
docker tag $IMAGE_NAME $DOCKER_USER/$IMAGE_NAME:$TIMESTAMP

# Push para Docker Hub
echo "📤 Fazendo push para Docker Hub..."
docker push $DOCKER_USER/$IMAGE_NAME:$VERSION
docker push $DOCKER_USER/$IMAGE_NAME:$TIMESTAMP

echo ""
echo "✅ Deploy concluído com sucesso!"
echo "Imagem disponível em: $DOCKER_USER/$IMAGE_NAME:$VERSION"
echo "Versão com timestamp: $DOCKER_USER/$IMAGE_NAME:$TIMESTAMP"

echo ""
echo "🔄 Para usar com Watchtower, execute:"
echo "docker run -d --name watchtower --restart unless-stopped \\"
echo "  -v /var/run/docker.sock:/var/run/docker.sock \\"
echo "  containrrr/watchtower:latest \\"
echo "  --interval 300 --cleanup"
