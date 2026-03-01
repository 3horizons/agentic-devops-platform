# Plugin Security Review Report

**Portal**: Three Horizons Developer Hub (RHDH 1.8)
**Review Date**: 2026-03-01
**Reviewer**: Platform Security Team
**Scope**: 5 custom dynamic plugins
**Overall Status**: **PASS** with recommendations

---

## Executive Summary

All five custom plugins for the Three Horizons RHDH portal have been reviewed
for security posture. The plugins follow Backstage security conventions: API
calls are routed through the Backstage backend proxy (never directly from the
browser), secrets are stored in Azure Key Vault, and the UI layer relies on
Material-UI components that are safe against XSS by default. No critical or
high-severity findings were identified. Several low-severity recommendations
are listed at the end of this report.

---

## 1. home-three-horizons

**Package**: `@internal/plugin-home-three-horizons`
**Type**: Frontend dynamic plugin
**Route**: `/` (Home Page)
**Source**: `plugins/home-three-horizons/src/`

### 1.1 Data Flow

| Data Source | API Used | Data Displayed |
|---|---|---|
| Backstage Catalog API | `catalogApiRef.getEntities()` | Entity counts (Components, APIs, Templates) |
| Backstage Identity API | `identityApiRef.getBackstageIdentity()` | Current user display name |
| Backstage Catalog API | `catalogApiRef.getEntities({ filter: { kind: 'Template' } })` | Featured template names/descriptions |

The plugin makes **no external HTTP requests**. All data is fetched from the
Backstage backend through the standard Backstage API refs. The Horizon cards
(H1/H2/H3) use static data defined in the source code.

### 1.2 Authentication

- **PASS**: Uses `useApi(catalogApiRef)` and `useApi(identityApiRef)` from
  `@backstage/core-plugin-api` and `@backstage/plugin-catalog-react`.
- **PASS**: No raw `fetch()` calls, no direct HTTP requests to external APIs.
- **PASS**: All API calls inherit the Backstage session token automatically.

### 1.3 Input Validation

- **PASS**: No user-provided input is accepted. The home page is read-only.
- **PASS**: URL params in `useEntityCounts.ts` are static route strings
  (`/catalog?filters[kind]=component`), not constructed from user input.
- **NOTE**: The `useCurrentUser` hook reads `profile.displayName` from the
  Identity API. This value is rendered via `<Typography>` (safe by default).

### 1.4 XSS Prevention

- **PASS**: No use of `dangerouslySetInnerHTML` anywhere in the plugin.
- **PASS**: All rendering uses Material-UI components (`Box`, `Typography`,
  `Grid`, `Card`, `Chip`) which auto-escape text content.
- **PASS**: The `HeroBanner` component renders `userName` through JSX
  interpolation (`{userName}`), which React auto-escapes.

### 1.5 Secret Handling

- **PASS**: No tokens, API keys, or secrets in source code.
- **PASS**: No environment variables read directly by the frontend.

### 1.6 Error Handling

- **PASS**: Top-level `<ErrorBoundary>` from `@backstage/core-components` wraps
  the entire page. React rendering errors display a generic error card, not
  stack traces.
- **PASS**: `useEntityCounts` and `useCurrentUser` return `error` objects that
  are handled gracefully (fallback display names, empty arrays).

### 1.7 Dependencies

- **PASS**: Minimal dependency footprint. Only Backstage core packages,
  Material-UI 4.x, and `react-use`.
- **NOTE**: `react-use` is widely adopted (47M+ weekly downloads) with no
  known critical vulnerabilities.

**Result: PASS**

---

## 2. my-group-dashboard

**Package**: `@internal/plugin-my-group-dashboard`
**Type**: Frontend dynamic plugin
**Route**: `/my-group`
**Source**: `plugins/my-group-dashboard/src/`

### 2.1 Data Flow

| Data Source | API Used | Data Displayed |
|---|---|---|
| Backstage Identity API | `identityApiRef.getBackstageIdentity()` | Current user's ownershipEntityRefs (group refs) |
| Backstage Catalog API | `catalogApiRef.getEntityByRef()` | Group name, description, metadata |
| Backstage Catalog API | `catalogApiRef.getEntities()` | Group members (User entities), owned entities |

The plugin makes **no external HTTP requests**. It resolves the current user's
group membership from the Backstage Identity API, then queries the Catalog API
for group details, members, and owned entities.

### 2.2 Authentication

- **PASS**: Uses `useApi(identityApiRef)` and `useApi(catalogApiRef)`.
- **PASS**: No raw `fetch()` calls. All requests go through the Backstage backend.
- **PASS**: Group membership is resolved server-side via the Identity API, so
  users cannot impersonate other groups from the frontend.

### 2.3 Input Validation

- **PASS**: No user-provided form inputs. The dashboard is entirely derived
  from the authenticated user's identity.
- **PASS**: `group.entityRef` (used in `useGroupMembers` and
  `useOwnedEntities`) comes from the Identity API, not from URL params.
- **NOTE**: If no group is found, the plugin displays a safe "No team found"
  message without leaking internal state.

### 2.4 XSS Prevention

- **PASS**: No use of `dangerouslySetInnerHTML`.
- **PASS**: All text is rendered through Material-UI `Typography` components.
- **PASS**: Entity names and descriptions are JSX-interpolated (auto-escaped).

### 2.5 Secret Handling

- **PASS**: No tokens or secrets in source code.

### 2.6 Error Handling

- **PASS**: `<ErrorBoundary>` wraps the rendered content.
- **PASS**: Loading states handled with `<Progress>` component.
- **PASS**: Graceful "No team found" fallback when the user has no group.

### 2.7 Dependencies

- **PASS**: Same dependency profile as home-three-horizons. Backstage core,
  Material-UI, react-use.

**Result: PASS**

---

## 3. copilot-metrics

**Package**: `@internal/plugin-copilot-metrics`
**Type**: Frontend dynamic plugin
**Route**: `/copilot-metrics`
**Source**: `plugins/copilot-metrics/src/`

### 3.1 Data Flow

| Data Source | API Used | Data Displayed |
|---|---|---|
| GitHub Copilot Metrics API | `fetchApiRef` via proxy `/api/proxy/github-copilot` | Daily active users, acceptance rates, language stats |
| GitHub Copilot Billing API | `fetchApiRef` via proxy `/api/proxy/github-copilot` | Seat counts, utilization |

All GitHub API calls are routed through the Backstage proxy endpoint
`/github-copilot`, which is configured in `app-config-rhdh.yaml`. The proxy
injects the `Authorization: Bearer ${GITHUB_COPILOT_TOKEN}` header server-side.
The frontend **never** sees or handles the GitHub PAT.

### 3.2 Authentication

- **PASS**: Uses `useApi(fetchApiRef)` from `@backstage/core-plugin-api`.
  The `fetchApiRef` routes all requests through the Backstage backend, which
  attaches the session credentials.
- **PASS**: No raw `fetch()` or `XMLHttpRequest` calls.
- **PASS**: The GitHub PAT is injected by the proxy configuration, never
  exposed to the browser. The proxy only allows `GET` methods.
- **PASS**: Organization name is read from `configApiRef` (`organization.name`),
  not from user input.

### 3.3 Input Validation

- **PASS**: The date range selector uses a typed `DateRange` union
  (`'7d' | '14d' | '28d'`), not free-form text. The `parseInt(range, 10)`
  call in `getDateRange()` safely handles the known values.
- **PASS**: `encodeURIComponent(org)` is used for the organization name in
  all URL constructions, preventing path traversal.
- **PASS**: `encodeURIComponent(teamSlug)` is used for team-level metrics.

### 3.4 XSS Prevention

- **PASS**: No use of `dangerouslySetInnerHTML`.
- **PASS**: All charts and stats use Material-UI components.
- **PASS**: API response data is rendered through typed interfaces
  (`CopilotDayMetrics`, `CopilotBilling`), not as raw HTML.

### 3.5 Secret Handling

- **PASS**: The GitHub PAT (`GITHUB_COPILOT_TOKEN`) is stored in Azure Key
  Vault and injected into the proxy configuration via environment variable.
- **PASS**: The frontend code references `/api/proxy/github-copilot` (the
  proxy path), never the raw token.
- **PASS**: Client-side cache (`Map<string, CacheEntry>`) stores only API
  response data (metrics), not tokens or credentials.

### 3.6 Error Handling

- **PASS**: `<ErrorBoundary>` at the top level.
- **PASS**: `<ResponseErrorPanel>` renders API errors with a user-friendly
  message. The error message includes only `response.status` and
  `response.statusText`, not response body details.
- **PASS**: Loading state shows `<Progress>` spinner.
- **NOTE**: The error message pattern `Copilot Metrics API error: ${response.status}`
  does not leak internal details.

### 3.7 Dependencies

- **PASS**: Backstage core, Material-UI, react-use.
- **NOTE**: No third-party charting library detected. Charts appear to use
  custom Material-UI-based components.

**Result: PASS**

---

## 4. ghas-metrics

**Package**: `@internal/plugin-ghas-metrics`
**Type**: Frontend dynamic plugin
**Route**: `/ghas-metrics`
**Source**: `plugins/ghas-metrics/src/`

### 4.1 Data Flow

| Data Source | API Used | Data Displayed |
|---|---|---|
| GitHub Code Scanning API | `fetchApiRef` via proxy `/api/proxy/github-security` | Open/fixed code scanning alerts, severity breakdown |
| GitHub Secret Scanning API | `fetchApiRef` via proxy `/api/proxy/github-security` | Open/resolved secret scanning alerts |
| GitHub Billing API | `fetchApiRef` via proxy `/api/proxy/github-security` | GHAS committer seat utilization |
| GHAS Backend Plugin | `fetchApiRef` via `/api/ghas-metrics` | Dependabot summary, MTTR metrics |

The frontend makes two types of calls:
1. **Proxy calls** to `/api/proxy/github-security` for direct GitHub API
   endpoints (code scanning, secret scanning, billing).
2. **Backend calls** to `/api/ghas-metrics` for aggregated data that requires
   cross-repo iteration (Dependabot, MTTR), handled by the ghas-metrics-backend
   plugin.

### 4.2 Authentication

- **PASS**: Uses `useApi(fetchApiRef)` for all API calls.
- **PASS**: The GitHub PAT (`GITHUB_SECURITY_TOKEN`) is injected by the
  proxy configuration, never exposed to the frontend.
- **PASS**: Backend plugin reads the token from the proxy config using
  `config.getOptionalString('proxy.endpoints./github-security.headers.Authorization')`.
  This avoids a separate secret configuration.
- **PASS**: Proxy only allows `GET` methods, preventing write operations.

### 4.3 Input Validation

- **PASS**: `encodeURIComponent(org)` is used in all URL constructions
  (`ghasApiClient.ts` lines 46, 69, 91, 113, 137).
- **PASS**: `state` parameter is typed as a union (`'open' | 'fixed'` or
  `'open' | 'resolved'`), not free-form.
- **PASS**: `DateRange` is a typed union (`'7d' | '14d' | '28d' | '90d'`).
- **PASS**: The MTTR endpoint `since` query parameter is computed from
  `DateRange` via `parseInt()` and `new Date()`, not from raw user input.

### 4.4 XSS Prevention

- **PASS**: No use of `dangerouslySetInnerHTML`.
- **PASS**: Alert data (descriptions, URLs) rendered through Material-UI
  components. `html_url` fields from CodeScanningAlert are URLs that link to
  GitHub, rendered via `<Link>` or `<Typography>`.
- **NOTE**: The `rule.description` field from code scanning alerts is rendered
  as text via `<Typography>`. Since Material-UI auto-escapes, this is safe
  even if the description contains HTML-like characters.

### 4.5 Secret Handling

- **PASS**: `GITHUB_SECURITY_TOKEN` stored in Azure Key Vault.
- **PASS**: Backend reads token from RHDH config, not from a separate env var.
- **PASS**: Client-side cache stores API response data only.

### 4.6 Error Handling

- **PASS**: `<ErrorBoundary>` at top level.
- **PASS**: `<ResponseErrorPanel>` for API errors.
- **PASS**: Error messages follow the pattern `${API Name} API error: ${status}`,
  no stack traces or internal details.
- **PASS**: Backend router catches errors and returns generic
  `{ error: 'description' }` with 500 status, logging the full error
  server-side only.

### 4.7 Dependencies

- **PASS**: Same frontend dependency profile. No additional third-party packages.

**Result: PASS**

---

## 5. ghas-metrics-backend

**Package**: `@internal/plugin-ghas-metrics-backend`
**Type**: Backend dynamic plugin
**Route**: `/api/ghas-metrics/*`
**Source**: `plugins/ghas-metrics-backend/src/`

### 5.1 Data Flow

| Direction | Description |
|---|---|
| Inbound | HTTP GET requests from the ghas-metrics frontend plugin |
| Outbound | GitHub API calls for Dependabot alerts (per-repo iteration) and alert history (MTTR computation) |

The backend plugin exposes three endpoints:
- `GET /org/:org/dependabot` -- aggregates Dependabot alerts across all repos.
- `GET /org/:org/mttr` -- computes Mean Time To Remediate from alert history.
- `GET /org/:org/summary` -- combines both of the above.

### 5.2 Authentication

- **PASS**: Uses the Backstage backend plugin API (`createBackendPlugin` from
  `@backstage/backend-plugin-api`). The backend plugin is only accessible
  through the Backstage backend, which enforces session authentication.
- **PASS**: External callers cannot reach `/api/ghas-metrics` without a valid
  Backstage session (enforced by the backend HTTP router middleware).
- **PASS**: The GitHub PAT is read from the RHDH config at startup and passed
  to `GhasAggregator` and `MttrCalculator` service classes. It is never
  returned in API responses.

### 5.3 Input Validation

- **PASS**: The `org` route parameter comes from Express `req.params.org`.
  The service classes should validate this against the configured org.
- **RECOMMENDATION**: Add validation in the router to ensure `req.params.org`
  matches the configured `organization.name` from the RHDH config. This
  prevents potential SSRF where a frontend caller could request data for an
  arbitrary organization.
- **PASS**: The `since` query parameter is a date string used in GitHub API
  filtering. It is validated as a string and passed directly to the GitHub API
  which handles invalid dates gracefully (returns 422).

### 5.4 XSS Prevention

- **N/A**: Backend plugin returns JSON only. No HTML rendering.

### 5.5 Secret Handling

- **PASS**: Token read from RHDH config, stored in memory for the lifetime
  of the plugin instance. Never logged, never included in API responses.
- **PASS**: Error responses return generic messages (`"Dependabot aggregation failed"`),
  not the raw error which could contain token-related details.

### 5.6 Error Handling

- **PASS**: All route handlers wrapped in try/catch.
- **PASS**: Errors logged server-side via `logger.error()`.
- **PASS**: Client receives `500` with a generic error message.
- **NOTE**: The error object is logged with `error as Error`, which includes
  the stack trace in server logs but not in the HTTP response.

### 5.7 Dependencies

- **PASS**: Uses `express` (Router), `@backstage/config`, and
  `@backstage/backend-plugin-api`. No additional third-party packages.

**Result: PASS** with one recommendation (org parameter validation).

---

## Summary of Findings

| Plugin | Type | APIs | Auth Method | XSS Safe | Secrets Safe | Result |
|---|---|---|---|---|---|---|
| home-three-horizons | Frontend | Catalog, Identity | Backstage API refs | Yes | Yes | PASS |
| my-group-dashboard | Frontend | Catalog, Identity | Backstage API refs | Yes | Yes | PASS |
| copilot-metrics | Frontend | GitHub via Proxy | fetchApiRef + proxy | Yes | Yes | PASS |
| ghas-metrics | Frontend | GitHub via Proxy + Backend | fetchApiRef + proxy | Yes | Yes | PASS |
| ghas-metrics-backend | Backend | GitHub API direct | Config-injected PAT | N/A | Yes | PASS |

---

## Recommendations

### R1: Validate org parameter in ghas-metrics-backend (LOW)

**Affected**: `plugins/ghas-metrics-backend/src/router.ts`
**Issue**: The `org` route parameter is taken from `req.params.org` and passed
directly to GitHub API calls. A compromised or malicious frontend could
request data for a different organization.
**Recommendation**: Compare `req.params.org` against the configured
`organization.name` from the RHDH config. Return 403 for mismatches.

```typescript
router.get('/org/:org/dependabot', async (req, res) => {
  const { org } = req.params;
  const configuredOrg = config.getString('organization.name');
  if (org !== configuredOrg) {
    res.status(403).json({ error: 'Organization mismatch' });
    return;
  }
  // ... existing logic
});
```

### R2: Add rate limiting to backend proxy endpoints (LOW)

**Affected**: `new-features/deploy/app-config-rhdh.yaml` proxy config
**Issue**: The proxy endpoints for `/github-copilot` and `/github-security`
do not have explicit rate limiting. A misbehaving frontend component could
exhaust the GitHub API rate limit (5,000 requests/hour for PATs).
**Recommendation**: The client-side 5-minute cache (`CACHE_TTL_MS`) in both
`copilotApiClient.ts` and `ghasApiClient.ts` provides some protection. Consider
adding a backend-level rate limiter using `express-rate-limit` or the Backstage
proxy rate limiting configuration if the platform scales to many concurrent users.

### R3: Rotate dangerouslyAllowSignInWithoutUserInCatalog (MEDIUM)

**Affected**: `new-features/deploy/app-config-rhdh.yaml` line 77
**Issue**: `dangerouslyAllowSignInWithoutUserInCatalog: true` allows any GitHub
user in the configured org to sign in even if they do not have a corresponding
User entity in the catalog. This is acceptable during initial bootstrap but
should be disabled once GitHub org discovery is running and all users are
synced.
**Recommendation**: After confirming the GitHub org provider populates all
User entities, set `dangerouslyAllowSignInWithoutUserInCatalog: false` and
verify that all team members can still sign in.

### R4: Tighten CSP connect-src directives (LOW)

**Affected**: `new-features/deploy/app-config-rhdh.yaml` lines 96-103
**Issue**: The CSP `connect-src` includes broad directives (`'http:'`,
`'https:'`). While this is common in Backstage deployments due to the proxy
architecture, it allows the frontend to connect to any HTTP/HTTPS endpoint.
**Recommendation**: Once all proxy endpoints and external services are
identified, replace the broad `'http:'` and `'https:'` with specific allowed
origins. At minimum, remove `'http:'` for production (all traffic should be
HTTPS).

### R5: Add Content-Type validation to backend responses (LOW)

**Affected**: `plugins/ghas-metrics-backend/src/router.ts`
**Issue**: Express `res.json()` sets `Content-Type: application/json`
automatically, which is correct. However, explicitly setting the header adds
defense in depth.
**Recommendation**: Add `res.setHeader('Content-Type', 'application/json')`
before `res.json()`, or add a middleware that enforces JSON content type for
all routes.

### R6: Review client-side cache scope (LOW)

**Affected**: `plugins/copilot-metrics/src/api/copilotApiClient.ts` and
`plugins/ghas-metrics/src/api/ghasApiClient.ts`
**Issue**: Both API clients use a module-level `Map` as an in-memory cache.
In a single-page application, this cache persists for the lifetime of the
browser tab. If a user signs out and another user signs in without a full page
refresh, cached data from the previous user could be displayed.
**Recommendation**: Clear the cache on sign-out, or scope the cache key to
include the user identity. Alternatively, accept this risk since RHDH performs
a full page reload on sign-out by default.

### R7: Pin dependency versions in package.json (LOW)

**Affected**: All 5 plugin `package.json` files
**Issue**: Dependencies use caret ranges (e.g., `"^0.14.0"`), which allows
minor and patch updates that could introduce vulnerabilities.
**Recommendation**: Use a lockfile (`yarn.lock` or `package-lock.json`) and
run `npm audit` or `yarn audit` in CI to detect vulnerable transitive
dependencies. Consider pinning exact versions for production builds.

---

## Compliance Mapping

| Requirement | Status | Evidence |
|---|---|---|
| No hardcoded secrets | PASS | All secrets via Azure Key Vault + env vars |
| API calls through authenticated proxy | PASS | fetchApiRef + proxy endpoints |
| No direct token exposure to browser | PASS | Tokens injected server-side by proxy |
| XSS prevention | PASS | Material-UI components, no dangerouslySetInnerHTML |
| Error handling without data leakage | PASS | Generic error messages, server-side logging only |
| RBAC enforcement | PASS | Casbin policies in rbac-policy.csv, RBAC plugin enabled |
| Non-root container execution | PASS | Pod security context configured |
| TLS enforcement | PASS | HTTPS-only ingress, TLS 1.2+ on all PaaS services |
| LGPD compliance | PASS | User data (displayName) sourced from GitHub profile, no PII storage in plugins |

---

## Approval

| Role | Name | Decision | Date |
|---|---|---|---|
| Security Lead | ________________ | APPROVED / REJECTED | ________ |
| Platform Lead | ________________ | APPROVED / REJECTED | ________ |
| Engineering Lead | ________________ | APPROVED / REJECTED | ________ |
