# Scripts de Desktop - Sistema de Impressão de Pulseiras

Esta pasta contém scripts para facilitar o uso do sistema por usuários finais através de uma interface gráfica no Windows.

## Scripts Disponíveis

### 🎯 Menu Principal
- **`menu-principal.bat`** - Menu principal com todas as opções do sistema
  - Interface colorida e amigável
  - 8 opções disponíveis: Configurar, Status, Logs, Iniciar, Parar, Reiniciar, Desinstalar, Sair
  - Navegação por números

### ⚙️ Scripts de Controle
- **`configurar.bat`** - Acesso à configuração interativa do sistema
  - Executa `docker exec -it print-bracelets-system node setup.js`
  - Permite configurar ID do totem, IP da impressora e URL do RabbitMQ

- **`iniciar.bat`** - Inicializa o sistema de impressão
  - Inicia containers `print-bracelets-system` e `watchtower`
  - Verifica se containers existem antes de tentar iniciar

- **`parar.bat`** - Para o sistema de impressão
  - Para containers do sistema e Watchtower
  - Confirmação antes de parar

- **`reiniciar.bat`** - Reinicia o sistema completo
  - Reinicia tanto o sistema quanto o Watchtower
  - Feedback visual do processo

### 📊 Scripts de Monitoramento
- **`status.bat`** - Mostra status atual do sistema
  - Lista containers em execução
  - Mostra informações de CPU, memória e rede
  - Exibe últimos logs

- **`logs.bat`** - Visualização de logs em tempo real
  - Executa `docker logs -f print-bracelets-system`
  - Instrução para sair com Ctrl+C

### 🗑️ Script de Remoção
- **`desinstalar.bat`** - Remove completamente o sistema
  - Confirmação dupla antes de executar
  - Remove containers, imagens e limpa recursos
  - Aviso claro sobre a ação irreversível

## Como Usar

### Instalação
Os scripts são automaticamente copiados para `C:\PrintBracelets\` durante a instalação do sistema.

### Acesso Rápido
Um atalho é criado na área de trabalho chamado **"Sistema de Impressao.lnk"** que aponta para o menu principal.

### Interface Visual
Todos os scripts usam:
- Cores diferentes para cada função
- Títulos descritivos nas janelas
- Feedback visual das operações
- Navegação intuitiva

## Estrutura de Cores

- 🟢 **Verde (0A)** - Menu principal e inicialização
- 🔵 **Azul (0B)** - Configuração
- 🟡 **Amarelo (0E)** - Operações de parada
- 🔵 **Azul claro (0D)** - Status e reinicialização  
- ⚪ **Branco (0F)** - Logs
- 🔴 **Vermelho (0C)** - Desinstalação

## Requisitos

- Windows com Docker Desktop instalado
- Sistema de impressão já instalado via `install-windows.ps1`
- Containers `print-bracelets-system` e `watchtower` configurados

## Solução de Problemas

### Erro "Container não encontrado"
- Execute primeiro o script de instalação
- Verifique se o Docker Desktop está rodando

### Erro "Docker não encontrado"
- Instale o Docker Desktop
- Reinicie o sistema após instalação

### Scripts não funcionam
- Execute como Administrador se necessário
- Verifique se os caminhos em `C:\PrintBracelets\` estão corretos

## Personalização

Para modificar a aparência dos scripts:
- Altere o comando `color` no início de cada arquivo
- Modifique os textos e mensagens conforme necessário
- Adicione validações extras se desejado

## Integração

Os scripts são projetados para trabalhar em conjunto com:
- Sistema principal containerizado
- Watchtower para atualizações automáticas
- Scripts de instalação multiplataforma
- Sistema de logs centralizados
