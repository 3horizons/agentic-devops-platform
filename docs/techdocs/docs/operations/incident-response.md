# Incident Response

This document defines the incident response process for the Three Horizons platform, including SLO definitions, severity classification, escalation procedures, communication templates, and post-incident review practices.

---

## Service Level Objectives (SLOs)

SLOs define the reliability targets for platform services. Prometheus recording rules calculate real-time SLO compliance, and alerting rules fire when burn rates indicate risk of breaching targets.

| Service | SLI | Target | Window |
| ------- | --- | ------ | ------ |
| RHDH Portal | Availability (HTTP 2xx/3xx) | 99.9% | 30 days |
| RHDH Portal | Latency (p99 < 2s) | 99.5% | 30 days |
| ArgoCD | Sync success rate | 99.5% | 30 days |
| API Services | Availability | 99.9% | 30 days |
| API Services | Latency (p99 < 500ms) | 99.0% | 30 days |
| AKS Cluster | Node availability | 99.95% | 30 days |
| Developer Lightspeed | Chat response time (< 10s) | 99.0% | 30 days |

### Error Budget

Each SLO has an associated error budget calculated over a 30-day rolling window:

```text
Error Budget = 1 - SLO Target

Examples:
  99.9% availability = 0.1% error budget = ~43 minutes of downtime per 30 days
  99.5% availability = 0.5% error budget = ~3.6 hours of downtime per 30 days
  99.0% availability = 1.0% error budget = ~7.2 hours of downtime per 30 days
```

When error budget is exhausted:

- Freeze non-critical deployments
- Prioritize reliability improvements
- Conduct error budget review with stakeholders

### Burn Rate Alerting

SLO alerts use multi-window burn rate detection to balance speed and accuracy:

| Window | Burn Rate | Budget Consumed | Action | Severity |
| ------ | --------- | --------------- | ------ | -------- |
| 5 minutes | 14.4x | 2% in 2 hours | Page on-call immediately | Critical |
| 1 hour | 6x | 5% in 5 hours | Page on-call | Critical |
| 24 hours | 3x | 10% in 10 hours | Create ticket, investigate | Warning |
| 30 days | 1x | 100% in 30 days | Review in next planning cycle | Info |

```yaml
# Example: 5-minute fast burn rate alert
- alert: SLOBurnRateFast
  expr: |
    (
      sum(rate(http_requests_total{code=~"5.."}[5m]))
      /
      sum(rate(http_requests_total[5m]))
    ) > (14.4 * (1 - 0.999))
  for: 2m
  labels:
    severity: critical
    slo: availability
  annotations:
    summary: "Fast SLO burn rate detected"
    description: "At this rate, the 30-day error budget will be exhausted in 2 hours."
```

---

## Severity Classification

| Severity | Definition | Response Time | Update Frequency | Examples |
| -------- | ---------- | ------------- | ---------------- | -------- |
| **SEV-1** | Platform-wide outage or data loss | 15 minutes | Every 15 min | AKS cluster down, RHDH inaccessible, data corruption |
| **SEV-2** | Degraded service for multiple teams | 30 minutes | Every 30 min | High error rates, ArgoCD sync failures, database latency |
| **SEV-3** | Single team or service impacted | 2 hours | Every 2 hours | One application down, build failures, single pod crash loop |
| **SEV-4** | Minor issue, no user impact | Next business day | Daily | Dashboard errors, documentation bugs, non-critical warnings |

### Severity Decision Tree

```text
Is the platform completely unavailable?
  YES --> SEV-1
  NO  --> Are multiple teams affected?
            YES --> Is data integrity at risk?
                      YES --> SEV-1
                      NO  --> SEV-2
            NO  --> Is a single team blocked from deploying?
                      YES --> SEV-3
                      NO  --> SEV-4
```

---

## On-Call Rotation

The Platform Engineering team maintains a weekly on-call rotation with primary and secondary responders.

### On-Call Responsibilities

- **Primary on-call**: First responder for all platform alerts
- **Secondary on-call**: Backup if primary does not acknowledge within SLA
- **Incident Commander**: Assigned for SEV-1 and SEV-2 incidents (typically a senior engineer or team lead)

### On-Call Schedule

- Rotation: Weekly, Monday 09:00 UTC to Monday 09:00 UTC
- Managed via PagerDuty with automatic escalation
- Handoff meeting: Monday morning with outgoing and incoming on-call

### On-Call Tools

| Tool | Purpose | Access |
| ---- | ------- | ------ |
| PagerDuty | Alert routing and escalation | Platform team members |
| Slack `#platform-incidents` | Incident communication | All engineers |
| Grafana | Dashboard investigation | SSO via Azure AD |
| Prometheus | Metric queries | Port-forward or ingress |
| Jaeger | Distributed trace analysis | Port-forward or ingress |
| Azure Portal | Infrastructure investigation | Azure AD RBAC |
| `@sre` Copilot Agent | Automated analysis and runbook suggestions | GitHub Copilot |

---

## Escalation Procedure

### Step-by-Step Process

1. **Alert fires** -- Alertmanager routes the alert to the on-call engineer via PagerDuty and Slack
2. **Acknowledge** -- On-call acknowledges within the response time for the severity level
3. **Triage** -- Determine severity, affected services, and blast radius
4. **Communicate** -- Post initial status update in `#platform-incidents` Slack channel
5. **Mitigate** -- Apply the appropriate runbook or manual intervention
6. **Escalate if needed**:
   - Infrastructure issues: Escalate to `@infra-team`
   - Security incidents: Escalate to `@security-team`
   - Application issues: Escalate to the owning team
   - Azure platform issues: Open Microsoft support case (Severity A for SEV-1)
   - AI/Lightspeed issues: Escalate to `@ai-team`
7. **Resolve** -- Confirm the issue is resolved and SLO burn rate is recovering
8. **Post-incident** -- Schedule a blameless post-incident review within 48 hours

### Escalation Matrix

| Issue Domain | Primary Team | Escalation Path | Azure Support |
| ------------ | ------------ | --------------- | ------------- |
| AKS cluster | `@infra-team` | Platform Lead, Azure Support | Severity A |
| Networking/VNet | `@infra-team` | Network Engineer, Azure Support | Severity B |
| RHDH portal | `@platform-team` | Platform Lead | Severity B |
| ArgoCD/GitOps | `@devops-team` | DevOps Lead | N/A |
| Database (PostgreSQL/Redis) | `@infra-team` | DBA, Azure Support | Severity A |
| Security breach | `@security-team` | CISO, Legal | Severity A |
| AI/Lightspeed | `@ai-team` | AI Lead, Azure Support | Severity B |
| CI/CD pipelines | `@devops-team` | DevOps Lead | N/A |

---

## Incident Communication

### Communication Channels

| Channel | Purpose | Audience |
| ------- | ------- | -------- |
| `#platform-incidents` | Real-time incident updates | All engineers |
| `#platform-alerts` | Automated alert notifications | On-call and platform team |
| PagerDuty | On-call paging and escalation | On-call engineers |
| Email | SEV-1 executive notifications | Leadership |
| Status page | External status communication | All users |

### Initial Status Update Template

Post this to `#platform-incidents` within 5 minutes of acknowledging an incident:

```text
[SEV-X] <Service Name> -- <Brief Description>

Impact: <Who is affected and how>
Status: Investigating
Start time: <YYYY-MM-DD HH:MM UTC>
On-call: <Name>
Next update: <ETA, typically 15-30 min>
```

### Ongoing Update Template

```text
[SEV-X] <Service Name> -- UPDATE #N

Status: Investigating / Mitigating / Monitoring
What we know: <Brief summary of findings>
Actions taken: <What has been done>
Next steps: <What will be done next>
Next update: <ETA>
```

### Resolution Template

```text
[SEV-X] <Service Name> -- RESOLVED

Resolution: <What fixed the issue>
Duration: <Start time to resolution time>
Impact: <Summary of user impact>
Follow-up: Post-incident review scheduled for <date/time>
```

---

## MTTR Tracking

Mean Time to Resolve (MTTR) is tracked for all incidents and broken down by phase:

| Metric | Definition | Target (SEV-1) | Target (SEV-2) |
| ------ | ---------- | --------------- | --------------- |
| Time to Detect (TTD) | Alert fire to acknowledgment | < 5 min | < 15 min |
| Time to Triage (TTT) | Acknowledgment to severity classification | < 10 min | < 15 min |
| Time to Mitigate (TTM) | Triage to impact reduction | < 30 min | < 1 hour |
| Time to Resolve (TTR) | Mitigation to full resolution | < 2 hours | < 4 hours |
| Total MTTR | Detection to resolution | < 2.75 hours | < 5.5 hours |

MTTR metrics are collected by the Engineering Intelligence pipeline and displayed on the DORA metrics dashboard in RHDH.

```bash
# Collect DORA metrics including MTTR
./scripts/engineering-intelligence/collect-github-metrics.sh
```

---

## Post-Incident Review (PIR)

All SEV-1 and SEV-2 incidents require a blameless post-incident review within 48 hours. SEV-3 incidents are reviewed at the team's discretion.

### PIR Process

1. **Schedule** -- Within 24 hours of resolution, schedule a 60-minute review meeting
2. **Prepare timeline** -- Incident Commander prepares a detailed timeline from alert to resolution
3. **Conduct review** -- Walk through the timeline, focusing on:
   - What happened (factual timeline)
   - What went well (effective response actions)
   - What could be improved (process gaps)
   - Root cause analysis (not symptoms)
   - Contributing factors (what made detection or resolution harder)
4. **Identify action items** -- Concrete improvements with owners and deadlines
5. **Document** -- Write the PIR document and store in the repository
6. **Follow up** -- Track action items to completion

### PIR Document Template

```markdown
## Post-Incident Review: [SEV-X] <Title>

**Date**: YYYY-MM-DD
**Duration**: X hours Y minutes
**Severity**: SEV-X
**Incident Commander**: <Name>

### Timeline

| Time (UTC) | Event |
| ---------- | ----- |
| HH:MM | Alert fired: <alert name> |
| HH:MM | On-call acknowledged |
| HH:MM | Severity classified as SEV-X |
| HH:MM | Root cause identified |
| HH:MM | Mitigation applied |
| HH:MM | Resolved, monitoring |

### Root Cause

<Description of the underlying cause>

### Contributing Factors

- <Factor 1>
- <Factor 2>

### What Went Well

- <Positive action 1>
- <Positive action 2>

### Action Items

| Action | Owner | Deadline | Status |
| ------ | ----- | -------- | ------ |
| <Action 1> | <Name> | YYYY-MM-DD | Open |
| <Action 2> | <Name> | YYYY-MM-DD | Open |
```

### Common PIR Action Item Categories

- **Monitoring**: Add missing alerts, improve alert thresholds
- **Runbooks**: Create or update runbooks for the failure scenario
- **Automation**: Automate manual mitigation steps
- **Architecture**: Improve resilience (redundancy, circuit breakers, retries)
- **Testing**: Add chaos engineering tests, load tests
- **Documentation**: Update operations documentation

---

## Copilot Agent Support

Use the `@sre` Copilot agent for incident assistance:

```text
@sre Create runbook for database connection timeout
@sre Analyze alert HighErrorRate for order-service
@sre Check SLO burn rate for RHDH portal
@sre What is the current error budget for API services?
@sre Generate a post-incident timeline for the last SEV-1
```

Use the `troubleshoot-incident` reusable prompt for structured investigation:

```text
/troubleshoot-incident
```

---

## Runbook References

See the [Runbooks](runbooks.md) page for step-by-step guides covering:

- AKS cluster operations
- ArgoCD sync issue resolution
- Database maintenance
- Certificate renewal
- Disaster recovery procedures
- Common alert response procedures
