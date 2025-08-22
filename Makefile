# Makefile para Sistema de Impressão
.PHONY: start build run clean help deploy push

# Variáveis
DOCKER_USER := matheuzsilva  # Altere para seu usuário Docker Hub
IMAGE_NAME := print-bracelets
VERSION := latest
TIMESTAMP := $(shell date +%Y%m%d-%H%M%S)

# Comando principal
start: build run

# Constrói a imagem Docker
build:
	@echo "🐳 Construindo imagem Docker..."
	docker build -t $(IMAGE_NAME) .

# Executa o container
run:
	@echo "🚀 Iniciando sistema..."
	docker run -it --rm --name print-bracelets-system $(IMAGE_NAME)

# Deploy completo (build + tag + push)
deploy: build
	@echo "🏷️ Taggeando imagem..."
	docker tag $(IMAGE_NAME) $(DOCKER_USER)/$(IMAGE_NAME):$(VERSION)
	docker tag $(IMAGE_NAME) $(DOCKER_USER)/$(IMAGE_NAME):$(TIMESTAMP)
	@echo "📤 Fazendo push para Docker Hub..."
	docker push $(DOCKER_USER)/$(IMAGE_NAME):$(VERSION)
	docker push $(DOCKER_USER)/$(IMAGE_NAME):$(TIMESTAMP)
	@echo "✅ Deploy concluído!"
	@echo "Imagem disponível em: $(DOCKER_USER)/$(IMAGE_NAME):$(VERSION)"

# Apenas push (assumindo que já foi feito build)
push:
	@echo "🏷️ Taggeando e fazendo push..."
	docker tag $(IMAGE_NAME) $(DOCKER_USER)/$(IMAGE_NAME):$(VERSION)
	docker push $(DOCKER_USER)/$(IMAGE_NAME):$(VERSION)

# Remove a imagem
clean:
	@echo "🧹 Removendo imagem..."
	docker rmi $(IMAGE_NAME) || true
	docker rmi $(DOCKER_USER)/$(IMAGE_NAME):$(VERSION) || true

# Remove containers parados
clean-containers:
	@echo "🧹 Removendo containers parados..."
	docker container prune -f

# Mostra ajuda
help:
	@echo "Comandos disponíveis:"
	@echo "  make start           - Constrói e executa o sistema"
	@echo "  make build           - Apenas constrói a imagem"
	@echo "  make run             - Apenas executa o container"
	@echo "  make deploy          - Build + Tag + Push para Docker Hub"
	@echo "  make push            - Apenas push para Docker Hub"
	@echo "  make clean           - Remove a imagem"
	@echo "  make clean-containers - Remove containers parados"
	@echo "  make help            - Mostra esta ajuda"
