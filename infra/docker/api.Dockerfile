FROM node:24-alpine AS build
WORKDIR /workspace/apps/api
COPY apps/api/package*.json ./
RUN npm ci
COPY apps/api ./
RUN npm run prisma:generate && npm run build

FROM node:24-alpine AS runtime
ENV NODE_ENV=production
WORKDIR /app
COPY --from=build /workspace/apps/api/package*.json ./
RUN npm ci --omit=dev
COPY --from=build /workspace/apps/api/dist ./dist
COPY --from=build /workspace/apps/api/src/generated ./src/generated
COPY --from=build /workspace/apps/api/prisma ./prisma
EXPOSE 3000
CMD ["node", "dist/main.js"]

