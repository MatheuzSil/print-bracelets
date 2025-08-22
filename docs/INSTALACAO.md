# 🖥️ Manual de Instalação - Máquina de Produção

## 🚀 Instalação Rápida

### **Linux (Ubuntu/CentOS/RHEL)**
```bash
# Baixar e executar script de instalação
curl -fsSL https://raw.githubusercontent.com/MatheuzSil/print-bracelets/main/scripts/installation/install.sh | bash

# OU manualmente:
wget https://raw.githubusercontent.com/MatheuzSil/print-bracelets/main/scripts/installation/install.sh
chmod +x install.sh
sudo ./install.sh
```

### **Windows Server/Desktop**
```powershell
# PowerShell como Administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MatheuzSil/print-bracelets/main/scripts/installation/install-windows.ps1" -OutFile "install-windows.ps1"
.\install-windows.ps1 -InstallDocker
```

---

## 🔧 Instalação Manual

### **1. Pré-requisitos**

#### Linux:
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install curl wget

# CentOS/RHEL
sudo yum install curl wget
```

#### Windows:
- Windows 10/11 ou Windows Server 2019+
- PowerShell 5.1+
- Acesso de administrador

### **2. Instalar Docker**

#### Linux (Ubuntu):
```bash
# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# Reiniciar para aplicar permissões
sudo systemctl restart docker
```

#### Windows:
1. Baixar Docker Desktop: https://desktop.docker.com/win/main/amd64/Docker%20Desktop%20Installer.exe
2. Executar o instalador
3. Reiniciar o computador
4. Iniciar Docker Desktop

### **3. Instalar Sistema**

#### Método 1: Docker Compose (Recomendado)
```bash
# Criar diretório
mkdir /opt/print-bracelets
cd /opt/print-bracelets

# Baixar docker-compose
wget https://raw.githubusercontent.com/MatheuzSil/print-bracelets/main/docker/compose/production.yml

# Iniciar sistema
docker-compose -f production.yml up -d
```

#### Método 2: Docker Run
```bash
# Sistema principal
docker run -d \
  --name print-bracelets-system \
  --restart unless-stopped \
  --network host \
  -it \
  --label "com.centurylinklabs.watchtower.enable=true" \
  matheuzsilva/print-bracelets:latest

# Watchtower (atualizações automáticas)
docker run -d \
  --name watchtower \
  --restart unless-stopped \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -e WATCHTOWER_CLEANUP=true \
  -e WATCHTOWER_POLL_INTERVAL=300 \
  -e WATCHTOWER_LABEL_ENABLE=true \
  containrrr/watchtower:latest \
  --interval 300 --cleanup
```

---

## 🎛️ Operação do Sistema

### **Comandos de Controle (Linux)**
```bash
# Ver status
print-bracelets-status

# Ver logs em tempo real  
print-bracelets-logs

# Reiniciar sistema
print-bracelets-restart

# Parar sistema
print-bracelets-stop

# Iniciar sistema
print-bracelets-start
```

### **Comandos de Controle (Windows)**
```
C:\PrintBracelets\status.bat    - Ver status
C:\PrintBracelets\logs.bat      - Ver logs
C:\PrintBracelets\restart.bat   - Reiniciar
C:\PrintBracelets\stop.bat      - Parar
C:\PrintBracelets\start.bat     - Iniciar
```

### **Comandos Docker Diretos**
```bash
# Ver containers rodando
docker ps

# Ver logs do sistema
docker logs -f print-bracelets-system

# Ver logs do watchtower  
docker logs -f watchtower

# Entrar no container para configurar
docker exec -it print-bracelets-system bash

# Reiniciar container
docker restart print-bracelets-system

# Parar tudo
docker stop print-bracelets-system watchtower

# Remover tudo
docker rm print-bracelets-system watchtower
```

---

## ⚙️ Configuração

### **1. Primeira Execução**
Ao iniciar, o sistema perguntará:
- **Totem ID**: Identificador único do totem
- **IP da Impressora**: Endereço IP na rede local  
- **Machine ID**: Identificador da máquina

### **2. Configuração de Rede**
- Container usa `network_mode: host` para acesso direto à impressora
- Porta da impressora: 9100 (padrão)
- RabbitMQ: Configurado automaticamente

### **3. Logs**
- **Linux**: `/var/log/print-bracelets/`
- **Windows**: `C:\ProgramData\PrintBracelets\logs\`
- **Container**: `docker logs print-bracelets-system`

---

## 🔄 Atualizações Automáticas

O **Watchtower** verifica atualizações a cada 5 minutos:
1. Detecta nova versão no Docker Hub
2. Para o container atual
3. Baixa nova imagem
4. Inicia container com nova versão
5. Remove imagem antiga

### **Forçar Atualização**
```bash
# Reiniciar watchtower para verificar imediatamente
docker restart watchtower

# OU parar/iniciar container manualmente
docker stop print-bracelets-system
docker rm print-bracelets-system
docker pull matheuzsilva/print-bracelets:latest
# Executar docker run novamente...
```

---

## 🚨 Troubleshooting

### **Container não inicia**
```bash
# Verificar logs de erro
docker logs print-bracelets-system

# Verificar se porta está ocupada
netstat -tulpn | grep :9100

# Remover e recriar container
docker rm -f print-bracelets-system
docker run -d --name print-bracelets-system...
```

### **Watchtower não atualiza**
```bash
# Verificar logs do watchtower
docker logs watchtower

# Verificar se há nova versão
docker pull matheuzsilva/print-bracelets:latest

# Reiniciar watchtower
docker restart watchtower
```

### **Problemas de rede**
```bash
# Verificar conectividade com impressora
ping [IP_DA_IMPRESSORA]

# Verificar se container pode acessar rede
docker exec -it print-bracelets-system ping [IP_DA_IMPRESSORA]
```

---

## 📞 Suporte

### **Verificação de Saúde**
```bash
# Status completo do sistema
docker ps --filter name=print-bracelets
docker ps --filter name=watchtower  

# Uso de recursos
docker stats print-bracelets-system

# Informações da imagem
docker inspect matheuzsilva/print-bracelets:latest
```

### **Backup/Restore**
```bash
# Backup da configuração
docker cp print-bracelets-system:/app/logs ./backup/

# Restore (se necessário)
docker cp ./backup/ print-bracelets-system:/app/logs/
```
