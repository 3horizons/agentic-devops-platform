# ${{ values.name }}

${{ values.description }}

## Prerequisites

- **Go 1.22+**
- **Docker** (optional, for containerized builds)

## Getting Started

### Running Locally

```bash
go run ./cmd/server
```

The service starts on [http://localhost:8080](http://localhost:8080).

### Building

```bash
go build -o bin/server ./cmd/server
./bin/server
```

## Endpoints

| Endpoint | Description |
|----------|-------------|
| `GET /api/v1/info` | Service information (name, version, environment) |
| `GET /health` | Health check (status and timestamp) |
| `GET /ready` | Readiness probe |

## Testing

```bash
go test ./...
```

Run tests with race detection and coverage:

```bash
go test -race -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html
```

## Linting

```bash
golangci-lint run ./...
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
├── cmd/
│   └── server/
│       └── main.go          # Application entry point
├── .devcontainer/
│   └── devcontainer.json
├── .github/workflows/
│   └── ci.yaml
├── catalog-info.yaml
├── Dockerfile
├── go.mod
└── README.md
```

## Configuration

Environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Server listen port | `8080` |
| `ENVIRONMENT` | Runtime environment name | `development` |

## Graceful Shutdown

The server handles `SIGINT` and `SIGTERM` signals for graceful shutdown with a 10-second timeout, ensuring in-flight requests complete before the process exits.

## License

Internal use only.
