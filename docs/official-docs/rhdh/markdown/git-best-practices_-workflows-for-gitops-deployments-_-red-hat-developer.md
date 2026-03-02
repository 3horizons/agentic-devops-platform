2/21/26, 3:25 PM

Git best practices: Workﬂows for GitOps deployments | Red Hat Developer

Git best practices: Workflows for GitOps
deployments

July 20, 2022

Christian Hernandez

Related topics: DevOps, GitOps, Kubernetes

Related products: Red Hat Advanced Cluster Management for

Kubernetes, Red Hat Advanced Cluster Security for

Kubernetes, Red Hat OpenShift

  Table of contents:



Note: The following is an excerpt from the e-book, The Path to

GitOps, which outlines Git best practices for GitOps deployment. You

can explore more best practices in How to set up your GitOps

directory structure.

Your Git workflows are at the center of your GitOps deployments because

workflows are the means of implementing your changes in your

environment. When you adopt GitOps, Git is not only your source of truth

(as it is for most projects) but also your interface into your environment.

Developers have used Git workflows for their application delivery method
for years, and now operations teams will have to adopt similar workflows.

But there are key differences between how you manage your code in Git

and how you manage your GitOps configuration in Git. Here I will go over
these differences and describe the best practices you should follow to

make the best use of Git workflows for your GitOps deployments. We will
see how to separate your configuration from your code, how to use

branches, how to use trunk-based development workflows effectively, and
tips for setting up policies and security for your Git workflows.

Separate your repositories

https://developers.redhat.com/articles/2022/07/20/git-workﬂows-best-practices-gitops-deployments

1/8

2/21/26, 3:25 PM

Git best practices: Workﬂows for GitOps deployments | Red Hat Developer

There are a few things to keep in mind when setting up your Git workflows

for your GitOps directory structure and GitOps in general. The first is to
keep your application code in a separate repository from your YAML

configurations. This might seem counterintuitive initially, but most teams
that start with code and configurations together quickly learn it’s better to

separate them.

There are a few reasons for separate repositories. First, you don’t want a
configuration change (such as changing the scale of a deployment from

three to four nodes) to trigger a rebuild of your application if your
application code didn’t change. Another reason is that the approval

process of getting a change into an environment shouldn’t hold back
continuous integration of your code. In general, application code and
configuration information have independent lifecycles.

Also, many organizations separate the deployment process into several

different teams. A lot of the time, the operations or release management
team takes care of the application’s release. Although DevOps aims to
reduce barriers between teams and their activities, you don’t want one
team’s process to slow down another.

Separate development in directories, not
branches

Another best practice that surprises many programmers is to separate
environments–such as test and production–into different directories, but
not create branches for them. Like the separation of code and

configurations, this principle might seem to go against the grain of version
control, but keeping track of environmental branches can be a challenge.

One of the difficulties you might encounter if you manage workflows
through branches is that promotion from one environment to another isn’t
as simple as a merge. You can see this issue with a simple example of

updating an image tag. The application has been built, tested, and
deemed ready to go from a sandbox environment to a test environment.
But updating the image tag comes with other changes you don’t want to
merge. What about the scale in the Deployment? What about the

ConfigMaps and Secrets? Those are bound to change in different

https://developers.redhat.com/articles/2022/07/20/git-workﬂows-best-practices-gitops-deployments

2/8

2/21/26, 3:25 PM

Git best practices: Workﬂows for GitOps deployments | Red Hat Developer

environments and include things that should not be merged into other
environments.

In short, every environment has configuration details specific to that

environment. You can manually make the changes one by one or "cherry-
pick", but then your "simple merge" is no longer that simple. When you’re
constantly cherry-picking or making manual changes, the effort level

outweighs the benefits of trying to mirror the application workflows.

Another danger of using branches and cherry-picking your way into

production is that this will likely introduce a significant drift. As you get
further along in the life of a software project, when it spawns hundreds of
environments with dozens upon dozens of applications, you can quickly

see how cherry-picking and making manual changes can get out of hand.
You can no longer use a simple diff to see the differences between
branches, as the differences will be astronomical.

In the world of Kubernetes, the Kustomize patching framework, and the
Helm package manager, using branches for environments is an

antipattern. Kustomize and Helm make using directories and overlays for
your environments easier. Kustomize, in particular, allows you to have a
core set of manifests (called a "base" in Kustomize) and store the deltas in
directories (called "overlays" in Kustomize). You use these overlays as

directories with specific environment configurations in these directories.

So do you use branches at all? Yes, but not in the way you think. With
GitOps, trunk-based development has emerged as the development

model for your configuration repositories.

Trunk-based development

The recommended workflow for implementing GitOps with Kubernetes
manifests is known as trunk-based development. This method defines one
branch as the "trunk" and carries out development on each environment in
a different short-lived branch. When development is complete for that
environment, the developer creates a pull request for the branch to the

trunk. Developers can also create a fork to work on an environment, and
then create a branch to merge the fork into the trunk.

Once the proper approvals are done, the pull request (or the branch from
the fork) gets merged into the trunk. The branch for that feature is

https://developers.redhat.com/articles/2022/07/20/git-workﬂows-best-practices-gitops-deployments

3/8

2/21/26, 3:25 PM

Git best practices: Workﬂows for GitOps deployments | Red Hat Developer

deleted, keeping your branches to a minimum. Trunk-based development
trades branches for directories.

You can think of the trunk as a "main" or primary branch. production and
prod are popular names for the trunk branch.

Trunk-based development came about to enable continuous integration
and continuous delivery by supplying a development model focused on
the fast delivery of changes to applications. But this model also works for

GitOps repositories because it keeps things simple and more in tune with
how Kustomize and Helm work. When you record deltas between
environments, you can clearly see what changes will be merged into the
trunk. You won’t have to cherry-pick nearly as often, and you’ll have the
confidence that what is in your Git repository is what is actually going into
your environment. This is what you want in a GitOps workflow.

Pay attention to policies and security

Part of the challenge with trunk-based development is that now there is a
single branch where things can go wrong. When relying on Git as your
source of truth, it can be quite scary to depend on a single branch for not
only your production environment but your organization as a whole. So
you need to pay special attention to the features that version control
offers for policy management and security to protect your trunk and
provide stability to your environment.

When setting up your Git repository policies, use GitHub’s branch
protection rules (or the equivalent from other Git providers). Setting
branch protection rules provides several benefits, the most important of
which is preventing someone from force pushing a change into the trunk
(which in turn makes an immediate alteration to your environment).

Branch protection also protects the branch from being accidentally or
intentionally deleted. There are other advantages to protected branches,
but the main takeaway is this: You need to trust what is in Git because it is
in charge of managing your environment. Take every precaution that
builds trust.

Also, set up rules as to who can perform a merge and when. Make sure
that all affected parties in your organization see a proposed merge. For
example, perhaps a network change should be approved not only by the

https://developers.redhat.com/articles/2022/07/20/git-workﬂows-best-practices-gitops-deployments

4/8

2/21/26, 3:25 PM

Git best practices: Workﬂows for GitOps deployments | Red Hat Developer

system administration team but also by the networking team and the
security team. A rule can take the form of a "minimum number of
approvals," but that doesn’t limit the number of approvals to the minimum.
And while you’ll have multiple approvers, you should allow only a handful
of people to actually merge the change.

Next steps

There is much to discover about Git strategy and Git management.
Download The Path to GitOps to explore how GitOps fits in your CI/CD
(continuous integration/continuous delivery) pipelines and the various
ways to implement it. Discover popular tools like Argo CD and Flux and
learn how Kustomize, Helm, and Kubernetes Operators make it easier to
deal with lengthy configuration files.

Find even more GitOps resources from Red Hat Developer:

Getting GitOps: A practical platform with OpenShift, Argo CD, and
Tekton helps you put it all together by walking through a common

use case from beginning to end.

Get a preview of GitOps Cookbook, a collection of useful recipes to
follow GitOps practices on Kubernetes.

Last updated: September 20, 2023

Related Posts

How to set up your GitOps directory structure

Why should developers care about GitOps?

The present and future of CI/CD with GitOps on Red Hat OpenShift

Modern Fortune Teller: Using GitOps to automate application deployment

on Red Hat OpenShift

The present and future of CI/CD with GitOps on Red Hat OpenShift

https://developers.redhat.com/articles/2022/07/20/git-workﬂows-best-practices-gitops-deployments

5/8

2/21/26, 3:25 PM

Git best practices: Workﬂows for GitOps deployments | Red Hat Developer

Recent Posts

OpenShift networking evolved: Real routing, no NAT or asymmetry

Understanding ATen: PyTorch's tensor library

Reimagining Red Hat Enterprise Linux image creation with Red Hat

Lightspeed Model Context Protocol

Control updates with download-only mode in bootc

Optimize infrastructure health with Red Hat Lightspeed MCP

What’s up next?

GitOps delivers on the vision promised to a

DevOps culture, and organizations are starting
to realize how valuable it is to deliver products in
a fast, highly automated, and secure way without
compromising the quality of their code. Read
The Path to GitOps and discover the tools,
workflows, and structures teams need to have in
place in order to enable a complete GitOps
workflow.

Get the e-book

https://developers.redhat.com/articles/2022/07/20/git-workﬂows-best-practices-gitops-deployments

6/8

2/21/26, 3:25 PM

Git best practices: Workﬂows for GitOps deployments | Red Hat Developer

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

https://developers.redhat.com/articles/2022/07/20/git-workﬂows-best-practices-gitops-deployments

7/8

2/21/26, 3:25 PM

Git best practices: Workﬂows for GitOps deployments | Red Hat Developer

© 2025 Red Hat

Privacy statement

Terms of use

All policies and guidelines

Digital accessibility

Cookie preferences

https://developers.redhat.com/articles/2022/07/20/git-workﬂows-best-practices-gitops-deployments

8/8

