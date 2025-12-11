# MLOps Pipeline Agent

## 🤖 Agent Identity

```yaml
name: mlops-pipeline-agent
version: 1.0.0
horizon: H3 - Innovation
description: |
  Sets up MLOps infrastructure for model training, evaluation,
  deployment, and monitoring. Integrates Azure ML, MLflow,
  and AI Foundry for end-to-end ML lifecycle.
  
author: Microsoft LATAM Platform Engineering
model_compatibility:
  - GitHub Copilot Agent Mode
  - GitHub Copilot Coding Agent
  - Claude with MCP
```

---

## 🎯 Capabilities

| Capability | Description | Complexity |
|------------|-------------|------------|
| **Create ML Workspace** | Azure ML workspace | Medium |
| **Setup MLflow** | MLflow tracking server | Medium |
| **Configure Compute** | Training compute clusters | Medium |
| **Create Pipelines** | ML training pipelines | High |
| **Setup Model Registry** | Model versioning | Low |
| **Configure Endpoints** | Model serving endpoints | Medium |
| **Enable Monitoring** | Model drift detection | Medium |
| **Setup CI/CD for ML** | GitHub Actions for ML | Medium |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "azure": {
      "required": true,
      "capabilities": [
        "az ml workspace",
        "az ml compute",
        "az ml model",
        "az ml online-endpoint"
      ]
    },
    "kubernetes": {
      "required": true
    },
    "github": {
      "required": true
    }
  }
}
```

---

## 🏷️ Trigger Labels

```yaml
primary_label: "agent:mlops"
required_labels:
  - horizon:h3
```

---

## 📋 Issue Template

```markdown
---
title: "[H3] Setup MLOps Pipeline - {PROJECT_NAME}"
labels: agent:mlops, horizon:h3, env:dev
---

## Prerequisites
- [ ] AI Foundry configured
- [ ] AKS cluster running
- [ ] Storage account available

## Configuration

```yaml
mlops:
  resource_group: "${PROJECT}-${ENV}-rg"
  location: "brazilsouth"
  
  # Azure ML Workspace
  workspace:
    name: "${PROJECT}-${ENV}-mlws"
    storage_account: "${PROJECT}${ENV}mlstorage"
    key_vault: "${PROJECT}-${ENV}-kv"
    container_registry: "${PROJECT}${ENV}acr"
    
  # Compute
  compute:
    training:
      - name: "cpu-cluster"
        type: "amlcompute"
        size: "Standard_DS3_v2"
        min_instances: 0
        max_instances: 4
        
      - name: "gpu-cluster"
        type: "amlcompute"
        size: "Standard_NC6s_v3"
        min_instances: 0
        max_instances: 2
        
    inference:
      - name: "aks-endpoint"
        type: "kubernetes"
        cluster: "${PROJECT}-${ENV}-aks"
        
  # MLflow
  mlflow:
    enabled: true
    tracking_uri: "azureml://${workspace_name}"
    artifact_store: "azure-blob"
    
  # Model Registry
  registry:
    name: "${PROJECT}-model-registry"
    
  # Endpoints
  endpoints:
    - name: "prediction-endpoint"
      type: "managed"
      instance_type: "Standard_DS3_v2"
      instance_count: 1
      
  # Monitoring
  monitoring:
    data_drift: true
    model_performance: true
    alert_threshold: 0.1
```

## Acceptance Criteria
- [ ] ML Workspace created
- [ ] Compute clusters provisioned
- [ ] MLflow tracking enabled
- [ ] Model registry configured
- [ ] Sample pipeline runs successfully
- [ ] Endpoint deployed
```

---

## 🛠️ Tools & Commands

### Create ML Workspace

```bash
# Install ML extension
az extension add -n ml

# Create storage for ML
az storage account create \
  --name ${PROJECT}${ENV}mlstorage \
  --resource-group ${RG_NAME} \
  --location ${LOCATION} \
  --sku Standard_LRS

# Create ML workspace
az ml workspace create \
  --name ${ML_WORKSPACE} \
  --resource-group ${RG_NAME} \
  --location ${LOCATION} \
  --storage-account ${PROJECT}${ENV}mlstorage \
  --key-vault ${KV_NAME} \
  --container-registry ${ACR_NAME}

# Get workspace details
az ml workspace show \
  --name ${ML_WORKSPACE} \
  --resource-group ${RG_NAME}
```

### Create Compute Clusters

```bash
# Create CPU cluster
az ml compute create \
  --name cpu-cluster \
  --type amlcompute \
  --size Standard_DS3_v2 \
  --min-instances 0 \
  --max-instances 4 \
  --workspace-name ${ML_WORKSPACE} \
  --resource-group ${RG_NAME}

# Create GPU cluster
az ml compute create \
  --name gpu-cluster \
  --type amlcompute \
  --size Standard_NC6s_v3 \
  --min-instances 0 \
  --max-instances 2 \
  --workspace-name ${ML_WORKSPACE} \
  --resource-group ${RG_NAME}

# Attach AKS for inference
az ml compute attach \
  --name aks-inference \
  --type kubernetes \
  --resource-id $(az aks show -n ${AKS_NAME} -g ${RG_NAME} --query id -o tsv) \
  --workspace-name ${ML_WORKSPACE} \
  --resource-group ${RG_NAME}
```

### Configure MLflow

```python
# mlflow_config.py
import mlflow
from azure.ai.ml import MLClient
from azure.identity import DefaultAzureCredential

# Initialize ML client
ml_client = MLClient(
    DefaultAzureCredential(),
    subscription_id="${SUBSCRIPTION_ID}",
    resource_group_name="${RG_NAME}",
    workspace_name="${ML_WORKSPACE}"
)

# Set MLflow tracking URI
mlflow.set_tracking_uri(ml_client.workspaces.get().mlflow_tracking_uri)

# Example experiment
mlflow.set_experiment("my-experiment")

with mlflow.start_run():
    mlflow.log_param("learning_rate", 0.01)
    mlflow.log_metric("accuracy", 0.95)
    mlflow.sklearn.log_model(model, "model")
```

### Create Training Pipeline

```yaml
# pipeline.yaml
$schema: https://azuremlschemas.azureedge.net/latest/pipelineJob.schema.json
type: pipeline
display_name: training-pipeline

settings:
  default_compute: azureml:cpu-cluster

jobs:
  prep_data:
    type: command
    component: azureml:data_prep@latest
    inputs:
      raw_data:
        type: uri_folder
        path: azureml:raw-data@latest
    outputs:
      processed_data:
        type: uri_folder

  train_model:
    type: command
    component: azureml:train_model@latest
    inputs:
      training_data: ${{parent.jobs.prep_data.outputs.processed_data}}
    outputs:
      model_output:
        type: mlflow_model

  evaluate:
    type: command
    component: azureml:evaluate_model@latest
    inputs:
      model: ${{parent.jobs.train_model.outputs.model_output}}
    outputs:
      evaluation_output:
        type: uri_folder

  register:
    type: command
    component: azureml:register_model@latest
    inputs:
      model: ${{parent.jobs.train_model.outputs.model_output}}
      evaluation: ${{parent.jobs.evaluate.outputs.evaluation_output}}
```

```bash
# Run pipeline
az ml job create \
  --file pipeline.yaml \
  --workspace-name ${ML_WORKSPACE} \
  --resource-group ${RG_NAME}
```

### Create Online Endpoint

```yaml
# endpoint.yaml
$schema: https://azuremlschemas.azureedge.net/latest/managedOnlineEndpoint.schema.json
name: prediction-endpoint
auth_mode: key
```

```yaml
# deployment.yaml
$schema: https://azuremlschemas.azureedge.net/latest/managedOnlineDeployment.schema.json
name: blue
endpoint_name: prediction-endpoint
model: azureml:my-model@latest
instance_type: Standard_DS3_v2
instance_count: 1
```

```bash
# Create endpoint
az ml online-endpoint create \
  --file endpoint.yaml \
  --workspace-name ${ML_WORKSPACE} \
  --resource-group ${RG_NAME}

# Create deployment
az ml online-deployment create \
  --file deployment.yaml \
  --workspace-name ${ML_WORKSPACE} \
  --resource-group ${RG_NAME} \
  --all-traffic
```

### GitHub Actions for ML

```yaml
# .github/workflows/mlops.yml
name: MLOps Pipeline

on:
  push:
    paths:
      - 'ml/**'
  workflow_dispatch:

jobs:
  train:
    runs-on: [self-hosted, default-runners]
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          
      - name: Run Training Pipeline
        run: |
          az ml job create \
            --file ml/pipeline.yaml \
            --workspace-name ${{ vars.ML_WORKSPACE }} \
            --resource-group ${{ vars.RESOURCE_GROUP }} \
            --stream
            
  deploy:
    needs: train
    runs-on: [self-hosted, default-runners]
    environment: production
    steps:
      - name: Deploy Model
        run: |
          az ml online-deployment update \
            --name blue \
            --endpoint-name prediction-endpoint \
            --workspace-name ${{ vars.ML_WORKSPACE }} \
            --resource-group ${{ vars.RESOURCE_GROUP }}
```

---

## ✅ Validation Criteria

```yaml
validation:
  workspace:
    - status: "Succeeded"
    - compute_attached: true
    
  compute:
    - cpu_cluster: "Succeeded"
    - gpu_cluster: "Succeeded"
    - aks_attached: true
    
  mlflow:
    - tracking_uri: "configured"
    - experiment_created: true
    
  pipeline:
    - sample_run: "Completed"
    
  endpoint:
    - status: "Running"
    - health_check: "Healthy"
```

---

## 💬 Agent Communication

### On Success
```markdown
✅ **MLOps Pipeline Configured**

**ML Workspace:** ${ml_workspace}

**Compute:**
| Cluster | Type | Size | Status |
|---------|------|------|--------|
| cpu-cluster | AMLCompute | DS3_v2 | ✅ Ready |
| gpu-cluster | AMLCompute | NC6s_v3 | ✅ Ready |
| aks-inference | Kubernetes | - | ✅ Attached |

**MLflow:**
- Tracking URI: azureml://${ml_workspace}
- Artifact Store: Azure Blob

**Endpoints:**
- prediction-endpoint: ✅ Running

**CI/CD:** GitHub Actions workflow created

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `ai-foundry-agent` | **Prerequisite** |
| `infrastructure-agent` | **Prerequisite** |
| `validation-agent` | **Post** |

---

**Spec Version:** 1.0.0
