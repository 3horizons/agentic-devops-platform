# Multi-Cloud Deployment Guide

**Deploy Backstage & RHDH with MCP across Azure, AWS, GCP, and On-Premise**

**Version:** 1.0
**Author:** paulasilva@microsoft.com
**Client:** Microsoft Latam GBB

---

## Table of Contents

1. [Multi-Cloud Strategy](#1-multi-cloud-strategy)
2. [Azure Primary Deployment](#2-azure-primary-deployment)
3. [AWS Deployment](#3-aws-deployment)
4. [GCP Deployment](#4-gcp-deployment)
5. [On-Premise Deployment](#5-on-premise-deployment)
6. [Multi-Cloud Comparison Matrix](#6-multi-cloud-comparison-matrix)
7. [CI/CD Multi-Cloud Pipeline](#7-cicd-multi-cloud-pipeline)
8. [Terraform Modules per Cloud](#8-terraform-modules-per-cloud)
9. [MCP Architecture Cross-Cloud](#9-mcp-architecture-cross-cloud)
10. [References](#10-references)

---

## 1. Multi-Cloud Strategy

A multi-cloud architecture leverages multiple cloud providers to optimize cost, reduce vendor lock-in, and ensure high availability. Model Context Protocol (MCP) enables seamless integration across all cloud platforms with a unified endpoint format.

### Why Multi-Cloud?

- **Avoid vendor lock-in**: Negotiate better pricing and maintain flexibility
- **Distributed workloads**: Optimize regional latency and ensure compliance
- **Disaster recovery**: Redundancy across independent cloud providers
- **Best-of-breed services**: Leverage unique strengths of each cloud
- **Business continuity**: Ensure operations across provider outages

### MCP: Cloud-Agnostic Foundation

Model Context Protocol provides a unified interface for AI clients to interact with backend services. Critically, the MCP endpoint format remains identical across all clouds, enabling:

- **Single endpoint URL** regardless of deployment location
- **Consistent AI prompt integration** across clouds
- **No client-side changes** when switching clouds
- **Infrastructure-agnostic patterns** for deployment
- **Simplified operations** with unified management

**Key Insight:** Infrastructure is cloud-specific, but the MCP interface is universal. Deploy once, scale everywhere.

---

## 2. Azure Primary Deployment

Azure is the primary deployment platform, leveraging managed services, native integration with Microsoft tools, and comprehensive security features via Azure Key Vault and Managed Identities.

### 2.1 Kubernetes Cluster Setup (AKS)

Create an Azure Kubernetes Service cluster with production-grade defaults:

```bash
az aks create \
  --resource-group myResourceGroup \
  --name backstage-aks \
  --node-count 3 \
  --vm-set-type VirtualMachineScaleSets \
  --zones 1 2 3 \
  --enable-managed-identity \
  --network-plugin azure \
  --enable-addons monitoring \
  --workspace-resource-id /subscriptions/{subscriptionId}/resourcegroups/{resourceGroup}/providers/microsoft.operationalinsights/workspaces/{workspaceName}
```

### 2.2 Container Registry (ACR)

Set up Azure Container Registry for private image storage and management:

```bash
az acr create \
  --resource-group myResourceGroup \
  --name backstageacr \
  --sku Standard \
  --location eastus

az acr update -n backstageacr --admin-enabled true

az acr credential show -n backstageacr
```

### 2.3 Secrets Management (Azure Key Vault)

Store all sensitive data securely using Azure Key Vault with Managed Identity access:

```bash
az keyvault create \
  --name backstageKeyVault \
  --resource-group myResourceGroup \
  --location eastus

az keyvault secret set \
  --vault-name backstageKeyVault \
  --name postgresql-password \
  --value 'SecurePassword123!'

az keyvault set-policy \
  --name backstageKeyVault \
  --object-id $(az aks show -g myResourceGroup -n backstage-aks --query identityProfile.kubeletidentity.objectid -o tsv) \
  --secret-permissions get list
```

### 2.4 Managed Identity Integration

Use Azure Managed Identity for secure pod-to-Azure service authentication without credentials:

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: backstage-sa
  namespace: default
  annotations:
    azure.workload.identity/client-id: <CLIENT_ID>
---
apiVersion: v1
kind: Pod
metadata:
  name: backstage-pod
  namespace: default
  labels:
    azure.workload.identity/use: "true"
spec:
  serviceAccountName: backstage-sa
  containers:
  - name: backstage
    image: backstageacr.azurecr.io/backstage:latest
    env:
    - name: AZURE_CLIENT_ID
      value: <CLIENT_ID>
```

### 2.5 AI Search Integration

Integrate Azure AI Search for semantic search and entity discovery within Backstage:

```bash
az search service create \
  --name backstage-search \
  --resource-group myResourceGroup \
  --location eastus \
  --sku standard
```

```json
POST https://<search-service>.search.windows.net/indexes?api-version=2023-11-01
Content-Type: application/json
api-key: <api-key>

{
  "name": "entities-index",
  "fields": [
    {"name": "id", "type": "Edm.String", "key": true},
    {"name": "name", "type": "Edm.String", "searchable": true},
    {"name": "description", "type": "Edm.String", "searchable": true}
  ],
  "semanticConfiguration": {
    "name": "default",
    "prioritizedFields": {
      "titleField": {"fieldName": "name"},
      "contentFields": [{"fieldName": "description"}]
    }
  }
}
```

### 2.6 GitHub Actions CI/CD Pipeline

Automate deployment to Azure with GitHub Actions:

```yaml
name: Deploy to Azure AKS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Build and push to ACR
      run: |
        az acr build \
          --registry backstageacr \
          --image backstage:${{ github.sha }} \
          --file Dockerfile .

    - name: Deploy to AKS
      run: |
        az aks get-credentials \
          --resource-group myResourceGroup \
          --name backstage-aks
        kubectl set image deployment/backstage \
          backstage=backstageacr.azurecr.io/backstage:${{ github.sha }}
```

### 2.7 Copilot Agent Mode Prompt (Azure)

```
You are an Azure DevOps Agent specializing in Kubernetes deployments.
Context: Managing Backstage + RHDH deployment on AKS with Azure managed services.

When deploying to Azure:
1. Use Azure Container Registry (ACR) for image storage
2. Leverage Azure Key Vault with Managed Identity for secrets
3. Use Azure-native monitoring (Application Insights)
4. Implement Azure Policy for compliance
5. Enable Azure AD integration for RBAC

Example: "Deploy Backstage microservice to AKS"
- Create/update ACR image
- Store secrets in Key Vault
- Deploy Helm chart with Managed Identity annotations
- Verify pod connectivity to Key Vault
- Update DNS/LoadBalancer in Azure

Your goal: Simplify Azure-specific deployment complexity through natural language.
```

---

## 3. AWS Deployment

Deploy Backstage and RHDH on Amazon Web Services using EKS, ECR, and Secrets Manager for a production-ready multi-cloud footprint.

### 3.1 Kubernetes Cluster Setup (EKS)

Create an Amazon EKS cluster with auto-scaling and multi-AZ deployment:

```bash
eksctl create cluster \
  --name backstage-eks \
  --version 1.27 \
  --region us-east-1 \
  --nodegroup-name backstage-nodes \
  --node-type t3.medium \
  --nodes 3 \
  --nodes-min 3 \
  --nodes-max 9 \
  --managed \
  --spot

aws eks update-kubeconfig \
  --region us-east-1 \
  --name backstage-eks
```

### 3.2 Container Registry (ECR)

Set up Amazon Elastic Container Registry for private image management:

```bash
aws ecr create-repository \
  --repository-name backstage \
  --region us-east-1 \
  --image-scan-on-push

aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com

docker tag backstage:latest \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com/backstage:latest
docker push \
  <account-id>.dkr.ecr.us-east-1.amazonaws.com/backstage:latest
```

### 3.3 Secrets Management (AWS Secrets Manager)

Securely manage secrets with AWS Secrets Manager and IAM roles:

```bash
aws secretsmanager create-secret \
  --name backstage/db-password \
  --secret-string 'SecurePassword123!' \
  --region us-east-1

aws secretsmanager get-secret-value \
  --secret-id backstage/db-password \
  --region us-east-1
```

### 3.4 IRSA (IAM Roles for Service Accounts)

Enable secure pod authentication using IRSA without long-lived credentials:

```bash
eksctl utils associate-iam-oidc-provider \
  --cluster=backstage-eks \
  --region us-east-1 \
  --approve

eksctl create iamserviceaccount \
  --cluster backstage-eks \
  --namespace default \
  --name backstage-sa \
  --attach-policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite \
  --approve
```

### 3.5 GitHub Actions CI/CD Pipeline

Automate deployment to AWS EKS with GitHub Actions:

```yaml
name: Deploy to AWS EKS

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Configure AWS credentials
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Build and push to ECR
      run: |
        aws ecr get-login-password | docker login --username AWS --password-stdin ${{ secrets.ECR_REGISTRY }}
        docker build -t backstage:${{ github.sha }} .
        docker tag backstage:${{ github.sha }} ${{ secrets.ECR_REGISTRY }}/backstage:${{ github.sha }}
        docker push ${{ secrets.ECR_REGISTRY }}/backstage:${{ github.sha }}

    - name: Update kubeconfig
      run: |
        aws eks update-kubeconfig --name backstage-eks --region us-east-1

    - name: Deploy to EKS
      run: |
        kubectl set image deployment/backstage \
          backstage=${{ secrets.ECR_REGISTRY }}/backstage:${{ github.sha }} \
          --namespace default
```

### 3.6 Copilot Agent Mode Prompt (AWS)

```
You are an AWS DevOps Agent specializing in Kubernetes deployments.
Context: Managing Backstage + RHDH deployment on EKS with AWS services.

When deploying to AWS:
1. Use ECR (Elastic Container Registry) for image storage
2. Leverage AWS Secrets Manager for secret management
3. Implement IRSA for pod-to-AWS service authentication
4. Use CloudWatch for monitoring and logging
5. Enable AWS IAM integration for RBAC

Example: "Deploy Backstage microservice to EKS"
- Push image to ECR
- Store secrets in Secrets Manager
- Deploy Helm chart with IRSA service account
- Configure pod IAM policy for Secrets Manager access
- Expose via AWS Load Balancer

Your goal: Simplify AWS-specific deployment complexity through natural language.
```

---

## 4. GCP Deployment

Deploy Backstage and RHDH on Google Cloud Platform using GKE, Artifact Registry, and Secret Manager for seamless multi-cloud operations.

### 4.1 Kubernetes Cluster Setup (GKE)

Create a Google Kubernetes Engine cluster with optimal configurations:

```bash
gcloud container clusters create backstage-gke \
  --zone us-central1-a \
  --num-nodes 3 \
  --machine-type n2-standard-4 \
  --enable-autorepair \
  --enable-autoupgrade \
  --enable-workload-identity \
  --workload-pool=PROJECT_ID.svc.id.goog \
  --addons HttpLoadBalancing,HttpsLoadBalancing

gcloud container clusters get-credentials backstage-gke \
  --zone us-central1-a
```

### 4.2 Container Registry (Artifact Registry)

Set up Google Artifact Registry for container image management:

```bash
gcloud artifacts repositories create backstage \
  --repository-format=docker \
  --location=us-central1 \
  --project=PROJECT_ID

gcloud auth configure-docker us-central1-docker.pkg.dev

docker build -t us-central1-docker.pkg.dev/PROJECT_ID/backstage/backstage:latest .
docker push us-central1-docker.pkg.dev/PROJECT_ID/backstage/backstage:latest
```

### 4.3 Secrets Management (Secret Manager)

Manage secrets securely using Google Cloud Secret Manager:

```bash
gcloud secrets create backstage-db-password \
  --replication-policy="automatic" \
  --data-file=- <<< "SecurePassword123!"

gcloud secrets add-iam-policy-binding backstage-db-password \
  --member=serviceAccount:PROJECT_ID.svc.id.goog \
  --role=roles/secretmanager.secretAccessor

gcloud secrets versions access latest \
  --secret="backstage-db-password"
```

### 4.4 Workload Identity Integration

Enable pod-to-GCP service authentication using Workload Identity:

```bash
kubectl create serviceaccount backstage-sa

gcloud iam service-accounts create backstage-sa \
  --display-name="Backstage Service Account"

gcloud iam service-accounts add-iam-policy-binding \
  backstage-sa@PROJECT_ID.iam.gserviceaccount.com \
  --role roles/iam.workloadIdentityUser \
  --member "serviceAccount:PROJECT_ID.svc.id.goog[default/backstage-sa]"

kubectl annotate serviceaccount backstage-sa \
  iam.gke.io/gcp-service-account=backstage-sa@PROJECT_ID.iam.gserviceaccount.com
```

### 4.5 GitHub Actions CI/CD Pipeline

Automate deployment to GKE with GitHub Actions:

```yaml
name: Deploy to GCP GKE

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v1
      with:
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        project_id: ${{ secrets.GCP_PROJECT_ID }}
        export_default_credentials: true

    - name: Build and push to Artifact Registry
      run: |
        gcloud auth configure-docker us-central1-docker.pkg.dev
        docker build -t us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/backstage/backstage:${{ github.sha }} .
        docker push us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/backstage/backstage:${{ github.sha }}

    - name: Get cluster credentials
      run: |
        gcloud container clusters get-credentials backstage-gke \
          --zone us-central1-a \
          --project ${{ secrets.GCP_PROJECT_ID }}

    - name: Deploy to GKE
      run: |
        kubectl set image deployment/backstage \
          backstage=us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/backstage/backstage:${{ github.sha }} \
          --namespace default
```

### 4.6 Copilot Agent Mode Prompt (GCP)

```
You are a Google Cloud DevOps Agent specializing in Kubernetes deployments.
Context: Managing Backstage + RHDH deployment on GKE with Google Cloud services.

When deploying to GCP:
1. Use Artifact Registry for image storage
2. Leverage Secret Manager for secret management
3. Implement Workload Identity for pod-to-GCP authentication
4. Use Cloud Logging and Cloud Monitoring for observability
5. Enable GCP IAM integration for RBAC

Example: "Deploy Backstage microservice to GKE"
- Push image to Artifact Registry
- Store secrets in Secret Manager
- Deploy Helm chart with Workload Identity annotations
- Configure pod service account with GCP IAM bindings
- Expose via Google Cloud Load Balancer

Your goal: Simplify GCP-specific deployment complexity through natural language.
```

---

## 5. On-Premise Deployment

Deploy Backstage and RHDH on-premise using OpenShift or k3s with Harbor registry and HashiCorp Vault for secrets management. This deployment is ideal for air-gapped environments with Ollama-powered Lightspeed AI.

### 5.1 Kubernetes Cluster Setup (OpenShift or k3s)

Deploy a robust on-premise Kubernetes cluster:

```bash
# Option 1: Deploy k3s (lightweight, single-command)
curl -sfL https://get.k3s.io | sh -

# Option 2: Deploy OpenShift (enterprise-grade)
openshift-install create install-config --dir=/path/to/install
openshift-install create cluster --dir=/path/to/install

# Verify cluster health
kubectl get nodes
kubectl get pods --all-namespaces
```

### 5.2 Container Registry (Harbor)

Set up Harbor as a private container registry with air-gapped image management:

```bash
helm repo add harbor https://helm.goharbor.io
helm repo update

helm install harbor harbor/harbor \
  --namespace harbor \
  --create-namespace \
  --values harbor-values.yaml

kubectl create secret docker-registry harbor-secret \
  --docker-server=harbor.local \
  --docker-username=admin \
  --docker-password=HarborPassword123 \
  --namespace default

docker tag backstage:latest harbor.local/library/backstage:latest
docker push harbor.local/library/backstage:latest
```

### 5.3 Secrets Management (HashiCorp Vault)

Deploy HashiCorp Vault for centralized secrets management:

```bash
helm repo add hashicorp https://helm.releases.hashicorp.com
helm repo update

helm install vault hashicorp/vault \
  --namespace vault \
  --create-namespace \
  --values vault-values.yaml

kubectl exec -n vault vault-0 -- vault operator init

vault kv put secret/backstage/database \
  password="SecurePassword123!" \
  connection-string="postgresql://backstage:PASSWORD@postgres:5432/backstage"

vault auth enable kubernetes

vault write auth/kubernetes/config \
  token_reviewer_jwt=@/var/run/secrets/kubernetes.io/serviceaccount/token \
  kubernetes_host="https://$KUBERNETES_SERVICE_HOST:$KUBERNETES_SERVICE_PORT"

vault policy write backstage - <<EOF
path "secret/backstage/*" {
  capabilities = ["read", "list"]
}
EOF
```

### 5.4 Air-Gapped Lightspeed with Ollama

Deploy Ollama locally for completely air-gapped AI-powered Lightspeed integration:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ollama
  namespace: ollama
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ollama
  template:
    metadata:
      labels:
        app: ollama
    spec:
      containers:
      - name: ollama
        image: ollama/ollama:latest
        ports:
        - containerPort: 11434
        volumeMounts:
        - name: ollama-data
          mountPath: /root/.ollama
        resources:
          requests:
            memory: "8Gi"
            cpu: "4"
          limits:
            memory: "16Gi"
            cpu: "8"
      volumes:
      - name: ollama-data
        persistentVolumeClaim:
          claimName: ollama-pvc
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ollama-pvc
  namespace: ollama
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 50Gi
---
apiVersion: v1
kind: Service
metadata:
  name: ollama
  namespace: ollama
spec:
  ports:
  - port: 11434
    targetPort: 11434
  selector:
    app: ollama
```

Pull model and configure RHDH:

```bash
kubectl exec -n ollama deployment/ollama -- ollama pull llama2
```

Configure RHDH to use local Ollama:

```yaml
lightspeed:
  enabled: true
  endpoint: "http://ollama.ollama.svc.cluster.local:11434"
  model: "llama2"
  aiFeatures:
    enabled: true
    plugins: ["bash", "jinja2", "python"]
```

### 5.5 GitHub Actions CI/CD Pipeline

Automate deployment to on-premise cluster with GitHub Actions:

```yaml
name: Deploy to On-Premise Kubernetes

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: [self-hosted, on-premise]
    steps:
    - uses: actions/checkout@v3

    - name: Build and push to Harbor
      run: |
        docker login -u admin -p ${{ secrets.HARBOR_PASSWORD }} harbor.local
        docker build -t harbor.local/library/backstage:${{ github.sha }} .
        docker push harbor.local/library/backstage:${{ github.sha }}

    - name: Deploy to on-premise cluster
      run: |
        kubectl set image deployment/backstage \
          backstage=harbor.local/library/backstage:${{ github.sha }} \
          --namespace default
```

### 5.6 Copilot Agent Mode Prompt (On-Premise)

```
You are an On-Premise Infrastructure Agent specializing in Kubernetes deployments.
Context: Managing Backstage + RHDH deployment on OpenShift/k3s with air-gapped Lightspeed AI.

When deploying to on-premise:
1. Use Harbor for private image management
2. Leverage HashiCorp Vault for secrets management
3. Deploy local Ollama for completely air-gapped AI features
4. Use standard Kubernetes resources (no cloud-specific APIs)
5. Implement internal DNS and certificate management

Example: "Deploy Backstage with Lightspeed to on-premise cluster"
- Build and push image to Harbor
- Store secrets in Vault with Kubernetes auth
- Deploy Helm chart with Vault integration
- Pull and run local Ollama model
- Configure RHDH to use local Ollama endpoint
- Set up internal DNS for service discovery

Your goal: Simplify on-premise deployment complexity for air-gapped environments.
```

---

## 6. Multi-Cloud Comparison Matrix

A comprehensive comparison of key infrastructure components across all supported cloud platforms:

| Component | Azure | AWS | GCP | On-Premise |
|-----------|-------|-----|-----|-----------|
| K8s Service | AKS | EKS | GKE | OpenShift / k3s |
| Container Registry | ACR | ECR | Artifact Registry | Harbor |
| Secrets Manager | Key Vault | Secrets Manager | Secret Manager | HashiCorp Vault |
| Pod Auth | Managed Identity | IRSA | Workload Identity | Kubernetes SA + Vault |
| Monitoring | Application Insights | CloudWatch | Cloud Monitoring | Prometheus + Grafana |
| Load Balancing | Azure LB / App Gateway | AWS LB | Google Cloud LB | MetalLB / Ingress |
| Cost (Est. Monthly) | $800-1,500 | $700-1,400 | $600-1,200 | $500+ (On-Premise) |
| Complexity (1-10) | 7 | 8 | 6 | 9 |
| MCP Endpoint | Same | Same | Same | Same |
| AI Client Changes | None | None | None | None |

**Critical:** The MCP endpoint remains identical across all clouds. Infrastructure varies; the AI interface does not.

---

## 7. CI/CD Multi-Cloud Pipeline

Deploy to all clouds simultaneously using a single GitHub Actions workflow with environment-based selection:

```yaml
name: Deploy to Multi-Cloud

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    outputs:
      image-tag: ${{ steps.image.outputs.tag }}
    steps:
    - uses: actions/checkout@v3

    - name: Generate image tag
      id: image
      run: echo "tag=${{ github.sha }}" >> $GITHUB_OUTPUT

    - name: Build Docker image
      run: docker build -t backstage:${{ steps.image.outputs.tag }} .

  deploy-azure:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Azure Login
      uses: azure/login@v1
      with:
        creds: ${{ secrets.AZURE_CREDENTIALS }}

    - name: Push to ACR
      run: |
        az acr build --registry backstageacr --image backstage:${{ needs.build.outputs.image-tag }} .

    - name: Deploy to AKS
      run: |
        az aks get-credentials --resource-group myResourceGroup --name backstage-aks
        kubectl set image deployment/backstage backstage=backstageacr.azurecr.io/backstage:${{ needs.build.outputs.image-tag }}

  deploy-aws:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Configure AWS
      uses: aws-actions/configure-aws-credentials@v2
      with:
        aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
        aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        aws-region: us-east-1

    - name: Push to ECR
      run: |
        aws ecr get-login-password | docker login --username AWS --password-stdin ${{ secrets.ECR_REGISTRY }}
        docker tag backstage:${{ needs.build.outputs.image-tag }} ${{ secrets.ECR_REGISTRY }}/backstage:${{ needs.build.outputs.image-tag }}
        docker push ${{ secrets.ECR_REGISTRY }}/backstage:${{ needs.build.outputs.image-tag }}

    - name: Deploy to EKS
      run: |
        aws eks update-kubeconfig --name backstage-eks --region us-east-1
        kubectl set image deployment/backstage backstage=${{ secrets.ECR_REGISTRY }}/backstage:${{ needs.build.outputs.image-tag }}

  deploy-gcp:
    needs: build
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Cloud SDK
      uses: google-github-actions/setup-gcloud@v1
      with:
        service_account_key: ${{ secrets.GCP_SA_KEY }}
        project_id: ${{ secrets.GCP_PROJECT_ID }}

    - name: Push to Artifact Registry
      run: |
        gcloud auth configure-docker us-central1-docker.pkg.dev
        docker tag backstage:${{ needs.build.outputs.image-tag }} us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/backstage/backstage:${{ needs.build.outputs.image-tag }}
        docker push us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/backstage/backstage:${{ needs.build.outputs.image-tag }}

    - name: Deploy to GKE
      run: |
        gcloud container clusters get-credentials backstage-gke --zone us-central1-a
        kubectl set image deployment/backstage backstage=us-central1-docker.pkg.dev/${{ secrets.GCP_PROJECT_ID }}/backstage/backstage:${{ needs.build.outputs.image-tag }}

  deploy-onprem:
    needs: build
    runs-on: [self-hosted, on-premise]
    steps:
    - uses: actions/checkout@v3
    - name: Push to Harbor
      run: |
        docker login -u admin -p ${{ secrets.HARBOR_PASSWORD }} harbor.local
        docker tag backstage:${{ needs.build.outputs.image-tag }} harbor.local/library/backstage:${{ needs.build.outputs.image-tag }}
        docker push harbor.local/library/backstage:${{ needs.build.outputs.image-tag }}

    - name: Deploy to on-premise cluster
      run: |
        kubectl set image deployment/backstage backstage=harbor.local/library/backstage:${{ needs.build.outputs.image-tag }}
```

---

## 8. Terraform Modules per Cloud

Infrastructure-as-Code modules for each cloud platform enable repeatable, consistent deployments:

### 8.1 Module Structure

```
terraform/
├── azure/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── aks/
│       ├── acr/
│       └── keyvault/
├── aws/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── eks/
│       ├── ecr/
│       └── secrets-manager/
├── gcp/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       ├── gke/
│       ├── artifact-registry/
│       └── secret-manager/
└── on-prem/
    ├── main.tf
    └── modules/
        ├── k3s-helm/
        ├── harbor/
        └── vault/
```

### 8.2 Azure Terraform Module

```hcl
# terraform/azure/main.tf
module "aks" {
  source = "./modules/aks"

  resource_group_name = var.resource_group_name
  cluster_name        = var.cluster_name
  location            = var.location
  node_count          = var.node_count
  vm_size             = "Standard_D2s_v3"
}

module "acr" {
  source = "./modules/acr"

  resource_group_name = var.resource_group_name
  registry_name       = var.registry_name
  location            = var.location
}

module "keyvault" {
  source = "./modules/keyvault"

  resource_group_name = var.resource_group_name
  vault_name          = var.vault_name
  location            = var.location
}

# terraform/azure/variables.tf
variable "resource_group_name" {
  type = string
}

variable "cluster_name" {
  type = string
  default = "backstage-aks"
}

variable "location" {
  type = string
  default = "eastus"
}

variable "node_count" {
  type = number
  default = 3
}
```

### 8.3 AWS Terraform Module

```hcl
# terraform/aws/main.tf
module "eks" {
  source = "./modules/eks"

  cluster_name    = var.cluster_name
  region          = var.region
  node_group_size = var.node_group_size
}

module "ecr" {
  source = "./modules/ecr"

  repository_name = var.repository_name
  region          = var.region
}

module "secrets_manager" {
  source = "./modules/secrets-manager"

  region = var.region
}

# terraform/aws/variables.tf
variable "cluster_name" {
  type = string
  default = "backstage-eks"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "node_group_size" {
  type = number
  default = 3
}
```

### 8.4 GCP Terraform Module

```hcl
# terraform/gcp/main.tf
module "gke" {
  source = "./modules/gke"

  project_id       = var.project_id
  cluster_name     = var.cluster_name
  region           = var.region
  node_count       = var.node_count
}

module "artifact_registry" {
  source = "./modules/artifact-registry"

  project_id       = var.project_id
  repository_name  = var.repository_name
  region           = var.region
}

module "secret_manager" {
  source = "./modules/secret-manager"

  project_id = var.project_id
}

# terraform/gcp/variables.tf
variable "project_id" {
  type = string
}

variable "cluster_name" {
  type = string
  default = "backstage-gke"
}

variable "region" {
  type = string
  default = "us-central1"
}
```

---

## 9. MCP Architecture Cross-Cloud

The critical insight in multi-cloud deployment is that Model Context Protocol provides a unified endpoint across all cloud platforms. The infrastructure changes, but the AI interface remains constant.

### 9.1 MCP Endpoint Consistency

Regardless of cloud provider, the MCP endpoint follows the same URL pattern:

```
# All clouds expose identical endpoint format:
https://mcp.backstage.example.com/api/v1

# The endpoint works identically across:
Azure:      mcp.backstage-azure.example.com
AWS:        mcp.backstage-aws.example.com
GCP:        mcp.backstage-gcp.example.com
On-Premise: mcp.backstage.internal.example.com

# AI clients use the same protocol regardless of cloud:
POST https://mcp.backstage.example.com/api/v1/call-tool
Content-Type: application/json
Authorization: Bearer <token>

{
  "tool": "deploy-service",
  "input": {
    "service": "my-app",
    "environment": "production"
  }
}
```

### 9.2 AI Client Independence

AI clients (Copilot, Claude, LLMs) require zero code changes when switching clouds:

```
# Copilot Agent Mode - No cloud-specific logic needed
You are a DevOps Agent managing Backstage deployments.

User Request: "Deploy the payment service to production"

Your actions (cloud-independent):
1. Call MCP endpoint: /api/v1/deploy-service
2. Provide parameters: service=payment, env=production
3. MCP endpoint handles cloud-specific implementation
4. Return deployment status to user

The MCP endpoint abstracts cloud complexity:
- Azure deployment logic runs on Azure infrastructure
- AWS deployment logic runs on AWS infrastructure
- GCP deployment logic runs on GCP infrastructure
- Same input, different backend execution
```

### 9.3 Infrastructure Abstraction Layer

The MCP server is deployed once per cloud with cloud-specific integrations, but presents a unified interface:

```python
# MCP Server - Runs on each cloud with cloud-specific backends
class MCPServer:
    def __init__(self, cloud_provider):
        self.cloud = cloud_provider

        # Cloud-specific initialization
        if cloud_provider == "azure":
            self.registry = ACRRegistry()
            self.secrets = KeyVaultManager()
            self.k8s = AKSClient()
        elif cloud_provider == "aws":
            self.registry = ECRRegistry()
            self.secrets = SecretsManager()
            self.k8s = EKSClient()
        elif cloud_provider == "gcp":
            self.registry = ArtifactRegistry()
            self.secrets = SecretManagerClient()
            self.k8s = GKEClient()

    def deploy_service(self, service_name, image, env):
        # Cloud-agnostic interface
        image_uri = self.registry.push_image(image)
        secrets = self.secrets.load_secrets(service_name)
        return self.k8s.deploy(service_name, image_uri, secrets, env)

# Result: Same API endpoint, different cloud backends
```

### 9.4 Deployment Flow

End-to-end flow showing MCP endpoint consistency across clouds:

```
User Request (Cloud-Agnostic):
↓
"Deploy backstage-web service to production using latest commit"
↓
AI Client (Copilot/Claude):
↓
POST https://mcp.backstage.example.com/api/v1/deploy-service
{
  "service": "backstage-web",
  "image": "backstage:abc123",
  "environment": "production"
}
↓
MCP Server (Cloud-Specific Backend):
├─ Azure → ACR + AKS deployment
├─ AWS → ECR + EKS deployment
├─ GCP → Artifact Registry + GKE deployment
└─ On-Prem → Harbor + OpenShift deployment
↓
Return Status (Identical Across Clouds):
{
  "status": "success",
  "deployment_id": "deploy-12345",
  "endpoint": "https://backstage-web.example.com"
}
↓
AI Client displays result to user
(No cloud-specific logic in client)
```

---

## 10. References

### Azure Documentation

- [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/)
- [Azure Container Registry (ACR)](https://learn.microsoft.com/en-us/azure/container-registry/)
- [Azure Key Vault](https://learn.microsoft.com/en-us/azure/key-vault/)
- [Azure Managed Identity](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Azure AI Search](https://learn.microsoft.com/en-us/azure/search/)

### AWS Documentation

- [Amazon EKS](https://docs.aws.amazon.com/eks/)
- [Amazon ECR](https://docs.aws.amazon.com/ecr/)
- [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/)
- [IAM Roles for Service Accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)
- [eksctl](https://eksctl.io/)

### GCP Documentation

- [Google Kubernetes Engine (GKE)](https://cloud.google.com/kubernetes-engine/docs)
- [Artifact Registry](https://cloud.google.com/artifact-registry/docs)
- [Secret Manager](https://cloud.google.com/secret-manager/docs)
- [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- [gcloud CLI](https://cloud.google.com/sdk/gcloud)

### On-Premise Tools

- [k3s - Lightweight Kubernetes](https://k3s.io/)
- [Red Hat OpenShift](https://www.redhat.com/en/technologies/cloud-platforms/openshift)
- [Harbor - Container Registry](https://goharbor.io/)
- [HashiCorp Vault](https://www.vaultproject.io/)
- [Ollama - Local LLMs](https://ollama.ai/)

### Backstage & RHDH

- [Backstage Official](https://backstage.io/)
- [Red Hat Developer Hub (RHDH)](https://developers.redhat.com/products/rhdh/)
- [Backstage Plugins](https://backstage.io/plugins)
- [RHDH AI Features (Lightspeed)](https://docs.redhat.com/en/documentation/red_hat_developer_hub)

### Model Context Protocol (MCP)

- [MCP Specification](https://modelcontextprotocol.io/)
- [MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)
- [MCP Server Implementation](https://modelcontextprotocol.io/docs/concepts/servers)
- [Azure AI Foundry Agents](https://learn.microsoft.com/azure/ai-services/agents/)

### CI/CD & DevOps

- [GitHub Actions](https://docs.github.com/en/actions)
- [Terraform](https://www.terraform.io/docs)
- [Helm](https://helm.sh/docs/)
- [GitOps with ArgoCD](https://argoproj.github.io/cd/)

---

**Document Version:** 1.0
**Last Updated:** February 27, 2026
**Framework:** Backstage + Red Hat Developer Hub (RHDH) with MCP
**Platforms:** Azure (Primary), AWS, GCP, On-Premise (OpenShift/k3s)
