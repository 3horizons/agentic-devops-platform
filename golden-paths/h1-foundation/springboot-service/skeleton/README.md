# ${{ values.name }}

${{ values.description }}

## Prerequisites

- **Java 21** (Eclipse Temurin recommended)
- **Maven 3.9+** (or use the included Maven Wrapper)
- **Docker** (optional, for containerized builds)

## Getting Started

### Running Locally

```bash
./mvnw spring-boot:run
```

The service starts on [http://localhost:8080](http://localhost:8080).

### Building

```bash
./mvnw clean package
```

### Running the JAR

```bash
java -jar target/${{ values.name }}-1.0.0-SNAPSHOT.jar
```

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/info` | Service information (name, version, environment) |
| `GET /swagger-ui.html` | OpenAPI / Swagger UI |
| `GET /api-docs` | OpenAPI JSON specification |
| `GET /actuator/health` | Health check |
| `GET /actuator/info` | Application info |
| `GET /actuator/metrics` | Application metrics |

## Testing

```bash
./mvnw test
```

Run the full verification suite (compile, test, integration test):

```bash
./mvnw verify
```

## Docker

### Build the image

```bash
docker build -t ${{ values.name }}:latest .
```

### Run the container

```bash
docker run -p 8080:8080 ${{ values.name }}:latest
```

## Project Structure

```
.
├── src/
│   ├── main/
│   │   ├── java/com/threehorizons/app/
│   │   │   ├── Application.java
│   │   │   └── controller/
│   │   │       └── InfoController.java
│   │   └── resources/
│   │       └── application.yml
│   └── test/
├── .devcontainer/
│   └── devcontainer.json
├── .github/workflows/
│   └── ci.yaml
├── catalog-info.yaml
├── Dockerfile
├── mvnw
├── pom.xml
└── README.md
```

## Configuration

Environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `APP_ENVIRONMENT` | Runtime environment name | `development` |
| `SERVER_PORT` | Server port | `8080` |

## License

Internal use only.
