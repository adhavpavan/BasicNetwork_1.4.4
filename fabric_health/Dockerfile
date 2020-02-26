FROM node:10.13-alpine

WORKDIR /usr/src/app

COPY . .

RUN npm install

EXPOSE 9091

ENTRYPOINT ["node", "fabric_health.js"]

#CMD ["yarn", "start"]

