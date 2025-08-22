# Makefile para Sistema de Impressão
.PHONY: start build run clean help

# Comando principal
start: build run

# Constrói a imagem Docker
build:
	@echo "Construindo imagem Docker..."
	docker build -t print-bracelets .

# Executa o container
run:
	@echo "Iniciando sistema..."
	docker run -it --rm --name print-bracelets-system print-bracelets

# Remove a imagem
clean:
	@echo "Removendo imagem..."
	docker rmi print-bracelets

# Remove containers parados
clean-containers:
	@echo "Removendo containers parados..."
	docker container prune -f

# Mostra ajuda
help:
	@echo "Comandos disponíveis:"
	@echo "  make start  - Constrói e executa o sistema"
	@echo "  make build  - Apenas constrói a imagem"
	@echo "  make run    - Apenas executa o container"
	@echo "  make clean  - Remove a imagem"
	@echo "  make help   - Mostra esta ajuda"
