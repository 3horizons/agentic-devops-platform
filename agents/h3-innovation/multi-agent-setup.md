# Multi-Agent Setup

## 🤖 Agent Identity

```yaml
name: multi-agent-setup
version: 1.0.0
horizon: H3 - Innovation
description: |
  Deploys and orchestrates multi-agent AI systems using
  AutoGen, Semantic Kernel, and Azure AI Foundry Agent Service.
  Enables complex agentic workflows with multiple collaborating agents.
  
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
| **Setup AutoGen** | Microsoft AutoGen framework | High |
| **Configure Semantic Kernel** | SK agent orchestration | Medium |
| **Create Agent Teams** | Multi-agent collaboration | High |
| **Setup Agent Memory** | Shared memory/context | Medium |
| **Configure Tools** | Agent tool integration | Medium |
| **Enable Guardrails** | Safety and content filtering | Medium |
| **Deploy on AKS** | Containerized agents | Medium |
| **Setup Monitoring** | Agent observability | Low |

---

## 🔧 MCP Servers Required

```json
{
  "mcpServers": {
    "azure": {
      "required": true,
      "capabilities": [
        "az cognitiveservices",
        "az redis"
      ]
    },
    "azure-ai": {
      "required": true,
      "capabilities": [
        "create_agent",
        "create_team"
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
primary_label: "agent:multi-agent"
required_labels:
  - horizon:h3
action_labels:
  - action:setup-autogen
  - action:setup-semantic-kernel
  - action:create-team
```

---

## 📋 Issue Template

```markdown
---
title: "[H3] Setup Multi-Agent System - {PROJECT_NAME}"
labels: agent:multi-agent, horizon:h3, env:dev
---

## Prerequisites
- [ ] AI Foundry configured
- [ ] AKS cluster running
- [ ] Redis for agent memory

## Configuration

```yaml
multi_agent:
  framework: "autogen"  # autogen, semantic-kernel, foundry-native
  
  # Models
  models:
    orchestrator: "gpt-4o"
    workers: "gpt-4o-mini"
    embeddings: "text-embedding-3-large"
    
  # Agent Team
  team:
    name: "devops-agents"
    pattern: "group-chat"  # group-chat, sequential, hierarchical
    
    agents:
      - name: "coordinator"
        role: "orchestrator"
        model: "gpt-4o"
        system_prompt: |
          You are the coordinator agent. Your role is to:
          1. Understand user requests
          2. Break down tasks
          3. Delegate to specialist agents
          4. Synthesize results
          
      - name: "code-analyst"
        role: "worker"
        model: "gpt-4o"
        tools:
          - "github_search"
          - "code_review"
        system_prompt: |
          You analyze code and provide recommendations.
          
      - name: "infrastructure-expert"
        role: "worker"
        model: "gpt-4o"
        tools:
          - "azure_resource_query"
          - "terraform_plan"
        system_prompt: |
          You are an Azure infrastructure expert.
          
      - name: "security-reviewer"
        role: "worker"
        model: "gpt-4o"
        tools:
          - "ghas_alerts"
          - "defender_findings"
        system_prompt: |
          You review security findings and recommend remediations.
          
  # Memory
  memory:
    type: "redis"
    host: "${REDIS_HOST}"
    ttl_hours: 24
    
  # Guardrails
  guardrails:
    content_filter: true
    max_turns: 20
    timeout_seconds: 300
    human_in_loop:
      - "delete"
      - "deploy-production"
      
  # Deployment
  deployment:
    type: "aks"
    replicas: 2
    resources:
      cpu: "1"
      memory: "2Gi"
```

## Acceptance Criteria
- [ ] Agent framework deployed
- [ ] All agents registered
- [ ] Team collaboration working
- [ ] Memory persistence verified
- [ ] Guardrails active
- [ ] Test conversation successful
```

---

## 🛠️ Agent Framework Code

### AutoGen Setup

```python
# autogen_team.py
import autogen
from autogen import AssistantAgent, UserProxyAgent, GroupChat, GroupChatManager

# Configuration
config_list = [
    {
        "model": "gpt-4o",
        "api_key": os.environ["AZURE_OPENAI_API_KEY"],
        "base_url": os.environ["AZURE_OPENAI_ENDPOINT"],
        "api_type": "azure",
        "api_version": "2024-02-15-preview"
    }
]

llm_config = {
    "config_list": config_list,
    "temperature": 0.7,
    "cache_seed": 42
}

# Create agents
coordinator = AssistantAgent(
    name="coordinator",
    system_message="""You are the coordinator agent. Your role is to:
    1. Understand user requests
    2. Break down tasks
    3. Delegate to specialist agents
    4. Synthesize results""",
    llm_config=llm_config
)

code_analyst = AssistantAgent(
    name="code_analyst",
    system_message="You analyze code and provide recommendations.",
    llm_config=llm_config
)

infra_expert = AssistantAgent(
    name="infrastructure_expert",
    system_message="You are an Azure infrastructure expert.",
    llm_config=llm_config
)

security_reviewer = AssistantAgent(
    name="security_reviewer",
    system_message="You review security findings and recommend remediations.",
    llm_config=llm_config
)

# User proxy
user_proxy = UserProxyAgent(
    name="user",
    human_input_mode="NEVER",
    max_consecutive_auto_reply=10,
    code_execution_config={"work_dir": "workspace"}
)

# Create group chat
groupchat = GroupChat(
    agents=[user_proxy, coordinator, code_analyst, infra_expert, security_reviewer],
    messages=[],
    max_round=20,
    speaker_selection_method="auto"
)

manager = GroupChatManager(groupchat=groupchat, llm_config=llm_config)

# Start conversation
user_proxy.initiate_chat(
    manager,
    message="Review our application security posture and infrastructure"
)
```

### Semantic Kernel Setup

```python
# semantic_kernel_agents.py
import semantic_kernel as sk
from semantic_kernel.agents import ChatCompletionAgent, AgentGroupChat
from semantic_kernel.connectors.ai.open_ai import AzureChatCompletion

# Initialize kernel
kernel = sk.Kernel()

# Add Azure OpenAI service
kernel.add_service(AzureChatCompletion(
    deployment_name="gpt-4o",
    endpoint=os.environ["AZURE_OPENAI_ENDPOINT"],
    api_key=os.environ["AZURE_OPENAI_API_KEY"]
))

# Create agents
coordinator = ChatCompletionAgent(
    kernel=kernel,
    name="Coordinator",
    instructions="You coordinate the team and synthesize results."
)

code_analyst = ChatCompletionAgent(
    kernel=kernel,
    name="CodeAnalyst",
    instructions="You analyze code quality and patterns."
)

infra_expert = ChatCompletionAgent(
    kernel=kernel,
    name="InfraExpert",
    instructions="You are an Azure infrastructure expert."
)

# Create group chat
chat = AgentGroupChat(
    agents=[coordinator, code_analyst, infra_expert],
    termination_strategy=TerminationStrategy.MaxMessages(20)
)

# Run conversation
async def run_team():
    async for response in chat.invoke("Analyze our deployment pipeline"):
        print(f"{response.agent_name}: {response.content}")
```

### Foundry Agent Service

```python
# foundry_agents.py
from azure.ai.projects import AIProjectClient
from azure.identity import DefaultAzureCredential

# Initialize client
project_client = AIProjectClient(
    credential=DefaultAzureCredential(),
    project_endpoint=os.environ["AI_PROJECT_ENDPOINT"]
)

# Create coordinator agent
coordinator = project_client.agents.create(
    model="gpt-4o",
    name="coordinator",
    instructions="You coordinate the team and delegate tasks.",
    tools=[
        {"type": "function", "function": {"name": "delegate_task"}},
        {"type": "function", "function": {"name": "synthesize_results"}}
    ]
)

# Create specialist agents
code_analyst = project_client.agents.create(
    model="gpt-4o",
    name="code_analyst",
    instructions="You analyze code.",
    tools=[{"type": "code_interpreter"}]
)

security_reviewer = project_client.agents.create(
    model="gpt-4o",
    name="security_reviewer",
    instructions="You review security.",
    tools=[
        {"type": "function", "function": {"name": "get_ghas_alerts"}},
        {"type": "function", "function": {"name": "get_defender_findings"}}
    ]
)
```

---

## 📦 Kubernetes Deployment

```yaml
# multi-agent-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: multi-agent-system
  namespace: ai-agents
spec:
  replicas: 2
  selector:
    matchLabels:
      app: multi-agent
  template:
    metadata:
      labels:
        app: multi-agent
        azure.workload.identity/use: "true"
    spec:
      serviceAccountName: ai-workload
      containers:
        - name: agent-orchestrator
          image: ${ACR_NAME}.azurecr.io/multi-agent:latest
          ports:
            - containerPort: 8000
          env:
            - name: AZURE_OPENAI_ENDPOINT
              valueFrom:
                secretKeyRef:
                  name: ai-secrets
                  key: openai-endpoint
            - name: REDIS_HOST
              value: "${REDIS_NAME}.redis.cache.windows.net"
            - name: AGENT_FRAMEWORK
              value: "autogen"
          resources:
            requests:
              cpu: "500m"
              memory: "1Gi"
            limits:
              cpu: "2"
              memory: "4Gi"
          livenessProbe:
            httpGet:
              path: /health
              port: 8000
            initialDelaySeconds: 30
            periodSeconds: 10
---
apiVersion: v1
kind: Service
metadata:
  name: multi-agent-service
  namespace: ai-agents
spec:
  selector:
    app: multi-agent
  ports:
    - port: 80
      targetPort: 8000
  type: ClusterIP
```

---

## ✅ Validation Criteria

```yaml
validation:
  framework:
    - deployed: true
    - version: "latest"
    
  agents:
    - coordinator: "registered"
    - code_analyst: "registered"
    - infra_expert: "registered"
    - security_reviewer: "registered"
    
  team:
    - collaboration_test: "successful"
    - max_turns_respected: true
    
  memory:
    - redis_connected: true
    - context_persisted: true
    
  guardrails:
    - content_filter: "active"
    - hitl_configured: true
    
  deployment:
    - pods_running: ">= 2"
    - health_endpoint: "200 OK"
```

---

## 💬 Agent Communication

### On Success
```markdown
✅ **Multi-Agent System Deployed**

**Framework:** AutoGen v0.4

**Agent Team:** devops-agents
| Agent | Role | Model | Tools |
|-------|------|-------|-------|
| coordinator | Orchestrator | gpt-4o | delegate, synthesize |
| code_analyst | Worker | gpt-4o | github_search, code_review |
| infra_expert | Worker | gpt-4o | azure_query, terraform |
| security_reviewer | Worker | gpt-4o | ghas_alerts, defender |

**Memory:** Redis (${redis_name})

**Guardrails:**
- Content Filter: ✅ Enabled
- Max Turns: 20
- Human-in-Loop: delete, deploy-production

**Deployment:**
- Pods: 2/2 Running
- Endpoint: http://multi-agent-service.ai-agents.svc

🎉 Closing this issue.
```

---

## 🔗 Related Agents

| Agent | Relationship |
|-------|--------------|
| `ai-foundry-agent` | **Prerequisite** |
| `database-agent` | **Prerequisite** (Redis) |
| `sre-agent-setup` | **Post** |

---

**Spec Version:** 1.0.0
