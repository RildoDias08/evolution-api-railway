# Fase 1: Build
FROM node:20.7.0-alpine AS builder

# Informações sobre a imagem
LABEL version="1.8.0" description="API para controle de recursos do WhatsApp via requisições HTTP." 
LABEL maintainer="Davidson Gomes" git="https://github.com/DavidsonGomes"
LABEL contact="contato@agenciadgcode.com"

# Atualizar e instalar dependências necessárias
RUN apk update && apk upgrade && \
    apk add --no-cache git tzdata ffmpeg wget curl

# Definir o diretório de trabalho
WORKDIR /evolution

# Copiar o arquivo package.json e instalar dependências
COPY ./package.json .

RUN npm install

# Copiar o restante dos arquivos do projeto
COPY . .

# Compilar a aplicação
RUN npm run build

# Fase 2: Deploy final
FROM node:20.7.0-alpine AS final

# Definir o fuso horário e variáveis de ambiente
ENV TZ=America/Sao_Paulo
ENV DOCKER_ENV=true

# Configurações do servidor
ENV SERVER_TYPE=http
ENV SERVER_PORT=8080
ENV SERVER_URL=http://localhost:8080

# Configurações de CORS
ENV CORS_ORIGIN=*
ENV CORS_METHODS=POST,GET,PUT,DELETE
ENV CORS_CREDENTIALS=true

# Configurações de log
ENV LOG_LEVEL=ERROR,WARN,DEBUG,INFO,LOG,VERBOSE,DARK,WEBHOOKS
ENV LOG_COLOR=true
ENV LOG_BAILEYS=error

# Configurações de instâncias e armazenamento
ENV DEL_INSTANCE=false
ENV DEL_TEMP_INSTANCES=true
ENV STORE_MESSAGES=true
ENV STORE_MESSAGE_UP=true
ENV STORE_CONTACTS=true
ENV STORE_CHATS=true

# Limpeza e armazenamento
ENV CLEAN_STORE_CLEANING_INTERVAL=7200
ENV CLEAN_STORE_MESSAGES=true
ENV CLEAN_STORE_MESSAGE_UP=true
ENV CLEAN_STORE_CONTACTS=true
ENV CLEAN_STORE_CHATS=true

# Configurações do banco de dados
ENV DATABASE_ENABLED=false
ENV DATABASE_CONNECTION_URI=mongodb://root:root@mongodb:27017/?authSource=admin&readPreference=primary&ssl=false&directConnection=true
ENV DATABASE_CONNECTION_DB_PREFIX_NAME=evolution
ENV DATABASE_SAVE_DATA_INSTANCE=false
ENV DATABASE_SAVE_DATA_NEW_MESSAGE=false
ENV DATABASE_SAVE_MESSAGE_UPDATE=false
ENV DATABASE_SAVE_DATA_CONTACTS=false
ENV DATABASE_SAVE_DATA_CHATS=false

# Configurações do RabbitMQ
ENV RABBITMQ_ENABLED=false
ENV RABBITMQ_URI=amqp://guest:guest@rabbitmq:5672
ENV RABBITMQ_EXCHANGE_NAME=evolution_exchange
ENV RABBITMQ_GLOBAL_ENABLED=false

# Configurações de WebSocket
ENV WEBSOCKET_ENABLED=false
ENV WEBSOCKET_GLOBAL_EVENTS=false

# Configurações de Webhook
ENV WA_BUSINESS_TOKEN_WEBHOOK=evolution
ENV WA_BUSINESS_URL=https://graph.facebook.com
ENV WA_BUSINESS_VERSION=v18.0
ENV WA_BUSINESS_LANGUAGE=pt_BR

# Configurações do SQS (Amazon Simple Queue Service)
ENV SQS_ENABLED=false

# Configurações de autenticação
ENV AUTHENTICATION_TYPE=apikey
ENV AUTHENTICATION_API_KEY=B6D711FCDE4D4FD5936544120E713976

# Configurações de cache
ENV CACHE_REDIS_ENABLED=false

# Definir o diretório de trabalho na fase final
WORKDIR /evolution

# Copiar arquivos do builder para o contêiner final
COPY --from=builder /evolution .

# Comando para iniciar a aplicação
CMD ["node", "./dist/src/main.js"]
