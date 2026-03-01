# Your First Golden Path: Creating a Microservice

> Phase 5.3 Onboarding -- First-Day Golden Path Guide
> Three Horizons Agentic DevOps Platform | Red Hat Developer Hub 1.8

---

## Introduction

This hands-on tutorial walks you through creating your first software component using a Golden Path template in the Three Horizons Developer Hub. By the end of this guide, you will have a fully scaffolded microservice with source code, a Dockerfile, a CI pipeline, and automatic registration in the portal catalog.

Golden Paths are opinionated, organization-approved templates that encode best practices for creating new services. They eliminate boilerplate setup and ensure every new component starts with a consistent, production-ready foundation.

**Time to complete**: 15-20 minutes.

---

## Prerequisites

Before starting, ensure you have:

- [ ] **Portal access**: You have completed the [Getting Started Guide](./getting-started-portal.md) and can log in to `https://devhub.3horizons.ai`.
- [ ] **GitHub account**: Your GitHub account belongs to the organization and has permission to create repositories.
- [ ] **Language familiarity**: Basic understanding of the programming language you will choose for your template.
- [ ] **Local development tools** (optional, for Step 5):
  - Git
  - Docker Desktop (for running the service locally via container)
  - The language runtime for your chosen template (Node.js 18+, Python 3.11+, .NET 8, Java 21, or Go 1.21+)

---

## Step 1: Choose Your Template

1. Log in to the portal at `https://devhub.3horizons.ai`.
2. Click **Create** in the left sidebar (or navigate to `/create`).
3. Browse the available Golden Path templates.

You will see six language-specific templates for microservice creation:

| Template | Language & Framework | Best For |
|----------|---------------------|----------|
| **Node.js Microservice** | Express + TypeScript | REST APIs, BFF (Backend for Frontend), real-time services |
| **Python FastAPI** | FastAPI + async | Data-centric APIs, ML serving endpoints, rapid prototyping |
| **React Frontend** | React + Vite + TypeScript | Single-page applications, admin dashboards, customer portals |
| **.NET 8 Web API** | ASP.NET Core + Entity Framework | Enterprise APIs, line-of-business applications, Azure-native services |
| **Spring Boot 3** | Java 21 + Maven + JPA | Enterprise Java services, existing Java ecosystem integration |
| **Go Microservice** | Go + Chi router | High-performance services, infrastructure tooling, CLI applications |

4. Click on the template that matches your use case. For this tutorial, we will use **Node.js Microservice** as the example, but the steps are the same for any template.

> **Tip**: If you are unsure which template to pick, Node.js Microservice or Python FastAPI are good starting points -- they have the smallest learning curve and fastest iteration cycle.

---

## Step 2: Fill in the Form

After selecting a template, the scaffolder wizard opens with a multi-step form. Here is what each field means and example values to use.

### Component Information (Step 1 of the wizard)

| Field | Description | Example Value |
|-------|-------------|---------------|
| **Service Name** | The name of your new microservice. Use `kebab-case` (lowercase, hyphens). This becomes the repository name and Kubernetes service name. | `my-order-service` |
| **Description** | A brief description of what your service does. This appears in the catalog and README. | `Order management microservice for the e-commerce platform` |
| **Owner** | The team that owns this service. Select from the dropdown (populated from GitHub teams synced to the catalog). | `backend-team` |
| **System** | The parent system this service belongs to. Systems group related components together. | `e-commerce-platform` |
| **Lifecycle** | The maturity stage of the service. Options: `experimental`, `development`, `staging`, `production`. | `experimental` |

> **Naming conventions**:
> - Service names must be lowercase alphanumeric with hyphens (e.g., `my-order-service`).
> - Avoid underscores, spaces, or special characters.
> - Keep names short but descriptive (3-5 words maximum).

### Repository Information (Step 2 of the wizard)

| Field | Description | Example Value |
|-------|-------------|---------------|
| **Host** | The Git host where the repository will be created. | `github.com` |
| **Organization** | Your GitHub organization. Select from the dropdown. | `3horizons` |
| **Repository Name** | Defaults to the Service Name. You can override it if needed. | `my-order-service` |
| **Default Branch** | The default branch name for the new repository. | `main` |
| **Visibility** | Repository visibility (`public` or `private`). | `private` |

### Review (Step 3 of the wizard)

Review all the values you entered. Double-check:

- Service name is correct and follows naming conventions.
- Owner is your actual team (not a different team).
- Organization is the correct GitHub org.
- Repository name does not conflict with an existing repo.

If everything looks good, proceed to the next step.

---

## Step 3: Create the Component

1. Click **"Create"** (or **"Run"**, depending on your RHDH version) to start the scaffolding process.
2. The scaffolder executes a series of automated steps. Watch the progress in real-time:

| Step | Action | What Happens |
|------|--------|-------------|
| **Fetch** | `fetch:template` | Downloads the template skeleton from the platform repository and applies your parameter values (service name, owner, description) to all template files. |
| **Publish** | `publish:github` | Creates a new GitHub repository in your organization, pushes the scaffolded source code, and configures the default branch. |
| **Register** | `catalog:register` | Registers the new component in the Backstage catalog by submitting the `catalog-info.yaml` URL from the new repository. |

3. Each step shows a green checkmark when complete. The entire process typically takes 15-30 seconds.

4. When all steps complete successfully, you will see two important links:
   - **Repository**: Click this to view your new GitHub repository.
   - **Catalog Entity**: Click this to view your new component in the portal catalog.

> **Troubleshooting**: If the scaffolder fails:
> - **"Repository already exists"**: Choose a different repository name.
> - **"Permission denied"**: Ensure your GitHub account has repository creation rights in the organization.
> - **"Template not found"**: The template may have been recently updated. Refresh the page and try again.

---

## Step 4: Explore Your New Service

Click the **Repository** link from the scaffolder results to open your new GitHub repository. Here is what you get out of the box:

### Project Structure

```
my-order-service/
├── src/
│   ├── index.ts              # Application entry point
│   ├── routes/
│   │   ├── health.ts         # Health check endpoints (/health, /ready)
│   │   └── api.ts            # API routes (/api/v1/info)
│   ├── middleware/
│   │   └── logging.ts        # Structured logging middleware
│   └── config/
│       └── index.ts          # Environment-based configuration
├── test/
│   └── health.test.ts        # Unit tests for health endpoints
├── .github/
│   └── workflows/
│       └── ci.yaml           # GitHub Actions CI pipeline
├── .devcontainer/
│   └── devcontainer.json     # Dev Container for VS Code / Codespaces
├── Dockerfile                # Multi-stage Docker build (non-root)
├── docker-compose.yaml       # Local development with Docker Compose
├── catalog-info.yaml         # Backstage catalog entity definition
├── package.json              # Dependencies and scripts
├── tsconfig.json             # TypeScript configuration
├── .eslintrc.js              # Linting rules
├── .prettierrc               # Code formatting rules
└── README.md                 # Auto-generated project documentation
```

> **Note**: The exact file structure varies by template. The structure above is for the Node.js Microservice template. Other templates follow similar patterns with language-appropriate tooling.

### What Each Template Provides

**All templates include:**

| Feature | Details |
|---------|---------|
| **Health Endpoints** | `GET /health` (liveness probe), `GET /ready` (readiness probe), `GET /api/v1/info` (service info) |
| **Dockerfile** | Multi-stage build, non-root user, optimized layer caching, production-ready |
| **CI Pipeline** | GitHub Actions workflow with lint, test, build, and Docker image push |
| **Dev Container** | VS Code / GitHub Codespaces development environment with all tools pre-installed |
| **Catalog Entry** | `catalog-info.yaml` with proper metadata, owner, system, and lifecycle annotations |
| **README** | Generated documentation with build instructions, API reference, and deployment notes |

**Template-specific extras:**

| Template | Additional Features |
|----------|-------------------|
| **Node.js Microservice** | Express 4, TypeScript 5, Jest testing, ESLint + Prettier, structured logging (pino) |
| **Python FastAPI** | FastAPI 0.100+, async endpoints, Pydantic models, auto-generated OpenAPI spec, pytest, Black + isort |
| **React Frontend** | Vite build, React Router, Tailwind CSS, Vitest, Storybook setup, production Nginx Dockerfile |
| **.NET 8 Web API** | ASP.NET Core 8, Entity Framework Core, Swagger/OpenAPI, xUnit tests, health checks middleware |
| **Spring Boot 3** | Java 21, Spring Boot 3.2, Maven, JPA/Hibernate, JUnit 5, Actuator health endpoints |
| **Go Microservice** | Go 1.21, Chi router, structured logging (slog), Go test, minimal dependencies, tiny Docker image |

---

## Step 5: Run Locally

Choose the tab for your template language and follow the instructions to run your new service locally.

### Node.js Microservice

```bash
# Clone the repository
git clone git@github.com:3horizons/my-order-service.git
cd my-order-service

# Install dependencies
npm install

# Run in development mode (with hot reload)
npm run dev

# The service starts on http://localhost:3000
# Test the health endpoint:
curl http://localhost:3000/health
# Expected: {"status":"ok"}

curl http://localhost:3000/api/v1/info
# Expected: {"name":"my-order-service","version":"1.0.0"}
```

### Python FastAPI

```bash
# Clone the repository
git clone git@github.com:3horizons/my-order-service.git
cd my-order-service

# Create a virtual environment
python -m venv .venv
source .venv/bin/activate  # On Windows: .venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Run in development mode (with hot reload)
uvicorn app.main:app --reload --port 8000

# The service starts on http://localhost:8000
# Test the health endpoint:
curl http://localhost:8000/health
# Expected: {"status":"ok"}

# View auto-generated API docs:
# Open http://localhost:8000/docs in your browser
```

### React Frontend

```bash
# Clone the repository
git clone git@github.com:3horizons/my-order-service.git
cd my-order-service

# Install dependencies
npm install

# Run in development mode (with hot reload)
npm run dev

# The application starts on http://localhost:5173
# Open in your browser to see the React app
```

### .NET 8 Web API

```bash
# Clone the repository
git clone git@github.com:3horizons/my-order-service.git
cd my-order-service

# Restore dependencies and run
dotnet restore
dotnet run

# The service starts on http://localhost:5000
# Test the health endpoint:
curl http://localhost:5000/health
# Expected: Healthy

# View Swagger UI:
# Open http://localhost:5000/swagger in your browser
```

### Spring Boot 3

```bash
# Clone the repository
git clone git@github.com:3horizons/my-order-service.git
cd my-order-service

# Build and run with Maven
./mvnw spring-boot:run

# The service starts on http://localhost:8080
# Test the health endpoint:
curl http://localhost:8080/actuator/health
# Expected: {"status":"UP"}

curl http://localhost:8080/api/v1/info
# Expected: {"name":"my-order-service","version":"1.0.0"}
```

### Go Microservice

```bash
# Clone the repository
git clone git@github.com:3horizons/my-order-service.git
cd my-order-service

# Download dependencies
go mod download

# Run the service
go run cmd/server/main.go

# The service starts on http://localhost:8080
# Test the health endpoint:
curl http://localhost:8080/health
# Expected: {"status":"ok"}

curl http://localhost:8080/api/v1/info
# Expected: {"name":"my-order-service","version":"1.0.0"}
```

### Alternative: Run with Docker

For any template, you can also run using Docker:

```bash
# Build the Docker image
docker build -t my-order-service:local .

# Run the container
docker run -p 3000:3000 my-order-service:local

# Test
curl http://localhost:3000/health
```

### Alternative: Run with Dev Container

If you use VS Code or GitHub Codespaces:

1. Open the repository in VS Code.
2. When prompted, click **"Reopen in Container"** (requires the Dev Containers extension).
3. VS Code will build the dev container and set up the complete development environment.
4. Open the integrated terminal and run the service using the language-specific commands above.

---

## Step 6: Verify in the Catalog

Now let us confirm that your new service is properly registered in the portal catalog.

1. Go back to the portal at `https://devhub.3horizons.ai`.
2. Click **Catalog** in the sidebar.
3. In the search bar, type the name of your service (e.g., `my-order-service`).
4. Your service should appear in the results. Click on it to open the detail page.

### Verify the Following

| Check | What to Look For |
|-------|-----------------|
| **Name** | Matches your service name (`my-order-service`) |
| **Kind** | `Component` |
| **Type** | `service` |
| **Owner** | Your team (e.g., `backend-team`) |
| **System** | The parent system you selected (e.g., `e-commerce-platform`) |
| **Lifecycle** | `experimental` (or whatever you chose) |
| **Source** | Link to the GitHub repository |
| **TechDocs** | If the template includes a `mkdocs.yml`, the Docs tab should be available |

> **Note**: If your service does not appear in the catalog immediately, wait 2-3 minutes. The catalog indexes new entities on a scheduled interval. You can also check the scaffolder output for the direct link to the catalog entity.

---

## Step 7: Check the CI Pipeline

Your new repository comes with a pre-configured GitHub Actions CI pipeline that runs automatically on push.

1. Navigate to your GitHub repository (e.g., `github.com/3horizons/my-order-service`).
2. Click the **Actions** tab.
3. You should see a workflow run triggered by the initial commit from the scaffolder.

### CI Pipeline Stages

| Stage | What It Does |
|-------|--------------|
| **Lint** | Runs the language-specific linter (ESLint, Flake8, dotnet format, etc.) to check code style |
| **Test** | Executes unit tests (Jest, pytest, xUnit, JUnit, Go test) |
| **Build** | Compiles the application and builds the Docker image |
| **Push** | Pushes the Docker image to the container registry (if configured) |
| **Security Scan** | Runs Trivy or similar scanner on the Docker image for known vulnerabilities |

4. Click on the workflow run to see detailed logs for each stage.
5. All stages should pass with green checkmarks on the initial scaffold.

> **Troubleshooting CI failures**:
> - **Lint failures**: The scaffolded code should pass linting out of the box. If it fails, check if there are organization-level lint rules that override the template defaults.
> - **Test failures**: Initial tests should pass. Failures may indicate a misconfigured test environment.
> - **Build failures**: Ensure the Dockerfile is compatible with the CI runner's Docker version.
> - **Push failures**: If image push fails, verify that the container registry credentials are configured in the repository's GitHub Actions secrets.

---

## Step 8: What You Have Built

Congratulations! By completing this Golden Path, you now have:

- A **new GitHub repository** with production-ready source code, tests, and configuration.
- A **CI pipeline** that automatically lints, tests, and builds your code on every push.
- A **Docker image** ready for Kubernetes deployment.
- A **dev container** for consistent local development.
- A **catalog entry** in the Three Horizons portal that makes your service discoverable to the entire organization.
- **Health endpoints** (`/health`, `/ready`) that are Kubernetes-compatible for liveness and readiness probes.
- **Structured logging** for observability and debugging.

---

## Next Steps

Now that your first service is up and running, here are the recommended next steps:

### Set Up ArgoCD Deployment

Deploy your service to the AKS cluster using GitOps:

1. Navigate to **Create** in the portal.
2. Select the **GitOps Deployment** template.
3. Link it to your new service's repository.
4. The template generates Kustomize overlays and an ArgoCD Application manifest.
5. ArgoCD will automatically sync your deployments from Git.

See the [GitOps Deployment guide](/docs/guides/DEPLOYMENT_GUIDE.md) for detailed instructions.

### Add API Documentation

If your service exposes an API:

1. Add an OpenAPI specification file (e.g., `openapi.yaml`) to your repository.
2. Update your `catalog-info.yaml` to register the API entity:

```yaml
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: my-order-api
  description: Order management API
spec:
  type: openapi
  lifecycle: experimental
  owner: backend-team
  system: e-commerce-platform
  definition:
    $text: ./openapi.yaml
```

3. Push to `main`. The catalog will index the API and it will appear in the APIs page.

### Explore Copilot Metrics

If your team uses GitHub Copilot:

1. Navigate to **Copilot Metrics** in the sidebar.
2. Review your team's Copilot adoption and acceptance rates.
3. Encourage team members to use Copilot for boilerplate code, tests, and documentation.

### Review GHAS Metrics

After your first CI run:

1. Navigate to **GHAS Metrics** in the sidebar.
2. Check if any code scanning or dependency alerts were raised for your new repository.
3. Address any critical or high severity findings before moving to production.

### Add TechDocs

Make your service documentation available in the portal:

1. Add a `mkdocs.yml` file to the root of your repository:

```yaml
site_name: my-order-service
nav:
  - Home: index.md
  - API Reference: api.md
  - Development: development.md
plugins:
  - techdocs-core
```

2. Create a `docs/` directory with your Markdown documentation files.
3. Add the TechDocs annotation to your `catalog-info.yaml`:

```yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

4. Push to `main`. TechDocs will build and publish your documentation, accessible from the component's Docs tab in the catalog.

### Continue Learning

- Visit **Learning Paths** for structured courses on platform fundamentals, AI development, and cloud-native architecture.
- Use **Lightspeed** to ask questions as you develop -- it understands the Three Horizons platform context.
- Explore other Golden Path templates for event-driven services, data pipelines, and AI agents.

---

## Template Quick Reference

| Template | Port | Health Endpoint | Docs Endpoint | Test Command | Build Command |
|----------|------|----------------|---------------|-------------|---------------|
| Node.js Microservice | 3000 | `GET /health` | -- | `npm test` | `npm run build` |
| Python FastAPI | 8000 | `GET /health` | `GET /docs` (Swagger UI) | `pytest` | `pip install -r requirements.txt` |
| React Frontend | 5173 | -- | -- | `npm test` | `npm run build` |
| .NET 8 Web API | 5000 | `GET /health` | `GET /swagger` | `dotnet test` | `dotnet build` |
| Spring Boot 3 | 8080 | `GET /actuator/health` | -- | `./mvnw test` | `./mvnw package` |
| Go Microservice | 8080 | `GET /health` | -- | `go test ./...` | `go build ./cmd/server` |

---

## Frequently Asked Questions

**Q: Can I modify the scaffolded code?**
A: Absolutely. The Golden Path template gives you a starting point. You own the generated repository and can modify anything -- code, configuration, CI pipeline, Dockerfile, etc.

**Q: What if I need a template that does not exist?**
A: Talk to the platform team about creating a new Golden Path template. You can also use the **Template Authoring** documentation in Learning Paths to create your own.

**Q: How do I delete a scaffolded component?**
A: Delete the GitHub repository, then remove the catalog entry by deleting the Location entity in the catalog or asking an admin to do so.

**Q: Can I scaffold into an existing repository?**
A: The standard templates create new repositories. If you need to add structure to an existing repo, use the repository's existing code as a base and manually apply the patterns from the template.

**Q: My service does not appear in the catalog after scaffolding. What should I do?**
A: Wait 2-3 minutes for the catalog to index. If it still does not appear, check that the `catalog-info.yaml` file exists in the repository's `main` branch and that the catalog location was registered successfully (check the scaffolder output logs).

**Q: How often does the CI pipeline run?**
A: The pipeline triggers on every push to any branch and on pull requests to `main`. You can customize the trigger conditions by editing `.github/workflows/ci.yaml`.

---

*Last updated: 2026-03-01 | Three Horizons Agentic DevOps Platform v4.0.0*
