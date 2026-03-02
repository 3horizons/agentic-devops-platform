---
name: rhdh-catalog-templates
description: "RHDH Software Catalog, Software Templates (Golden Paths), TechDocs, GitHub integration, Scorecards, and Adoption Insights reference. ALWAYS consult these docs before creating templates, configuring catalog, or setting up TechDocs."
---

# RHDH Catalog, Templates & TechDocs Skill

This skill provides the official Red Hat documentation for the RHDH Software Catalog, Software Templates (Golden Paths), TechDocs, GitHub integration, Scorecards, and Adoption Insights. **Always consult these references before creating templates, configuring the catalog, integrating with GitHub, or setting up TechDocs.**

## When to Use This Skill

- Creating or validating Software Templates (Golden Paths)
- Configuring the Software Catalog (locations, rules, processors)
- Setting up TechDocs (generation, publishing, rendering)
- Integrating RHDH with GitHub (org discovery, webhooks, catalog sync)
- Configuring Scorecards for project health visualization
- Reviewing Adoption Insights metrics
- Troubleshooting catalog entity registration or template execution failures
- Understanding Golden Path best practices and developer productivity impact

## Mandatory Rule

> **ALWAYS** read the relevant official documentation below **BEFORE** creating or modifying Software Templates, configuring catalog discovery, setting up TechDocs, or integrating with GitHub. Templates and catalog configuration have strict YAML schemas — validate against official docs to prevent scaffolder errors.

## Official Documentation References

### Software Catalog & Templates

| Document | Path | Covers |
|----------|------|--------|
| **Software Development & Management** | [streamline_software_development_and_management_in_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/streamline_software_development_and_management_in_red_hat_developer_hub.md) | Software Catalog, entity model, catalog processors, entity providers, catalog rules, bulk import |
| **Golden Paths Productivity** | [how-golden-paths-improve-developer-productivity-_-red-hat-developer.md](../../../docs/official-docs/rhdh/markdown/how-golden-paths-improve-developer-productivity-_-red-hat-developer.md) | Golden Path philosophy, paved roads, developer productivity impact, case studies |

### TechDocs

| Document | Path | Covers |
|----------|------|--------|
| **TechDocs** | [techdocs_for_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/techdocs_for_red_hat_developer_hub.md) | TechDocs generation, MkDocs configuration, publishing backends, rendering pipeline |
| **Managing Documentation** | [manage_and_consume_technical_documentation_within_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/manage_and_consume_technical_documentation_within_red_hat_developer_hub.md) | Documentation consumption, TechDocs annotations, doc discovery, search integration |

### Integrations & Analytics

| Document | Path | Covers |
|----------|------|--------|
| **GitHub Integration** | [integrating_red_hat_developer_hub_with_github.md](../../../docs/official-docs/rhdh/markdown/integrating_red_hat_developer_hub_with_github.md) | GitHub App setup, org discovery, catalog sync, webhooks, GitHub Actions integration |
| **Scorecards** | [understand_and_visualize_red_hat_developer_hub_project_health_using_scorecards.md](../../../docs/official-docs/rhdh/markdown/understand_and_visualize_red_hat_developer_hub_project_health_using_scorecards.md) | Scorecard definitions, checks (documentation, CI/CD, security), scoring criteria, visualization |
| **Adoption Insights** | [adoption_insights_in_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/adoption_insights_in_red_hat_developer_hub.md) | Portal usage metrics, template adoption tracking, plugin usage analytics, team activity |

## Quick Reference: Catalog Configuration

### Entity Discovery
```yaml
catalog:
  locations:
    - type: url
      target: https://github.com/org/repo/blob/main/catalog-info.yaml
      rules:
        - allow: [Component, API, System, Domain, Resource, Group, User]
  providers:
    github:
      myOrg:
        organization: '3horizons'
        catalogPath: '/catalog-info.yaml'
        filters:
          branch: 'main'
          repository: '.*'
        schedule:
          frequency: { minutes: 30 }
          timeout: { minutes: 3 }
```

### Entity Model
```
Domain → System → Component → API
                             → Resource
Group → User
Location → Template
```

## Quick Reference: TechDocs

### Annotation for TechDocs
```yaml
# In catalog-info.yaml
metadata:
  annotations:
    backstage.io/techdocs-ref: dir:.
```

### MkDocs Configuration
```yaml
# mkdocs.yml in repo root
site_name: My Service
nav:
  - Home: index.md
  - API: api.md
plugins:
  - techdocs-core
```

## Validation Checklist

- [ ] `catalog-info.yaml` has valid `apiVersion: backstage.io/v1alpha1`
- [ ] Entity `kind` is one of: Component, API, System, Domain, Resource, Group, User, Template, Location
- [ ] `spec.owner` references a valid catalog Group or User entity
- [ ] GitHub App has correct permissions for org discovery
- [ ] TechDocs annotation `backstage.io/techdocs-ref: dir:.` is present
- [ ] `mkdocs.yml` exists in repository root with `techdocs-core` plugin
- [ ] Scorecards checks are configured for relevant quality gates
