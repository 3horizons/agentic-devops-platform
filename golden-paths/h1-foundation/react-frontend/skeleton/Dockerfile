# =============================================================================
# Multi-stage Dockerfile for React Frontend Application
# Stage 1: Build the application
# Stage 2: Serve with nginx
# =============================================================================

# --- Build Stage ---
FROM node:20-alpine AS build

WORKDIR /app

COPY package.json package-lock.json* ./
RUN npm ci

COPY . .
RUN npm run build

# --- Production Stage ---
FROM nginx:alpine-slim

COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
