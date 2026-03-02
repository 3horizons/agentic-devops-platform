2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

How golden paths improve developer
productivity

Enter hyperspace with golden paths: A guide to developer productivity

January 29, 2025

Josephine Pfeiffer

Related topics: Developer productivity, Developer tools, IDEs

Related products: Developer Tools, Red Hat OpenShift Dev Spaces,

Red Hat Developer Hub

  Table of contents:



Building software is hard enough without getting bogged down by

repetitive tasks, endless approval chains, and inconsistent tooling. Enter

golden paths—the shortcuts every developer wishes they had. They’re not

just about speed. They’re about freeing your brain to focus on the good

stuff: writing code, solving problems, and shipping features.

This guide explores how golden paths and software templates can

transform your workflow from chaos to cosmos. We’ll cover how to set

them up, why they matter, and where they might trip you up. By the end,
you’ll have a clear map to hyperspace your way to faster, more secure, and

less frustrating development.

The purpose of golden paths

Golden paths are the tried-and-true methods that guide developers and

engineers through the most efficient way to tackle common tasks. Think
of them as the rails that keep you from wandering off into chaos. They

provide structure and ensure consistent best practices compliance, saving
time and cognitive load.

Using infrastructure as code (IaC) to automate underlying infrastructure

was a driving force for DevOps. But that automation failed developers. It

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

1/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

was self-service, but there were hundreds of configuration fields to be

filled out. It's the same with DevSecOps. Developers can't (and shouldn't)
be infrastructure or security experts.

Golden paths shift that responsibility onto systems rather than people.

They integrate configuration and security guidelines and bake in policies
and rules for proactive prevention, making a developer's work secure by

default.

The role of software templates

Software templates make golden paths come to life. They are prewritten

pieces of code/config that allow us to implement golden paths
automatically. When you need a CI/CD pipeline, database provisioning, or
a Git repo set up according to compliance rules, you can push a button or

issue a command, and it’s done.

IaC is like putting your thumb out to hitchhike. Software templates are like
getting in the car. They’re not just about provisioning infrastructure, but
also ensuring that everything is done consistently and securely for
developers—every single time.

Implementing golden paths

Implementing your golden path starts with a data-driven approach:

analyze workflows to identify repetitive, tedious tasks, and standardize
how they’re addressed using software templates. By mapping pain points
such as inconsistent processes, error-prone configurations, or redundant
approvals, you can create templates that enforce best practices and

streamline common tasks.

Once these templates are in place, you can integrate developer-friendly
tools like Red Hat OpenShift Dev Spaces to ensure a consistent
experience. With preconfigured linting, docs generation, and debugging
setups baked into the environment, developers can focus on coding

instead of fighting their tools, catching issues early, and avoiding costly
mistakes down the line.

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

2/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

Case study: Managing Terraform projects with
Developer Hub and OpenShift Dev Spaces

Organizations face common challenges when using Terraform, such as

enforcing standards, setting guardrails, cloud cost awareness, and
consistent tooling. Let’s explore how we can address these challenges
with golden paths in Red Hat Developer Hub and OpenShift Dev Spaces.

Developer Hub basics

You can refer a full code example on GitHub.

In Developer Hub (Figure 1), a template resource serves as the foundation
for scaffolding a project or automating a process. It defines:

Inputs: The parameters that the end user (e.g., a developer) must
provide, like project name, instance type, or region.

Outputs: The resources or configurations that will be generated
based on the provided inputs, such as a Terraform project, CI/CD
pipelines, or standardized code structures.

Created by Josephine Pfeiffer, License – under Apache 2.0.

Figure 1: Red Hat Developer Hub template editor.

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

3/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

A Developer Hub template structures a terraform project automatically,
generating the following resources out of a project skeleton using
scaffolding:

❯ tree
.

├── catalog-info.yaml

├── devfile.yaml
└── terraform

    ├── main.tf
    ├── outputs.tf

    ├── terraform.tfvars
    └── variables.tf

2 directories, 6 files

Copy snippet

Scaffolding creates a structured starting point for a project based on the
user’s inputs. This ensures that the required files are ready, so developers
don’t start from scratch, as follows:

(...)
  steps:

    - id: generateTerraform

      name: Generating Terraform Configuration

      action: fetch:template
      input:

        url: ./terraform-skeleton

        values:

          projectName: ${{ parameters.repoName }}

          instanceType: ${{ parameters.instanceType }}

          databaseType: ${{ parameters.databaseType }}

          securityGroupType: ${{ parameters.securityGroupType

          dataType: ${{ parameters.dataType }}
          region: ${{ parameters.location }}

          orgName: ${{ parameters.orgName }}

          repoName: ${{ parameters.repoName }}
          owner: ${{ parameters.owner }}

          system: ${{ parameters.system }}
          applicationType: api
          description: ${{ parameters.description }}

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

4/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

          sourceControl: gitlab-gitlab.apps.cluster-vxdd5.vxd

(...)

Copy snippet

The template’s  publish  action creates the project repository, passing
along config. In this case, we dynamically set the  repoUrl , and pre-fill
projectVariables :

(...)

    - id: publish

      name: Publishing Terraform Project to GitLab

      action: publish:gitlab

      input:

        repoUrl: gitlab-gitlab.apps.cluster-vxdd5.vxdd5.sandb

        description: Terraform project for ${{ parameters.rep

        defaultBranch: main

        projectVariables:

          - key: 'INFRACOST_API_KEY'

            value: ''

            protected: false

            masked: true

(...)

Copy snippet

The  output  section in the template defines dynamic links that will be
displayed for the user after the template execution is complete. The
following links provide quick access to key resources generated or

affected during the process:

(...)

  output:
    links:

      - title: Open the Terraform Repository in GitLab
        url: ${{ steps.publish.output.remoteUrl }}

      - title: Open the Catalog Info Component

        icon: catalog
        entityRef: ${{ steps.publish.output.entityRef }}

(...)

Copy snippet

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

5/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

In our case, it looks like outputs shown in Figure 2.

Created by Josephine Pfeiffer,

Figure 2: Red Hat Developer Hub scaffolding process outputs.

Enforcing standards and setting guardrails

Templates enforce compliance from day zero. They ensure valid inputs
(e.g., repo names and instance types) and logical defaults (e.g., AWS

regions). For example, selecting "public data" limits region choices to
Europe or the United States. Selecting "customer data" forces Zurich to
be the only option.

Constraints like  maxLength  and regex patterns prevent invalid input.
For example,  repoName  must start with a letter and only contain
alphanumeric characters or hyphens:

(...)

      properties:

        repoName:
          title: Repository Name

          type: string

          maxLength: 16

          pattern: '^([a-zA-Z][a-zA-Z0-9]*)(-[a-zA-Z0-9]+)*$

          ui:autofocus: true

          ui:help: 'Must be alphanumeric, 1-16 characters, st

(...)

Copy snippet

In the template, we can set guardrails for allowed instance types, as shown
in the following example:

(...)
      properties:

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

6/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

        instanceType:
          title: Compute Instance Type (AWS Graviton)
          type: string

          enum:
            - t4g.micro
            - t4g.small

            - t4g.medium
          description: Select the Graviton instance type
(...)

Copy snippet

When we're setting up our infrastructure, the type of data we're handling

directly impacts the region where we can store it. If the data type is
public_data , we have the flexibility to pick between regions like  eu-
central-1  (Frankfurt),  us-east-1  (Virginia), or  eu-central-2
(Zurich). However, if we're dealing with  customer_data , our choice is
restricted to  eu-central-2  only. This could ensure that customer
information is kept within a specific geographic boundary to comply with
local privacy regulations, as follows:

(...)
        dataType:

          title: Data Type

          type: string

          enum:
            - customer_data

            - employee_data

            - public_data

          enumNames:

            - customer data

            - employee data

            - public data

          description: Select the type of data being processe
        location:

          title: AWS Region

          type: string
          enum:

            - eu-central-1
            - us-east-1
            - eu-central-2

          enumNames:

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

7/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

            - Frankfurt

            - Virginia

            - Zurich

          description: Choose the AWS region for your infrast

          ui:options:

            conditional:

              dataType: public_data

              allowedValues:

                - eu-central-1

                - us-east-1

                - eu-central-2

              defaultValues: eu-central-2

      dependencies:

        dataType:

          allOf:

            - if:

                properties:

                  dataType:
                    const: public_data

              then:

                properties:

                  location:
                    enum:

                      - eu-central-1

                      - us-east-1

                      - eu-central-2

                    enumNames:
                      - Frankfurt

                      - Virginia

                      - Zurich

            - if:

                properties:
                  dataType:
                    const: customer_data
              then:

                properties:
                  location:
                    enum:
                      - eu-central-2
                    enumNames:

                      - Zurich
(...)

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

8/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

Copy snippet

In its final form, the user interacts with an interface like Figure 3.

Created by Josephine Pfeiffer,

Figure 3: Comparison of logic gates in a software template.

In the image shown in Figure 3, selecting Public Data on the left allows
the user to select three AWS regions. On the right, selecting Customer
Data allows the user to select only one region.

Scaffolding syntax supports logic which allows us to define some default
behaviors and conditions to simplify reuse and reduce redundancy.

The following example checks if  values.instanceType  exists. If true,
it's assigned to  instance_type . Otherwise, it defaults to
"t4g.micro"  as follows:

(...)
{%- if values.instanceType %}
instance_type = "${{ values.instanceType }}"

{%- else %}
instance_type = "t4g.micro"
{%- endif %}
(...)

Copy snippet

The next example determines the  vpc_id  based on the region. If it's
"us-east-1" ,  "eu-central-1" , or  "eu-central-2" , it gets a
specific VPC. If it is anything else, it defaults back to  "vpc-
0e2fd71e4d9b6fec5"  as follows:

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

9/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

(...)
{%- if region == "us-east-1" %}
vpc_id = "vpc-0e2fd71e4d9b6fec5"
{%- elif region == "eu-central-1" %}

vpc_id = "vpc-3707605d"
{%- elif region == "eu-central-2" %}
vpc_id = "vpc-09321946b9adb23fa"
{%- else %}

vpc_id = "vpc-0e2fd71e4d9b6fec5"
{%- endif %}

Copy snippet

Cost awareness

Managing costs in the cloud is an important topic, and many organizations
who go to the cloud are doing it wrong. When I was the CTO at a startup,
my personal credit card was the payment method for the company's AWS
account. Believe me, there is no better way to keep costs managed than
that. A less nerve-wracking approach is integrating FinOps practices by
shifting cloud cost analysis left. This promotes accountability early and
transparently projects cost upfront.

In our example, we achieved this by baking CI jobs into the scaffolded
project, which generates projected cost reports for every merge request,

as shown in Figure 4.

Created by Josephine Pfeiffer,

Figure 4: Cost Report generated based on terraform code.

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

10/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

Consistent tooling

Devfiles standardize environments, bundling integrated development
environment (IDE) configs, containers, and commands into a unified
setup. They are a mechanism for teams to share configurations across
projects and provide a single source of truth throughout the application
lifecycle.

In our example, we can preinstall the Terraform extension for VS Code as
follows:

  .vscode/extensions.json: |
{

   "recommendations": [
         "hashicorp.terraform"
       ]
}

Copy snippet

To define standardized commands, we can run right in the IDE, shifting left

even further from the CI pipeline. The following example automatically
generates documentation for the Terraform code we write:

(...)
commands:
  - id: generate-docs
exec:
   component: terraform-tools

   commandLine: "terraform-docs markdown . > ../docs.md"
   workingDir: ${PROJECTS_ROOT}/galaxy/terraform
   group:
     kind: build
     isDefault: false
(...)

Copy snippet

The development environment uses a custom container image packaged

with the required tooling for infrastructure projects. For other use cases
like developing Quarkus or Node.js apps, you might want to build a

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

11/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

different container image that includes the tooling for those frameworks
as follows:

(...)
components:
  - name: terraform-tools
container:
   image: quay.io/pfeifferj/tfdev:latest

   memoryLimit: 512Mi
   cpuLimit: "1"
   mountSources: true
   volumeMounts:
     - name: terraform-data
       path: ${PROJECTS_ROOT}/galaxy/terraform
(...)

Copy snippet

Putting everything together, we just scaffolded our development
environment for this project as shown in Figure 5.

Created by Josephine Pfeiffer,

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

12/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

Figure 5: OpenShift Dev Spaces web development environment.

The documentation we generated with our  tf-docs  task is shown in
Figure 6.

Created by Josephine Pfeiffer,

Figure 6: Documentation automatically generated by tf-docs task.

4 benefits of golden paths

The ultimate question: Why bother with golden paths? When deciding

whether to utilize golden paths, consider the many benefits they offer.

4 golden path benefits:

1. Reduces cognitive load: Standardized processes free up mental

space for innovation.

2. Better security: Shift left without requiring developers to be
security experts. Templates ensure built-in security practices.

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

13/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

3. Faster development: Standardization means no more reinventing

the wheel.

4. Simplified compliance and auditing: You can meet security

standards using templates, making audits painless.

Golden path pitfalls

When utilizing golden paths, be wary of these issues that may present
themselves:

Outdated templates: If templates aren't regularly updated, they
can embed obsolete or insecure practices.

Over-reliance: Developers might become too dependent on
templates, stifling innovation or producing cookie-cutter solutions

that don't fit specific needs.

Security blind spots: Templates can create a false sense of security

if not implemented correctly, which could introduce vulnerabilities.

Lifecycle management is essential. You can’t just set up templates and
forget them. They need continuous updates to adapt to new technologies,

security threats, and user needs. A dedicated team should treat these
templates as a product, evolving them as the galaxy shifts.

Wrapping up

Golden paths and software templates accelerate developer productivity,
enhance security, and reduce frustration. If Infrastructure as Code was the

start, golden paths are the hyperspace jump that takes you where you
need to go, efficiently and with enhanced security.

Learn more about Red Hat Trusted Software Supply Chain, Red Hat

Developer Hub, and explore what shift security left means.

Related Posts

Red Hat OpenShift Dev Spaces security best practices

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

14/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

Integrate a private AI coding assistant into your CDE using Ollama,

Continue, and OpenShift Dev Spaces

Efficient image builds with FUSE in Red Hat OpenShift Dev Spaces

A developer’s guide to Red Hat Developer Hub and Janus

Red Hat Developer Hub: Your gateway to seamless development

Recent Posts

OpenShift networking evolved: Real routing, no NAT or asymmetry

Understanding ATen: PyTorch's tensor library

Reimagining Red Hat Enterprise Linux image creation with Red Hat

Lightspeed Model Context Protocol

Control updates with download-only mode in bootc

Optimize infrastructure health with Red Hat Lightspeed MCP

What’s up next?

Learn how to onboard developers onto Red Hat
Developer Hub so they can import and use
relevant templates and run the application on
the development environment.

Start the activity

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

15/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

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

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

16/17

2/21/26, 3:23 PM

How golden paths improve developer productivity | Red Hat Developer

© 2025 Red Hat

Privacy statement

Terms of use

All policies and guidelines

Digital accessibility

Cookie preferences

https://developers.redhat.com/articles/2025/01/29/how-golden-paths-improve-developer-productivity#

17/17

