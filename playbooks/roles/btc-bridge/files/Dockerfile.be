FROM node:12-alpine3.12

RUN apk add git
WORKDIR /app

ENV NODE_ENV testnet

#RUN mkdir -p /root/.aws /app/keys /app/encrypted

COPY . /app/
#RUN mv .env.testnet .env
RUN npm install
RUN npm run build

CMD npm start