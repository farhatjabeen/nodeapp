FROM node:12.2.0-alpine

WORKDIR app

COPY . .
RUN npm i express --save
EXPOSE 8000

CMD ["node","app.js"]
