# 🎯 Guia Rápido - Sistema de Múltiplos Totems

## Como usar o novo sistema em 5 passos:

### 1. 🚀 Iniciar o Sistema
```bash
npm start
```

### 2. ➕ Cadastrar seu primeiro totem
- Selecione opção **[1] Cadastrar Totem**
- Exemplo de dados:
  ```
  Nome do totem: Loja Shopping Norte
  Totem ID: loja-shopping-norte-001
  IP da Impressora: 192.168.1.100
  Machine ID: totem-loja-1
  ```

### 3. ➕ Cadastrar mais totems (opcional)
- Repita o processo para cada totem
- Exemplo de segundo totem:
  ```
  Nome do totem: Loja Centro
  Totem ID: loja-centro-002  
  IP da Impressora: 192.168.1.101
  Machine ID: totem-loja-2
  ```

### 4. ▶️ Iniciar um ou mais totems
- Selecione opção **[3] Iniciar Totem**
- Escolha da lista qual totem iniciar
- **Uma nova janela será aberta para cada totem!** 🪟
- Status mudará para **[ATIVO]**

### 5. 📊 Monitorar
- Selecione opção **[2] Ver Totems Cadastrados** para ver status
- Cada janela de totem mostrará seus próprios logs
- Múltiplos totems podem rodar simultaneamente

## 🔄 Operações Comuns

### ⏹️ Parar um totem específico:
- Opção **[4] Parar Totem**
- Escolha qual totem parar
- Apenas esse totem será finalizado

### 🗂️ Ver todos os totems:
- Opção **[2] Ver Totems Cadastrados**
- Mostra nome, status, IP, data de criação

### 🚪 Sair do sistema:
- Opção **[9] Sair**
- Para todos os totems ativos automaticamente

## ⚡ Vantagens do Novo Sistema

### ✅ Antes (Sistema Antigo):
- ❌ Apenas 1 totem por vez
- ❌ Configuração manual toda vez
- ❌ Sem controle individual

### ✅ Agora (Novo Sistema):
- ✅ Múltiplos totems simultâneos
- ✅ Configurações salvas permanentemente  
- ✅ Uma janela para cada totem
- ✅ Controle individual (iniciar/parar)
- ✅ Interface amigável com menu
- ✅ Status visual dos totems
- ✅ Logs detalhados por totem

## 🖥️ Como ficam as janelas:

```
┌─ Janela 1: Menu Principal ──────┐
│ [1] Cadastrar Totem             │
│ [2] Ver Totems Cadastrados      │  
│ [3] Iniciar Totem              │
│ [4] Parar Totem                │
│ [9] Sair                       │
└─────────────────────────────────┘

┌─ Janela 2: Totem Loja Norte ────┐    ┌─ Janela 3: Totem Loja Centro ──┐
│ ✅ [Loja Norte] Conectado...     │    │ ✅ [Loja Centro] Conectado...    │
│ ℹ️ [Loja Norte] Aguardando...    │    │ ℹ️ [Loja Centro] Aguardando...   │
│ ✅ [Loja Norte] Pulseira impressa │    │ ✅ [Loja Centro] Pulseira impressa│
└─────────────────────────────────┘    └─────────────────────────────────┘
```

## 💡 Dica Pro:
Deixe o **Menu Principal** sempre aberto para gerenciar seus totems facilmente!

---
🎉 **Agora você pode operar quantos totems precisar, cada um em sua própria janela!**