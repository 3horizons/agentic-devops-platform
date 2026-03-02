2/21/26, 3:25 PM

Improving front-end developer experience | Red Hat Developer

How to create a better front-end
developer experience

June 1, 2021

Zackary Allen

Related topics: CI/CD, DevOps

Related products: Developer Tools

  Table of contents:



Who are the first users of a new feature or new application? If you think

they are customers, think again.

The first users are actually the front-end developers, and their experience

testing those new applications and features makes your first user

experience (UX). If your front-end developers have a smooth experience

developing new products, your users will almost always have a smooth

experience using them.

Take developing a form using React, for example. If developers are able to

develop the form without any difficulty, it will likely be a positive

experience for the customer as well. The reason? The developer had to fill
out the form to test it. If tweaking the form takes one second but filling it

out takes one minute, the developer will probably find a way to reduce the
feedback loop. It might be reduced through technical means by

integrating with browsers that autofill address fields, or by advising the
design team that the form could be split up so it can be more modularly

tweaked and tested. Whatever the case, developers tend to write software
consistent with their tools.

That's why UX design teams should strive to not only improve the end-

user experience in their products, but also streamline the experience of
the developers who build them. Developer experience refers to the

workflow developers move through as they write, update, and maintain
code for each release. From local build tooling to shared workflows and

https://developers.redhat.com/articles/2021/06/01/how-create-better-front-end-developer-experience

1/8

2/21/26, 3:25 PM

Improving front-end developer experience | Red Hat Developer

shared deployments, strong developer experience paves the path for solid

UX.

In this article, we'll explore common pain points that can complicate the
development process and how to address them to foster better developer

experiences.

What makes a good developer experience?

Front-end developers want to be able to write code to add features in an

environment that closely resembles what users will encounter in the end
product. After committing and pushing their code changes, they'd

typically like to run tests to make sure their changes don't break anything
unexpectedly. Beyond test validation, front-end developers might want to
validate new features by sharing a link with stakeholders. Once their

changes meet the stakeholders' criteria, developers want their code to
make its way into the central repository and then to end users. Sometimes
the new features reach end users as soon as the changes are merged, and
sometimes that transition happens on a time-based schedule.

A strong front-end developer experience moves smoothly through each

of these phases. Unfortunately, few front-end development experiences
are seamless.

Common pain points for front-end developers

Common front-end development pain points span three main areas:
environments, testing, and releases. Often, front-end development
environments lack key features that end-user environments have, such as

authorization or live data. Frequently, networking pieces are missing or
need to be properly proxied to test these environments. And speaking of
tests, they don't write, run, or analyze themselves!

There's no silver bullet that solves any of these problems, yet front-end
developers spend a significant portion of their time on them. Let's

examine each of these pain points in detail, and look at methods front-
end developers and DevOps engineers can use to help solve them.

Pain point #1: Environments

https://developers.redhat.com/articles/2021/06/01/how-create-better-front-end-developer-experience

2/8

2/21/26, 3:25 PM

Improving front-end developer experience | Red Hat Developer

While most front ends start standalone, few continue on their own
because they usually need certain back-end services. Back-end

developers can develop without a front end, but front-end developers
certainly can’t develop without a back end. In general, there are three
solutions to running back-end services to use against a local front end:

1. Run the back-end services locally (see Figure 1).

2. Use a shared back-end deployment.

3. Use mock data in your front end.

Solutions one and three allow offline development. While an internet

connection is a given nowadays, offline development is still a better
experience than online development for developers who travel or live in
places that experience intermittent outages due to weather. Offline

development also doesn't require a VPN, which can be difficult to set up
on certain devices.

Figure 1: Hot-reloading changes with Webpack on a local cloud.redhat.com
environment with back-end services running locally.

Solutions one and two require an extra step to run a command before
developing the front end. The local back end might need additional
configuration (like a database), and a shared back end might require a
proxy. This leads to a worse developer experience but can help catch
back-end bugs earlier than mocking the data might.

The third solution provides the best overall developer experience but
requires the most work, because each back-end endpoint must be

https://developers.redhat.com/articles/2021/06/01/how-create-better-front-end-developer-experience

3/8

2/21/26, 3:25 PM

Improving front-end developer experience | Red Hat Developer

spoofed to return mocked data. This requires front-end and back-end
developers working together to create mocks.

The first solution provides the best back-end developer experience
because they can test local back-end changes against a front end.

The environment is the first pain point that needs solving for front-end
developers, and is generally the hardest of the common pain points to get
right. Being able to work offline is a good experience. Not having to run a

back end to make front end changes is a great experience.

Pain point #2: Testing

Most front ends don't start out needing tests. However, as they grow, it's
important that the user experience doesn't degrade when adding new
features or fixing unrelated bugs. Writing, running, and reporting tests can
be painful. Let's take a look at how to ease the testing process across two
different front-end testing categories: unit tests and integration tests.

Unit tests

The best way to make test writing easier is only to write tests that are
important. Adding automatic snapshot tests for custom components can
help catch bugs. After that, spend time testing event and state
interactions. When developing tests, most tools have a watch mode that

can be used to run tests only when the test files change.

Integration tests

With certain frameworks, it’s possible to record user interactions on a
webpage to avoid coding the test cases yourself. For large test suites,
tools like BrowserStack offer a grid of 10 concurrent runners for free and

open source accounts.

Reporting tests

There are dozens of reporting formats, but HTML reports that can be
uploaded to a pull request (PR) like the one shown in Figure 2 are usually
best. For unit tests, tools like Codecov can help maintain a certain

coverage percentage as well.

https://developers.redhat.com/articles/2021/06/01/how-create-better-front-end-developer-experience

4/8

2/21/26, 3:25 PM

Improving front-end developer experience | Red Hat Developer

Figure 2: An HTML accessibility report for a pull request complete with screenshots.

Pain point #3: Releasing

When opening a pull request, it’s often useful to share changes with
designers and other developers in the form of a PR preview. If you just
need to host static files, services like Netlify can work with minimal
configuration, or a service like Surge can work with an existing continuous
integration (CI) system. For sites that also need a back end, Vercel and

Heroku have free tiers sufficient for most deployments.

For releasing, tools like semantic-release for normal repos and Lerna for
monorepos (see Figure 3) can release to Git, GitHub, or Node Package
Manager (npm) on every push to the main branch of your repository. Of
course, there's always the option to write your own bash script for

complete flexibility.

https://developers.redhat.com/articles/2021/06/01/how-create-better-front-end-developer-experience

5/8

2/21/26, 3:25 PM

Improving front-end developer experience | Red Hat Developer

Figure 3: Lerna auto-releasing @patternfly/react-* packages to npm from a
merged pull request.

Conclusion: Developer experience is user
experience

Improving the front-end developer experience lowers the cost of front-
end development and enhances the overall user experience. Addressing
front-end developer pain points will look different for every project, but
the payoff is the same: A smoother experience for developers carries

through to your end users.

Last updated: February 5, 2024

Recent Posts

OpenShift networking evolved: Real routing, no NAT or asymmetry

Understanding ATen: PyTorch's tensor library

Reimagining Red Hat Enterprise Linux image creation with Red Hat

Lightspeed Model Context Protocol

Control updates with download-only mode in bootc

Optimize infrastructure health with Red Hat Lightspeed MCP

https://developers.redhat.com/articles/2021/06/01/how-create-better-front-end-developer-experience

6/8

2/21/26, 3:25 PM

Improving front-end developer experience | Red Hat Developer

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

https://developers.redhat.com/articles/2021/06/01/how-create-better-front-end-developer-experience

7/8

2/21/26, 3:25 PM

Improving front-end developer experience | Red Hat Developer

© 2025 Red Hat

Privacy statement

Terms of use

All policies and guidelines

Digital accessibility

Cookie preferences

https://developers.redhat.com/articles/2021/06/01/how-create-better-front-end-developer-experience

8/8

