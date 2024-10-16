FROM node:20.7.0-alpine AS builder

LABEL version="1.8.0" description="Api to control whatsapp features through http requests." 
LABEL maintainer="Rildo dias" git="https://github.com/RildoDias08"


RUN apk update && apk upgrade && \
    apk add --no-cache git tzdata ffmpeg wget curl

WORKDIR /evolution

COPY package.json .  # Certifique-se de que este arquivo está na raiz

RUN npm install

COPY . .

RUN npm run build

FROM node:20.7.0-alpine AS final

# Defina variáveis de ambiente
ENV TZ=America/Sao_Paulo \
    DOCKER_ENV=true \
    SERVER_TYPE=http \
    SERVER_PORT=8080 \
    SERVER_URL=http://localhost:8080 \
    CORS_ORIGIN=* \
    CORS_METHODS=POST,GET,PUT,DELETE \
    CORS_CREDENTIALS=true \
    LOG_LEVEL=ERROR,WARN,DEBUG,INFO,LOG,VERBOSE,DARK,WEBHOOKS \
    LOG_COLOR=true \
    LOG_BAILEYS=error \
    DEL_INSTANCE=false \
    DEL_TEMP_INSTANCES=true \
    STORE_MESSAGES=true \
    STORE_MESSAGE_UP=true \
    STORE_CONTACTS=true \
    STORE_CHATS=true \
    CLEAN_STORE_CLEANING_INTERVAL=7200 \
    CLEAN_STORE_MESSAGES=true \
    CLEAN_STORE_MESSAGE_UP=true \
    CLEAN_STORE_CONTACTS=true \
    CLEAN_STORE_CHATS=true \
    DATABASE_ENABLED=false \
    DATABASE_CONNECTION_URI=mongodb://root:root@mongodb:27017/?authSource=admin&readPreference=primary&ssl=false&directConnection=true \
    DATABASE_CONNECTION_DB_PREFIX_NAME=evolution \
    AUTHENTICATION_API_KEY=B6D711FCDE4D4FD5936544120E713976

WORKDIR /evolution

COPY --from=builder /evolution .

CMD [ "node", "./dist/src/main.js" ]
