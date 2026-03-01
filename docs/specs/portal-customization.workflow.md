---
name: portal-customization
description: "End-to-end workflow for customizing the RHDH portal to match the Three Horizons reference template. Orchestrates @rhdh-architect for design, @platform for implementation, @deploy for deployment, and all supporting agents."
trigger: manual
agents:
  - rhdh-architect
  - platform
  - template-engineer
  - devops
  - deploy
  - security
  - docs
  - test
  - reviewer
  - github-integration
  - sre
  - onboarding
---

# Portal Customization Workflow

## Overview

This workflow orchestrates the complete customization of RHDH to match the Three Horizons Developer Hub reference template. It follows a deterministic 6-phase sequence with validation gates between phases.

## Execution Mode

Three modes are available (ask user before starting):

| Mode | Description | When to Use |
|------|-------------|-------------|
| **Full Auto** | Execute all phases sequentially, pause only at validation gates | Experienced users, staging environments |
| **Phase-by-Phase** | Execute one phase, wait for user approval, then proceed | First deployment, production environments |
| **Design Only** | Execute Phase 0 only, output all specs and configs | Planning, architecture review |

## Workflow Sequence

### Gate 0: Prerequisites Check

Before starting, verify:
- [ ] RHDH instance is deployed and accessible
- [ ] `app-config.yaml` is editable (Git repo or ConfigMap)
- [ ] `dynamic-plugins-config.yaml` is editable
- [ ] Container registry (ACR) is accessible for OCI artifacts
- [ ] GitHub App credentials are available
- [ ] User has admin access to RHDH

**If any prerequisite fails** → Stop and instruct user on what's missing.

---

### Phase 0: Architecture Design
**Agent:** `@rhdh-architect`
**Input:** Three Horizons Portal HTML reference + RHDH Official Documentation Guide
**Duration:** ~2 hours

**Steps:**
1. Read `skills/rhdh-plugin-design/references/portal-gap-analysis.md`
2. For each of the 13 pages, apply the Decision Framework:
   - Config-only → generate YAML snippet
   - Existing plugin → generate wiring config
   - Custom plugin → generate component spec + ADR
3. Produce deliverables:
   - `docs/adr/ADR-001-home-page-plugin.md`
   - `docs/adr/ADR-002-my-group-plugin.md`
   - `docs/specs/home-page-components.md`
   - `docs/specs/my-group-components.md`
   - `config/app-config-branding.yaml`
   - `config/dynamic-plugins-config.yaml`
4. Validate all YAML using `scripts/validate-plugin-config.py`

**Validation Gate 0:**
- [ ] All ADRs written
- [ ] All component specs complete
- [ ] YAML validation passes
- [ ] User approves architecture

**On approval** → Proceed to Phase 1
**On rejection** → Revise and re-validate

---

### Phase 1: Branding & Navigation
**Agent:** `@platform`
**Input:** Branding config from Phase 0
**Duration:** ~4 hours

**Steps:**
1. Apply `config/app-config-branding.yaml` to the RHDH instance:
   - Microsoft logo SVGs uploaded to branding path
   - Theme colors (#0078D4, #1B1B1F sidebar)
   - Segoe UI typography
2. Apply `config/dynamic-plugins-config.yaml` sidebar navigation:
   - 11 menu items in correct order
   - Icons mapped to each page
3. Verify branding renders correctly on all pages

**Validation Gate 1:**
- [ ] Logo displays in sidebar header
- [ ] Sidebar background is #1B1B1F
- [ ] All 11 navigation items visible
- [ ] Correct icons for each item
- [ ] Theme colors applied (blue primary, indicator)

**Handoff:** → `@security` (verify RBAC visibility rules for admin menu)

---

### Phase 2: Native Pages Configuration
**Agents:** `@platform` + `@template-engineer` + `@docs` + `@github-integration`
**Duration:** ~2 days (can run in parallel)

**Parallel tracks:**

**Track A — @platform:**
1. Configure Catalog page (search, filters, entity table)
2. Enable API Docs dynamic plugin
3. Enable Lightspeed dynamic plugin + Azure OpenAI config
4. Enable Notifications dynamic plugin
5. Enable RBAC Web UI plugin
6. Configure User Settings page

**Track B — @template-engineer:**
1. Create 6 Golden Path templates:
   - `golden-paths/h1/nodejs-microservice/template.yaml`
   - `golden-paths/h1/python-fastapi/template.yaml`
   - `golden-paths/h1/react-frontend/template.yaml`
   - `golden-paths/h1/dotnet-webapi/template.yaml`
   - `golden-paths/h1/springboot-service/template.yaml`
   - `golden-paths/h1/go-microservice/template.yaml`
2. Each with skeleton, devcontainer.json, GitHub Actions CI/CD

**Track C — @docs:**
1. Create TechDocs content for 6 documentation categories
2. Configure Learning Paths page (TechDocs route or custom)
3. Set up mkdocs.yml in each service repo

**Track D — @github-integration:**
1. Configure GitHub App for org discovery
2. Set up catalog provider for repository import
3. Populate catalog with discovered entities

**Validation Gate 2:**
- [ ] Catalog shows entities from GitHub discovery
- [ ] 6 templates visible in Create page
- [ ] API Docs page renders API cards
- [ ] Lightspeed chat is functional
- [ ] Notifications page loads
- [ ] RBAC admin page accessible
- [ ] TechDocs pages render

---

### Phase 3: Custom Plugin Development
**Agents:** `@rhdh-architect` (specs) → `@platform` (code) → `@test` + `@reviewer`
**Duration:** ~2.5 weeks (4 custom plugins)

**Step 3.1 — Home Page Plugin (Frontend only):**
1. `@rhdh-architect` provides component specs from Phase 0
2. `@platform` scaffolds plugin: `./scripts/scaffold-plugin.sh home-three-horizons ./plugins`
3. `@platform` implements 6 components:
   - HeroBanner, StatCards, HorizonCards, QuickAccess, FeaturedTemplates, ColorBar
4. `@test` writes unit tests (TestApiProvider + mock catalog data)
5. `@reviewer` reviews code quality
6. Build: `npx @janus-idp/cli package export-dynamic-plugin`
7. Push to ACR: `oras push myacr.azurecr.io/plugins/home-three-horizons:1.0.0`

**Step 3.2 — My Group Plugin (Frontend only):**
1. Same flow as 3.1 for My Group Dashboard
2. Components: GroupHeader, GroupStats, MemberList, OwnedComponents
3. Test, review, build, push

**Step 3.3 — Copilot Metrics Plugin (Full-Stack: Frontend + Backend proxy):**
1. `@rhdh-architect` provides full-stack architecture specs
2. `@platform` scaffolds: `./scripts/scaffold-plugin.sh copilot-metrics ./plugins`
3. `@platform` implements backend proxy (Express routes to GitHub Copilot Metrics API):
   - GET /api/copilot-metrics/org → GitHub GET /orgs/{org}/copilot/metrics
   - GET /api/copilot-metrics/team/:slug → GitHub team metrics
   - GET /api/copilot-metrics/billing → GitHub Copilot billing
   - Auth: GITHUB_COPILOT_METRICS_PAT from Key Vault
4. `@platform` implements 8 frontend components:
   - ActiveUsersCard, AcceptanceRateChart, LanguageBreakdown, IdeUsageChart,
     TeamComparison, ChatUsageStats, TrendSparklines, SeatUtilization
5. `@test` writes unit + integration tests (mock GitHub API responses)
6. `@reviewer` reviews (focus: rate limiting, error handling, PAT security)
7. Build + push both frontend and backend OCI artifacts

**Step 3.4 — GHAS Metrics Plugin (Full-Stack: Frontend + Backend proxy + Aggregation):**
1. `@rhdh-architect` provides full-stack architecture specs
2. `@platform` scaffolds: `./scripts/scaffold-plugin.sh ghas-metrics ./plugins`
3. `@platform` implements backend proxy + aggregation layer:
   - GET /api/ghas-metrics/code-scanning → GitHub code scanning alerts (org-level)
   - GET /api/ghas-metrics/secret-scanning → GitHub secret scanning alerts (org-level)
   - GET /api/ghas-metrics/dependabot → Aggregated across all repos (repo-level API)
   - GET /api/ghas-metrics/billing → GHAS committers + per-repo breakdown
   - GET /api/ghas-metrics/mttr → Computed Mean Time To Remediate
   - Auth: GITHUB_GHAS_METRICS_PAT (scopes: security_events, repo, admin:org)
   - 5-min cache layer to avoid rate limits during Dependabot aggregation
4. `@platform` implements 9 frontend components:
   - CodeScanningCard, SecretScanningCard, DependabotAlertsCard, GhasCommittersCard,
     SecurityTrendChart, SeverityBreakdown, MttrMetrics, PushProtectionCard, RepoCoverageTable
5. `@test` writes unit + integration tests (mock GitHub API responses, test aggregation logic)
6. `@reviewer` reviews (focus: pagination handling, caching, PAT scope security)
7. Build + push both frontend and backend OCI artifacts

**Step 3.5 — Learning Paths Plugin (optional):**
1. If TechDocs route is insufficient, build card-grid plugin
2. Otherwise skip (TechDocs route from Phase 2 is sufficient)

**Validation Gate 3:**
- [ ] All tests pass (>80% coverage) for all 4 custom plugins
- [ ] Code review approved for all plugins
- [ ] OCI artifacts pushed to ACR (6 artifacts: 2 frontend-only + 2 full-stack pairs)
- [ ] All plugins load in dev environment
- [ ] Copilot Metrics dashboard shows live data from GitHub API
- [ ] GHAS Metrics dashboard aggregates Dependabot alerts correctly

---

### Phase 4: CI/CD & Deployment
**Agents:** `@devops` (pipeline) → `@deploy` (orchestration)
**Duration:** ~2 days

**Step 4.1 — @devops: Plugin Build Pipeline:**
1. Create GitHub Actions workflow: `.github/workflows/build-plugins.yaml`
2. Triggers on push to `plugins/**`
3. Builds, tests, exports dynamic plugin, pushes OCI artifact

**Step 4.2 — @deploy: Portal Deployment:**
1. Update `dynamic-plugins-config.yaml` with custom plugin references
2. Run `helm upgrade --install backstage backstage/backstage --values values-aks.yaml`
3. Verify all pods running
4. Validate all 13 pages accessible

**Validation Gate 4:**
- [ ] Helm upgrade successful
- [ ] All pods in Running state
- [ ] Custom Home Page loads with live data from Catalog API
- [ ] My Group shows current user's team
- [ ] Copilot Metrics dashboard renders GitHub API data
- [ ] GHAS Metrics dashboard renders security alerts and MTTR
- [ ] All 13-item navigation works end-to-end

---

### Phase 5: Polish & Verification
**Agents:** `@security` + `@sre` + `@onboarding`
**Duration:** ~2 days

**Parallel tracks:**

**@security:**
- Final RBAC policy review
- Auth provider configuration verification
- Custom plugin security scan

**@sre:**
- Prometheus metrics export configured
- Grafana dashboard for portal health
- SLOs defined: 99.9% uptime, <2s page load

**@onboarding:**
- Getting Started guide for new portal
- Page-by-page walkthrough documentation
- First-day Golden Path template execution guide

**Final Validation:**
- [ ] Security review passed
- [ ] Monitoring dashboards active
- [ ] Onboarding materials published
- [ ] All 13 pages match reference template within acceptable tolerance
- [ ] Performance meets SLOs

---

## Rollback Procedure

If deployment fails at any gate:

1. `helm rollback backstage 0 --namespace rhdh` — Revert to previous Helm release
2. Remove custom plugin references from `dynamic-plugins-config.yaml`
3. Redeploy with `helm upgrade`
4. Investigate failure with `@sre` and `@devops`
5. Fix and re-enter workflow at the failed phase

## Success Criteria

The workflow is complete when:
- All 13 pages of the Three Horizons Portal are functional in RHDH
- Custom Home Page and My Group Dashboard display live data
- Copilot Metrics dashboard displays GitHub Copilot usage metrics (active users, acceptance rates, seat utilization)
- GHAS Metrics dashboard displays security posture (code scanning, secret scanning, Dependabot, MTTR)
- 6 Golden Path templates are available in the Create page
- Microsoft branding is applied consistently
- RBAC roles are enforced
- Monitoring is active
- Onboarding documentation is published
