# 📦 Instalação do Sistema de Impressão de Pulseiras

## Para repositório privado - use este método:

### 1. Obter os arquivos
- **Opção A**: Clone o repositório (se tiver acesso)
- **Opção B**: Baixe este arquivo e o `install-simples.ps1`

### 2. Instalar
```powershell
# Execute como Administrador no PowerShell
Set-ExecutionPolicy RemoteSigned -Force
.\install-simples.ps1
```

### 3. Usar o sistema
- Um ícone será criado na área de trabalho: **"Sistema de Impressao"**
- Clique duplo para abrir o menu
- Na primeira vez, escolha **"Configurar Sistema"**

## Requisitos
- Windows 10/11
- Docker Desktop instalado
- Executar PowerShell como Administrador

## Download Docker Desktop
https://www.docker.com/products/docker-desktop/

---

## 🎯 O que o instalador faz:

1. ✅ Verifica se Docker está instalado e rodando
2. ✅ Baixa a imagem do sistema do Docker Hub
3. ✅ Cria todos os scripts de controle em `C:\PrintBracelets\`
4. ✅ Cria ícone na área de trabalho
5. ✅ Inicia o sistema automaticamente
6. ✅ Configura atualizações automáticas (Watchtower)

## 📱 Scripts criados:
- **Menu Principal** - Interface gráfica completa
- **Configurar** - Setup inicial (totem ID, IP impressora)
- **Iniciar/Parar** - Controle do sistema
- **Status** - Ver estado atual
- **Logs** - Monitoramento em tempo real
- **Reiniciar** - Reset completo
- **Desinstalar** - Remoção total

---

**Sistema pronto em 2 minutos!** 🚀
