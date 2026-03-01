# API Guidelines

This document defines the standards for building and publishing REST APIs on the Three Horizons platform. All APIs registered in the RHDH catalog must follow these conventions.

## REST Conventions

### URL Structure

Use kebab-case for URL paths and plural nouns for resource collections:

```
GET    /api/v1/orders          # List orders
POST   /api/v1/orders          # Create an order
GET    /api/v1/orders/{id}     # Get a specific order
PUT    /api/v1/orders/{id}     # Update an order
DELETE /api/v1/orders/{id}     # Delete an order
```

### HTTP Methods

| Method | Purpose | Idempotent |
|--------|---------|------------|
| GET | Retrieve resource(s) | Yes |
| POST | Create a resource | No |
| PUT | Replace a resource | Yes |
| PATCH | Partially update a resource | No |
| DELETE | Remove a resource | Yes |

### Status Codes

- **200** -- Success with response body
- **201** -- Resource created (include `Location` header)
- **204** -- Success with no response body
- **400** -- Bad request (validation error)
- **401** -- Unauthorized (missing or invalid credentials)
- **403** -- Forbidden (insufficient permissions)
- **404** -- Resource not found
- **409** -- Conflict (duplicate resource)
- **429** -- Rate limited
- **500** -- Internal server error

## API Versioning

All APIs must include a version prefix in the URL path:

```
/api/v1/resources
/api/v2/resources
```

**Versioning rules**:

- Increment the major version (`v1` to `v2`) for breaking changes
- Non-breaking changes (new optional fields, new endpoints) do not require a version bump
- Support at minimum the current and previous major version
- Deprecate old versions with a minimum 90-day notice via the `Sunset` header

## OpenAPI Specifications

Every API must publish an OpenAPI 3.0+ specification:

- Store the spec at `docs/openapi.yaml` in the repository root
- Register the API in the RHDH catalog using `apiVersion: backstage.io/v1alpha1` with `kind: API`
- Include descriptions for all endpoints, parameters, and response schemas
- Use `$ref` for shared schemas to avoid duplication

Example catalog registration:

```yaml
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: order-service-api
  description: Order management API
spec:
  type: openapi
  lifecycle: production
  owner: commerce-team
  definition:
    $text: ./docs/openapi.yaml
```

## Naming Conventions

- **Endpoints**: kebab-case (`/api/v1/order-items`)
- **Query parameters**: camelCase (`?pageSize=20&sortBy=createdAt`)
- **Request/response fields**: camelCase (`{ "orderId": "123", "createdAt": "..." }`)
- **Headers**: Title-Case with hyphens (`Content-Type`, `X-Request-Id`)

## Pagination

Use cursor-based or offset pagination for list endpoints:

```json
{
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 150,
    "totalPages": 8
  }
}
```

## Error Response Format

Return consistent error responses across all APIs:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "The 'email' field is required",
    "details": [
      { "field": "email", "reason": "required" }
    ]
  }
}
```

## Health Check Endpoints

Every API must expose:

- `GET /healthz` -- Liveness probe (returns 200 if the process is running)
- `GET /readyz` -- Readiness probe (returns 200 if dependencies are reachable)
- `GET /metrics` -- Prometheus metrics endpoint (port 8080 or 9090)
