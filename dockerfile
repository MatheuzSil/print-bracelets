FROM node:18-alpine

# Instala dependências do sistema
RUN apk add --no-cache bash

# Define diretório de trabalho
WORKDIR /app

# Copia arquivos de dependências
COPY package*.json ./

# Instala dependências
RUN npm ci --only=production

# Copia código da aplicação
COPY src/ ./
COPY layout.tspl ./

# Cria usuário não-root
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Muda ownership dos arquivos
RUN chown -R nodejs:nodejs /app
USER nodejs

# Labels para identificação
LABEL maintainer="matheuzsilva"
LABEL version="1.0.0"
LABEL description="Sistema de Impressão de Pulseiras"

# Comando de entrada
ENTRYPOINT ["node", "setup.js"]
