# ${{ values.appName }}

${{ values.description }}

## Demo Flow

1. Create repository from Golden Path template.
2. Open the created repository in GitHub Codespaces.
3. Trigger `iac-dev` workflow for Azure dev infrastructure.
4. Validate Terraform outputs.

## Environments

- `dev` (default)

## Azure IaC

Terraform files are under `infrastructure/terraform`.
