Red Hat Developer Hub 1.8
Dynamic plugins reference
Red Hat Developer Hub is preinstalled with a selection of dynamic plugins that you
can enable and configure to extend Developer Hub functionality
Last Updated: 2026-02-18

Red Hat Developer Hub 1.8 Dynamic plugins reference
Red Hat Developer Hub is preinstalled with a selection of dynamic plugins that you can enable and
configure to extend Developer Hub functionality

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
Red Hat Developer Hub (RHDH) is preinstalled with a selection of dynamic plugins that users can
enable and configure to extend RHDH functionality.

Table of Contents
Table of Contents
.P .R . E. .F . A. .C . E. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 3. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
.C . H. .A . P. .T .E . R. . 1.. .P . R. .E . I.N . S. .T . A. .L .L . E. .D . .D . Y. .N . A. .M . .I C. . P. .L . U. .G . I.N . .S . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .4 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1.1. RED HAT SUPPORTED PLUGINS 5
1.2. TECHNOLOGY PREVIEW PLUGINS 10
1.2.1. Red Hat Technology Preview plugins 10
1.2.2. Deprecated plugins 20
.C . H. .A . P. .T .E . R. . 2. .. O. . T. .H . E. R. . I.N . .S .T . A. .L . L. A. .B . L. .E . .P . L. U. .G . .I N. .S . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 2. .1 . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
1

Red Hat Developer Hub 1.8 Dynamic plugins reference
2

PREFACE
PREFACE
The dynamic plugin support is based on the backend plugin manager package, which is a service that
scans a configured root directory (dynamicPlugins.rootDirectory in the app config) for dynamic plugin
packages and loads them dynamically.
You can use the dynamic plugins that come preinstalled with Red Hat Developer Hub or install external
dynamic plugins from a public NPM registry.
3

Red Hat Developer Hub 1.8 Dynamic plugins reference
CHAPTER 1. PREINSTALLED DYNAMIC PLUGINS
Red Hat Developer Hub is preinstalled with a selection of dynamic plugins.
The following preinstalled dynamic plugins are enabled by default:
@backstage-community/plugin-analytics-provider-segment
@backstage-community/plugin-scaffolder-backend-module-quay
@backstage-community/plugin-scaffolder-backend-module-regex
@backstage/plugin-events-backend
@backstage/plugin-techdocs
@backstage/plugin-techdocs-backend
@backstage/plugin-techdocs-module-addons-contrib
@red-hat-developer-hub/backstage-plugin-catalog-backend-module-marketplace
@red-hat-developer-hub/backstage-plugin-dynamic-home-page
@red-hat-developer-hub/backstage-plugin-global-floating-action-button
@red-hat-developer-hub/backstage-plugin-global-header
@red-hat-developer-hub/backstage-plugin-marketplace
@red-hat-developer-hub/backstage-plugin-marketplace-backend
@red-hat-developer-hub/backstage-plugin-adoption-insights
@red-hat-developer-hub/backstage-plugin-adoption-insights-backend
@red-hat-developer-hub/backstage-plugin-analytics-module-adoption-insights
@red-hat-developer-hub/backstage-plugin-quickstart
The dynamic plugins that require custom configuration are disabled by default.
Upon application startup, for each plugin that is disabled by default, the install-dynamic-plugins init
container within the Developer Hub pod log displays a message similar to the following:
======= Skipping disabled dynamic plugin ./dynamic-plugins/dist/backstage-plugin-catalog-backend-
module-github-dynamic
To enable this plugin, add a package with the same name to the Helm chart and change the value in the
disabled field to ‘false’. For example:
global:
dynamic:
includes:
- dynamic-plugins.default.yaml
4

CHAPTER 1. PREINSTALLED DYNAMIC PLUGINS
    plugins:
      - package: ./dynamic-plugins/dist/backstage-plugin-catalog-backend-module-github-dynamic
        disabled: false
NOTE
The default configuration for a plugin is extracted from the dynamic-
plugins.default.yaml file, however, you can use a pluginConfig entry to override the
default configuration.
1.1. RED HAT SUPPORTED PLUGINS
Red Hat supports the following 28 plugins:
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
| Adoption Insights | @red-hat-developer- | 0.2.1 | ./dynamic-            |
| ----------------- | ------------------- | ----- | --------------------- |
|                   | hub/backstage-      |       | plugins/dist/red-hat- |
|                   | plugin-adoption-    |       | developer-hub-        |
|                   | insights            |       | backstage-plugin-     |
adoption-insights
| Adoption Insights | @red-hat-developer- | 0.2.1 | ./dynamic-            |
| ----------------- | ------------------- | ----- | --------------------- |
|                   | hub/backstage-      |       | plugins/dist/red-hat- |
|                   | plugin-adoption-    |       | developer-hub-        |
|                   | insights-backend    |       | backstage-plugin-     |
adoption-insights-
backend-dynamic
| Analytics Module  | @red-hat-developer- | 0.2.0 | ./dynamic-            |
| ----------------- | ------------------- | ----- | --------------------- |
| Adoption Insights | hub/backstage-      |       | plugins/dist/red-hat- |
|                   | plugin-analytics-   |       | developer-hub-        |
|                   | module-adoption-    |       | backstage-plugin-     |
|                   | insights            |       | analytics-module-     |
adoption-insights-
dynamic
5

Red Hat Developer Hub 1.8 Dynamic plugins reference
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|                    | @backstage-         |        | ./dynamic-           |
| ------------------ | ------------------- | ------ | -------------------- |
| Analytics Provider |                     | 1.19.1 |                      |
| Segment            | community/plugin-   |        | plugins/dist/backsta |
|                    | analytics-provider- |        | ge-community-        |
|                    | segment             |        | plugin-analytics-    |
provider-segment
BACKSTAGE_VERSI
ON
RHDH_VERSION
SEGMENT_TEST_M
ODE
SEGMENT_WRITE_K
EY
|         | @roadiehq/backstag |       | ./dynamic-           |
| ------- | ------------------ | ----- | -------------------- |
| Argo CD |                    | 4.4.2 |                      |
|         | e-plugin-argo-cd-  |       | plugins/dist/roadieh |
|         | backend            |       | q-backstage-plugin-  |
argo-cd-backend-
dynamic
ARGOCD_AUTH_TO
KEN
ARGOCD_AUTH_TO
KEN2
ARGOCD_INSTANC
E1_URL
ARGOCD_INSTANC
E2_URL
ARGOCD_PASSWO
RD
ARGOCD_USERNA
ME
| Dynamic Home Page | @red-hat-developer- | 1.9.2 | ./dynamic-            |
| ----------------- | ------------------- | ----- | --------------------- |
|                   | hub/backstage-      |       | plugins/dist/red-hat- |
|                   | plugin-dynamic-     |       | developer-hub-        |
|                   | home-page           |       | backstage-plugin-     |
dynamic-home-page
6

CHAPTER 1. PREINSTALLED DYNAMIC PLUGINS
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|            | @backstage/plugin- |        | ./dynamic-           |
| ---------- | ------------------ | ------ | -------------------- |
| GitHub Org |                    | 0.3.13 |                      |
|            | catalog-backend-   |        | plugins/dist/backsta |
|            | module-github-org  |        | ge-plugin-catalog-   |
backend-module-
github-org-dynamic
GITHUB_ORG
GITHUB_URL
| GitHub | @backstage/plugin- | 0.10.2 | ./dynamic-           |
| ------ | ------------------ | ------ | -------------------- |
|        | catalog-backend-   |        | plugins/dist/backsta |
|        | module-github      |        | ge-plugin-catalog-   |
backend-module-
github-dynamic
GITHUB_ORG
| GitHub | @backstage/plugin-  | 0.8.2 | ./dynamic-            |
| ------ | ------------------- | ----- | --------------------- |
|        | scaffolder-backend- |       | plugins/dist/backsta  |
|        | module-github       |       | ge-plugin-scaffolder- |
backend-module-
github-dynamic
| Global Floating Action | @red-hat-developer- | 1.5.0 | ./dynamic-            |
| ---------------------- | ------------------- | ----- | --------------------- |
| Button                 | hub/backstage-      |       | plugins/dist/red-hat- |
|                        | plugin-global-      |       | developer-hub-        |
|                        | floating-action-    |       | backstage-plugin-     |
|                        | button              |       | global-floating-      |
action-button
| Global Header | @red-hat-developer-  | 1.18.1 | ./dynamic-            |
| ------------- | -------------------- | ------ | --------------------- |
|               | hub/backstage-       |        | plugins/dist/red-hat- |
|               | plugin-global-header |        | developer-hub-        |
backstage-plugin-
global-header
7

Red Hat Developer Hub 1.8 Dynamic plugins reference
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|          | @backstage-       |        | ./dynamic-           |
| -------- | ----------------- | ------ | -------------------- |
| Keycloak |                   | 3.14.2 |                      |
|          | community/plugin- |        | plugins/dist/backsta |
|          | catalog-backend-  |        | ge-community-        |
|          | module-keycloak   |        | plugin-catalog-      |
backend-module-
keycloak-dynamic
KEYCLOAK_BASE_
URL
KEYCLOAK_CLIENT
_ID
KEYCLOAK_CLIENT
_SECRET
KEYCLOAK_LOGIN_
REALM
KEYCLOAK_REALM
| Kubernetes | @backstage/plugin- | 0.20.1 | ./dynamic-           |
| ---------- | ------------------ | ------ | -------------------- |
|            | kubernetes-backend |        | plugins/dist/backsta |
ge-plugin-
kubernetes-backend-
dynamic
K8S_CLUSTER_NAM
E
K8S_CLUSTER_TOK
EN
K8S_CLUSTER_URL
| Kubernetes | @backstage-         | 2.10.1 | ./dynamic-           |
| ---------- | ------------------- | ------ | -------------------- |
|            | community/plugin-   |        | plugins/dist/backsta |
|            | scaffolder-backend- |        | ge-community-        |
|            | module-kubernetes   |        | plugin-scaffolder-   |
backend-module-
kubernetes-dynamic
|      | @backstage/plugin- |        | ./dynamic-           |
| ---- | ------------------ | ------ | -------------------- |
| Ldap |                    | 0.11.8 |                      |
|      | catalog-backend-   |        | plugins/dist/backsta |
|      | module-ldap        |        | ge-plugin-catalog-   |
backend-module-
ldap-dynamic
8

CHAPTER 1. PREINSTALLED DYNAMIC PLUGINS
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|              | @redhat/backstage-  |       | @redhat/backstage- |
| ------------ | ------------------- | ----- | ------------------ |
| Orchestrator |                     | 1.8.2 |                    |
|              | plugin-orchestrator |       | plugin-            |
orchestrator@1.8.2
| Orchestrator | @redhat/backstage- | 1.8.2 | @redhat/backstage- |
| ------------ | ------------------ | ----- | ------------------ |
|              | plugin-scaffolder- |       | plugin-scaffolder- |
|              | backend-module-    |       | backend-module-    |
|              | orchestrator       |       | orchestrator-      |
dynamic@1.8.2
| Quay | @backstage-       | 1.24.0 | ./dynamic-           |
| ---- | ----------------- | ------ | -------------------- |
|      | community/plugin- |        | plugins/dist/backsta |
|      | quay              |        | ge-community-        |
plugin-quay
| Quay | @backstage-         | 2.11.0 | ./dynamic-           |
| ---- | ------------------- | ------ | -------------------- |
|      | community/plugin-   |        | plugins/dist/backsta |
|      | scaffolder-backend- |        | ge-community-        |
|      | module-quay         |        | plugin-scaffolder-   |
backend-module-
quay-dynamic
| Quickstart | @red-hat-developer- | 1.6.2 | ./dynamic-            |
| ---------- | ------------------- | ----- | --------------------- |
|            | hub/backstage-      |       | plugins/dist/red-hat- |
|            | plugin-quickstart   |       | developer-hub-        |
backstage-plugin-
quickstart
| RBAC | @backstage-       | 1.45.1 | ./dynamic-           |
| ---- | ----------------- | ------ | -------------------- |
|      | community/plugin- |        | plugins/dist/backsta |
|      | rbac              |        | ge-community-        |
plugin-rbac
| Regex | @backstage-         | 2.8.0 | ./dynamic-           |
| ----- | ------------------- | ----- | -------------------- |
|       | community/plugin-   |       | plugins/dist/backsta |
|       | scaffolder-backend- |       | ge-community-        |
|       | module-regex        |       | plugin-scaffolder-   |
backend-module-
regex-dynamic
| Signals | @backstage/plugin- | 0.3.7 | ./dynamic-           |
| ------- | ------------------ | ----- | -------------------- |
|         | signals-backend    |       | plugins/dist/backsta |
ge-plugin-signals-
backend-dynamic
9

Red Hat Developer Hub 1.8 Dynamic plugins reference
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|                 | @backstage/plugin- |        | ./dynamic-           |
| --------------- | ------------------ | ------ | -------------------- |
| TechDocs Module |                    | 1.1.27 |                      |
| Addons Contrib  | techdocs-module-   |        | plugins/dist/backsta |
|                 | addons-contrib     |        | ge-plugin-techdocs-  |
module-addons-
contrib
|          | @backstage/plugin- |        | ./dynamic-           |
| -------- | ------------------ | ------ | -------------------- |
| TechDocs |                    | 1.14.1 |                      |
|          | techdocs           |        | plugins/dist/backsta |
ge-plugin-techdocs
| TechDocs | @backstage/plugin- | 2.0.5 | ./dynamic-           |
| -------- | ------------------ | ----- | -------------------- |
|          | techdocs-backend   |       | plugins/dist/backsta |
ge-plugin-techdocs-
backend-dynamic
| Tekton | @backstage-       | 3.29.0 | ./dynamic-           |
| ------ | ----------------- | ------ | -------------------- |
|        | community/plugin- |        | plugins/dist/backsta |
|        | tekton            |        | ge-community-        |
plugin-tekton
| Topology | @backstage-       | 2.7.0 | ./dynamic-           |
| -------- | ----------------- | ----- | -------------------- |
|          | community/plugin- |       | plugins/dist/backsta |
|          | topology          |       | ge-community-        |
plugin-topology
NOTE
For more information about configuring KeyCloak, see Configuring dynamic
plugins.
For more information about configuring TechDocs, see Configuring TechDocs.
1.2. TECHNOLOGY PREVIEW PLUGINS
IMPORTANT
Red Hat Developer Hub includes a select number of Technology Preview plugins,
available for customers to configure and enable. These plugins are provided with support
scoped per Technical Preview terms, might not be functionally complete, and Red Hat
does not recommend using them for production. These features provide early access to
upcoming product features, enabling customers to test functionality and provide
feedback during the development process.
For more information on Red Hat Technology Preview features, see Technology Preview
Features Scope.
1.2.1. Red Hat Technology Preview plugins
10

CHAPTER 1. PREINSTALLED DYNAMIC PLUGINS
Red Hat provides Technology Preview support for the following 56 plugins:
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
| 3scale | @backstage-       | 3.8.0 | ./dynamic-           |
| ------ | ----------------- | ----- | -------------------- |
|        | community/plugin- |       | plugins/dist/backsta |
|        | 3scale-backend    |       | ge-community-        |
plugin-3scale-
backend-dynamic
THREESCALE_ACC
ESS_TOKEN
THREESCALE_BASE
_URL
| ACR | @backstage-       | 1.17.0 | ./dynamic-           |
| --- | ----------------- | ------ | -------------------- |
|     | community/plugin- |        | plugins/dist/backsta |
|     | acr               |        | ge-community-        |
plugin-acr
| Argo CD (Red Hat) | @backstage-       | 2.0.0 | ./dynamic-           |
| ----------------- | ----------------- | ----- | -------------------- |
|                   | community/plugin- |       | plugins/dist/backsta |
|                   | redhat-argocd     |       | ge-community-        |
plugin-redhat-
argocd
| Argo CD | @roadiehq/scaffolde | 1.7.1 | ./dynamic-           |
| ------- | ------------------- | ----- | -------------------- |
|         | r-backend-argocd    |       | plugins/dist/roadieh |
q-scaffolder-
backend-argocd-
dynamic
ARGOCD_AUTH_TO
KEN
ARGOCD_AUTH_TO
KEN2
ARGOCD_INSTANC
E1_URL
ARGOCD_INSTANC
E2_URL
ARGOCD_PASSWO
RD
ARGOCD_USERNA
ME
11

Red Hat Developer Hub 1.8 Dynamic plugins reference
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|              | @backstage-       |        | ./dynamic-           |
| ------------ | ----------------- | ------ | -------------------- |
| Azure Devops |                   | 0.18.0 |                      |
|              | community/plugin- |        | plugins/dist/backsta |
|              | azure-devops      |        | ge-community-        |
plugin-azure-devops
| Azure Devops | @backstage-       | 0.19.0 | ./dynamic-           |
| ------------ | ----------------- | ------ | -------------------- |
|              | community/plugin- |        | plugins/dist/backsta |
|              | azure-devops-     |        | ge-community-        |
|              | backend           |        | plugin-azure-        |
devops-backend-
dynamic
AZURE_ORG
AZURE_TOKEN
| Azure Repositories | @parfuemerie-       | 0.3.0 | ./dynamic-           |
| ------------------ | ------------------- | ----- | -------------------- |
|                    | douglas/scaffolder- |       | plugins/dist/parfuem |
|                    | backend-module-     |       | erie-douglas-        |
|                    | azure-repositories  |       | scaffolder-backend-  |
module-azure-
repositories-
dynamic
| Azure | @backstage/plugin-  | 0.2.12 | ./dynamic-            |
| ----- | ------------------- | ------ | --------------------- |
|       | scaffolder-backend- |        | plugins/dist/backsta  |
|       | module-azure        |        | ge-plugin-scaffolder- |
backend-module-
azure-dynamic
| Bitbucket Cloud | @backstage/plugin- | 0.5.2 | ./dynamic-           |
| --------------- | ------------------ | ----- | -------------------- |
|                 | catalog-backend-   |       | plugins/dist/backsta |
|                 | module-bitbucket-  |       | ge-plugin-catalog-   |
|                 | cloud              |       | backend-module-      |
bitbucket-cloud-
dynamic
BITBUCKET_WORK
SPACE
| Bitbucket Cloud | @backstage/plugin-  | 0.2.12 | ./dynamic-            |
| --------------- | ------------------- | ------ | --------------------- |
|                 | scaffolder-backend- |        | plugins/dist/backsta  |
|                 | module-bitbucket-   |        | ge-plugin-scaffolder- |
|                 | cloud               |        | backend-module-       |
bitbucket-cloud-
dynamic
12

CHAPTER 1. PREINSTALLED DYNAMIC PLUGINS
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|                  | @backstage/plugin- |       | ./dynamic-           |
| ---------------- | ------------------ | ----- | -------------------- |
| Bitbucket Server |                    | 0.5.2 |                      |
|                  | catalog-backend-   |       | plugins/dist/backsta |
|                  | module-bitbucket-  |       | ge-plugin-catalog-   |
|                  | server             |       | backend-module-      |
bitbucket-server-
dynamic
BITBUCKET_HOST
|                  | @backstage/plugin-  |        | ./dynamic-            |
| ---------------- | ------------------- | ------ | --------------------- |
| Bitbucket Server |                     | 0.2.12 |                       |
|                  | scaffolder-backend- |        | plugins/dist/backsta  |
|                  | module-bitbucket-   |        | ge-plugin-scaffolder- |
|                  | server              |        | backend-module-       |
bitbucket-server-
dynamic
|             | @red-hat-developer- |        | ./dynamic-            |
| ----------- | ------------------- | ------ | --------------------- |
| Bulk Import |                     | 1.18.1 |                       |
|             | hub/backstage-      |        | plugins/dist/red-hat- |
|             | plugin-bulk-import  |        | developer-hub-        |
backstage-plugin-
bulk-import
|             | @red-hat-developer- |       | ./dynamic-            |
| ----------- | ------------------- | ----- | --------------------- |
| Bulk Import |                     | 6.5.1 |                       |
|             | hub/backstage-      |       | plugins/dist/red-hat- |
|             | plugin-bulk-import- |       | developer-hub-        |
|             | backend             |       | backstage-plugin-     |
bulk-import-
backend-dynamic
|         | @roadiehq/backstag |       | ./dynamic-           |
| ------- | ------------------ | ----- | -------------------- |
| Datadog |                    | 2.5.0 |                      |
|         | e-plugin-datadog   |       | plugins/dist/roadieh |
q-backstage-plugin-
datadog
| Dynatrace | @backstage-       | 10.8.0 | ./dynamic-           |
| --------- | ----------------- | ------ | -------------------- |
|           | community/plugin- |        | plugins/dist/backsta |
|           | dynatrace         |        | ge-community-        |
plugin-dynatrace
| Gerrit | @backstage/plugin-  | 0.2.12 | ./dynamic-            |
| ------ | ------------------- | ------ | --------------------- |
|        | scaffolder-backend- |        | plugins/dist/backsta  |
|        | module-gerrit       |        | ge-plugin-scaffolder- |
backend-module-
gerrit-dynamic
13

Red Hat Developer Hub 1.8 Dynamic plugins reference
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|                | @backstage-       |        | ./dynamic-           |
| -------------- | ----------------- | ------ | -------------------- |
| GitHub Actions |                   | 0.14.0 |                      |
|                | community/plugin- |        | plugins/dist/backsta |
|                | github-actions    |        | ge-community-        |
plugin-github-
actions
|                 | @roadiehq/backstag |       | ./dynamic-           |
| --------------- | ------------------ | ----- | -------------------- |
| GitHub Insights |                    | 3.2.0 |                      |
|                 | e-plugin-github-   |       | plugins/dist/roadieh |
|                 | insights           |       | q-backstage-plugin-  |
github-insights
| GitHub Issues | @backstage-       | 0.13.0 | ./dynamic-           |
| ------------- | ----------------- | ------ | -------------------- |
|               | community/plugin- |        | plugins/dist/backsta |
|               | github-issues     |        | ge-community-        |
plugin-github-issues
| GitHub Pull Requests | @roadiehq/backstag    | 3.5.2 | ./dynamic-           |
| -------------------- | --------------------- | ----- | -------------------- |
|                      | e-plugin-github-pull- |       | plugins/dist/roadieh |
|                      | requests              |       | q-backstage-plugin-  |
github-pull-requests
|            | @backstage/plugin- |        | ./dynamic-           |
| ---------- | ------------------ | ------ | -------------------- |
| GitLab Org |                    | 0.2.12 |                      |
|            | catalog-backend-   |        | plugins/dist/backsta |
|            | module-gitlab-org  |        | ge-plugin-catalog-   |
backend-module-
gitlab-org-dynamic
|        | @immobiliarelabs/ba |        | ./dynamic-            |
| ------ | ------------------- | ------ | --------------------- |
| GitLab |                     | 6.13.0 |                       |
|        | ckstage-plugin-     |        | plugins/dist/immobili |
|        | gitlab              |        | arelabs-backstage-    |
plugin-gitlab
| GitLab | @backstage/plugin- | 0.7.2 | ./dynamic-           |
| ------ | ------------------ | ----- | -------------------- |
|        | catalog-backend-   |       | plugins/dist/backsta |
|        | module-gitlab      |       | ge-plugin-catalog-   |
backend-module-
gitlab-dynamic
14

CHAPTER 1. PREINSTALLED DYNAMIC PLUGINS
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|        | @immobiliarelabs/ba |        | ./dynamic-            |
| ------ | ------------------- | ------ | --------------------- |
| GitLab |                     | 6.13.0 |                       |
|        | ckstage-plugin-     |        | plugins/dist/immobili |
|        | gitlab-backend      |        | arelabs-backstage-    |
plugin-gitlab-
backend-dynamic
GITLAB_HOST
GITLAB_TOKEN
| GitLab | @backstage/plugin-  | 0.9.4 | ./dynamic-            |
| ------ | ------------------- | ----- | --------------------- |
|        | scaffolder-backend- |       | plugins/dist/backsta  |
|        | module-gitlab       |       | ge-plugin-scaffolder- |
backend-module-
gitlab-dynamic
| Http Request | @roadiehq/scaffolde | 5.4.2 | ./dynamic-           |
| ------------ | ------------------- | ----- | -------------------- |
|              | r-backend-module-   |       | plugins/dist/roadieh |
|              | http-request        |       | q-scaffolder-        |
backend-module-
http-request-
dynamic
| JFrog Artifactory | @backstage-       | 1.18.2 | ./dynamic-           |
| ----------------- | ----------------- | ------ | -------------------- |
|                   | community/plugin- |        | plugins/dist/backsta |
|                   | jfrog-artifactory |        | ge-community-        |
plugin-jfrog-
artifactory
| Jenkins | @backstage-       | 0.22.0 | ./dynamic-           |
| ------- | ----------------- | ------ | -------------------- |
|         | community/plugin- |        | plugins/dist/backsta |
|         | jenkins           |        | ge-community-        |
plugin-jenkins
| Jenkins | @backstage-       | 0.17.0 | ./dynamic-           |
| ------- | ----------------- | ------ | -------------------- |
|         | community/plugin- |        | plugins/dist/backsta |
|         | jenkins-backend   |        | ge-community-        |
plugin-jenkins-
backend-dynamic
JENKINS_TOKEN
JENKINS_URL
JENKINS_USERNAM
E
15

Red Hat Developer Hub 1.8 Dynamic plugins reference
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|      | @roadiehq/backstag |        | ./dynamic-           |
| ---- | ------------------ | ------ | -------------------- |
| Jira |                    | 2.13.1 |                      |
|      | e-plugin-jira      |        | plugins/dist/roadieh |
q-backstage-plugin-
jira
| Kubernetes | @backstage/plugin- | 0.12.10 | ./dynamic-           |
| ---------- | ------------------ | ------- | -------------------- |
|            | kubernetes         |         | plugins/dist/backsta |
ge-plugin-
kubernetes
| Lighthouse | @backstage-       | 0.12.0 | ./dynamic-           |
| ---------- | ----------------- | ------ | -------------------- |
|            | community/plugin- |        | plugins/dist/backsta |
|            | lighthouse        |        | ge-community-        |
plugin-lighthouse
| MS Graph | @backstage/plugin- | 0.7.3 | ./dynamic-           |
| -------- | ------------------ | ----- | -------------------- |
|          | catalog-backend-   |       | plugins/dist/backsta |
|          | module-msgraph     |       | ge-plugin-catalog-   |
backend-module-
msgraph-dynamic
MICROSOFT_CLIEN
T_ID
MICROSOFT_CLIEN
T_SECRET
MICROSOFT_TENAN
T_ID
| Marketplace | @red-hat-developer- | 0.11.4 | ./dynamic-            |
| ----------- | ------------------- | ------ | --------------------- |
|             | hub/backstage-      |        | plugins/dist/red-hat- |
|             | plugin-marketplace  |        | developer-hub-        |
backstage-plugin-
marketplace
| Marketplace | @red-hat-developer- | 0.7.1 | ./dynamic-            |
| ----------- | ------------------- | ----- | --------------------- |
|             | hub/backstage-      |       | plugins/dist/red-hat- |
|             | plugin-catalog-     |       | developer-hub-        |
|             | backend-module-     |       | backstage-plugin-     |
|             | marketplace         |       | catalog-backend-      |
module-
marketplace-
dynamic
16

CHAPTER 1. PREINSTALLED DYNAMIC PLUGINS
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|             | @red-hat-developer- |        | ./dynamic-            |
| ----------- | ------------------- | ------ | --------------------- |
| Marketplace |                     | 0.11.0 |                       |
|             | hub/backstage-      |        | plugins/dist/red-hat- |
|             | plugin-marketplace- |        | developer-hub-        |
|             | backend             |        | backstage-plugin-     |
marketplace-
backend-dynamic
|                  | @backstage-       |        | ./dynamic-           |
| ---------------- | ----------------- | ------ | -------------------- |
| Nexus Repository |                   | 1.16.0 |                      |
| Manager          | community/plugin- |        | plugins/dist/backsta |
|                  | nexus-repository- |        | ge-community-        |
|                  | manager           |        | plugin-nexus-        |
repository-manager
|               | @backstage/plugin- |       | ./dynamic-           |
| ------------- | ------------------ | ----- | -------------------- |
| Notifications |                    | 0.5.9 |                      |
|               | notifications      |       | plugins/dist/backsta |
ge-plugin-
notifications
| Notifications | @backstage/plugin- | 0.3.12 | ./dynamic-           |
| ------------- | ------------------ | ------ | -------------------- |
|               | notifications-     |        | plugins/dist/backsta |
|               | backend-module-    |        | ge-plugin-           |
|               | email              |        | notifications-       |
backend-module-
email-dynamic
EMAIL_HOSTNAME
EMAIL_PASSWORD
EMAIL_SENDER
EMAIL_USERNAME
| Notifications | @backstage/plugin- | 0.5.9 | ./dynamic-           |
| ------------- | ------------------ | ----- | -------------------- |
|               | notifications-     |       | plugins/dist/backsta |
|               | backend            |       | ge-plugin-           |
notifications-
backend-dynamic
|                   | @redhat/backstage-   |       | @redhat/backstage-   |
| ----------------- | -------------------- | ----- | -------------------- |
| Orchestrator Form |                      | 1.8.2 |                      |
| Widgets           | plugin-orchestrator- |       | plugin-orchestrator- |
|                   | form-widgets         |       | form-widgets@1.8.2   |
17

Red Hat Developer Hub 1.8 Dynamic plugins reference
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|              | @redhat/backstage-   |       | @redhat/backstage-   |
| ------------ | -------------------- | ----- | -------------------- |
| Orchestrator |                      | 1.8.2 |                      |
|              | plugin-orchestrator- |       | plugin-orchestrator- |
|              | backend              |       | backend-             |
dynamic@1.8.2
| PagerDuty | @pagerduty/backsta | 0.16.0 | ./dynamic-           |
| --------- | ------------------ | ------ | -------------------- |
|           | ge-plugin          |        | plugins/dist/pagerdu |
ty-backstage-plugin
| PagerDuty | @pagerduty/backsta | 0.9.11 | ./dynamic-           |
| --------- | ------------------ | ------ | -------------------- |
|           | ge-plugin-backend  |        | plugins/dist/pagerdu |
ty-backstage-plugin-
backend-dynamic
PAGERDUTY_API_B
ASE
PAGERDUTY_CLIEN
T_ID
PAGERDUTY_CLIEN
T_SECRET
PAGERDUTY_SUBD
OMAIN
|              | @backstage-         |       | ./dynamic-           |
| ------------ | ------------------- | ----- | -------------------- |
| Pingidentity |                     | 0.7.0 |                      |
|              | community/plugin-   |       | plugins/dist/backsta |
|              | catalog-backend-    |       | ge-community-        |
|              | module-pingidentity |       | plugin-catalog-      |
backend-module-
pingidentity-
dynamic
| Scaffolder Relation | @backstage-        | 2.8.0 | ./dynamic-           |
| ------------------- | ------------------ | ----- | -------------------- |
| Processor           | community/plugin-  |       | plugins/dist/backsta |
|                     | catalog-backend-   |       | ge-community-        |
|                     | module-scaffolder- |       | plugin-catalog-      |
|                     | relation-processor |       | backend-module-      |
scaffolder-relation-
processor-dynamic
| Security Insights | @roadiehq/backstag | 3.2.0 | ./dynamic-           |
| ----------------- | ------------------ | ----- | -------------------- |
|                   | e-plugin-security- |       | plugins/dist/roadieh |
|                   | insights           |       | q-backstage-plugin-  |
security-insights
18

CHAPTER 1. PREINSTALLED DYNAMIC PLUGINS
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|            | @backstage-         |       | ./dynamic-           |
| ---------- | ------------------- | ----- | -------------------- |
| ServiceNow |                     | 2.8.1 |                      |
|            | community/plugin-   |       | plugins/dist/backsta |
|            | scaffolder-backend- |       | ge-community-        |
|            | module-servicenow   |       | plugin-scaffolder-   |
backend-module-
servicenow-dynamic
SERVICENOW_BASE
_URL
SERVICENOW_PASS
WORD
SERVICENOW_USER
NAME
| Signals | @backstage/plugin- | 0.0.22 | ./dynamic-           |
| ------- | ------------------ | ------ | -------------------- |
|         | signals            |        | plugins/dist/backsta |
ge-plugin-signals
| SonarQube | @backstage-       | 0.18.0 | ./dynamic-           |
| --------- | ----------------- | ------ | -------------------- |
|           | community/plugin- |        | plugins/dist/backsta |
|           | sonarqube         |        | ge-community-        |
plugin-sonarqube
| SonarQube | @backstage-       | 0.12.0 | ./dynamic-           |
| --------- | ----------------- | ------ | -------------------- |
|           | community/plugin- |        | plugins/dist/backsta |
|           | sonarqube-backend |        | ge-community-        |
plugin-sonarqube-
backend-dynamic
SONARQUBE_TOKE
N
SONARQUBE_URL
|           | @backstage-         |       | ./dynamic-           |
| --------- | ------------------- | ----- | -------------------- |
| SonarQube |                     | 2.8.0 |                      |
|           | community/plugin-   |       | plugins/dist/backsta |
|           | scaffolder-backend- |       | ge-community-        |
|           | module-sonarqube    |       | plugin-scaffolder-   |
backend-module-
sonarqube-dynamic
| Tech Radar | @backstage-       | 1.11.0 | ./dynamic-           |
| ---------- | ----------------- | ------ | -------------------- |
|            | community/plugin- |        | plugins/dist/backsta |
|            | tech-radar        |        | ge-community-        |
plugin-tech-radar
19

Red Hat Developer Hub 1.8 Dynamic plugins reference
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
|            | @backstage-        |        | ./dynamic-           |
| ---------- | ------------------ | ------ | -------------------- |
| Tech Radar |                    | 1.10.0 |                      |
|            | community/plugin-  |        | plugins/dist/backsta |
|            | tech-radar-backend |        | ge-community-        |
plugin-tech-radar-
backend-dynamic
TECH_RADAR_DAT
A_URL
| Utils | @roadiehq/scaffolde | 4.0.3 | ./dynamic-           |
| ----- | ------------------- | ----- | -------------------- |
|       | r-backend-module-   |       | plugins/dist/roadieh |
|       | utils               |       | q-scaffolder-        |
backend-module-
utils-dynamic
1.2.2. Deprecated plugins
IMPORTANT
Red Hat Developer Hub (RHDH) includes a number of deprecated plugins, which are no
longer being actively developed. It is recommended that if you depend on any of these
plugins, you migrate to an alternative solution as soon as possible, as these plugins will be
removed in a future release.
RHDH includes the following 2 deprecated plugins:
| Name | Plugin | Version | Path and required |
| ---- | ------ | ------- | ----------------- |
variables
| OCM | @backstage-       | 5.8.0 | ./dynamic-           |
| --- | ----------------- | ----- | -------------------- |
|     | community/plugin- |       | plugins/dist/backsta |
|     | ocm               |       | ge-community-        |
plugin-ocm
| OCM | @backstage-       | 5.9.1 | ./dynamic-           |
| --- | ----------------- | ----- | -------------------- |
|     | community/plugin- |       | plugins/dist/backsta |
|     | ocm-backend       |       | ge-community-        |
plugin-ocm-
backend-dynamic
OCM_HUB_NAME
OCM_HUB_URL
OCM_SA_TOKEN
20

CHAPTER 2. OTHER INSTALLABLE PLUGINS
CHAPTER 2. OTHER INSTALLABLE PLUGINS
The following Technology Preview plugins are not preinstalled and must be installed from an external
source:
| Name               | Plugin           | Version | Installation Details |
| ------------------ | ---------------- | ------- | -------------------- |
| Ansible Automation | @ansible/plugin- | 1.0.0   | Learn more           |
| Platform Frontend  | backstage-rhaap  |         |                      |
| Ansible Automation | @ansible/plugin- | 1.0.0   | Learn more           |
| Platform           | backstage-rhaap- |         |                      |
backend
| Ansible Automation  | @ansible/plugin-    | 1.0.0 | Learn more |
| ------------------- | ------------------- | ----- | ---------- |
| Platform Scaffolder | scaffolder-backend- |       |            |
Backend
module-backstage-
rhaap
21