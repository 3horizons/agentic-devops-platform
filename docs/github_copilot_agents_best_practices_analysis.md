GitHub Copilot Agents - Best Practices Analysis

Three Horizons Accelerator v4 - Conformance Report

Date: February 03, 2026

Version: 1.0

Client: Three Horizons Platform

Team: Latam Software GBB

Author: paulasilva@microsoft.com

**Microsoft Confidential**

# Table of Contents

*\[Right-click and select \'Update Field\' to refresh Table of Contents\]*

# Executive Summary

This report provides a comprehensive analysis of the Three Horizons Accelerator v4 repository structure, comparing its GitHub Copilot agents, prompts, skills, instructions, and MCP servers configuration against industry best practices documented in GitHub\'s official guidance.

## Overall Assessment

The Three Horizons Accelerator demonstrates strong adherence to GitHub Copilot agents best practices with a well-structured implementation. The repository shows mature patterns for enterprise DevOps automation using AI-powered agents.

  -----------------------------------------------------------------------
  **Category**            **Status**              **Score**
  ----------------------- ----------------------- -----------------------
  Repository Structure    ✅ Excellent            95%

  Custom Agents           ✅ Excellent            90%

  Prompts                 ✅ Good                 85%

  Instructions            ✅ Excellent            90%

  MCP Configuration       ✅ Good                 85%

  Documentation           ✅ Excellent            95%
  -----------------------------------------------------------------------

# Repository Structure Analysis

## Expected Structure (Best Practices)

According to GitHub\'s official documentation and best practices, the recommended repository structure for Copilot agents should include:

- .github/copilot-instructions.md - Repository-wide custom instructions

- .github/instructions/\*.instructions.md - Path-scoped instructions

- .github/agents/\*.agent.md - Custom agent profiles

- .github/skills/\<skill-name\>/SKILL.md - Agent skills

- .github/prompts/\*.prompt.md - Reusable prompt files

- AGENTS.md - Optional agent playbook file

## Three Horizons Implementation

The repository follows the recommended structure with some variations:

  --------------------------------------------------------------------------------------
  **Component**              **Location**                      **Status**
  -------------------------- --------------------------------- -------------------------
  Custom Instructions        .github/copilot-instructions.md   ✅ Present

  Path-Scoped Instructions   .github/instructions/             ✅ Present (3 files)

  Custom Agents              .github/agents/                   ✅ Present (3-7 agents)

  Skills                     Referenced in agents              ⚠️ External reference

  Prompts                    .github/prompts/                  ✅ Present (3 files)

  MCP Configuration          mcp-servers/mcp-config.json       ✅ Present

  Agent Documentation        agents/                           ✅ Comprehensive
  --------------------------------------------------------------------------------------

# Custom Agents Analysis

## Agents Inventory

The repository contains specialized agents following the \'one agent, one job\' principle:

  ----------------------------------------------------------------------------------------------------
  **Agent**               **Purpose**               **Tools/Skills**
  ----------------------- ------------------------- --------------------------------------------------
  platform                Golden Paths, RHDH, IDP   rhdh-portal, helm-cli, kubectl-cli

  terraform               Azure IaC specialist      terraform-cli, azure-cli, validation-scripts

  reviewer                Code review specialist    terraform-cli, github-cli, validation-scripts

  security                Security compliance       azure-cli, kubectl-cli, terraform-cli

  sre                     Operations, SLOs          observability-stack, kubectl-cli, azure-cli

  devops                  CI/CD pipelines           terraform-cli, kubectl-cli, helm-cli, argocd-cli

  architect               Solution architecture     azure-infrastructure, terraform-cli
  ----------------------------------------------------------------------------------------------------

## Best Practice Compliance

### Strengths Identified

- Single responsibility: Each agent has a clear, focused purpose

- Skills integration: Agents reference specific skills for capabilities

- Documentation: Rich documentation within each agent file

- Commands section: Explicit validation commands included

- Output format: Clear output expectations defined

- Domain knowledge: Comprehensive project-specific context

### Improvement Opportunities

- YAML frontmatter: Missing \'tools\' array specification in standard format

- Missing \'infer\' property: Not specifying auto-selection behavior

- Three-tier boundaries: Partially implemented (should use ✅ ALWAYS / ⚠️ ASK FIRST / 🚫 NEVER format consistently)

- Handoffs configuration: No explicit handoffs between agents defined

# Custom Instructions Analysis

## Repository-Wide Instructions

The .github/copilot-instructions.md file serves as the \'factory floor rules\' that apply to all Copilot interactions in the repository.

### Content Analysis

  ----------------------------------------------------------------------------
  **Section**             **Best Practice**            **Implementation**
  ----------------------- ---------------------------- -----------------------
  Project Identity        Tech stack, structure        ✅ Comprehensive

  Commands                Build/test/lint with flags   ✅ Present

  Boundaries              What not to modify           ⚠️ Present but brief

  Naming Conventions      Resource naming patterns     ✅ Well-documented

  File Locations          Component directories        ✅ Clear mapping

  Security Requirements   Auth, secrets, scanning      ✅ Comprehensive
  ----------------------------------------------------------------------------

## Path-Scoped Instructions

The repository includes path-scoped instructions for specific file types:

- terraform.instructions.md - Applies to \*.tf, \*\*/terraform/\*\*, \*.tfvars

- kubernetes.instructions.md - Applies to \*.yaml, \*.yml, \*\*/kubernetes/\*\*

- python.instructions.md - Python coding standards

### Excellent Practices Found

- Uses applyTo frontmatter with glob patterns

- Includes complete code templates

- Security requirements clearly stated

- Validation commands documented

- Consistent with overall project standards

# Prompts Analysis

## Prompt Files Inventory

  ------------------------------------------------------------------------------
  **Prompt**                 **Purpose**                 **Mode**
  -------------------------- --------------------------- -----------------------
  create-service.prompt.md   Scaffold new microservice   agent

  generate-tests.prompt.md   Create test suites          agent

  review-code.prompt.md      Code review automation      agent
  ------------------------------------------------------------------------------

## Best Practice Compliance

### Strengths

- Proper YAML frontmatter with name, description, mode

- Clear input requirements (what to ask user)

- Step-by-step procedures

- Code templates and examples

- Output format specification

- Multi-language support (Python, Go)

### Improvement Opportunities

- Missing \'tools\' specification in frontmatter

- No explicit scope/boundary definitions

- Could benefit from acceptance criteria checklists

- Missing non-goals/out-of-scope sections

# MCP Servers Configuration Analysis

## Configured MCP Servers

The repository has a comprehensive MCP configuration in mcp-servers/mcp-config.json:

  -----------------------------------------------------------------------------------------
  **Server**              **Purpose**             **Capabilities**
  ----------------------- ----------------------- -----------------------------------------
  azure                   Azure CLI operations    az aks, az acr, az keyvault, az network

  github                  GitHub API operations   gh repo, gh secret, gh workflow, gh pr

  terraform               Terraform operations    init, plan, apply, state

  kubernetes              K8s cluster ops         kubectl get, apply, delete, logs

  Kubernetes clusters            oc login, oc project, oc new-app

  helm                    Helm chart ops          install, upgrade, uninstall, repo

  docker                  Container ops           build, push, pull, run

  defender                Security scanning       az security assessment, alerts

  entra                   Azure AD ops            az ad app, sp, group, user
  -----------------------------------------------------------------------------------------

## Best Practice Compliance

### Strengths

- Well-organized server definitions

- Environment variables for secrets (not hardcoded)

- Capabilities clearly defined per server

- Comprehensive Azure and DevOps coverage

- Good separation of concerns (different servers for different tools)

### Improvement Opportunities

- Consider using \'tools\' whitelist for more restrictive access

- Add \'readonly\' variants for discovery/planning agents

- Document which agents can use which MCP servers

- Consider adding rate limiting or approval flows for destructive operations

# Recommendations

## High Priority

> 1\. Add \'tools\' array to agent frontmatter: Specify exactly which tools each agent can use (read, search, edit, execute)
>
> 2\. Implement three-tier boundaries consistently: Use ✅ ALWAYS / ⚠️ ASK FIRST / 🚫 NEVER format in all agents
>
> 3\. Add \'infer: false\' to specialized agents: Prevent auto-selection of agents that should be explicitly invoked
>
> 4\. Create SKILL.md files: Move reusable procedures from agents to dedicated skill folders

## Medium Priority

> 1\. Add handoffs configuration: Define agent-to-agent handoffs for multi-step workflows (planner → implementer → tester)
>
> 2\. Create AGENTS.md at root: Consolidate agent playbook for project-wide visibility
>
> 3\. Add acceptance criteria to prompts: Include explicit success/failure conditions
>
> 4\. Document MCP server usage per agent: Map which agents can use which MCP servers

## Low Priority

> 1\. Add model specification: Consider specifying preferred models for different agents
>
> 2\. Create read-only agent variants: For planning and research tasks
>
> 3\. Add copilot-setup-steps.yml: Pre-install dependencies for Coding Agent
>
> 4\. Implement Mission Control governance: Document parallel task guidelines

# Conformance Checklist

## Repository Structure

- ✅ .github/copilot-instructions.md present and comprehensive

- ✅ .github/instructions/ with path-scoped rules

- ✅ .github/agents/ with specialized agents

- ✅ .github/prompts/ with reusable prompts

- ✅ MCP configuration with Azure/DevOps coverage

- ⚠️ Skills defined externally (not in .github/skills/)

## Agent Design

- ✅ Single responsibility per agent

- ✅ Domain knowledge documented

- ✅ Commands section with validation

- ✅ Output format specified

- ⚠️ Tools array not in standard format

- ⚠️ Three-tier boundaries partially implemented

- ❌ Handoffs not configured

## Instructions Quality

- ✅ Project identity and tech stack

- ✅ Build/test/lint commands

- ✅ Security requirements

- ✅ Naming conventions

- ✅ Path-scoped rules with applyTo

- ✅ Code templates and examples

## Security & Governance

- ✅ No hardcoded secrets in MCP config

- ✅ Environment variables for credentials

- ✅ Security scanning mentioned

- ⚠️ Explicit consent for destructive ops could be stronger

- ⚠️ Agent access control not documented

# Conclusion

The Three Horizons Accelerator v4 demonstrates excellent alignment with GitHub Copilot agents best practices. The implementation shows mature DevOps patterns with comprehensive Azure and Kubernetes coverage. The agent specialization follows the recommended \'one agent, one job\' pattern, and the documentation quality is high.

Key strengths include the comprehensive MCP server configuration, well-documented path-scoped instructions, and rich agent capabilities. The main areas for improvement are standardizing the agent frontmatter format, implementing explicit tool restrictions, and adding agent handoffs for complex workflows.

Overall conformance score: 88% - representing an enterprise-grade implementation that follows industry best practices with minor refinements recommended.

Source: GitHub Copilot Best Practices (https://docs.github.com/en/copilot/get-started/best-practices)

Source: Custom Agents Documentation (https://docs.github.com/en/copilot/how-tos/use-copilot-agents/coding-agent/create-custom-agents)

Source: Agent Skills Documentation (https://docs.github.com/en/copilot/concepts/agents/about-agent-skills)
