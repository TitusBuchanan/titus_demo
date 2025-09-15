# syntax=docker/dockerfile:1.7
FROM node:20-alpine AS base

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci --ignore-scripts --no-audit --no-fund || npm install --ignore-scripts --no-audit --no-fund

COPY src ./src
COPY public ./public

EXPOSE 3000
ENV NODE_ENV=production PORT=3000
CMD ["npm", "start"]


