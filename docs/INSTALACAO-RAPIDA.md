# ⚡ Instalação Rápida - Sistema de Impressão

## 🐧 **Linux (Instalação Automática)**
```bash
curl -fsSL https://raw.githubusercontent.com/MatheuzSil/print-bracelets/main/scripts/installation/install.sh | bash
```

## 🪟 **Windows (Instalação Automática)**
```powershell
# Executar PowerShell como Administrador
Set-ExecutionPolicy RemoteSigned -Force
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/MatheuzSil/print-bracelets/main/scripts/installation/install-windows.ps1" -OutFile "install.ps1"
.\install.ps1 -InstallDocker
```

## 🐳 **Docker Compose (Alternativo)**
```bash
# Baixar e executar
curl -fsSL https://raw.githubusercontent.com/MatheuzSil/print-bracelets/main/docker/compose/production.yml -o docker-compose.yml
docker-compose up -d
```

---

## ✅ **Após a instalação:**

### **Linux - Comandos disponíveis:**
- `print-bracelets-status` - Ver status
- `print-bracelets-logs` - Ver logs em tempo real
- `print-bracelets-restart` - Reiniciar sistema

### **Windows - Scripts disponíveis:**
- `C:\PrintBracelets\status.bat` - Ver status
- `C:\PrintBracelets\logs.bat` - Ver logs
- `C:\PrintBracelets\restart.bat` - Reiniciar sistema

---

## 🔧 **Sistema configurado automaticamente para:**
- ✅ Iniciar com o sistema
- ✅ Atualizar automaticamente (5 min)
- ✅ Reiniciar em caso de falha
- ✅ Logs centralizados

**Documentação completa:** [INSTALACAO.md](INSTALACAO.md)
