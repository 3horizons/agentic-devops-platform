# Production Runbooks

This directory contains operational runbooks for the Three Horizons Platform.

## Runbook Index

| Runbook | Description | Priority |
|---------|-------------|----------|
| [Incident Response](incident-response.md) | Procedures for handling production incidents | P1 |
| [Emergency Procedures](emergency-procedures.md) | Critical emergency actions and escalation | P1 |
| [Deployment Runbook](deployment-runbook.md) | Manual deployment procedures | P2 |
| [Rollback Runbook](rollback-runbook.md) | Rollback procedures for failed deployments | P2 |
| [Node Replacement](node-replacement.md) | Node drain and replacement procedures | P2 |
| [Disaster Recovery](disaster-recovery.md) | DR procedures and failover | P1 |

## Runbook Structure

Each runbook follows a standard structure:

1. **Overview** - Purpose and scope
2. **Prerequisites** - Required access and tools
3. **Procedures** - Step-by-step instructions
4. **Verification** - How to verify success
5. **Escalation** - When and how to escalate
6. **References** - Related documentation

## Severity Levels

| Level | Response Time | Examples |
|-------|---------------|----------|
| **SEV1** | 15 minutes | Platform down, data loss risk |
| **SEV2** | 30 minutes | Major feature unavailable |
| **SEV3** | 4 hours | Minor feature degraded |
| **SEV4** | 24 hours | Non-critical issues |

## On-Call Procedures

1. Acknowledge alerts within response time SLA
2. Follow the appropriate runbook
3. Escalate if unable to resolve
4. Document actions in incident ticket
5. Conduct post-incident review for SEV1/SEV2

## Quick Reference

### Common Commands

```bash
# Check cluster health
kubectl get nodes
kubectl top nodes

# Check all pods
kubectl get pods -A | grep -v Running

# Check ArgoCD sync status
kubectl get applications -n argocd

# Check recent events
kubectl get events -A --sort-by='.lastTimestamp' | tail -20

# Validate deployment
./scripts/validate-deployment.sh --environment prod
```

### Important URLs

| Service | URL |
|---------|-----|
| ArgoCD | https://argocd.YOUR_DOMAIN |
| Grafana | https://grafana.YOUR_DOMAIN |
| Alertmanager | https://alertmanager.YOUR_DOMAIN |
| RHDH | https://rhdh.YOUR_DOMAIN |

### Emergency Contacts

| Role | Contact |
|------|---------|
| Platform On-Call | Check PagerDuty rotation |
| Security Team | security@YOUR_ORG |
| Cloud Ops | cloudops@YOUR_ORG |

## Maintenance Windows

- **Standard**: Sundays 00:00-04:00 UTC
- **Emergency**: As needed with stakeholder approval
- **Planned**: Scheduled 1 week in advance

## Related Documentation

- [Administrator Guide](../guides/ADMINISTRATOR_GUIDE.md)
- [Troubleshooting Guide](../guides/TROUBLESHOOTING_GUIDE.md)
- [Architecture Guide](../guides/ARCHITECTURE_GUIDE.md)

---

## 🤖 Using Copilot Agents with Runbooks

The Three Horizons platform includes **Copilot Chat Agents** that can assist you during operations. Use them alongside these runbooks for faster resolution.

| Scenario | Agent | How to Use |
|----------|-------|----------|
| Incident response & triage | `@sre` | "Help me diagnose why pods are crashing in namespace X" |
| Security incidents | `@security` | "Check RBAC misconfigurations on the AKS cluster" |
| Rollback & deployment issues | `@devops` | "Help me rollback the ArgoCD application to the previous version" |
| Infrastructure recovery | `@terraform` | "Show me the Terraform plan to recreate the networking module" |
| Log & metric analysis | `@sre` | "Query Prometheus for error rate in the last 30 minutes" |

> **Tip:** Type `@sre` in Copilot Chat as your on-call companion for any runbook. The agent will decompose your request into sub-tasks and guide you step by step.
