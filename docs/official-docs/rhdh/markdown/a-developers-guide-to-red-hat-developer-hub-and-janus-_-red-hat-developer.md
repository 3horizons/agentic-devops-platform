2/21/26, 3:24 PM

A developer’s guide to Red Hat Developer Hub and Janus | Red Hat Developer

A developer’s guide to Red Hat
Developer Hub and Janus

May 23, 2023

Ian Lawson, Yaina Williams

Related topics: Developer tools, GitOps, Kubernetes, Open source

Related products: Red Hat Developer Hub, Red Hat Plug-ins for

Backstage, Red Hat OpenShift

  Table of contents:



This article introduces the new Red Hat Developer Hub and Janus project

to address the challenges IT organizations face in the development

process. A developer’s work can be fraught with disparate development

systems and distributed teams, and organizations with multiple

development teams often struggle with competing priorities, diverse tools

and technologies, and establishing best practices.

These challenges make it difficult to quickly start development and

adhere to multiple security and compliance standards. A unified platform

that can consolidate these elements of the development process and

foster internal collaboration will enable development teams to focus on
rapidly enhancing code and functionality to efficiently build high-quality

software.

Simplifying the inner loop for developers

Simplifying the inner and outer loop model is also an important part of
improving the development process. The article Standardizing application

delivery with OpenShift explains the concept and purpose of dividing the
development process into two loops. In the inner loop, the developer

works on the code. In the outer loop, developers push the code to version
control for automation, testing, and deployment until it is ready for

https://developers.redhat.com/articles/2023/05/23/developers-guide-red-hat-developer-hub-and-janus#

1/8

2/21/26, 3:24 PM

A developer’s guide to Red Hat Developer Hub and Janus | Red Hat Developer

release. Developers need a simple inner loop so that they can focus on

finding software solutions, not configuring tools.

Developers need a single place, like a hub, where they can find resources,
utilize and generate shareable components, and follow Golden Path

templates (templated paths to quick and easy software development).
Read on to learn about the new Red Hat Developer Hub and Janus

project, and how they simplify the developer workflow.

Overview of Backstage and Project Janus

Red Hat Developer Hub is our enterprise-grade, supported version

of Backstage, an open source framework (provided by Spotify) for
building developer portals. Engineering teams can use Red Hat Developer
Hub to reduce friction and frustration and boost their productivity, giving

their organization a competitive advantage.

We have preloaded all the necessary Red Hat plug-ins, including a variety
of technology and tools that reduce developer cognitive load and support
self service, while maintaining context and underlying technologies
continuously maintained and improved by platform teams.

Our new initiative, Project Janus, has developed and enhanced the

Golden Path templates, Backstage platform, and plug-ins.

6 Red Hat Plug-ins for Backstage

Red Hat Plug-ins for Backstage work in tandem with Red Hat Developer
Hub and pre-existing customer installations of Backstage, extending

functionality and improving the overall experience. These 6 plug-ins are
the supported version of the community plug-ins:

Authentication and Authorization with Keycloak: Load users and
groups from Keycloak to Backstage, enabling use of multiple
authentication providers applied to Backstage entities.

Multicluster View with Open Cluster Manager (OCM): This plug-
in provides a multicluster view from Open Cluster Manager’s

MultiClusterHub and MultiCluster Engine in Backstage.

Container Image Registry for Quay: The container image registry
for Quay improves the integration and speed of interactions with

https://developers.redhat.com/articles/2023/05/23/developers-guide-red-hat-developer-hub-and-janus#

2/8

2/21/26, 3:24 PM

A developer’s guide to Red Hat Developer Hub and Janus | Red Hat Developer

Quay registries by providing a view into the container image details.
This includes Common Vulnerabilities and Exposures (CVEs)

associated with deployed images.

Application Topology for Kubernetes: Consistently visualize

relationships and real-time status of applications and workloads
deployed to any Kubernetes target, including Red Hat OpenShift.

Pipelines with Tekton: This plug-in provides details of all Tekton
Pipelines and their status across all services.

GitOps with Argo CD: Track the health and status of Argo CD and

monitor services inside Backstage.

Streamline onboarding with Golden Path
templates

Red Hat Developer Hub provides Golden Path templates that are
essential for fast-tracking development and ensuring organization and

consistency. These templates are referred to as golden because they
provide gold-standard best practices for developers to follow so your
code will be coherent, scalable, and maintainable.

You can streamline application and developer onboarding with Golden
Path templates. Golden Paths provide pre-architected and supported

approaches to building and deploying a particular piece of software
without having to learn all the details of the technology used.

Templates enable self-service for developers. They also provide the best

pathway to fix bugs or implement features, enabling developers to speed
up the process, thereby making your organization more competitive.

The two sides of Red Hat Developer Hub

We will explain Red Hat Developer Hub by describing it from two sides—
consumption and configuration—and two points of view (i.e., the
developer and the DevOps administrator.)

From a consumption perspective, Red Hat Developer Hub perfectly
matches the functionality needed for the developer as part of the inner
loop. For the first time, a developer has a single place to find everything,

https://developers.redhat.com/articles/2023/05/23/developers-guide-red-hat-developer-hub-and-janus#

3/8

2/21/26, 3:24 PM

A developer’s guide to Red Hat Developer Hub and Janus | Red Hat Developer

from links, integrated development environments (IDEs), and GitHub
repos, to documentation and components catalogs added to applications.

How Red Hat Developer Hub benefits developers

Red Hat Developer Hub provides a single place for a developer to work.
Finally, there’s a hub for all things a developer needs, such as resources,

clusters, and templates. Red Hat Developer Hub provides complete
coverage of the inner loop, IDE, direction interaction, and authentication
to GitHub.

Developers must understand the complexity of the various tools they use.
Learning numerous toolsets as well as the ins and outs of the frameworks,

technologies, and components of their organization can be time
consuming. The primary goal of Red Hat Developer Hub is to ease the
development process and provide an aggregated toolset that reduces the
mental overhead of context switching and searching for the core
components they need.

Red Hat Developer Hub provides a wizard and template-driven
experience for end developers. This makes it very easy to build complex
systems from multiple components, including Git source-driven
deployments to systems such as Kubernetes and OpenShift. In addition,
the provisioning of these components simplifies the knowledge the
developer needs. With a couple of clicks and text entry points, developers
can convert a template to a running application component without
knowing the convoluted technology beneath it.

This gives developers more time to spend on developing rather than
configuring development environments and components. Not only is the
developer presented with a rich set of components from which to choose,
but system administrators can configure these components.

How Red Hat Developer Hub benefits administrators

Red Hat Developer Hub is built on the Janus open source project, which
extends the Backstage open source project, providing a highly
configurable and secure development portal and catalog to control which
components can be built together. Red Hat Developer Hub extends the
functionality through a set of predefined supported plug-ins providing

https://developers.redhat.com/articles/2023/05/23/developers-guide-red-hat-developer-hub-and-janus#

4/8

2/21/26, 3:24 PM

A developer’s guide to Red Hat Developer Hub and Janus | Red Hat Developer

extensions and components to ease the developer's path as they design
and build composite applications.

Using code-as-config, administrators can control exactly what developers

can interact with and at what level, providing a simple to use and simple to
configure mechanism for providing developers with a single point for all
things development.

Red Hat Developer Hub also provides a highly configurable authentication
model, allowing integration with providers such as GitHub and Keycloak.

Administrators can configure authentication methods, templates (i.e.,
multi-component quick starts and API definitions), and the base
definitions. This is a sophisticated tool for building organizational
developer portals.

Red Hat Developer Hub increases productivity
and more

Red Hat Developer Hub is designed to significantly improve engineering
productivity for IT organizations, enabling development teams to focus on
what really matters—writing high-quality code and accelerating
application delivery to give organizations a competitive advantage.

Learn more by visiting the Red Hat Developer Hub.

Last updated: November 17, 2023

Related Posts

Red Hat joins the Backstage.io community

How the new RHEL 9.2 improves the developer experience

How to create a better front-end developer experience

What is Podman Desktop? A developer's introduction

Git best practices: Workflows for GitOps deployments

https://developers.redhat.com/articles/2023/05/23/developers-guide-red-hat-developer-hub-and-janus#

5/8

2/21/26, 3:24 PM

A developer’s guide to Red Hat Developer Hub and Janus | Red Hat Developer

Recent Posts

OpenShift networking evolved: Real routing, no NAT or asymmetry

Understanding ATen: PyTorch's tensor library

Reimagining Red Hat Enterprise Linux image creation with Red Hat

Lightspeed Model Context Protocol

Control updates with download-only mode in bootc

Optimize infrastructure health with Red Hat Lightspeed MCP

What’s up next?

Download The Modern Developer to get up to

speed on the latest trends in application
development, including an overview of the
internal developer platform (IDP) and inner loop
and outer loop constructs.

Get the e-book

https://developers.redhat.com/articles/2023/05/23/developers-guide-red-hat-developer-hub-and-janus#

6/8

2/21/26, 3:24 PM

A developer’s guide to Red Hat Developer Hub and Janus | Red Hat Developer

Platforms

Build

Quicklinks

Communicate

RED HAT DEVELOPER

Build here. Go anywhere.

We serve the builders. The problem solvers who create careers with code.

Join us if you’re a developer, software engineer, web designer, front-end designer,

UX designer, computer scientist, architect, tester, product manager, project
manager or team lead.

Sign me up

About Red Hat

Jobs

Events

Locations

Contact Red Hat

Red Hat Blog

Inclusion at Red Hat

Cool Stuff Store

Red Hat Summit

https://developers.redhat.com/articles/2023/05/23/developers-guide-red-hat-developer-hub-and-janus#

7/8

2/21/26, 3:24 PM

A developer’s guide to Red Hat Developer Hub and Janus | Red Hat Developer

© 2025 Red Hat

Privacy statement

Terms of use

All policies and guidelines

Digital accessibility

Cookie preferences

https://developers.redhat.com/articles/2023/05/23/developers-guide-red-hat-developer-hub-and-janus#

8/8

