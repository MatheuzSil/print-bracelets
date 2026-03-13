# 🖨️ Sistema de Impressão de Pulseiras - Múltiplos Totems

Sistema avançado para gerenciamento e impressão de pulseiras com suporte a múltiplos totems simultâneos.

## ✨ Características

- 🏢 **Gerenciamento de Múltiplos Totems**: Cadastre quantos totems precisar
- 🖥️ **Janelas Independentes**: Cada totem roda em sua própria janela
- 💾 **Configurações Persistentes**: Todas as configurações são salvas automaticamente
- 📊 **Logs Detalhados**: Sistema de logs com timestamp e identificação por totem
- 🔄 **Controle Individual**: Inicie e pare totems individualmente
- 🎯 **Interface Amigável**: Menu intuitivo para todas as operações

## 🚀 Como Usar

### Iniciando o Sistema

```bash
npm start
```

ou

```bash
node run.js
```

### Menu Principal

O sistema apresenta as seguintes opções:

```
[1] Cadastrar Totem          - Adiciona um novo totem ao sistema
[2] Ver Totems Cadastrados   - Lista todos os totems e seus status
[3] Iniciar Totem           - Inicia um totem em nova janela
[4] Parar Totem             - Para um totem específico
[5] Ver Logs em Tempo Real   - (Em desenvolvimento)
[6] Reiniciar Sistema        - (Em desenvolvimento)
[7] Atualizar do GitHub      - (Em desenvolvimento)
[8] Desinstalar Sistema      - (Em desenvolvimento)
[9] Sair                     - Encerra o sistema
```

## 📋 Cadastrando um Totem

1. Selecione a opção **[1] Cadastrar Totem**
2. Informe:
   - **Nome do Totem**: Nome identificador (ex: "Totem Loja 1")
   - **Totem ID**: ID único do totem no sistema
   - **IP da Impressora**: Endereço IP da impressora
   - **Machine ID**: ID da máquina

3. Confirme as configurações
4. O totem será salvo e estará disponível para uso

## ▶️ Iniciando um Totem

1. Selecione a opção **[3] Iniciar Totem**
2. Escolha o totem da lista
3. Uma nova janela será aberta com o totem rodando
4. O status será atualizado para **[ATIVO]**

## ⏹️ Parando um Totem

1. Selecione a opção **[4] Parar Totem**
2. Escolha o totem ativo da lista
3. O totem será finalizado e o status voltará para **[INATIVO]**

## 📁 Arquivos de Configuração

- `totems.json` - Armazena as configurações de todos os totems cadastrados
- Localização: Pasta raiz do projeto

### Exemplo de configuração:

```json
[
  {
    "id": 1640995200000,
    "nome": "Totem Loja Principal",
    "totemId": "1be6a224-83b7-4072-92c0-11b347b20f16",
    "printerIp": "192.168.1.100",
    "machineId": "totem-loja-1",
    "rabbitUrl": "amqps://...",
    "printerPort": 9100,
    "dataCriacao": "2024-01-01T10:00:00.000Z"
  }
]
```

## 📊 Sistema de Logs

Cada totem possui logs detalhados com:
- ⏰ **Timestamp**: Data e hora de cada evento
- 🏷️ **Identificação**: Nome do totem que gerou o log
- 📋 **Tipo**: INFO, SUCCESS, ERROR
- 📝 **Mensagem**: Descrição detalhada do evento

### Exemplo de logs:

```
[05/02/2026 14:30:15] ℹ️ [Totem Loja 1] Conectando ao RabbitMQ...
[05/02/2026 14:30:16] ✅ [Totem Loja 1] Aguardando mensagens na fila: print_bracelets_1be6a224
[05/02/2026 14:30:45] ℹ️ [Totem Loja 1] Nova mensagem recebida para 2 criança(s)
[05/02/2026 14:30:45] ℹ️ [Totem Loja 1] Responsável: João da Silva
[05/02/2026 14:30:46] ✅ [Totem Loja 1] Pulseira de Maria da Silva enviada com sucesso!
```

## 🔧 Configurações Técnicas

- **RabbitMQ**: Sistema de filas para comunicação
- **Impressoras**: Suporte a impressoras de etiquetas (porta 9100)
- **Layouts**: Arquivos TSPL para formatação das pulseiras
- **QR Codes**: Geração automática de códigos para rastreamento

## 🖥️ Requisitos do Sistema

- Node.js 14+
- Windows (suporte nativo para múltiplas janelas)
- Acesso à rede para conectar com impressoras
- Conexão com internet para RabbitMQ

## 🛠️ Desenvolvimento

### Executar em modo desenvolvimento:

```bash
npm run setup    # Executa apenas o setup
npm run direct   # Executa diretamente um totem
```

### Estrutura do projeto:

```
📁 print-bracelets/
├── 📄 run.js                 # Ponto de entrada principal
├── 📁 src/
│   ├── 📄 setup.js           # Interface de gerenciamento
│   └── 📄 print-bracelets.js # Sistema de impressão
├── 📄 layout.tspl            # Layout pulseiras crianças
├── 📄 layoutparent.tspl      # Layout pulseira responsável
├── 📄 totems.json            # Configurações dos totems
└── 📄 package.json           # Dependências do projeto
```

## 🚨 Solução de Problemas

### Totem não inicia
- Verifique se o IP da impressora está correto
- Confirme se o Totem ID é único
- Verifique a conexão de rede

### Impressora não responde
- Teste conectividade com `ping [IP_DA_IMPRESSORA]`
- Verifique se a porta 9100 está aberta
- Confirme se a impressora está ligada e em rede

### Logs não aparecem
- Verifique se o totem está realmente ativo
- Confirme se há mensagens na fila do RabbitMQ
- Verifique a conectividade com a internet

## 📞 Suporte

Para problemas ou sugestões, consulte a documentação ou abra uma issue no repositório.

---

Desenvolvido com ❤️ para facilitar o gerenciamento de múltiplos totems de impressão.