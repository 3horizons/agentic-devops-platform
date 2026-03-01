# ${{ values.name }}

${{ values.description }}

## Prerequisites

- [Python](https://www.python.org/) >= 3.11
- [pip](https://pip.pypa.io/) (included with Python)
- [Docker](https://www.docker.com/) (optional, for containerized builds)

## Getting Started

### Install dependencies

```bash
pip install -e '.[dev]'
```

### Run in development mode

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000 --app-dir src
```

The service will start on [http://localhost:8000](http://localhost:8000).

Interactive API documentation (Swagger UI) is available at [http://localhost:8000/docs](http://localhost:8000/docs).

ReDoc documentation is available at [http://localhost:8000/redoc](http://localhost:8000/redoc).

## API Endpoints

| Method | Path           | Description                          |
|--------|----------------|--------------------------------------|
| GET    | /health        | Health check (status and timestamp)  |
| GET    | /ready         | Readiness probe                      |
| GET    | /api/v1/info   | Service name, version, environment   |
| GET    | /docs          | Swagger UI (auto-generated)          |
| GET    | /redoc         | ReDoc (auto-generated)               |

## Testing

```bash
pytest
```

Run tests with coverage report:

```bash
pytest --cov
```

## Linting and Type Checking

```bash
ruff check src/
mypy src/
```

## Docker

### Build the image

```bash
docker build -t ${{ values.name }}:latest .
```

### Run the container

```bash
docker run -p 8000:8000 ${{ values.name }}:latest
```

## Deployment

This service includes Kubernetes-ready health and readiness probe endpoints:

- **Liveness probe**: `GET /health`
- **Readiness probe**: `GET /ready`

## Environment Variables

| Variable     | Default       | Description           |
|--------------|---------------|-----------------------|
| ENVIRONMENT  | development   | Runtime environment   |
| LOG_LEVEL    | info          | structlog log level   |
