# =============================================================================
# Multi-stage Dockerfile for Spring Boot 3 with Java 21
# =============================================================================

# --- Build stage ---
FROM eclipse-temurin:21-jdk-alpine AS build

WORKDIR /workspace

# Copy Maven wrapper and pom.xml first for dependency caching
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Download dependencies (cached layer)
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copy source code and build
COPY src/ src/
RUN ./mvnw package -DskipTests -B

# --- Runtime stage ---
FROM eclipse-temurin:21-jre-alpine

LABEL maintainer="platform-engineering"
LABEL org.opencontainers.image.source="https://github.com/${{ values.repoUrl | projectSlug }}"

RUN addgroup -S appgroup && adduser -S appuser -G appgroup -u 1001

WORKDIR /app

COPY --from=build /workspace/target/*.jar app.jar

RUN chown -R appuser:appgroup /app

USER 1001

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
    CMD wget -qO- http://localhost:8080/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
