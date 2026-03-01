# Golden Path Templates

Golden Paths are pre-built RHDH Software Templates that scaffold new projects with production-ready defaults. They provide a standardized starting point that includes CI/CD pipelines, monitoring, security configurations, and deployment manifests, so developers can focus on writing business logic instead of boilerplate.

## What Is a Golden Path?

A Golden Path is an opinionated, well-supported way to build and deploy a specific type of workload. Each template:

- Scaffolds a complete repository with source code, Dockerfile, Helm chart, and GitHub Actions workflows
- Registers the new component in the RHDH Software Catalog
- Configures ArgoCD for GitOps-based deployment
- Sets up Prometheus ServiceMonitor and health check endpoints
- Applies security defaults (non-root container, resource limits, network policies)

## Available Templates by Horizon

### H1 -- Foundation (6 templates)

| Template | Description |
|----------|-------------|
| **basic-cicd** | Simple CI/CD pipeline with linting, testing, and container build |
| **security-baseline** | Project with pre-configured security scanning (Trivy, GHAS) |
| **documentation-site** | MkDocs-based documentation site with TechDocs integration |
| **web-application** | Frontend web app with Nginx serving and CDN configuration |
| **new-microservice** | Containerized microservice with health checks and metrics |
| **infrastructure-provisioning** | Terraform module with testing and CI validation |

### H2 -- Enhancement (9 templates)

| Template | Description |
|----------|-------------|
| **microservice** | Full microservice with database, caching, and observability |
| **api-microservice** | REST API with OpenAPI spec, validation, and documentation |
| **event-driven-microservice** | Event-based service with message broker integration |
| **data-pipeline** | ETL/ELT pipeline with scheduling and monitoring |
| **batch-job** | Kubernetes CronJob with retry logic and alerting |
| **api-gateway** | API gateway with rate limiting and authentication |
| **gitops-deployment** | ArgoCD application configuration for existing services |
| **ado-to-github-migration** | 6-phase Azure DevOps to GitHub migration toolkit |
| **reusable-workflows** | Shared GitHub Actions workflow library |

### H3 -- Innovation (8 templates)

| Template | Description |
|----------|-------------|
| **foundry-agent** | Azure AI Foundry agent with tool calling and RAG |
| **sre-agent-integration** | SRE automation agent with runbook execution |
| **mlops-pipeline** | ML training and deployment pipeline with model registry |
| **multi-agent-system** | Multi-agent orchestration with handoff patterns |
| **copilot-extension** | GitHub Copilot extension with custom skills |
| **rag-application** | Retrieval-Augmented Generation app with AI Search |
| **ai-evaluation-pipeline** | LLM output evaluation with quality metrics |
| **engineering-intelligence-dashboard** | DORA and Copilot metrics dashboard |

## How to Use a Golden Path

1. Open the RHDH portal and navigate to **Create**
2. Browse or search for a template by name or technology
3. Click the template to view its description and required parameters
4. Fill in the form:
   - **Component Name**: kebab-case identifier (e.g., `order-service`)
   - **Owner**: Team that owns the component (e.g., `platform-team`)
   - **Repository**: GitHub organization and repository name
   - **Description**: Brief description of the component
   - **Technology-specific options**: Language, framework, database, etc.
5. Click **Create** and wait for the scaffolding to complete
6. Follow the generated repository README for local development setup

## Creating Custom Templates

To create a new Golden Path template, use the `@template-engineer` Copilot agent:

```
@template-engineer Create a template for a GraphQL API using Node.js with PostgreSQL
```

Templates follow the Backstage Software Template format with `template.yaml`, a `skeleton/` directory, and parameterized placeholders.
