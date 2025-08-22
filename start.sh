#!/bin/bash

# Pergunta as infos
read -p "Digite o Totem ID: " TOTEM_ID
read -p "Digite o Printer IP: " PRINTER_IP

# Variáveis fixas
RABBIT_URL="amqps://heqbymsv:2twbq9gst2Mo8GpjeRZ41Tdw46zu4Ygj@jackal.rmq.cloudamqp.com/heqbymsv"
PRINTER_PORT=9100

# Exporta variáveis pro Node
export TOTEM_ID
export PRINTER_IP
export RABBIT_URL
export PRINTER_PORT

# Roda o sistema
node index.js
