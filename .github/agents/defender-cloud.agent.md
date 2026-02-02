---
name: defender-cloud-agent
version: 1.0.0
horizon: H1-Foundation
task: Configure Microsoft Defender for Cloud
skills:
  - azure-infrastructure
  - terraform-cli
  - validation-scripts
triggers:
  - "enable defender"
  - "configure security center"
  - "setup cloud security"
---

# Defender for Cloud Agent

## Task
Enable and configure Microsoft Defender for Cloud for security posture management.

## Skills Reference
- **[azure-infrastructure](../../skills/azure-infrastructure/)** - Defender configuration
- **[terraform-cli](../../skills/terraform-cli/)** - Infrastructure as code
- **[validation-scripts](../../skills/validation-scripts/)** - Security validation

## Workflow

```mermaid
graph LR
    A[Start] --> B[Enable Defender Plans]
    B --> C[Configure Auto-Provisioning]
    C --> D[Setup Alerts]
    D --> E[Configure CSPM]
    E --> F[Validate Security Score]
```

## Commands

### Enable Defender for Containers
```bash
az security pricing create \
  --name Containers \
  --tier Standard

az security pricing create \
  --name KeyVaults \
  --tier Standard

az security pricing create \
  --name StorageAccounts \
  --tier Standard
```

### Check Security Score
```bash
az security secure-score list --output table
```

### Deploy via Terraform
```bash
cd terraform/environments/${ENV}
terraform plan -target=module.defender -out=defender.tfplan
terraform apply defender.tfplan
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| environment | Yes | - | dev, staging, prod |
| enable_containers | No | true | Defender for Containers |
| enable_keyvaults | No | true | Defender for Key Vault |
| enable_cspm | No | true | Cloud Security Posture |

## Dependencies
- Subscription-level permissions

## Triggers Next
- None (foundational security layer)
