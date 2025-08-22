FROM node:18

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Define o script de setup como entrypoint
ENTRYPOINT ["node", "setup.js"]
