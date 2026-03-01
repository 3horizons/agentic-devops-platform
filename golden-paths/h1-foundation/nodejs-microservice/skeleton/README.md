# ${{ values.name }}

${{ values.description }}

## Prerequisites

- [Node.js](https://nodejs.org/) >= 20.x
- [npm](https://www.npmjs.com/) >= 10.x
- [Docker](https://www.docker.com/) (optional, for containerized builds)

## Getting Started

### Install dependencies

```bash
npm install
```

### Run in development mode

```bash
npm run dev
```

The service will start on [http://localhost:3000](http://localhost:3000).

### Build for production

```bash
npm run build
npm start
```

## API Endpoints

| Method | Path           | Description                          |
|--------|----------------|--------------------------------------|
| GET    | /health        | Health check (status and timestamp)  |
| GET    | /ready         | Readiness probe                      |
| GET    | /api/v1/info   | Service name, version, environment   |

## Testing

```bash
npm test
```

Run tests with coverage report:

```bash
npm test -- --coverage
```

## Linting

```bash
npm run lint
```

## Docker

### Build the image

```bash
docker build -t ${{ values.name }}:latest .
```

### Run the container

```bash
docker run -p 3000:3000 ${{ values.name }}:latest
```

## Deployment

This service includes Kubernetes-ready health and readiness probe endpoints:

- **Liveness probe**: `GET /health`
- **Readiness probe**: `GET /ready`

## Environment Variables

| Variable   | Default       | Description           |
|------------|---------------|-----------------------|
| PORT       | 3000          | Server listen port    |
| NODE_ENV   | development   | Runtime environment   |
| LOG_LEVEL  | info          | Pino log level        |
