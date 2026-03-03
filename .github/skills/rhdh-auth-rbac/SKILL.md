---
name: rhdh-auth-rbac
description: "RHDH authentication and authorization reference — covers GitHub OAuth, Microsoft Entra ID SSO, RBAC policies, permission framework, and role definitions. ALWAYS consult these docs before configuring auth providers or RBAC policies."
---

# RHDH Authentication & Authorization (RBAC) Skill

This skill provides the official Red Hat documentation for RHDH authentication and authorization. **Always consult these references before configuring authentication providers, RBAC policies, permission rules, or role definitions.**

## When to Use This Skill

- Configuring authentication providers (GitHub OAuth, Microsoft Entra ID SSO, OIDC, SAML)
- Setting up RBAC policies (CSV-based permission policies)
- Defining roles (Admin, Developer, Team Lead, Viewer)
- Reviewing or auditing permission policies
- Troubleshooting login failures or permission denied errors
- Integrating with identity providers (Keycloak, Microsoft Entra ID, GitHub)
- Configuring guest access or anonymous access
- Setting up session management and token handling

## Mandatory Rule

> **ALWAYS** read the relevant official documentation below **BEFORE** configuring authentication providers, modifying RBAC policies, or troubleshooting auth issues. Incorrect auth configuration can lock users out of the portal or expose unauthorized access. The official docs contain provider-specific configuration syntax, required scopes, and security best practices.

## Official Documentation References

| Document | Path | Covers |
|----------|------|--------|
| **Authentication** | [authentication_in_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/authentication_in_red_hat_developer_hub.md) | Auth providers (GitHub, Microsoft, Google, OIDC, SAML), sign-in resolvers, session management, guest access, provider configuration |
| **Authorization (RBAC)** | [authorization_in_red_hat_developer_hub.md](../../../docs/official-docs/rhdh/markdown/authorization_in_red_hat_developer_hub.md) | Permission framework, RBAC policies CSV format, role definitions, conditional policies, permission rules, plugin-level permissions |

## Quick Reference: Authentication

### GitHub OAuth Configuration
```yaml
auth:
  environment: production
  providers:
    github:
      production:
        clientId: ${GITHUB_CLIENT_ID}
        clientSecret: ${GITHUB_CLIENT_SECRET}
        signIn:
          resolvers:
            - resolver: usernameMatchingUserEntityName
```

### Microsoft Entra ID / Microsoft SSO
```yaml
auth:
  providers:
    microsoft:
      production:
        clientId: ${AZURE_CLIENT_ID}
        clientSecret: ${AZURE_CLIENT_SECRET}
        tenantId: ${AZURE_TENANT_ID}
        signIn:
          resolvers:
            - resolver: emailMatchingUserEntityProfileEmail
```

### Sign-In Page Configuration
```yaml
signInPage: github    # or 'microsoft', 'oidc', 'guest'
```

## Quick Reference: RBAC

### RBAC Policy CSV Format
```csv
# role, entity-reference
g, user:default/admin-user, role:default/admin
g, group:default/platform-team, role:default/admin
g, group:default/developers, role:default/developer

# policy, entity-reference, permission, action, effect
p, role:default/admin, catalog-entity, read, allow
p, role:default/admin, catalog-entity, create, allow
p, role:default/admin, catalog-entity, delete, allow
p, role:default/developer, catalog-entity, read, allow
p, role:default/developer, catalog.entity.create, create, allow
p, role:default/viewer, catalog-entity, read, allow
```

### Key Permission Resources
| Resource | Actions | Notes |
|----------|---------|-------|
| `catalog-entity` | read, create, update, delete | Software Catalog entities |
| `catalog.entity.create` | create | Entity registration |
| `scaffolder-template` | read | Template visibility |
| `scaffolder-action` | use | Template execution |
| `policy-entity` | read, create, update, delete | RBAC policy management |
| `lightspeed.chat` | use | AI Lightspeed access |
| `mcp.tools.execute` | use | MCP tool execution |

### RBAC Configuration in app-config.yaml
```yaml
permission:
  enabled: true
  rbac:
    admin:
      users:
        - name: user:default/admin
      superAdminRole: true
    policies-csv-file: /opt/app-root/src/rbac-policy.csv
    policyFileReload: true
```

## Security Checklist

- [ ] Guest access disabled in production (`auth.providers.guest` removed or `dangerouslyAllowOutsideDevelopment: false`)
- [ ] RBAC enabled (`permission.enabled: true`)
- [ ] Admin role restricted to platform team only
- [ ] All sensitive auth values stored in Kubernetes Secrets (not ConfigMaps)
- [ ] GitHub OAuth scopes are minimal (`read:user`, `read:org`)
- [ ] Session tokens have appropriate expiry
- [ ] Audit logs enabled to track permission changes
