# Agent Router (Orchestrator)

## 🤖 Overview

The Agent Router is the orchestration layer that:
1. **Monitors** GitHub Issues for agent labels
2. **Routes** issues to appropriate agents
3. **Orchestrates** multi-agent workflows
4. **Tracks** execution state and dependencies
5. **Handles** failures and escalations

---

## 🔀 Routing Rules

```yaml
# Agent Routing Configuration
routing:
  # Label → Agent mapping
  agent_mapping:
    "agent:infrastructure": "h1-foundation/infrastructure-agent"
    "agent:networking": "h1-foundation/networking-agent"
    "agent:security": "h1-foundation/security-agent"
    "agent:gitops": "h2-enhancement/gitops-agent"
    "agent:golden-paths": "h2-enhancement/golden-paths-agent"
    "agent:observability": "h2-enhancement/observability-agent"
    "agent:rhdh": "h2-enhancement/rhdh-portal-agent"
    "agent:ai-foundry": "h3-innovation/ai-foundry-agent"
    "agent:migration": "cross-cutting/migration-agent"
    "agent:validation": "cross-cutting/validation-agent"
    "agent:rollback": "cross-cutting/rollback-agent"
    
  # Priority routing
  priority_order:
    - "priority:critical"  # Immediate
    - "priority:high"      # Next in queue
    - "priority:normal"    # Standard queue
    
  # Environment-based approval
  environment_policies:
    dev:
      auto_execute: true
      require_approval: false
      
    staging:
      auto_execute: true
      require_approval: true
      approvers: ["platform-team"]
      
    prod:
      auto_execute: false
      require_approval: true
      approvers: ["platform-leads", "security-team"]
      manual_agents: ["infrastructure-agent", "gitops-agent"]
```

---

## 🔄 Workflow Orchestration

### Full Platform Deployment

```yaml
# Orchestrated deployment workflow
workflow:
  name: "Full Three Horizons Deployment"
  trigger:
    issue_labels: ["workflow:full-deployment"]
    
  stages:
    # Stage 1: H1 Foundation (Parallel where possible)
    - name: "H1-Foundation"
      agents:
        - agent: "infrastructure-agent"
          action: "create"
          wait_for: null
          
        - agent: "networking-agent"
          action: "configure"
          wait_for: "infrastructure-agent"
          
        - agent: "security-agent"
          action: "configure"
          wait_for: "infrastructure-agent"
          
    # Stage 2: H2 Enhancement (After H1 complete)
    - name: "H2-Enhancement"
      wait_for: "H1-Foundation"
      agents:
        - agent: "gitops-agent"
          action: "install"
          wait_for: null
          
        - agent: "observability-agent"
          action: "install"
          wait_for: "gitops-agent"
          
        - agent: "golden-paths-agent"
          action: "register"
          wait_for: "gitops-agent"
          
        - agent: "rhdh-portal-agent"
          action: "install"
          wait_for: "gitops-agent"
          
    # Stage 3: H3 Innovation (After H2 complete)
    - name: "H3-Innovation"
      wait_for: "H2-Enhancement"
      agents:
        - agent: "ai-foundry-agent"
          action: "setup"
          wait_for: null
          
    # Stage 4: Validation (Always last)
    - name: "Validation"
      wait_for: "H3-Innovation"
      agents:
        - agent: "validation-agent"
          action: "full-audit"
          
  on_failure:
    - notify: ["platform-team"]
    - action: "pause"
    - create_issue: "Deployment failure - manual intervention required"
```

### Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                            FULL DEPLOYMENT WORKFLOW                          │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STAGE 1: H1 FOUNDATION                                                      │
│                                                                              │
│  ┌──────────────────┐                                                       │
│  │ Infrastructure   │                                                       │
│  │ Agent            │─────┬─────────────────────────┐                      │
│  └──────────────────┘     │                         │                      │
│                           ▼                         ▼                      │
│                 ┌──────────────────┐     ┌──────────────────┐              │
│                 │ Networking       │     │ Security         │              │
│                 │ Agent            │     │ Agent            │              │
│                 └──────────────────┘     └──────────────────┘              │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STAGE 2: H2 ENHANCEMENT                                                     │
│                                                                              │
│  ┌──────────────────┐                                                       │
│  │ GitOps           │─────┬─────────────────┬─────────────────┐            │
│  │ Agent            │     │                 │                 │            │
│  └──────────────────┘     ▼                 ▼                 ▼            │
│                 ┌──────────────┐   ┌──────────────┐   ┌──────────────┐     │
│                 │ Observability│   │ Golden Paths │   │ RHDH Portal  │     │
│                 │ Agent        │   │ Agent        │   │ Agent        │     │
│                 └──────────────┘   └──────────────┘   └──────────────┘     │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STAGE 3: H3 INNOVATION                                                      │
│                                                                              │
│                         ┌──────────────────┐                                │
│                         │ AI Foundry       │                                │
│                         │ Agent            │                                │
│                         └──────────────────┘                                │
└─────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────┐
│  STAGE 4: VALIDATION                                                         │
│                                                                              │
│                         ┌──────────────────┐                                │
│                         │ Validation       │                                │
│                         │ Agent            │                                │
│                         └──────────────────┘                                │
└─────────────────────────────────────────────────────────────────────────────┘
```

---

## 📋 GitHub Workflow for Agent Routing

```yaml
# .github/workflows/agent-router.yml
name: Agent Router

on:
  issues:
    types: [opened, labeled]

jobs:
  route-to-agent:
    runs-on: ubuntu-latest
    if: contains(github.event.issue.labels.*.name, 'agent:')
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Identify Agent
        id: identify
        run: |
          # Extract agent label
          AGENT_LABEL=$(echo '${{ toJson(github.event.issue.labels) }}' | \
            jq -r '.[] | select(.name | startswith("agent:")) | .name' | head -1)
          
          # Map to agent spec
          case $AGENT_LABEL in
            "agent:infrastructure") AGENT="h1-foundation/infrastructure-agent" ;;
            "agent:networking") AGENT="h1-foundation/networking-agent" ;;
            "agent:security") AGENT="h1-foundation/security-agent" ;;
            "agent:gitops") AGENT="h2-enhancement/gitops-agent" ;;
            "agent:golden-paths") AGENT="h2-enhancement/golden-paths-agent" ;;
            "agent:observability") AGENT="h2-enhancement/observability-agent" ;;
            "agent:rhdh") AGENT="h2-enhancement/rhdh-portal-agent" ;;
            "agent:ai-foundry") AGENT="h3-innovation/ai-foundry-agent" ;;
            "agent:migration") AGENT="cross-cutting/migration-agent" ;;
            "agent:validation") AGENT="cross-cutting/validation-agent" ;;
            *) AGENT="unknown" ;;
          esac
          
          echo "agent=$AGENT" >> $GITHUB_OUTPUT
          echo "label=$AGENT_LABEL" >> $GITHUB_OUTPUT
          
      - name: Check Environment Policy
        id: policy
        run: |
          # Extract environment label
          ENV_LABEL=$(echo '${{ toJson(github.event.issue.labels) }}' | \
            jq -r '.[] | select(.name | startswith("env:")) | .name' | head -1)
          
          case $ENV_LABEL in
            "env:dev")
              echo "auto_execute=true" >> $GITHUB_OUTPUT
              echo "require_approval=false" >> $GITHUB_OUTPUT
              ;;
            "env:staging")
              echo "auto_execute=true" >> $GITHUB_OUTPUT
              echo "require_approval=true" >> $GITHUB_OUTPUT
              ;;
            "env:prod")
              echo "auto_execute=false" >> $GITHUB_OUTPUT
              echo "require_approval=true" >> $GITHUB_OUTPUT
              ;;
            *)
              echo "auto_execute=false" >> $GITHUB_OUTPUT
              echo "require_approval=true" >> $GITHUB_OUTPUT
              ;;
          esac
          
      - name: Add Initial Comment
        uses: actions/github-script@v7
        with:
          script: |
            const agent = '${{ steps.identify.outputs.agent }}';
            const body = `👋 **Agent Router**
            
            I've identified this issue for **${agent}**.
            
            **Status:** 🔄 Preparing agent execution...
            
            **Policy:**
            - Auto-execute: ${{ steps.policy.outputs.auto_execute }}
            - Require approval: ${{ steps.policy.outputs.require_approval }}
            `;
            
            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: body
            });
            
      - name: Request Approval (if needed)
        if: steps.policy.outputs.require_approval == 'true'
        uses: trstringer/manual-approval@v1
        with:
          secret: ${{ secrets.GITHUB_TOKEN }}
          approvers: platform-team
          minimum-approvals: 1
          issue-title: "Approval needed: ${{ github.event.issue.title }}"
          
      - name: Load Agent Spec
        id: load-spec
        run: |
          AGENT_PATH="accelerator-agents/agents/${{ steps.identify.outputs.agent }}.md"
          if [ -f "$AGENT_PATH" ]; then
            echo "spec_found=true" >> $GITHUB_OUTPUT
          else
            echo "spec_found=false" >> $GITHUB_OUTPUT
          fi
          
      - name: Trigger Copilot Coding Agent
        if: steps.policy.outputs.auto_execute == 'true'
        uses: actions/github-script@v7
        with:
          script: |
            // Assign to Copilot Coding Agent
            // This triggers the agent to pick up the issue
            await github.rest.issues.update({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              labels: [...context.payload.issue.labels.map(l => l.name), 'agent:executing'],
              assignees: ['copilot-swe-agent']  // Or your agent assignee
            });
            
            // Add execution comment
            await github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `🚀 **Agent Execution Started**
              
              Agent: **${{ steps.identify.outputs.agent }}**
              
              The agent is now processing this request. Updates will be posted here.`
            });

  # Workflow orchestration job
  orchestrate-workflow:
    runs-on: ubuntu-latest
    if: contains(github.event.issue.labels.*.name, 'workflow:')
    
    steps:
      - name: Checkout
        uses: actions/checkout@v4
        
      - name: Identify Workflow
        id: workflow
        run: |
          WORKFLOW_LABEL=$(echo '${{ toJson(github.event.issue.labels) }}' | \
            jq -r '.[] | select(.name | startswith("workflow:")) | .name' | head -1)
          echo "workflow=${WORKFLOW_LABEL#workflow:}" >> $GITHUB_OUTPUT
          
      - name: Create Stage Issues
        uses: actions/github-script@v7
        with:
          script: |
            const workflow = '${{ steps.workflow.outputs.workflow }}';
            const parentIssue = context.issue.number;
            
            // Define workflow stages
            const workflows = {
              'full-deployment': [
                { stage: 'H1', agent: 'infrastructure', title: '[H1] Infrastructure Setup', deps: [] },
                { stage: 'H1', agent: 'security', title: '[H1] Security Configuration', deps: ['infrastructure'] },
                { stage: 'H2', agent: 'gitops', title: '[H2] GitOps Setup', deps: ['infrastructure'] },
                { stage: 'H2', agent: 'observability', title: '[H2] Observability Stack', deps: ['gitops'] },
                { stage: 'H2', agent: 'golden-paths', title: '[H2] Register Golden Paths', deps: ['gitops'] },
                { stage: 'H3', agent: 'ai-foundry', title: '[H3] AI Foundry Setup', deps: ['gitops'] },
                { stage: 'Validation', agent: 'validation', title: '[Validation] Platform Audit', deps: ['ai-foundry'] }
              ],
              'h1-only': [
                { stage: 'H1', agent: 'infrastructure', title: '[H1] Infrastructure Setup', deps: [] },
                { stage: 'H1', agent: 'security', title: '[H1] Security Configuration', deps: ['infrastructure'] },
                { stage: 'Validation', agent: 'validation', title: '[Validation] H1 Validation', deps: ['security'] }
              ]
            };
            
            const stages = workflows[workflow] || [];
            
            for (const stage of stages) {
              const body = `## Auto-generated from workflow issue #${parentIssue}
              
              **Stage:** ${stage.stage}
              **Dependencies:** ${stage.deps.length > 0 ? stage.deps.join(', ') : 'None'}
              
              ---
              
              _This issue was created by the Agent Router workflow._`;
              
              await github.rest.issues.create({
                owner: context.repo.owner,
                repo: context.repo.repo,
                title: stage.title,
                body: body,
                labels: [`agent:${stage.agent}`, 'workflow:auto-created']
              });
            }
            
            // Comment on parent issue
            await github.rest.issues.createComment({
              issue_number: parentIssue,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `📋 **Workflow Orchestration**
              
              Created ${stages.length} stage issues for **${workflow}** workflow.
              
              Progress will be tracked here.`
            });
```

---

## 📊 Execution Tracking

### GitHub Project Board

```yaml
# Project board configuration
project:
  name: "Accelerator Agent Execution"
  
  columns:
    - name: "Backlog"
      automation:
        - issues_with_label: "agent:*"
        - not_assigned: true
        
    - name: "Queued"
      automation:
        - assigned_to: "copilot-swe-agent"
        - not_labeled: "agent:executing"
        
    - name: "Executing"
      automation:
        - labeled: "agent:executing"
        
    - name: "Awaiting Approval"
      automation:
        - labeled: "agent:awaiting-approval"
        
    - name: "Validating"
      automation:
        - labeled: "agent:validating"
        
    - name: "Done"
      automation:
        - issue_state: "closed"
        - labeled: "agent:completed"
        
    - name: "Failed"
      automation:
        - labeled: "agent:failed"
```

---

## 🔔 Notifications

```yaml
# Notification configuration
notifications:
  teams:
    webhook_url: "${TEAMS_WEBHOOK}"
    events:
      - agent_started
      - agent_completed
      - agent_failed
      - approval_required
      
  templates:
    agent_started: |
      🚀 **Agent Started**
      
      **Issue:** #${issue_number} - ${issue_title}
      **Agent:** ${agent_name}
      **Triggered by:** ${actor}
      
    agent_completed: |
      ✅ **Agent Completed**
      
      **Issue:** #${issue_number} - ${issue_title}
      **Agent:** ${agent_name}
      **Duration:** ${duration}
      
    agent_failed: |
      ❌ **Agent Failed**
      
      **Issue:** #${issue_number} - ${issue_title}
      **Agent:** ${agent_name}
      **Error:** ${error_message}
      
      [View Issue](${issue_url})
```

---

## 📚 Agent Catalog Summary

| Agent | Horizon | Primary Action | Trigger Label |
|-------|---------|----------------|---------------|
| Infrastructure Agent | H1 | Create Azure resources | `agent:infrastructure` |
| Networking Agent | H1 | Configure networking | `agent:networking` |
| Security Agent | H1 | Security hardening | `agent:security` |
| GitOps Agent | H2 | Install ArgoCD | `agent:gitops` |
| Golden Paths Agent | H2 | Manage templates | `agent:golden-paths` |
| Observability Agent | H2 | Install monitoring | `agent:observability` |
| RHDH Portal Agent | H2 | Install RHDH | `agent:rhdh` |
| AI Foundry Agent | H3 | Setup AI platform | `agent:ai-foundry` |
| Migration Agent | Cross | ADO → GitHub | `agent:migration` |
| Validation Agent | Cross | Platform validation | `agent:validation` |
| Rollback Agent | Cross | Rollback deployments | `agent:rollback` |

---

**Spec Version:** 1.0.0  
**Last Updated:** December 2024
