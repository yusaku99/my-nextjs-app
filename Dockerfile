FROM node:22-alpine As Dependency

WORKDIR /app

COPY package.json ./

RUN npm ci

FROM node:22-alpine As Builder

WORKDIR /app

COPY --from=dependency /app/node_modules ./node_modules
COPY . .

RUN npm prisma generate
RUN npm run build

FROM node:22-alpine As Runner   

WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package.json ./

EXPOSE 3000

CMD ["sh", "-c", "npm run prisma:generate && npm start"]



