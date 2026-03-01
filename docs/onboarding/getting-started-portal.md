# Getting Started with Three Horizons Developer Hub

> Phase 5.3 Onboarding -- Portal Getting Started Guide
> Three Horizons Agentic DevOps Platform | Red Hat Developer Hub 1.8

---

## Welcome

The **Three Horizons Developer Hub** is your organization's Internal Developer Platform (IDP), built on Red Hat Developer Hub (RHDH) 1.8 and powered by the Backstage framework. It serves as a single pane of glass for discovering services, scaffolding new components, viewing API documentation, tracking engineering metrics, and accessing AI-powered development tools.

The portal is organized around the **Three Horizons maturity model**:

- **Horizon 1 -- Foundation**: Core platform services, CI/CD pipelines, infrastructure provisioning, and developer onboarding.
- **Horizon 2 -- Enhancement**: Intelligent automation with GitHub Copilot, AI Foundry integration, MCP servers, and Developer Lightspeed.
- **Horizon 3 -- Innovation**: Autonomous agents, self-healing systems, predictive operations, and multi-agent orchestration.

Whether you are a developer shipping microservices, a team lead monitoring Copilot adoption, or a security engineer reviewing GHAS posture, this portal has a dedicated view for you.

---

## First Login

### Step 1: Navigate to the Portal

Open your browser and go to:

```
https://devhub.3horizons.ai
```

### Step 2: Sign In with GitHub

1. Click the **"Sign in with GitHub"** button on the login page.
2. If this is your first time, GitHub will ask you to **authorize** the Three Horizons GitHub App.
3. Review the requested permissions (read access to your profile and email) and click **Authorize**.

### Step 3: Landing on the Home Page

After successful authentication, you will land on the **Three Horizons Home Page** -- the customized dashboard that provides an at-a-glance view of the entire platform.

> **Note**: If you encounter a "User not found in catalog" message, your GitHub organization membership is being synced. This typically resolves within 30 minutes as the catalog provider runs on a scheduled interval. Contact your platform administrator if the issue persists.

---

## Home Page Tour

The Home page is the command center of the Three Horizons Developer Hub. Here is what you will see from top to bottom:

### Color Bar

At the very top of the page, a thin **4-color horizontal bar** displays the Microsoft brand palette (Red `#F25022`, Green `#7FBA00`, Blue `#00A4EF`, Yellow `#FFB900`). This is a visual identity element consistent across all pages.

### Hero Banner

Below the color bar, the hero section features:

- The **"Agentic DevOps Platform"** label and **"Three Horizons"** title.
- A brief tagline: *"Powered by Red Hat Developer Hub -- Your single pane of glass for services, APIs, documentation, and developer tooling."*
- A **global search bar** where you can search for components, APIs, templates, and documentation across the entire catalog.

### Stat Cards

Four metric cards display live counts pulled from the catalog:

| Card | What It Shows |
|------|---------------|
| **Components** | Total registered software components (services, websites, libraries) |
| **APIs** | Total registered API definitions (OpenAPI, gRPC, GraphQL) |
| **Templates** | Number of available Golden Path software templates |
| **Horizons** | The three maturity horizons (H1, H2, H3) |

### Horizon Cards

Three cards represent the Three Horizons model:

- **Horizon 1 -- Foundation** (Blue): IDP Portal, GitHub, Templates, CI/CD.
- **Horizon 2 -- Enhancement** (Green): Copilot, AI Foundry, MCP, Lightspeed.
- **Horizon 3 -- Innovation** (Yellow): Agents, Self-Healing, Predictive.

Clicking a horizon card navigates you to the relevant catalog filter for that maturity tier.

### Quick Access

Four shortcut tiles for the most common actions:

- **Software Catalog** -- Browse all registered components.
- **API Explorer** -- Discover and explore APIs.
- **Create Component** -- Scaffold a new service from a template.
- **Documentation** -- Access TechDocs and developer guides.

### Featured Templates

Three highlighted Golden Path templates for quick scaffolding:

- **Node.js Microservice** -- Express + TypeScript + Docker + GitHub Actions CI/CD.
- **Python FastAPI** -- FastAPI with async support, OpenAPI docs, and Azure deployment.
- **React Frontend** -- React + TypeScript + Vite + Tailwind CSS.

---

## Navigating the Portal

The sidebar on the left is your primary navigation. Each menu item leads to a distinct section of the portal.

| Menu Item | Path | Description | Who Uses It |
|-----------|------|-------------|-------------|
| **Home** | `/` | Three Horizons dashboard with stats, horizon cards, quick access, and featured templates | Everyone |
| **Catalog** | `/catalog` | Browse all registered entities (components, APIs, systems, resources) with search and filters | Everyone |
| **Create** | `/create` | Scaffold new components from Golden Path templates (6 language-specific templates plus infrastructure and GitOps templates) | Developers, Team leads |
| **APIs** | `/api-docs` | API documentation viewer with OpenAPI, gRPC, and GraphQL spec rendering | Developers, API consumers |
| **My Group** | `/my-group` | Team dashboard showing your group's members, owned components, APIs, and recent deployments | Team members |
| **Copilot Metrics** | `/copilot-metrics` | GitHub Copilot usage analytics: acceptance rates, active users, language breakdown, editor stats | Team leads, Engineering managers |
| **GHAS Metrics** | `/ghas-metrics` | GitHub Advanced Security posture: code scanning alerts, secret scanning, Dependabot vulnerabilities, MTTR trends | Security team, Engineering managers |
| **Learning Paths** | `/learning-paths` | TechDocs-powered documentation: platform fundamentals, AI-powered development, cloud-native architecture, security | Everyone |
| **Notifications** | `/notifications` | Platform alerts: template updates, pipeline results, team changes, catalog events | Everyone |
| **Lightspeed** | `/lightspeed` | AI-powered chat assistant (Developer Lightspeed) for code suggestions, documentation generation, architecture Q&A | Developers |
| **Administration** | `/rbac` | RBAC policy management, user roles, dynamic plugin configuration (Admin, Developer, Viewer roles) | Admins only |
| **Settings** | `/settings` | Personal preferences: profile, integrations, appearance (light/dark theme), starred entities | Everyone |
| **Search** | `/search` | Full-text search across all catalog entities, documentation, and templates | Everyone |

> **Tip**: The sidebar divider separates the primary navigation items (Home through Create) from the auxiliary tools (Lightspeed, Notifications, Administration, Settings). This helps you quickly orient yourself.

---

## Your First 30 Minutes

Follow this guided tour to familiarize yourself with the portal:

### Minute 0-5: Explore the Home Page

1. Take in the stat cards. How many components does your organization have registered? How many APIs?
2. Read through the three Horizon cards to understand the platform maturity model.
3. Try the global search bar -- type the name of a service you know about and see if it appears.

### Minute 5-10: Browse the Catalog

1. Click **Catalog** in the sidebar.
2. Use the kind filter to switch between Components, APIs, Systems, and Resources.
3. Click on any component to see its detail page -- you will find metadata, links, CI/CD status, and documentation.
4. Star a component you work with frequently (click the star icon) so it appears in your Starred Entities.

### Minute 10-15: Check My Group

1. Click **My Group** in the sidebar.
2. Verify that your team name, members, and owned components are displayed correctly.
3. If your team is missing, ask your platform administrator to ensure your GitHub team is synced to the catalog via the `githubOrg` provider.

### Minute 15-20: Try Lightspeed

1. Click **Lightspeed** in the sidebar.
2. In the chat input, type: *"What templates are available for creating a new microservice?"*
3. Lightspeed will respond with information about the available Golden Path templates.
4. Try another question: *"How do I add API documentation to my service?"*

### Minute 20-25: Visit Learning Paths

1. Click **Learning Paths** in the sidebar.
2. Browse the available learning tracks:
   - **Platform Fundamentals** -- catalog, templates, TechDocs, CI/CD.
   - **AI-Powered Development** -- Copilot, MCP servers, AI Foundry.
   - **Cloud-Native Architecture** -- Kubernetes, Azure, IaC, microservices.
   - **Security & Compliance** -- identity, RBAC, secrets, compliance.
3. Open a track that interests you and read through the first section.

### Minute 25-30: Review the Create Page

1. Click **Create** in the sidebar.
2. Browse the available Golden Path templates.
3. Read the description and tags for each template to understand what it provides.
4. Do not create anything yet -- the [First-Day Golden Path Guide](./first-day-golden-path.md) walks you through your first scaffolding experience step by step.

---

## Portal Roles and Permissions

The portal uses Role-Based Access Control (RBAC) with three built-in roles:

| Role | Who Gets It | What They Can Do |
|------|------------|-----------------|
| **Admin** | Platform engineers, DevOps leads | Full access: manage RBAC policies, configure plugins, register locations, manage users |
| **Developer** | All developers | Read catalog, create components from templates, view APIs, use Lightspeed, view metrics |
| **Viewer** | Stakeholders, managers | Read-only access to catalog, APIs, metrics dashboards, and documentation |

Your role is automatically assigned based on your GitHub team membership. Contact your platform administrator if you need a role change.

---

## Getting Help

- **In-portal help**: Use Lightspeed (`/lightspeed`) to ask questions about the platform.
- **Documentation**: Check Learning Paths (`/learning-paths`) for comprehensive guides.
- **Team support**: Reach out to the `#platform-support` channel in your organization's chat.
- **Bug reports**: File an issue in the platform repository using the appropriate issue template.
- **Detailed walkthrough**: See the [Portal Walkthrough](./portal-walkthrough.md) for a page-by-page deep dive.
- **Hands-on tutorial**: See the [First-Day Golden Path Guide](./first-day-golden-path.md) to create your first service.

---

## Quick Reference Card

```
Portal URL:        https://devhub.3horizons.ai
Authentication:    GitHub OAuth (Sign in with GitHub)
Organization:      Three Horizons
Default Theme:     Light (Microsoft palette, Segoe UI font)

Key Shortcuts:
  /              Home dashboard
  /catalog       Software catalog
  /create        Scaffold new component
  /api-docs      API documentation
  /lightspeed    AI chat assistant
  /search        Global search

Support:
  Chat:          #platform-support
  Docs:          /learning-paths
  Issues:        GitHub Issues with RHDH templates
```

---

*Last updated: 2026-03-01 | Three Horizons Agentic DevOps Platform v4.0.0*
