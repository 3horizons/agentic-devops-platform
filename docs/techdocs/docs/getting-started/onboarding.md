# Onboarding Guide

This guide walks through the complete onboarding process for new teams joining the Three Horizons Developer Hub. Follow these steps to get your team set up and productive.

## Prerequisites

Before starting the onboarding process, ensure your team has:

- **GitHub Organization membership** -- Request access from your org admin
- **Azure AD accounts** -- Provisioned through your IT department
- **Azure subscription access** -- At minimum, Reader role for your resource group
- **CLI tools installed** -- Run the prerequisite validation script:

```bash
./scripts/validate-prerequisites.sh
```

Required tool versions:

| Tool | Minimum Version |
|------|----------------|
| Azure CLI | >= 2.50 |
| Terraform | >= 1.5.0 |
| kubectl | >= 1.28 |
| Helm | >= 3.12 |
| GitHub CLI | >= 2.30 |

## Step 1: GitHub Access and Permissions

1. Accept the GitHub organization invitation
2. Ensure you are added to the appropriate team (e.g., `@platform-team`, `@infra-team`)
3. Configure your GitHub CLI authentication:

```bash
gh auth login --web
gh auth status
```

4. Set up SSH keys or personal access tokens as needed for repository access

## Step 2: Portal Login and Role Assignment

1. Navigate to the RHDH portal URL
2. Sign in using GitHub OAuth (recommended) or Azure AD SSO
3. Your role is assigned by the Platform Engineering team via CSV-based RBAC policies:
   - **Admin** -- Full platform management capabilities
   - **Developer** -- Create components, browse catalog, use templates
   - **Viewer** -- Read-only access to catalog and documentation

To request a role change, contact the Platform Engineering team or open an issue using the `role-request` template.

## Step 3: Explore the Developer Hub

Once logged in, familiarize yourself with the portal sections:

- **Home** -- Quick actions, recent components, platform status widgets
- **Catalog** -- Browse all registered services, APIs, and resources
- **Create** -- Launch Golden Path templates to scaffold new projects
- **APIs** -- Explore API documentation and dependencies
- **Docs** -- Access TechDocs for platform and component documentation
- **Lightspeed** -- AI chat assistant for platform guidance

## Step 4: Create Your First Component

Use the [Quick Start](quick-start.md) guide to create your first component from a Golden Path template. Recommended starting templates:

- **H1 -- Web Application**: Basic web app with CI/CD and monitoring
- **H1 -- New Microservice**: Containerized microservice with health checks
- **H2 -- API Microservice**: Full REST API with OpenAPI spec and database

## Step 5: Set Up Local Development

Clone your newly created repository and configure the local development environment:

```bash
gh repo clone <org>/<your-component>
cd <your-component>
# Follow the README.md in the scaffolded repository
```

## Team Admin Responsibilities

If you are onboarding a team, you must also:

1. Register your team as a Group entity in the RHDH catalog
2. Update the RBAC CSV policies to assign roles to team members
3. Configure ArgoCD project permissions for your team namespaces
4. Set up GitHub team permissions for repository access

## Support

For onboarding issues, reach out via:

- **Slack**: `#platform-support`
- **GitHub Issues**: Use the `onboarding-help` issue template
- **Copilot Agent**: `@onboarding Set up new team <team-name>`
