Red Hat Developer Hub 1.8

About Red Hat Developer Hub

Red Hat Developer Hub is a customizable developer portal with enterprise-level
support and a centralized software catalog that you can use to build high-quality
software efficiently in a streamlined development environment

Last Updated: 2026-02-18

Red Hat Developer Hub 1.8 About Red Hat Developer Hub

Red Hat Developer Hub is a customizable developer portal with enterprise-level support and a
centralized software catalog that you can use to build high-quality software efficiently in a
streamlined development environment

Legal Notice

Copyright © Red Hat.

Except as otherwise noted below, the text of and illustrations in this documentation are licensed by
Red Hat under the Creative Commons Attribution–Share Alike 3.0 Unported license . If you
distribute this document or an adaptation of it, you must provide the URL for the original version.

Red Hat, as the licensor of this document, waives the right to enforce, and agrees not to assert,
Section 4d of CC-BY-SA to the fullest extent permitted by applicable law.

Red Hat, the Red Hat logo, JBoss, Hibernate, and RHCE are trademarks or registered trademarks of
Red Hat, LLC. or its subsidiaries in the United States and other countries.

Linux ® is the registered trademark of Linus Torvalds in the United States and other countries.

XFS is a trademark or registered trademark of Hewlett Packard Enterprise Development LP or its
subsidiaries in the United States and other countries.

The OpenStack ® Word Mark and OpenStack logo are trademarks or registered trademarks of the
Linux Foundation, used under license.

All other trademarks are the property of their respective owners.

Abstract

Red Hat Developer Hub (RHDH) is a customizable developer portal with enterprise-level support
and a centralized software catalog that you can use to build high-quality software efficiently in a
streamlined development environment.

Table of Contents

Table of Contents

PREFACE
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

3

CHAPTER 1. UNDERSTANDING INTERNAL DEVELOPER PLATFORMS
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

4

CHAPTER 2. SYSTEM ARCHITECTURE FOR DEPLOYMENT PLANNING
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

6

CHAPTER 3. ACHIEVE HIGH AVAILABILITY WITH DATABASE AND CACHE LAYERS
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

9

CHAPTER 4. INTEGRATIONS IN RED HAT DEVELOPER HUB
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

11

4.1. INTEGRATION WITH RED HAT OPENSHIFT CONTAINER PLATFORM

4.2. INTEGRATION WITH RED HAT ADVANCED DEVELOPER SUITE - SECURE SUPPLY CHAIN
4.3. EXTENDING BACKSTAGE WITH RED HAT DEVELOPER HUB

11

11
11

CHAPTER 5. SUPPORTED PLATFORMS
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

12

CHAPTER 6. SIZING REQUIREMENTS FOR RED HAT DEVELOPER HUB
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

13

CHAPTER 7. RED HAT DEVELOPER HUB SUPPORT
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

14

1

Red Hat Developer Hub 1.8 About Red Hat Developer Hub

2

PREFACE

PREFACE

Red Hat Developer Hub (RHDH) is an enterprise-grade internal developer portal (IDP) that helps
simplify and accelerates software delivery. It provides a customizable web-based interface that
centralizes access to key development resources, including source code repositories, CI and CD
pipelines, APIs, documentation, and runtime environments.

Red Hat Developer Hub is designed for cloud-native environments, including supported Kubernetes
platforms, Red Hat OpenShift Container Platform, and hybrid infrastructure. By consolidating tools and
standardizing development workflows, it helps teams deliver software faster with more consistency.

Designed for enterprise-scale software teams, RHDH helps developers focus on building software
rather than managing tools. Developers can onboard quickly, create environments, and integrate with
existing systems. With enterprise-grade security, role-based access control, and 24x7 support, teams
stay productive while meeting compliance and reliability standards.

3

Red Hat Developer Hub 1.8 About Red Hat Developer Hub

CHAPTER 1. UNDERSTANDING INTERNAL DEVELOPER
PLATFORMS

An internal developer platform (IDP) is a curated set of tools and services that supports developer self-
service. Instead of navigating multiple systems, developers use a unified interface to provision
environments, deploy code, and access APIs.

Why IDPs matter

IDPs address the challenges of modern software delivery by enabling self-service, enforcing
standards, and improving the developer experience.

For organizations

Scalability: RHDH enables consistent developer onboarding and application delivery across
growing teams and environments.

Security: Role-based access control (RBAC) and integration with enterprise systems ensure
access is managed securely and in line with compliance requirements.

Operational efficiency: By removing manual handoffs and centralizing key development
workflows, RHDH improves time to value and increases return on engineering investment.

For platform engineers

Curated platforms: Platform teams can design reusable templates and integrations aligned
with organizational policies and developer needs.

Central configuration: Infrastructure and policies are defined as code and centrally
managed, reducing drift and maintenance overhead.

Governance at scale: Policies and best practices are embedded into developer workflows
using automation and templates, without adding friction to the process.

For developers

Faster onboarding: Developers can use learning paths, software templates, and software
catalog to deploy compliant services within minutes, without depending on other teams for
setup.

Reduced cognitive load: Developers can find tools, documentation, and deployment
environments in one place, eliminating the need to switch between systems or manage
disconnected resources.

Self-service workflows: Developers can create applications or environments on demand,
without raising tickets or waiting for approvals.

Built-in standards: Developers can use preconfigured templates that enforce secure,
compliant workflows without requiring manual setup.

Cross-team visibility: Developers can discover shared service catalogs and documentation
to improve reuse and reduce duplication.

Higher productivity: Developers can spend more time building features and less time
configuring infrastructure or resolving toolchain inconsistencies.

4

CHAPTER 1. UNDERSTANDING INTERNAL DEVELOPER PLATFORMS

Key features

Centralized dashboard

Access development tools, CI/CD pipelines, APIs, monitoring tools, and documentation from a single
interface. Integrate with systems like Git, Red Hat OpenShift Container Platform, Kubernetes, and
JIRA.

Learning paths

Guide developers through structured tutorials and onboarding steps. Help teams upskill with internal
and Red Hat training resources in one place.

Plugins and integrations

Extend RHDH with verified plugins that add new functionality without downtime. Dynamically
integrate with supported tools such as Tekton for pipelines, GitOps for deployment automation,
Nexus Repository for artifact storage, and JFrog Artifactory. RHDH also supports connecting to Red
Hat OpenShift Container Platform, CI/CD systems, and security scanners through Red Hat-curated
extensions.

Role-Based Access Control (RBAC)

Manage user access with robust security permissions tailored to organizational needs.

Software catalog

Search, view, and manage services, APIs, and libraries from a central inventory. Track ownership,
metadata, and component health in one place.

Software templates

Accelerate project setup using preconfigured templates for CI/CD, runtime, and security.
Standardize implementation while enabling developer autonomy.

Tech docs

Create, store, and view technical documentation alongside code. Make content searchable,
consistently formatted, and accessible through the portal.

Scalability

Support growing teams and applications while maintaining access to the same tools and services.

Additional resources

Configuring templates

TechDocs for Red Hat Developer Hub

Customizing the Learning Paths in Red Hat Developer Hub

Introduction to plugins

Integrations in Red Hat Developer Hub

Authentication in Red Hat Developer Hub

5

Red Hat Developer Hub 1.8 About Red Hat Developer Hub

CHAPTER 2. SYSTEM ARCHITECTURE FOR DEPLOYMENT
PLANNING

Red Hat Developer Hub (RHDH) uses a client-server architecture with a browser-based frontend and a
stateless backend service layer. Use this architecture to plan for horizontal scaling, high availability, and
efficient data synchronization across the Software Catalog.

By understanding the RHDH architecture, you can perform the following planning tasks:

Plan scalable deployments

Deploy multiple backend instances behind a load balancer to manage increased load.

Ensure high availability

Configure database replication and cache clustering to eliminate single points of failure.

Optimize resource allocation

Assign infrastructure resources based on which components require persistent storage or high-
performance memory.

The following diagram shows the RHDH internal architecture (frontend and backend) and its external
dependencies, such as authentication providers, load balancers, and databases:

6

CHAPTER 2. SYSTEM ARCHITECTURE FOR DEPLOYMENT PLANNING

The RHDH architecture includes three primary layers. While the data layer (PostgreSQL and optional
Redis cache) stores the indexed Software Catalog, the source of truth remains in external systems, such
as Git repositories, CI/CD platforms, and other integrations. Catalog providers continuously scan these
external systems and synchronize data to the database for fast querying.

Frontend (Client)

The frontend is a browser-based single-page application (SPA). Use the frontend interface to browse
the Software Catalog, interact with plugins, and connect to external integrations. The frontend
communicates with the backend exclusively using REST API calls.

Backend (Service Layer)

The backend provides REST API endpoints for the frontend. It manages the Software Catalog (an
inventory of your organization’s software components, APIs, and resources) and handles authentication.

The stateless design allows you to scale the backend horizontally by running multiple instances behind a
load balancer. The backend externalizes all persistent state to a PostgreSQL database, including:

Catalog entities

Task history

Session data (managed through a database-backed session store)

External data dependencies

RHDH requires PostgreSQL for persistence. For production environments, use a logical cache to

7

Red Hat Developer Hub 1.8 About Red Hat Developer Hub

RHDH requires PostgreSQL for persistence. For production environments, use a logical cache to
improve performance.

PostgreSQL database

Stores indexed Software Catalog entities (synchronized from external systems like Git repositories
and CI/CD platforms), profiles, authentication data, and backend state. You must configure
PostgreSQL with high availability (HA) for production deployments.

Redis Cache (Optional)

Configure Redis as a shared logical cache across backend instances to improve performance for
frequently accessed data, such as rendered TechDocs and catalog entities.

TIP

The default in-memory cache is suitable only for single-instance deployments. You must use Redis for
production deployments with multiple backend instances to ensure cache consistency.

8

CHAPTER 3. ACHIEVE HIGH AVAILABILITY WITH DATABASE AND CACHE LAYERS

CHAPTER 3. ACHIEVE HIGH AVAILABILITY WITH DATABASE
AND CACHE LAYERS

To achieve high availability (HA) in Red Hat Developer Hub, you must implement redundancy and
failover for the backend service and its external data dependencies. This configuration uses horizontal
scaling, database replication, and a shared logical cache to make sure RHDH remains operational during
component failures.

Backend scalability

RHDH backend uses a stateless design to support horizontal scaling. PostgreSQL stores persistent data
and the database manages sessions, allowing multiple backend instances to serve any request
simultaneously. To improve performance, you can configure an optional logical cache using Redis.

To maintain backend availability, observe the following architectural requirements:

Deploy multiple backend instances

Run at least two backend instances for basic HA.

Configure a load balancer

Use platform-provided load balancing, such as OpenShift Routes, Kubernetes Ingress, or cloud
provider load balancers.

Enable health checks

Configure the load balancer to probe backend health and remove failed instances from rotation.

Disable session affinity (sticky sessions)

Database-backed sessions allow any instance to serve any request.

Database high availability

RHDH operations rely on PostgreSQL for persistence. A database outage renders the deployment non-
functional until the database is restored. For production deployments, you must configure PostgreSQL
with high availability (primary-replica replication) to minimize downtime.

IMPORTANT

If you use catalog providers exclusively, the database acts as an indexed cache. You do
not require disaster recovery backups because you can repopulate catalog data from
external sources of truth, such as Git repositories, CI/CD platforms, and monitoring tools.

Cache high availability (optional)

Configuring Redis as a shared logical cache improves production performance by sharing cached data
across multiple backend instances. A shared cache makes sure that all instances access the same
processed data, such as rendered TechDocs.

If the logical cache fails, the platform remains functional, but you might experience the following
symptoms:

Slower response times due to cache misses.

Increased database load because the backend must fetch data from PostgreSQL.

No impact on authentication or core functionality.

For maximum performance stability in production, configure Redis with high availability using Redis

9

Red Hat Developer Hub 1.8 About Red Hat Developer Hub

For maximum performance stability in production, configure Redis with high availability using Redis
Sentinel for small deployments or Redis Cluster for larger deployments.

10

CHAPTER 4. INTEGRATIONS IN RED HAT DEVELOPER HUB

CHAPTER 4. INTEGRATIONS IN RED HAT DEVELOPER HUB

Red Hat Developer Hub integrates seamlessly with Red Hat OpenShift Container Platform and other
tools, enabling comprehensive development and deployment workflows across enterprise.

4.1. INTEGRATION WITH RED HAT OPENSHIFT CONTAINER
PLATFORM

Red Hat Developer Hub is fully integrated with Red Hat OpenShift Container Platform, offering:

Operators to manage application lifecycle.

Access to advanced OpenShift capabilities such as service mesh, serverless functions, GitOps,
and distributed tracing.

Pipelines and GitOps plugins for streamlined cloud-native workflows.

4.2. INTEGRATION WITH RED HAT ADVANCED DEVELOPER SUITE -
SECURE SUPPLY CHAIN

Red Hat Advanced Developer Suite - secure supply chain (RHADS - ssc) enhances Red Hat Developer
Hub by providing secure CI/CD capabilities that integrate security measures into every stage of the
development process.

While Red Hat Developer Hub focuses on the inner loop (code, build, and test), RHADS - ssc manages
the outer loop, automating:

Code scanning

Image building

Vulnerability detection

Deployment

RHADS - ssc includes tools like Red Hat Trusted Artifact Signer (TAS) for code integrity, Red Hat
Trusted Profile Analyzer (TPA) for automated Software build of Materials (SBOM) creation, and Red
Hat Advanced Cluster Security (ACS) for vulnerability scanning.

4.3. EXTENDING BACKSTAGE WITH RED HAT DEVELOPER HUB

Red Hat Developer Hub which is a fully supported, enterprise-grade productized version of upstream
Backstage extends the upstream project by adding:

Enhanced search capabilities that aggregate data from CI/CD pipelines, cloud providers, source
control, and more.

A centralized software catalog for locating applications, APIs, and resources.

Automation through open-source plugins that expand Backstage’s core functionality.

Simplified technical documentation using Markdown and GitHub, with integrated search for
easy navigation.

11

Red Hat Developer Hub 1.8 About Red Hat Developer Hub

CHAPTER 5. SUPPORTED PLATFORMS

You can find the supported platforms and life cycle dates for both current and past versions of Red Hat
Developer Hub on the Life Cycle page.

Additional resources

Life Cycle page

12

CHAPTER 6. SIZING REQUIREMENTS FOR RED HAT DEVELOPER HUB

CHAPTER 6. SIZING REQUIREMENTS FOR RED HAT
DEVELOPER HUB

Learn about sizing requirements for Red Hat Developer Hub. Table 1 lists the sizing requirements for
installing and running Red Hat Developer Hub, including Developer Hub application, database
components, and Operator. Table 2 lists recommended sizing requirements for external PostgreSQL
deployment based on the deployment scale.

Table 6.1. Recommended sizing for running Red Hat Developer Hub

Components

Red Hat Developer Hub
application

Red Hat Developer Hub
database

Red Hat Developer Hub
Operator

Central Processing Unit
(CPU)

4 vCPU

2 vCPU

1 vCPU

Memory

Storage size

16 GB

2 GB

8 GB

20 GB

1500 Mi

50 Mi

Replicas

2 or more

3 or more

1 or more

Table 6.2. Recommended sizing for external PostgreSQL deployments with Red Hat Developer Hub

Sizing legend

Small-scale

Mid-scale

Large-scale

Enterprise-scale

Application usage

up to 5 thousand
entities, up to 50
concurrent users

5–20 thousand
entities, 50–150
concurrent users

20–50 thousand
entities, 150–400
concurrent users

50–150 thousand
entities, 400–800
concurrent users

vCPU

2

4

8

16

Memory

8 GiB

16 GiB

32 GiB

64 GiB

Storage

50 GiB

100 GiB

200 GiB

500 GiB

Number of replicas

1

2

2-3

3+

PostgreSQL
Database HA

1 primary

1 primary, 1 standby

1 primary, 1
synchronous
standby

1 primary, 1
synchronous
standby, 1
asynchronous
replica

13

Red Hat Developer Hub 1.8 About Red Hat Developer Hub

CHAPTER 7. RED HAT DEVELOPER HUB SUPPORT

If you experience difficulty with a procedure described in this documentation, visit the Red Hat
Customer Portal. You can use the Red Hat Customer Portal for the following purposes:

To search or browse through the Red Hat Knowledgebase of technical support articles about
Red Hat products.

To create a support case for Red Hat Global Support Services (GSS), select Red Hat
Developer Hub as the product and select the appropriate product version.

Additional resources

Red Hat Customer Portal

Create a support case for Red Hat Global Support Services (GSS)

Red Hat Developer Hub Life Cycle

Next steps

Installing Red Hat Developer Hub on Amazon Elastic Kubernetes Service

Installing Red Hat Developer Hub on Google Cloud on Google Cloud

Installing Red Hat Developer Hub on Google Kubernetes Engine

Installing Red Hat Developer Hub on Microsoft Azure Kubernetes Service

Installing Red Hat Developer Hub on OpenShift Container Platform

14

