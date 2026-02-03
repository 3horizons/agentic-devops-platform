---
name: validation-scripts
description: Validation scripts for deployment and configuration verification
version: "1.0.0"
license: MIT
tools_required: ["bash"]
---

## When to Use
- Pre-deployment validation
- Post-deployment verification
- Configuration compliance checks
- Naming convention validation

## Prerequisites
- Bash shell
- Required CLI tools (az, kubectl, terraform, gh)
- Appropriate permissions for target resources

## Available Scripts

### validate-cli-prerequisites.sh
```bash
# Validates all required CLI tools are installed
./scripts/validate-cli-prerequisites.sh
```

### validate-config.sh
```bash
# Validates configuration files
./scripts/validate-config.sh --environment <env>
```

### validate-deployment.sh
```bash
# Validates deployment status
./scripts/validate-deployment.sh --environment <env>
```

### validate-naming.sh
```bash
# Validates Azure resource naming conventions
./scripts/validate-naming.sh --resource-group <rg>
```

### validate-agents.sh
```bash
# Validates agent configuration files
./scripts/validate-agents.sh
```

## Best Practices
1. Run validation before any deployment
2. Include validation in CI/CD pipelines
3. Document validation failures clearly
4. Exit with non-zero code on failure
5. Provide remediation steps

## Output Format
1. Script executed
2. Validation results (pass/fail)
3. Details of any failures
4. Remediation recommendations

## Integration with Agents
Used by: @validation, @devops, @sre
