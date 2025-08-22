# Sistema de Impressão de Pulseiras - Docker

Este sistema permite imprimir pulseiras através de mensagens RabbitMQ em um ambiente containerizado.

## Como usar

### Opção 1: Docker Compose (Recomendado)

```bash
docker-compose up --build
```

### Opção 2: Docker direto

```bash
# Build da imagem
docker build -t print-bracelets .

# Executar o container
docker run -it print-bracelets
```

## Configuração

Ao iniciar o container, você será solicitado a informar:

1. **Totem ID**: Identificador único do totem
2. **IP da Impressora**: Endereço IP da impressora na rede
3. **Machine ID**: Identificador único da máquina

Os seguintes valores são configurados automaticamente:
- **Rabbit URL**: `amqps://heqbymsv:2twbq9gst2Mo8GpjeRZ41Tdw46zu4Ygj@jackal.rmq.cloudamqp.com/heqbymsv`
- **Porta da Impressora**: `9100`

## Exemplo de uso

```
=== Configuração do Sistema de Impressão ===

Digite o Totem ID: TOTEM001
Digite o IP da Impressora: 192.168.1.100
Digite o Machine ID: MACHINE001

=== Configurações ===
Totem ID: TOTEM001
IP da Impressora: 192.168.1.100
Machine ID: MACHINE001
Rabbit URL: amqps://heqbymsv:2twbq9gst2Mo8GpjeRZ41Tdw46zu4Ygj@jackal.rmq.cloudamqp.com/heqbymsv
Porta da Impressora: 9100
========================

Confirma as configurações? (s/n): s
Iniciando sistema...
```

## Parar o container

Para parar o sistema, use `Ctrl+C` no terminal ou:

```bash
docker-compose down
```

## Logs

Para ver os logs do container:

```bash
docker-compose logs -f
```

## Requisitos

- Docker
- Docker Compose
- Impressora conectada à rede local
- Acesso à internet para conexão com RabbitMQ
