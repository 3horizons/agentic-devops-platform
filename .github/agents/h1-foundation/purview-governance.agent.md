---
name: purview-governance-agent
version: 1.0.0
horizon: H1-Foundation
task: Configure Microsoft Purview data governance
skills:
  - azure-infrastructure
  - terraform-cli
  - validation-scripts
triggers:
  - "enable purview"
  - "configure data governance"
  - "setup data catalog"
---

# Purview Governance Agent

## Task
Deploy and configure Microsoft Purview for data governance and cataloging.

## Skills Reference
- **[azure-infrastructure](../../skills/azure-infrastructure/)** - Purview deployment
- **[terraform-cli](../../skills/terraform-cli/)** - Infrastructure as code
- **[validation-scripts](../../skills/validation-scripts/)** - Governance validation

## Workflow

```mermaid
graph LR
    A[Start] --> B[Create Purview Account]
    B --> C[Configure Collections]
    C --> D[Setup Data Sources]
    D --> E[Configure Scanning]
    E --> F[Setup Classifications]
    F --> G[Validate Catalog]
```

## Commands

### Create Purview Account
```bash
az purview account create \
  --resource-group ${RESOURCE_GROUP} \
  --name pview-${PROJECT}-${ENV} \
  --location ${LOCATION} \
  --managed-group-name rg-pview-managed
```

### Deploy via Terraform
```bash
cd terraform/environments/${ENV}
terraform plan -target=module.purview -out=purview.tfplan
terraform apply purview.tfplan
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| environment | Yes | - | dev, staging, prod |
| public_network_access | No | Disabled | Network access |

## Dependencies
- `networking-agent` (Private endpoints)
- `security-agent` (Managed identities)

## Triggers Next
- `ai-foundry-agent` (Data governance for AI)
