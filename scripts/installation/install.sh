#!/bin/bash

# Script de instalação automática do sistema de impressão
echo "======================================================"
echo "  Sistema de Impressão de Pulseiras - Instalação"
echo "======================================================"
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configurações
DOCKER_USER="matheuzsilva"
IMAGE_NAME="print-bracelets"
CONTAINER_NAME="print-bracelets-system"

echo -e "${BLUE}🔍 Verificando requisitos...${NC}"

# Verifica se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo -e "${RED}❌ Docker não encontrado!${NC}"
    echo -e "${YELLOW}Instalando Docker...${NC}"
    
    # Instala Docker no Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
        sudo apt-get update
        sudo apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        echo "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y docker-ce docker-ce-cli containerd.io
        sudo usermod -aG docker $USER
    # Instala Docker no CentOS/RHEL
    elif command -v yum &> /dev/null; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install -y docker-ce docker-ce-cli containerd.io
        sudo systemctl start docker
        sudo systemctl enable docker
        sudo usermod -aG docker $USER
    else
        echo -e "${RED}❌ Sistema operacional não suportado!${NC}"
        echo "Por favor, instale o Docker manualmente: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Docker instalado com sucesso!${NC}"
    echo -e "${YELLOW}⚠️  Faça logout/login para aplicar permissões do Docker${NC}"
else
    echo -e "${GREEN}✅ Docker já instalado${NC}"
fi

# Verifica se Docker está rodando
if ! docker info &> /dev/null; then
    echo -e "${YELLOW}🔄 Iniciando Docker...${NC}"
    sudo systemctl start docker
fi

# Instala Docker Compose se necessário
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}📦 Instalando Docker Compose...${NC}"
    sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    echo -e "${GREEN}✅ Docker Compose instalado${NC}"
fi

echo ""
echo -e "${BLUE}🚀 Configurando sistema de impressão...${NC}"

# Para containers antigos se existirem
echo -e "${YELLOW}🔄 Parando containers existentes...${NC}"
docker stop $CONTAINER_NAME watchtower 2>/dev/null || true
docker rm $CONTAINER_NAME watchtower 2>/dev/null || true

# Puxa a imagem mais recente
echo -e "${BLUE}📥 Baixando imagem mais recente...${NC}"
docker pull $DOCKER_USER/$IMAGE_NAME:latest

# Cria diretório para logs
mkdir -p /var/log/print-bracelets

# Inicia o sistema principal
echo -e "${BLUE}🖨️ Iniciando sistema de impressão...${NC}"
docker run -d \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    --network host \
    -v /var/log/print-bracelets:/app/logs \
    -it \
    --label "com.centurylinklabs.watchtower.enable=true" \
    $DOCKER_USER/$IMAGE_NAME:latest

# Inicia o Watchtower para atualizações automáticas
echo -e "${BLUE}🔄 Configurando atualizações automáticas...${NC}"
docker run -d \
    --name watchtower \
    --restart unless-stopped \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e WATCHTOWER_CLEANUP=true \
    -e WATCHTOWER_POLL_INTERVAL=300 \
    -e WATCHTOWER_LABEL_ENABLE=true \
    -e WATCHTOWER_INCLUDE_STOPPED=true \
    -e WATCHTOWER_REVIVE_STOPPED=true \
    containrrr/watchtower:latest \
    --interval 300 --cleanup

# Cria script de controle
echo -e "${BLUE}📝 Criando scripts de controle...${NC}"

# Script para ver logs
cat > /usr/local/bin/print-bracelets-logs << 'EOF'
#!/bin/bash
echo "=== Logs do Sistema de Impressão ==="
docker logs -f print-bracelets-system
EOF

# Script para reiniciar
cat > /usr/local/bin/print-bracelets-restart << 'EOF'
#!/bin/bash
echo "Reiniciando sistema de impressão..."
docker restart print-bracelets-system
echo "Sistema reiniciado!"
EOF

# Script para parar
cat > /usr/local/bin/print-bracelets-stop << 'EOF'
#!/bin/bash
echo "Parando sistema de impressão..."
docker stop print-bracelets-system watchtower
echo "Sistema parado!"
EOF

# Script para iniciar
cat > /usr/local/bin/print-bracelets-start << 'EOF'
#!/bin/bash
echo "Iniciando sistema de impressão..."
docker start print-bracelets-system watchtower
echo "Sistema iniciado!"
EOF

# Script de status
cat > /usr/local/bin/print-bracelets-status << 'EOF'
#!/bin/bash
echo "=== Status do Sistema ==="
docker ps --filter name=print-bracelets-system --filter name=watchtower
echo ""
echo "=== Últimas atualizações ==="
docker logs --tail 10 watchtower
EOF

# Torna scripts executáveis
chmod +x /usr/local/bin/print-bracelets-*

echo ""
echo -e "${GREEN}🎉 Instalação concluída com sucesso!${NC}"
echo ""
echo -e "${BLUE}📋 Comandos disponíveis:${NC}"
echo "  print-bracelets-status   - Ver status do sistema"
echo "  print-bracelets-logs     - Ver logs em tempo real"
echo "  print-bracelets-restart  - Reiniciar sistema"
echo "  print-bracelets-stop     - Parar sistema"
echo "  print-bracelets-start    - Iniciar sistema"
echo ""
echo -e "${BLUE}🔄 Sistema configurado para:${NC}"
echo "  • Iniciar automaticamente com o sistema"
echo "  • Atualizar automaticamente a cada 5 minutos"
echo "  • Reiniciar automaticamente em caso de falha"
echo "  • Logs salvos em /var/log/print-bracelets"
echo ""
echo -e "${YELLOW}⚠️  Para interagir com o sistema (configurar impressora), execute:${NC}"
echo "  docker exec -it print-bracelets-system bash"
echo ""
echo -e "${GREEN}✅ Sistema pronto para uso!${NC}"
