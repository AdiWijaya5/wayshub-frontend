FROM node:14-alpine AS builder

WORKDIR /app

COPY package*.json .

RUN npm install

COPY . .

FROM node:14-alpine

RUN npm install -g pm2 && npm cache clean --force

COPY package*.json ./

RUN npm ci --only=production && npm cache clean --force

COPY --from=builder /app .

EXPOSE 3000

CMD ["pm2-runtime", "npm", "--", "start"]









