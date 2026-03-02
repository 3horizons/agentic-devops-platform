Red Hat Developer Hub 1.8

Using dynamic plugins in Red Hat Developer
Hub

Using Red Hat Developer Hub plugins to access your development infrastructure and
software development tools

Last Updated: 2026-02-18

Red Hat Developer Hub 1.8 Using dynamic plugins in Red Hat Developer
Hub

Using Red Hat Developer Hub plugins to access your development infrastructure and software
development tools

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

The following sections provide information about how you can use Red Hat Developer Hub (RHDH)
dynamic plugins.

Table of Contents

Table of Contents

CHAPTER 1. USING ANSIBLE PLUG-INS FOR RED HAT DEVELOPER HUB
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

3

CHAPTER 2. USING THE ARGO CD PLUGIN
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

4

CHAPTER 3. USING THE JFROG ARTIFACTORY PLUGIN
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

6

CHAPTER 4. USING KEYCLOAK
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

7

4.1. IMPORTING USERS AND GROUPS IN DEVELOPER HUB USING THE KEYCLOAK PLUGIN

7

CHAPTER 5. USING THE NEXUS REPOSITORY MANAGER PLUGIN
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

8

CHAPTER 6. USING THE TEKTON PLUGIN
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

9

CHAPTER 7. USING THE TOPOLOGY PLUGIN
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

10

7.1. ENABLING USERS TO USE THE TOPOLOGY PLUGIN
7.2. USING THE TOPOLOGY PLUGIN

10
10

1

Red Hat Developer Hub 1.8 Using dynamic plugins in Red Hat Developer Hub

2

CHAPTER 1. USING ANSIBLE PLUG-INS FOR RED HAT DEVELOPER HUB

CHAPTER 1. USING ANSIBLE PLUG-INS FOR RED HAT
DEVELOPER HUB

Ansible plug-ins for Red Hat Developer Hub deliver an Ansible-specific portal experience with curated
learning paths, push-button content creation, integrated development tools, and other opinionated
resources.

IMPORTANT

The Ansible plug-ins are a Technology Preview feature only.

Technology Preview features are not supported with Red Hat production service level
agreements (SLAs), might not be functionally complete, and Red Hat does not
recommend using them for production. These features provide early access to upcoming
product features, enabling customers to test functionality and provide feedback during
the development process.

Additonal resources

Technology Preview Features Scope

Red Hat Developer Support Policy

Using Ansible plug-ins for Red Hat Developer Hub

3

Red Hat Developer Hub 1.8 Using dynamic plugins in Red Hat Developer Hub

CHAPTER 2. USING THE ARGO CD PLUGIN

You can use the Argo CD plugin to visualize the Continuous Delivery (CD) workflows in OpenShift
GitOps. This plugin provides a visual overview of the application’s status, deployment details, commit
message, author of the commit, container image promoted to environment and deployment history.

Prerequisites

You have enabled the Argo CD plugin in Red Hat Developer Hub RHDH.

Procedure

1.  Select the Catalog tab and choose the component that you want to use.

2.  Select the CD tab to view insights into deployments managed by Argo CD.

3.  Select an appropriate card to view the deployment details (for example, commit message,

author name, and deployment history).

a.  Click the link icon (

 ) to open the deployment details in Argo CD.

4.  Select the Overview tab and navigate to the Deployment summary section to review the
summary of your application’s deployment across namespaces. Additionally, select an

4

appropriate Argo CD app to open the deployment details in Argo CD, or select a commit ID
from the Revision column to review the changes in GitLab or GitHub.

CHAPTER 2. USING THE ARGO CD PLUGIN

Additional resources

Installing and viewing plugins in Red Hat Developer Hub

5

Red Hat Developer Hub 1.8 Using dynamic plugins in Red Hat Developer Hub

CHAPTER 3. USING THE JFROG ARTIFACTORY PLUGIN

The JFrog Artifactory plugin displays information about your container images within the Jfrog
Artifactory registry.

IMPORTANT

The JFrog Artifactory plugin is a Technology Preview feature only.

Technology Preview features are not supported with Red Hat production service level
agreements (SLAs), might not be functionally complete, and Red Hat does not
recommend using them for production. These features provide early access to upcoming
product features, enabling customers to test functionality and provide feedback during
the development process.

For more information on Red Hat Technology Preview features, see Technology Preview
Features Scope.

Additional detail on how Red Hat provides support for bundled community dynamic
plugins is available on the Red Hat Developer Support Policy  page.

Prerequisites

Your Developer Hub application is installed and running.

You have enabled the JFrog Artifactory plugin.

Procedure

1.  Open your Developer Hub application and select a component from the Catalog page.

2.  Go to the Image Registry tab.

The Image Registry tab contains a list of container images within your Jfrog Artifactory
repository and related information, such as Version, Repositories, Manifest, Modified, and
Size.

6

CHAPTER 4. USING KEYCLOAK

CHAPTER 4. USING KEYCLOAK

The Keycloak backend plugin, which integrates Keycloak into Developer Hub, has the following
capabilities:

Synchronization of Keycloak users in a realm.

Synchronization of Keycloak groups and their users in a realm.

4.1. IMPORTING USERS AND GROUPS IN DEVELOPER HUB USING THE
KEYCLOAK PLUGIN

After configuring the plugin successfully, the plugin imports the users and groups each time when
started.

NOTE

If you set up a schedule, users and groups will also be imported.

Procedure

1.  in Red Hat Developer Hub, go to the Catalog page.

2.  Select User from the entity type filter to display the list of imported users.

3.  Browse the list of users displayed on the page.

4.  Select a user to view detailed information imported from Keycloak.

5.  To view groups, select Group from the entity type filter.

6.  Browse the list of groups shown on the page.

7.  From the list of groups, select a group to view the information imported from Keycloak.

7

Red Hat Developer Hub 1.8 Using dynamic plugins in Red Hat Developer Hub

CHAPTER 5. USING THE NEXUS REPOSITORY MANAGER
PLUGIN

The Nexus Repository Manager plugin displays the information about your build artifacts in your
Developer Hub application. The build artifacts are available in the Nexus Repository Manager.

IMPORTANT

The Nexus Repository Manager plugin is a Technology Preview feature only.

Technology Preview features are not supported with Red Hat production service level
agreements (SLAs), might not be functionally complete, and Red Hat does not
recommend using them for production. These features provide early access to upcoming
product features, enabling customers to test functionality and provide feedback during
the development process.

For more information on Red Hat Technology Preview features, see Technology Preview
Features Scope.

Additional detail on how Red Hat provides support for bundled community dynamic
plugins is available on the Red Hat Developer Support Policy  page.

The Nexus Repository Manager is a front-end plugin that enables you to view the information about
build artifacts.

Prerequisites

Your Developer Hub application is installed and running.

You have installed the Nexus Repository Manager plugin.

Procedure

1.  Open your Developer Hub application and select a component from the Catalog page.

2.  Go to the BUILD ARTIFACTS tab.

The BUILD ARTIFACTS tab contains a list of build artifacts and related information, such as
VERSION, REPOSITORY, REPOSITORY TYPE, MANIFEST, MODIFIED, and SIZE.

8

CHAPTER 6. USING THE TEKTON PLUGIN

CHAPTER 6. USING THE TEKTON PLUGIN

You can use the Tekton plugin to visualize the results of CI/CD pipeline runs on your Kubernetes or
OpenShift clusters. The plugin allows users to visually see high level status of all associated tasks in the
pipeline for their applications.

You can use the Tekton front-end plugin to view PipelineRun resources.

Prerequisites

You have installed the Red Hat Developer Hub (RHDH).

You have installed the Tekton plugin. For the installation process, see Installing and configuring
the Tekton plugin.

Procedure

1.  Open your RHDH application and select a component from the Catalog page.

2.  Go to the CI tab.

The CI tab displays the list of PipelineRun resources associated with a Kubernetes cluster. The
list contains pipeline run details, such as NAME, VULNERABILITIES, STATUS, TASK STATUS,
STARTED, and DURATION.

3.  Click the expand row button besides PipelineRun name in the list to view the PipelineRun

visualization. The pipeline run resource includes tasks to complete. When you hover the mouse
pointer on a task card, you can view the steps to complete that particular task.

9

Red Hat Developer Hub 1.8 Using dynamic plugins in Red Hat Developer Hub

CHAPTER 7. USING THE TOPOLOGY PLUGIN

Topology is a front-end plugin that enables you to view the workloads as nodes that power any service
on the Kubernetes cluster.

7.1. ENABLING USERS TO USE THE TOPOLOGY PLUGIN

The Topology plugin is defining additional permissions. When Authorization in Red Hat Developer Hub  is
enabled, to enable users to use the Topology plugin, grant them:

The kubernetes.clusters.read and kubernetes.resources.read, read permissions to view the
Topology panel.

The kubernetes.proxy use permission to view the pod logs.

The catalog-entity read permission to view the Red Hat Developer Hub software catalog items.

Prerequisites

You are managing Authorization in Red Hat Developer Hub by using external files .

Procedure

Add the following permission policies to your rbac-policy.csv file to create a  topology-viewer
role that has access to the Topology plugin features, and add the role to the users requiring this
authorization:

g, user:default/<YOUR_USERNAME>, role:default/topology-viewer
p, role:default/topology-viewer, kubernetes.clusters.read, read, allow  1
p, role:default/topology-viewer, kubernetes.resources.read, read, allow  2
p, role:default/topology-viewer, kubernetes.proxy, use, allow  3
p, role:default/topology-viewer, catalog-entity, read, allow  4

1 2

Grants the user the ability to see the Topology panel.

3

4

Grants the user the ability to view the pod logs.

Grants the user the ability to see the catalog item.

7.2. USING THE TOPOLOGY PLUGIN

Prerequisites

Your Red Hat Developer Hub instance is installed and running.

You have installed the Topology plugin.

You have enabled the users to use the Topology plugin .

Procedure

1.  Open your RHDH application and select a component from the Catalog page.

10

2.  Go to the TOPOLOGY tab and you can view the workloads such as deployments or pods as

nodes.

CHAPTER 7. USING THE TOPOLOGY PLUGIN

3.  Select a node and a pop-up appears on the right side that contains two tabs: Details and

Resources.
The Details and Resources tabs contain the associated information and resources for the
node.

4.  Click the Open URL button on the top of a node.

11

Red Hat Developer Hub 1.8 Using dynamic plugins in Red Hat Developer Hub

Click the Open URL button to access the associated  Ingresses and run your application in a
new tab.

12

