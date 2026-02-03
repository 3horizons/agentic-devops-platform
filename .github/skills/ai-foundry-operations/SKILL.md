---
name: ai-foundry-operations
description: Azure AI Foundry and OpenAI operations
version: "1.0.0"
license: MIT
tools_required: ["az", "curl"]
---

## When to Use
- AI Foundry resource management
- Model deployment operations
- OpenAI API interactions
- RAG pipeline configuration

## Prerequisites
- Azure CLI authenticated
- AI Foundry workspace access
- OpenAI resource access

## Commands

### AI Foundry Resources
```bash
# List AI Foundry workspaces
az ml workspace list -o table

# Show workspace details
az ml workspace show --name <workspace> --resource-group <rg>

# List compute resources
az ml compute list --workspace-name <workspace> --resource-group <rg>
```

### OpenAI Deployments
```bash
# List Cognitive Services accounts
az cognitiveservices account list -o table

# Show OpenAI account
az cognitiveservices account show --name <account> --resource-group <rg>

# List deployments
az cognitiveservices account deployment list --name <account> --resource-group <rg> -o table

# Check quota
az cognitiveservices usage list --location eastus2 -o table
```

### Model Testing
```bash
# Test chat completion
curl -X POST "https://<endpoint>.openai.azure.com/openai/deployments/<deployment>/chat/completions?api-version=2024-02-15-preview" \
  -H "Content-Type: application/json" \
  -H "api-key: $OPENAI_API_KEY" \
  -d '{"messages":[{"role":"user","content":"Hello"}]}'
```

## Best Practices
1. Configure content safety filters
2. Implement rate limiting
3. Use managed identity for authentication
4. Monitor token usage and costs
5. Enable logging for compliance

## Output Format
1. Command executed
2. Resource status
3. Deployment details
4. Recommendations

## Integration with Agents
Used by: @ai-foundry, @mlops-pipeline
