# Three Horizons Accelerator - Platform Services

> **Version:** 4.0.0
> **Last Updated:** December 2025
> **Audience:** Platform Engineers, Developers

## Overview

This directory contains configuration for platform-level services that run on top of the infrastructure layer.

## Structure

```text
platform/
└── rhdh/
    └── values.yaml   # Red Hat Developer Hub Helm values
```

## Red Hat Developer Hub (RHDH)

RHDH provides the Internal Developer Portal (IDP) based on Backstage. The `values.yaml` file configures:

- Authentication providers
- Catalog locations and Golden Path templates
- Plugin configuration
- TechDocs integration

## 📚 Related Documentation

| Document | Description |
|----------|-------------|
| [Architecture Guide](../docs/guides/ARCHITECTURE_GUIDE.md) | Platform architecture and RHDH role |
| [Golden Paths](../golden-paths/README.md) | Available Golden Path templates for RHDH |
| [Administrator Guide](../docs/guides/ADMINISTRATOR_GUIDE.md) | Portal administration procedures |

---

**Document Version:** 2.0.0
**Last Updated:** December 2025
**Maintainer:** Platform Engineering Team
