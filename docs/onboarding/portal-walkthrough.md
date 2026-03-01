# Three Horizons Developer Hub -- Page-by-Page Walkthrough

> Phase 5.3 Onboarding -- Detailed Portal Walkthrough
> Three Horizons Agentic DevOps Platform | Red Hat Developer Hub 1.8

---

## Overview

This document provides a comprehensive walkthrough of every page in the Three Horizons Developer Hub portal. For each of the 13 pages, you will find the URL path, what the page displays, key features and interactions, practical tips, and links to related pages.

Use this guide as a reference when you need to understand what a specific page does or how to get the most out of it.

---

## Table of Contents

1. [Home](#1-home)
2. [Catalog](#2-catalog)
3. [Create](#3-create)
4. [APIs](#4-apis)
5. [My Group](#5-my-group)
6. [Copilot Metrics](#6-copilot-metrics)
7. [GHAS Metrics](#7-ghas-metrics)
8. [Learning Paths](#8-learning-paths)
9. [Notifications](#9-notifications)
10. [Lightspeed](#10-lightspeed)
11. [Administration / RBAC](#11-administration--rbac)
12. [User Settings](#12-user-settings)
13. [Search](#13-search)

---

## 1. Home

| Property | Value |
|----------|-------|
| **URL Path** | `/` |
| **Sidebar Label** | Home |
| **Icon** | House icon |
| **Accessible By** | Everyone |

### What It Shows

The Home page is the customized Three Horizons dashboard and the default landing page after login. It provides a high-level overview of the entire platform, organized into distinct visual sections.

### Key Features and Interactions

**Color Bar (Top)**
A fixed 4-pixel horizontal bar at the very top of the viewport renders the Microsoft brand palette in four equal segments: Red (`#F25022`), Green (`#7FBA00`), Blue (`#00A4EF`), Yellow (`#FFB900`). This bar is persistent across all pages.

**Hero Banner**
- Displays the "Agentic DevOps Platform" label above the "Three Horizons" title.
- A descriptive tagline summarizes the portal's purpose.
- Contains a **global search bar** that searches across components, APIs, templates, and documentation. Typing a query and pressing Enter navigates you to the Search results page.

**Stat Cards (4 cards in a row)**
- **Components** (Blue): Count of all registered software components in the catalog.
- **APIs** (Green): Count of all registered API entities.
- **Templates** (Yellow): Count of available Golden Path software templates.
- **Horizons** (Red): Static count of 3, representing the H1/H2/H3 maturity model.

These counts are live values sourced from the Backstage Catalog API.

**Horizon Cards (3 cards in a row)**
- **H1 -- Foundation** (Blue accent): Core platform capabilities including IDP Portal, GitHub integration, Templates, and CI/CD.
- **H2 -- Enhancement** (Green accent): Intelligent automation including Copilot, AI Foundry, MCP, and Lightspeed.
- **H3 -- Innovation** (Yellow accent): Autonomous operations including Agents, Self-Healing, and Predictive systems.

Each card includes descriptive tags. Clicking a card filters the catalog to entities tagged with the corresponding horizon.

**Quick Access (4 shortcut tiles)**
- **Software Catalog** -- Navigates to `/catalog`.
- **API Explorer** -- Navigates to `/api-docs`.
- **Create Component** -- Navigates to `/create`.
- **Documentation** -- Navigates to `/docs`.

**Featured Templates (3 template cards)**
Highlights the most popular Golden Path templates with description and technology tags. Clicking a card navigates to the Create page with that template pre-selected.

**Starred Entities Card**
Displays your personally starred/bookmarked entities for quick access.

**Featured Docs Card**
Shows recently updated or featured documentation entries from TechDocs.

### Tips and Best Practices

- Use the Home page search bar for quick navigation -- it is faster than browsing the sidebar for known entities.
- Star your most frequently accessed components so they appear on the Home page every time you log in.
- Check the stat cards periodically to track catalog growth over time.

### Related Pages

- [Catalog](#2-catalog) -- Full entity browsing
- [Create](#3-create) -- Template scaffolding
- [Search](#13-search) -- Advanced search

---

## 2. Catalog

| Property | Value |
|----------|-------|
| **URL Path** | `/catalog` |
| **Sidebar Label** | Catalog |
| **Icon** | Grid/category icon |
| **Accessible By** | Everyone |

### What It Shows

The Software Catalog is the central registry of all entities in the organization. It displays components, APIs, systems, domains, resources, groups, users, locations, and templates in a searchable, filterable table view.

### Key Features and Interactions

**Search and Filter Bar**
- A text search field at the top lets you filter entities by name, description, or tag.
- **Kind filter**: Switch between entity kinds (Component, API, System, Domain, Resource, Template, User, Group).
- **Type filter**: Further refine by entity type (Service, Website, Library, Pipeline for components; OpenAPI, gRPC, GraphQL for APIs).
- **Lifecycle filter**: Filter by lifecycle stage (experimental, development, staging, production).
- **Owner filter**: Filter by owning team or user.
- **Tag filter**: Filter by custom tags applied to entities.

**Entity Table**
Each row displays:
- **Name**: Clickable link to the entity detail page.
- **Kind**: Entity kind badge (Component, API, etc.).
- **Owner**: The team or user who owns the entity.
- **Type**: The entity subtype.
- **Lifecycle**: Current lifecycle stage with color-coded badge.
- **Description**: Truncated description text.

**Entity Detail Page** (accessed by clicking a row)
- **Overview tab**: Metadata, owner, system, tags, links, and relations.
- **CI/CD tab**: GitHub Actions workflow status and history.
- **API tab**: API definition rendering (for API entities).
- **Docs tab**: TechDocs documentation (if `backstage.io/techdocs-ref` annotation is present).
- **Dependencies tab**: Visualizes entity relationships (dependsOn, consumesApi, providesApi).

**Register Existing Component** (button in top-right)
Allows you to register an existing `catalog-info.yaml` by providing its URL. The catalog will fetch and index the entity.

### Tips and Best Practices

- Use the **Kind** tabs at the top of the catalog to quickly switch between Components, APIs, and other entity types rather than scrolling through all entities.
- Bookmark a specific filter combination by saving the URL -- filter state is encoded in query parameters.
- If an entity is missing from the catalog, verify that the repository contains a `catalog-info.yaml` file on the `main` branch and that the catalog provider has run (every 30 minutes by default).
- Star important entities using the star icon so they appear on your Home page.

### Related Pages

- [Home](#1-home) -- Stat cards reflect catalog counts
- [APIs](#4-apis) -- Dedicated API browsing
- [My Group](#5-my-group) -- Filtered to your team's entities
- [Create](#3-create) -- Add new entities via templates
- [Search](#13-search) -- Full-text search across all entities

---

## 3. Create

| Property | Value |
|----------|-------|
| **URL Path** | `/create` |
| **Sidebar Label** | Create |
| **Icon** | Plus-circle icon |
| **Accessible By** | Developers, Admins |

### What It Shows

The Create page is the scaffolder interface. It lists all registered Golden Path software templates that can be used to generate new components, services, infrastructure, or documentation with a guided form experience.

### Key Features and Interactions

**Template Search**
A search bar at the top filters templates by name, description, or tag.

**Template Cards**
Each template card shows:
- **Icon**: Visual identifier for the template technology.
- **Title**: Template name (e.g., "Node.js Microservice").
- **Description**: What the template creates and what technologies it includes.
- **Tags**: Technology and category tags (e.g., `nodejs`, `typescript`, `docker`).

**Available Templates (Language-Specific Golden Paths)**

| Template | Technologies | What It Creates |
|----------|-------------|-----------------|
| **Node.js Microservice** | Express, TypeScript, Docker, GitHub Actions | Containerized Node.js service with CI/CD |
| **Python FastAPI** | FastAPI, async, OpenAPI, Azure deployment | Python API with auto-generated OpenAPI docs |
| **React Frontend** | React, TypeScript, Vite, Tailwind CSS | Modern frontend application with testing |
| **.NET 8 Web API** | ASP.NET Core, Entity Framework, Azure SQL | Enterprise .NET API with data access |
| **Spring Boot 3** | Java 21, Maven, JPA, Kubernetes configs | Java microservice with K8s-ready configuration |
| **Go Microservice** | Go, Chi router, Docker multi-stage | Lightweight Go service with minimal footprint |

**Additional Templates (Infrastructure and Platform)**
- Basic CI/CD Pipeline
- Security Baseline
- Documentation Site
- Web Application
- API Gateway
- GitOps Deployment
- Event-Driven Microservice
- Data Pipeline
- Batch Job
- Reusable Workflows
- ADO-to-GitHub Migration
- RAG Application
- Copilot Extension
- Foundry Agent
- Multi-Agent System
- MLOps Pipeline
- AI Evaluation Pipeline
- SRE Agent Integration

**Scaffolder Wizard** (after selecting a template)
1. **Form step**: Fill in parameters (service name, description, owner, system, lifecycle, repository name).
2. **Review step**: Confirm all values before creation.
3. **Execution step**: Watch the scaffolder execute actions (Fetch skeleton, Publish to GitHub, Register in catalog).
4. **Completion step**: Links to the new GitHub repository and the catalog entry.

### Tips and Best Practices

- Read the template description carefully before selecting -- each template is tailored to a specific use case.
- Use `kebab-case` for service names (e.g., `my-order-service`) -- this convention is enforced by the templates.
- Set lifecycle to `experimental` for new services that are still being developed.
- After scaffolding, wait 1-2 minutes for the catalog to index the new `catalog-info.yaml` before searching for your new component in the Catalog.
- See the [First-Day Golden Path Guide](./first-day-golden-path.md) for a detailed step-by-step tutorial.

### Related Pages

- [Catalog](#2-catalog) -- Where your new component will appear
- [Home](#1-home) -- Featured templates shortcut
- [Learning Paths](#8-learning-paths) -- Template authoring documentation

---

## 4. APIs

| Property | Value |
|----------|-------|
| **URL Path** | `/api-docs` |
| **Sidebar Label** | APIs |
| **Icon** | Bar chart / extension icon |
| **Accessible By** | Everyone |

### What It Shows

The APIs page provides a dedicated view for browsing and exploring all registered API entities. It renders API definitions in their native format -- OpenAPI specifications are rendered with Swagger UI, gRPC definitions display the proto schema, and GraphQL APIs show the schema explorer.

### Key Features and Interactions

**API Search**
Filter APIs by name, description, owner, or specification type.

**API Cards**
Each API card displays:
- **Title**: The API name.
- **Description**: What the API does.
- **Spec Type badge**: OpenAPI, gRPC, GraphQL, or AsyncAPI.
- **Version badge**: Current API version.

**API Detail Page** (accessed by clicking a card)
- **Overview**: Metadata, owner, system, lifecycle.
- **Definition**: Interactive API definition rendering.
  - OpenAPI: Swagger UI with "Try It Out" functionality (if configured).
  - gRPC: Proto file rendering with service and message definitions.
  - GraphQL: Schema explorer with query builder.
- **Consumers**: List of components that consume this API (`consumesApi` relation).
- **Providers**: The component that provides this API (`providesApi` relation).

### Tips and Best Practices

- Use this page instead of searching through individual repositories when you need to discover what APIs are available.
- The API definitions are sourced from the `spec.definition` field in the API entity's `catalog-info.yaml`. Ensure your API entities reference a valid spec URL or inline definition.
- For OpenAPI specs, host the spec file at a stable URL (e.g., in the repository) and reference it with `$text: https://...` in the catalog-info.yaml.
- APIs with lifecycle `deprecated` will be visually distinguished -- check lifecycle before integrating.

### Related Pages

- [Catalog](#2-catalog) -- APIs are a subset of catalog entities
- [Create](#3-create) -- API Microservice template creates APIs with auto-generated specs
- [Search](#13-search) -- Search across API definitions

---

## 5. My Group

| Property | Value |
|----------|-------|
| **URL Path** | `/my-group` |
| **Sidebar Label** | My Group |
| **Icon** | People/group icon |
| **Accessible By** | Team members |

### What It Shows

My Group is a personalized team dashboard that displays information about your team (GitHub team synced to the catalog), including team members, owned components, owned APIs, and recent deployment activity.

### Key Features and Interactions

**Team Stat Cards (4 cards)**
- **Components**: Number of components owned by your team.
- **Members**: Number of team members.
- **APIs**: Number of APIs owned by your team.
- **Deployments**: Recent deployment count.

**Team Members Section**
Displays avatars, names, and roles of all members in your GitHub team. Clicking a member navigates to their user entity page in the catalog.

**Team Components Table**
Lists all components owned by your team with:
- **Name**: Clickable link to the component detail page.
- **Type**: Component type (Service, API, Website, Library).
- **Lifecycle**: Current lifecycle stage with color-coded badge.
- **Last Deploy**: Timestamp of the most recent deployment.

**Owned APIs**
Lists all API entities where your team is the owner.

### Tips and Best Practices

- Your team assignment is based on your GitHub organization team membership. If you are not seeing your team, verify your membership at `github.com/orgs/<org>/teams`.
- The catalog syncs GitHub org data every 60 minutes. Changes to team membership may take up to an hour to reflect in the portal.
- Use My Group as your daily starting point to check the status of your team's services.

### Related Pages

- [Catalog](#2-catalog) -- Full entity browsing with owner filter
- [Copilot Metrics](#6-copilot-metrics) -- Team-level Copilot usage
- [GHAS Metrics](#7-ghas-metrics) -- Team-level security posture
- [Settings](#12-user-settings) -- Profile and team configuration

---

## 6. Copilot Metrics

| Property | Value |
|----------|-------|
| **URL Path** | `/copilot-metrics` |
| **Sidebar Label** | Copilot Metrics |
| **Icon** | Analytics/chart icon |
| **Accessible By** | Team leads, Engineering managers, Admins |

### What It Shows

The Copilot Metrics page is a custom dashboard that visualizes GitHub Copilot usage data across your organization. It provides insights into developer adoption, code acceptance rates, and productivity trends.

### Key Features and Interactions

**Organization Overview Cards**
- **Total Active Users**: Number of developers actively using Copilot.
- **Acceptance Rate**: Percentage of Copilot suggestions accepted by developers.
- **Total Suggestions**: Number of code suggestions generated in the reporting period.
- **Total Acceptances**: Number of code suggestions accepted.

**Copilot Usage by Language**
A breakdown showing which programming languages see the most Copilot activity (suggestions, acceptances, lines of code). Common languages tracked include TypeScript, Python, Go, Java, C#, and HCL.

**Copilot Usage by Editor**
Shows adoption across IDE/editors (VS Code, JetBrains, Neovim, Visual Studio).

**Seat Utilization**
Displays how many allocated Copilot seats are actively being used versus idle.

**Trends Over Time**
Time-series charts showing acceptance rate trends, active user counts, and suggestion volumes over the selected date range.

### Tips and Best Practices

- Review this dashboard weekly to understand Copilot adoption trends across your organization.
- A healthy acceptance rate is typically 25-35%. Rates significantly below this may indicate developers are not finding the suggestions useful, which could suggest configuration or context issues.
- Use the language breakdown to identify which technology stacks benefit most from Copilot and where additional training might help.
- Data is sourced from the GitHub Copilot API via the `/github-copilot` proxy endpoint and refreshed on each page load.

### Related Pages

- [My Group](#5-my-group) -- Team-specific context
- [GHAS Metrics](#7-ghas-metrics) -- Complementary security metrics
- [Administration / RBAC](#11-administration--rbac) -- Control who can view metrics

---

## 7. GHAS Metrics

| Property | Value |
|----------|-------|
| **URL Path** | `/ghas-metrics` |
| **Sidebar Label** | GHAS Metrics |
| **Icon** | Shield/security icon |
| **Accessible By** | Security team, Engineering managers, Admins |

### What It Shows

The GHAS (GitHub Advanced Security) Metrics page presents a comprehensive security posture dashboard. It aggregates data from GitHub code scanning, secret scanning, and Dependabot across all repositories in the organization.

### Key Features and Interactions

**Security Posture Overview Cards**
- **Code Scanning Alerts**: Total open code scanning alerts (with severity breakdown: critical, high, medium, low).
- **Secret Scanning Alerts**: Total detected secrets across repositories.
- **Dependabot Alerts**: Total open dependency vulnerability alerts.
- **MTTR (Mean Time to Remediate)**: Average time to close security alerts.

**Code Scanning Section**
- Alert distribution by severity (critical, high, medium, low).
- Alert distribution by tool (CodeQL, third-party scanners).
- Top repositories with the most open alerts.
- Trend chart showing alert open/close rates over time.

**Secret Scanning Section**
- Total secrets detected by type (API keys, tokens, passwords, certificates).
- Alert states: open, resolved, revoked, false positive.
- Repositories with the most detected secrets.

**Dependabot Section**
- Vulnerability distribution by severity.
- Vulnerability distribution by ecosystem (npm, pip, NuGet, Maven, Go modules).
- Repositories with the most outdated dependencies.
- Auto-fix PRs generated and merged.

**MTTR Trends**
Time-series chart showing how quickly security alerts are being remediated over weeks and months.

### Tips and Best Practices

- Review this dashboard at least weekly with your security team to identify trends and prioritize remediation.
- Focus on **critical** and **high** severity alerts first -- these represent the greatest risk.
- A rising MTTR trend indicates the team is falling behind on remediation. Consider dedicating sprint capacity to security fixes.
- Data is sourced from the GitHub Security API via the `/github-security` proxy endpoint.
- Complement this dashboard with the Prometheus alerting rules that monitor security-related SLOs.

### Related Pages

- [Copilot Metrics](#6-copilot-metrics) -- Complementary developer productivity metrics
- [Catalog](#2-catalog) -- View security annotations on individual components
- [Administration / RBAC](#11-administration--rbac) -- Control who can view security data

---

## 8. Learning Paths

| Property | Value |
|----------|-------|
| **URL Path** | `/learning-paths` (also accessible via `/docs`) |
| **Sidebar Label** | Learning Paths |
| **Icon** | Graduation cap / school icon |
| **Accessible By** | Everyone |

### What It Shows

Learning Paths is the TechDocs-powered documentation hub. It provides structured educational content organized into learning tracks that cover platform fundamentals, AI tools, cloud-native development, and security practices.

### Key Features and Interactions

**Documentation Search**
A search bar at the top enables full-text search across all published TechDocs.

**Learning Tracks (4 primary tracks)**

| Track | Color | Topics |
|-------|-------|--------|
| **Platform Fundamentals** | Blue | Catalog usage, template authoring, TechDocs publishing, CI/CD integration, portal navigation |
| **AI-Powered Development** | Green | GitHub Copilot best practices, MCP server configuration, Azure AI Foundry usage, Lightspeed chat |
| **Cloud-Native Architecture** | Yellow | Kubernetes patterns, Azure services, Infrastructure as Code (Terraform), microservice design |
| **Security & Compliance** | Red | Workload Identity, RBAC configuration, secrets management (Key Vault + ESO), compliance automation (LGPD, SOC2) |

**TechDocs Viewer**
When you click into a specific document, the TechDocs reader renders MkDocs-generated content with:
- Table of contents sidebar.
- Syntax-highlighted code blocks.
- Navigation between pages within the same documentation set.
- Link to the source file in GitHub for contributions.

**Component Documentation**
TechDocs is also integrated at the component level -- if a component has a `backstage.io/techdocs-ref` annotation in its `catalog-info.yaml`, its documentation will be accessible from the component's detail page (Docs tab).

### Tips and Best Practices

- Start with "Platform Fundamentals" if you are new to the Three Horizons portal.
- TechDocs are generated from MkDocs configuration files (`mkdocs.yml`) in each repository. To contribute to documentation, edit the Markdown files in the `docs/` folder of the relevant repository.
- Rebuild TechDocs after making changes by pushing to `main` -- the TechDocs builder runs automatically.
- Use the search functionality rather than browsing manually -- TechDocs search indexes the full content of all documents.

### Related Pages

- [Home](#1-home) -- Featured docs card
- [Catalog](#2-catalog) -- Component-level docs via TechDocs tab
- [Lightspeed](#10-lightspeed) -- Ask AI about documentation topics
- [Search](#13-search) -- Cross-entity search including docs

---

## 9. Notifications

| Property | Value |
|----------|-------|
| **URL Path** | `/notifications` |
| **Sidebar Label** | Notifications |
| **Icon** | Bell icon |
| **Accessible By** | Everyone |

### What It Shows

The Notifications page displays platform events, alerts, and updates relevant to you. Notifications are generated by catalog changes, pipeline events, template updates, team membership changes, and platform announcements.

### Key Features and Interactions

**Notification List**
Each notification includes:
- **Icon and color**: Indicates the notification type (info, success, warning, error).
- **Title**: Brief summary of the event.
- **Description**: Additional detail and context.
- **Timestamp**: When the event occurred (relative time, e.g., "2 hours ago").

**Notification Types**

| Type | Color | Example |
|------|-------|---------|
| **Info** (Blue) | Blue accent | New template available, team membership changes |
| **Success** (Green) | Green accent | Pipeline succeeded, deployment completed |
| **Warning** (Yellow) | Yellow accent | TechDocs rebuild required, cert expiring soon |
| **Error** (Red) | Red accent | Pipeline failed, sync error, security alert |

**Notification Actions**
- **Mark as read**: Click a notification to mark it as read.
- **Dismiss**: Remove individual notifications from the list.
- **Mark all as read**: Bulk action at the top of the page.

### Tips and Best Practices

- Check Notifications daily to stay informed about changes to your team's components and platform updates.
- Notifications about failed pipelines or security alerts should be acted on promptly.
- The notification system is powered by the Backstage Notifications plugin with a backend that persists notifications in the PostgreSQL database.

### Related Pages

- [Home](#1-home) -- Home page may surface unread notification count
- [Catalog](#2-catalog) -- Related entity changes
- [Settings](#12-user-settings) -- Notification preferences

---

## 10. Lightspeed

| Property | Value |
|----------|-------|
| **URL Path** | `/lightspeed` |
| **Sidebar Label** | Lightspeed |
| **Icon** | Lightning bolt icon |
| **Accessible By** | Developers, Admins |

### What It Shows

Developer Lightspeed is an AI-powered chat assistant integrated directly into the portal. It is powered by Azure AI Foundry (GPT-4o) and provides conversational assistance for development tasks, architecture questions, and platform guidance.

### Key Features and Interactions

**Chat Interface**
- A centered chat panel with an input field at the bottom.
- Type your question or prompt and press Enter (or click Send).
- Responses stream in real-time with Markdown rendering, code blocks, and links.

**Capability Cards (4 cards below the chat)**

| Capability | Description |
|------------|-------------|
| **Code Suggestions** | Get intelligent code completions, refactoring advice, and implementation patterns |
| **Doc Generation** | Auto-generate documentation from your source code or API specifications |
| **Code Review** | AI-powered code review with security analysis and performance suggestions |
| **Architecture Q&A** | Ask questions about system architecture, design patterns, and best practices |

**Example Prompts to Try**
- *"What templates are available for creating a new microservice?"*
- *"How do I add API documentation to my service?"*
- *"Explain the Three Horizons maturity model."*
- *"What are the best practices for Kubernetes health probes?"*
- *"Help me write a GitHub Actions workflow for my Node.js service."*
- *"What is the difference between ArgoCD sync waves and sync hooks?"*

**Conversation History**
Lightspeed maintains conversation context within a session. You can ask follow-up questions that reference earlier parts of the conversation.

### Tips and Best Practices

- Be specific in your questions for better answers. Instead of "How do I deploy?", ask "How do I deploy a Python FastAPI service to the AKS cluster using ArgoCD?".
- Lightspeed has context about the Three Horizons platform, Golden Path templates, and infrastructure patterns. Leverage this by asking platform-specific questions.
- Code snippets in responses can be copied directly to your clipboard.
- Lightspeed does not have access to your private repository code -- it provides general guidance based on platform knowledge.

### Related Pages

- [Learning Paths](#8-learning-paths) -- Structured documentation for deeper learning
- [Create](#3-create) -- Templates referenced in Lightspeed responses
- [APIs](#4-apis) -- API documentation referenced in responses

---

## 11. Administration / RBAC

| Property | Value |
|----------|-------|
| **URL Path** | `/rbac` |
| **Sidebar Label** | Administration |
| **Icon** | Shield icon |
| **Accessible By** | Admins only |

### What It Shows

The Administration page provides role-based access control (RBAC) management for the portal. It allows administrators to view and manage roles, permissions, and policies that govern who can do what within the Developer Hub.

### Key Features and Interactions

**Role-Based Access Control Table**

| Role | Default Members | Permissions |
|------|----------------|-------------|
| **Admin** | Platform engineers (3 users) | Full CRUD access, RBAC management, Kubernetes proxy, plugin configuration, location registration |
| **Developer** | All developers (15+ users) | Read catalog, create components from templates, execute scaffolder, view APIs, use Lightspeed, view metrics |
| **Viewer** | Stakeholders, managers (8+ users) | Read-only access to catalog, APIs, documentation, and metrics dashboards |

**Policy Management**
- View current RBAC policies loaded from the CSV policy file (`/opt/app-root/src/rbac-policy.csv`).
- Policies follow the format: `role, entity-ref, action, permission, effect`.
- Admins can review which users are assigned to which roles.

**Dynamic Plugins Management**
View the status of all dynamic plugins:
- **Enabled plugins**: Home, Search, Catalog, Scaffolder, TechDocs, API Docs, GitHub Actions, Lightspeed, RBAC, Kubernetes, Notifications, User Settings.
- **Disabled plugins**: Segment Analytics (CSP violations), Signals (WebSocket issues), Adoption Insights (crypto context issue).

**User Management**
View all users synced from the GitHub organization, their team memberships, and their assigned roles.

### Tips and Best Practices

- Only designated administrators should access this page. The RBAC plugin enforces this restriction automatically.
- When adding new RBAC policies, test them in a non-production environment first.
- The policy CSV file is mounted as a ConfigMap in the Kubernetes deployment. Changes require a Helm upgrade or ConfigMap update.
- Review the admin user list periodically and follow the principle of least privilege -- only grant Admin role to users who need it.

### Related Pages

- [Settings](#12-user-settings) -- Individual user preferences
- [My Group](#5-my-group) -- Team-level view
- [Catalog](#2-catalog) -- Entity ownership and access

---

## 12. User Settings

| Property | Value |
|----------|-------|
| **URL Path** | `/settings` |
| **Sidebar Label** | Settings |
| **Icon** | Gear/cog icon |
| **Accessible By** | Everyone |

### What It Shows

The User Settings page provides personal configuration options for your portal experience. It covers profile management, external integrations, appearance preferences, and bookmarked entities.

### Key Features and Interactions

**Profile Section**
- Displays your GitHub-synced profile: display name, email, avatar.
- Shows your entity reference in the catalog (e.g., `user:default/johndoe`).
- Links to your GitHub profile.

**Integrations Section**
- View configured integrations (GitHub OAuth tokens, Azure credentials).
- Manage personal access tokens for API interactions.
- Configure external service connections.

**Appearance Section**
- **Theme toggle**: Switch between Light and Dark themes.
  - Light theme: White background, Microsoft palette accents, Segoe UI font.
  - Dark theme: Dark background (`#1B1B1F`), adjusted accent colors, same Segoe UI font.
- Sidebar behavior preferences.

**Starred Entities Section**
- View and manage your bookmarked components, APIs, documentation, and templates.
- Starred entities appear on the Home page in the Starred Entities card.
- Click the unstar icon to remove an entity from your bookmarks.

### Tips and Best Practices

- Verify your profile information is correct -- it is pulled from your GitHub account.
- If your email is not showing, ensure it is set as public on your GitHub profile or added to the GitHub OAuth scopes.
- Use the Dark theme for reduced eye strain during extended coding sessions.
- Regularly review your starred entities and unstar anything no longer relevant.

### Related Pages

- [Home](#1-home) -- Starred entities appear here
- [Administration / RBAC](#11-administration--rbac) -- Role assignment (admin-managed)
- [Catalog](#2-catalog) -- Star/unstar entities from here

---

## 13. Search

| Property | Value |
|----------|-------|
| **URL Path** | `/search` |
| **Sidebar Label** | (Accessed via search bars or `/search` URL) |
| **Icon** | Magnifying glass icon |
| **Accessible By** | Everyone |

### What It Shows

The Search page provides full-text search across the entire portal: catalog entities (components, APIs, systems), TechDocs documentation, templates, and more. It is powered by the PostgreSQL search backend.

### Key Features and Interactions

**Search Input**
A large search bar at the top of the page. Type a query and results appear below.

**Search Filters**
- **Kind**: Filter results by entity kind (Component, API, Template, Documentation, etc.).
- **Lifecycle**: Filter by lifecycle stage.
- **Owner**: Filter by owning team.

**Search Results**
Each result shows:
- **Title**: Entity or document name (clickable link).
- **Kind badge**: Entity kind indicator.
- **Description**: Excerpt with highlighted matching terms.
- **Location**: Where the result comes from (repository, TechDocs source, etc.).

**Search Sources**
The search index includes:
- All catalog entities (components, APIs, systems, groups, users, templates).
- TechDocs documentation content (full-text of all published docs).
- Template descriptions and parameters.

### Tips and Best Practices

- Search is available from multiple locations: the Home page hero banner, the Catalog filter bar, and the dedicated `/search` page. They all feed into the same search backend.
- Use specific terms for more accurate results. For example, search for `auth-service` rather than just `auth`.
- If you are looking for a specific type of result, use the Kind filter to narrow down (e.g., filter to "Template" to find scaffolder templates).
- The search index is rebuilt periodically. Very recently registered entities may take a few minutes to appear in search results.

### Related Pages

- [Home](#1-home) -- Global search bar in hero banner
- [Catalog](#2-catalog) -- Entity-specific filtering
- [Learning Paths](#8-learning-paths) -- Documentation search
- [Create](#3-create) -- Template search

---

## Page Accessibility Summary

| Page | Everyone | Developers | Team Leads | Security | Admins |
|------|----------|-----------|------------|----------|--------|
| Home | Yes | Yes | Yes | Yes | Yes |
| Catalog | Yes | Yes | Yes | Yes | Yes |
| Create | -- | Yes | Yes | -- | Yes |
| APIs | Yes | Yes | Yes | Yes | Yes |
| My Group | Yes | Yes | Yes | Yes | Yes |
| Copilot Metrics | -- | -- | Yes | -- | Yes |
| GHAS Metrics | -- | -- | Yes | Yes | Yes |
| Learning Paths | Yes | Yes | Yes | Yes | Yes |
| Notifications | Yes | Yes | Yes | Yes | Yes |
| Lightspeed | -- | Yes | Yes | -- | Yes |
| Administration | -- | -- | -- | -- | Yes |
| Settings | Yes | Yes | Yes | Yes | Yes |
| Search | Yes | Yes | Yes | Yes | Yes |

---

*Last updated: 2026-03-01 | Three Horizons Agentic DevOps Platform v4.0.0*
