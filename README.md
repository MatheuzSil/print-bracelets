# 🖨️ Sistema de Impressão de Pulseiras

Sistema containerizado para impressão automática de pulseiras via RabbitMQ com atualizações automáticas via Watchtower.

## 🚀 Instalação Rápida

> **Nota**: Como este repositório é privado, faça o download/clone primeiro.

### Windows - Instalação Local
```powershell
# 1. Clone ou baixe o repositório
git clone https://github.com/MatheuzSil/print-bracelets.git
cd print-bracelets

# 2. Execute o instalador (como Administrador)
Set-ExecutionPolicy RemoteSigned -Force
.\install-simples.ps1
```

### Windows - Instalação Manual Rápida
```powershell
# Se você tem Docker instalado, pode executar diretamente:
docker run -d --name print-bracelets-system --restart unless-stopped --network host -it matheuzsilva/print-bracelets:latest

# Para atualizações automáticas, adicione o Watchtower:
docker run -d --name watchtower --restart unless-stopped -v "//./pipe/docker_engine://./pipe/docker_engine" -e WATCHTOWER_CLEANUP=true -e WATCHTOWER_POLL_INTERVAL=300 -e WATCHTOWER_LABEL_ENABLE=true containrrr/watchtower:latest --interval 300 --cleanup
```

### Linux
```bash
curl -fsSL https://raw.githubusercontent.com/MatheuzSil/print-bracelets/main/scripts/installation/install.sh | bash
```

## 📁 Estrutura do Projeto

```
📁 src/                     # Código fonte
├── print-bracelets.js      # Sistema principal
├── setup.js               # Interface de configuração  
├── reset-printer.js        # Reset da impressora
└── test-*.js              # Arquivos de teste

� scripts/                 # Scripts de automação
├── installation/           # Scripts de instalação
│   ├── install.sh         # Instalação Linux
│   └── install-windows.ps1 # Instalação Windows
├── desktop/               # Scripts para área de trabalho
│   ├── Configurar Sistema.bat
│   ├── Status do Sistema.bat  
│   ├── Ver Logs.bat
│   ├── Iniciar Sistema.bat
│   ├── Parar Sistema.bat
│   └── Reiniciar Sistema.bat
└── deployment/            # Scripts de deploy
    ├── deploy.sh          # Deploy Linux
    └── deploy.ps1         # Deploy Windows

📁 docker/                  # Configurações Docker
└── compose/               # Arquivos Docker Compose
    ├── docker-compose.yml     # Desenvolvimento
    ├── docker-compose.prod.yml # Produção alternativa  
    ├── production.yml         # Produção principal
    └── watchtower.yml         # Apenas Watchtower

📁 docs/                    # Documentação
├── INSTALACAO.md          # Manual completo
└── INSTALACAO-RAPIDA.md   # Guia rápido

📁 Arquivos raiz
├── dockerfile             # Imagem Docker
├── package.json          # Dependências Node.js
├── layout.tspl           # Template de impressão
├── Makefile             # Comandos make
└── start.*              # Scripts de inicialização
```

## 🎯 Uso Após Instalação

### Windows - Scripts na Área de Trabalho
Após a instalação, encontre na área de trabalho a pasta **"Sistema Impressao"** com:

- 🔧 **Configurar Sistema.bat** - Configurar impressora (primeira vez)
- 📊 **Status do Sistema.bat** - Ver status atual  
- 📋 **Ver Logs.bat** - Monitorar atividade
- ▶️ **Iniciar Sistema.bat** - Iniciar serviço
- ⏸️ **Parar Sistema.bat** - Parar serviço
- 🔄 **Reiniciar Sistema.bat** - Reiniciar serviço

### Linux - Comandos do Terminal
```bash
print-bracelets-status    # Ver status
print-bracelets-logs      # Ver logs em tempo real  
print-bracelets-restart   # Reiniciar sistema
print-bracelets-start     # Iniciar sistema
print-bracelets-stop      # Parar sistema
```

## ⚙️ Configuração

Na primeira execução, o sistema perguntará:
- **Totem ID**: Identificador único do totem
- **IP da Impressora**: Endereço IP na rede local
- **Machine ID**: Identificador da máquina

Valores automáticos:
- **Rabbit URL**: Configurado automaticamente
- **Porta da Impressora**: 9100 (padrão)

## � Atualizações Automáticas

O **Watchtower** verifica atualizações automaticamente a cada 5 minutos:
- ✅ Detecta novas versões no Docker Hub
- ✅ Baixa e atualiza automaticamente
- ✅ Reinicia o sistema com nova versão  
- ✅ Remove versões antigas

## �️ Desenvolvimento

### Executar localmente
```bash
# Desenvolvimento
docker-compose -f docker/compose/docker-compose.yml up --build

# Produção local
docker-compose -f docker/compose/production.yml up -d
```

### Fazer deploy
```bash
# Windows
.\scripts\deployment\deploy.ps1

# Linux  
./scripts/deployment/deploy.sh

# Make
make deploy
```

## 📚 Documentação

- 📖 [Manual Completo](docs/INSTALACAO.md)
- ⚡ [Instalação Rápida](docs/INSTALACAO-RAPIDA.md)

## 🆘 Suporte

### Verificar Status
```bash
docker ps --filter name=print-bracelets
docker logs print-bracelets-system
```

### Troubleshooting Comum
- **Container não inicia**: Verificar logs com scripts da área de trabalho
- **Impressora não responde**: Verificar IP e conectividade de rede
- **Atualizações falham**: Verificar logs do Watchtower

---

## 🏗️ Tecnologias

- **Node.js** - Runtime
- **Docker** - Containerização  
- **RabbitMQ** - Mensageria
- **Watchtower** - Atualizações automáticas
- **TSPL** - Linguagem da impressora

---

**Sistema pronto para produção com instalação automática e interface amigável!** 🎉
