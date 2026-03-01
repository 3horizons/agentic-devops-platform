# =============================================================================
# Multi-stage Dockerfile for Go Microservice
# =============================================================================

# --- Build stage ---
FROM golang:1.22-alpine AS build

RUN apk add --no-cache git

WORKDIR /src

# Copy go.mod and go.sum first for dependency caching
COPY go.mod go.sum* ./
RUN go mod download

# Copy source code and build
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /app ./cmd/server

# --- Runtime stage ---
FROM gcr.io/distroless/static-debian12

LABEL maintainer="platform-engineering"
LABEL org.opencontainers.image.source="https://github.com/${{ values.repoUrl | projectSlug }}"

COPY --from=build /app /app

USER nonroot:nonroot

EXPOSE 8080

ENTRYPOINT ["/app"]
