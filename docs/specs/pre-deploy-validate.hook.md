---
name: pre-deploy-validate
description: "Validates all RHDH configuration files before deployment. Runs automatically when @deploy is invoked or when Helm upgrade is attempted."
trigger: userPromptSubmitted
pattern: "deploy|helm upgrade|apply config"
agents:
  - rhdh-architect
---

# Pre-Deploy Validation Hook

## Purpose

This hook ensures all RHDH configuration files are valid before any deployment is executed. It catches YAML errors, missing plugin references, route conflicts, and RBAC inconsistencies before they cause deployment failures.

## When This Hook Fires

- User invokes `@deploy`
- User runs `helm upgrade` or `helm install`
- User says "apply config", "deploy portal", or "update RHDH"

## Validation Sequence

### Step 1: YAML Syntax Validation
```bash
python scripts/validate-plugin-config.py \
  config/dynamic-plugins-config.yaml \
  config/app-config.yaml
```

**Pass criteria:** Exit code 0, no errors (warnings are OK)

### Step 2: Plugin Reference Check
For each plugin in `dynamic-plugins-config.yaml`:
- Verify the OCI artifact exists in ACR: `oras discover myacr.azurecr.io/plugins/{name}:{tag}`
- Verify `importName` matches an export in the plugin package

### Step 3: Route Conflict Check
- No duplicate `path` values across all `dynamicRoutes`
- No orphaned `menuItems` pointing to non-existent routes

### Step 4: RBAC Policy Consistency
- All roles referenced in `rbac-policy.csv` have matching permission definitions
- Admin role exists and has full access
- No policies reference non-existent entity kinds

### Step 5: Branding Asset Check
- Logo SVG files exist at the configured paths
- Theme color values are valid hex codes

## Output

If all checks pass:
```
Pre-deploy validation: PASSED
  [ok] YAML syntax valid
  [ok] All plugin OCI artifacts found
  [ok] No route conflicts
  [ok] RBAC policies consistent
  [ok] Branding assets present

Proceeding with deployment...
```

If any check fails:
```
Pre-deploy validation: FAILED
  [ok] YAML syntax valid
  [FAIL] Plugin 'home-three-horizons' OCI artifact not found in ACR
  [ok] No route conflicts

DEPLOYMENT BLOCKED. Fix the issues above and retry.
```

## Recovery

If validation fails:
1. Read the error messages
2. Fix the specific issue (push missing OCI artifact, fix YAML, etc.)
3. Re-run the deploy command — the hook will fire again automatically
