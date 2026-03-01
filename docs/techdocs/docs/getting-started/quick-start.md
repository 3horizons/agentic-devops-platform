# Quick Start

Get up and running with the Three Horizons Developer Hub in five steps. This guide assumes the platform has already been deployed by your Platform Engineering team.

## Prerequisites

- GitHub account with organization membership
- Azure AD credentials (for SSO login)
- Access granted by your team admin in the RHDH RBAC policies

## Step 1: Access the Portal

Navigate to the RHDH portal URL provided by your Platform Engineering team. Sign in using GitHub OAuth or Azure AD SSO. On first login, you will be assigned the **Developer** role by default.

```
https://developer-hub.<your-domain>.com
```

## Step 2: Browse the Software Catalog

From the home page, click **Catalog** in the left navigation. The catalog displays all registered services, APIs, libraries, and infrastructure components. Use filters to narrow results by:

- **Kind**: Component, API, Resource, System, Group
- **Type**: Service, library, documentation, website
- **Owner**: Filter by team ownership
- **Lifecycle**: Production, experimental, deprecated
- **Tags**: Search by technology tags (e.g., `nodejs`, `python`, `terraform`)

## Step 3: Create a Component from a Golden Path

1. Click **Create** in the left navigation to open the template catalog
2. Browse available Golden Path templates organized by horizon (H1, H2, H3)
3. Select a template (e.g., **Web Application** or **API Microservice**)
4. Fill in the required parameters: component name, owner, repository details
5. Click **Create** to scaffold the project

The template will automatically:

- Create a GitHub repository with the scaffolded code
- Register the component in the RHDH catalog
- Configure CI/CD pipelines via GitHub Actions
- Set up ArgoCD deployment manifests

## Step 4: Explore APIs

Navigate to **APIs** in the left navigation to browse registered API definitions. Each API entry includes:

- OpenAPI specification rendered as interactive documentation
- Ownership and lifecycle information
- Consuming and providing components
- Links to source repository and CI/CD status

## Step 5: Use Developer Lightspeed

Click the **Lightspeed** icon in the bottom-right corner of the portal to open the AI chat assistant. Lightspeed is powered by Azure OpenAI and can help you:

- Answer questions about platform services and configurations
- Explain error messages and suggest fixes
- Guide you through template selection and usage
- Provide code snippets and best practices

```
Example: "How do I configure a readiness probe for my service?"
```

## What's Next

- Read the [Onboarding Guide](onboarding.md) for full team setup instructions
- Explore [CI/CD Pipelines](../development/cicd.md) for deployment workflows
- Review [Security Baseline](../security/security-baseline.md) for compliance requirements
