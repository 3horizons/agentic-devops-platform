Red Hat Developer Hub 1.8

Manage and consume technical documentation
within Red Hat Developer Hub

Managing the documentation lifecycle - add, search, view, and edit content - using
the TechDocs plugin in Red Hat Developer Hub (RHDH)

Last Updated: 2026-02-18

Red Hat Developer Hub 1.8 Manage and consume technical
documentation within Red Hat Developer Hub

Managing the documentation lifecycle - add, search, view, and edit content - using the TechDocs
plugin in Red Hat Developer Hub (RHDH)

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

The TechDocs plugin empowers developers by providing a complete documentation lifecycle
management tool. Authorized administrators set up the service, allowing developers to manage
documentation directly in Red Hat Developer Hub (RHDH), including adding new content,
searching, viewing, and making edits.

Table of Contents

Table of Contents

CHAPTER 1. ADDING DOCUMENTATION TO TECHDOCS FOR YOUR PROJECT
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

3

1.1. IMPORTING DOCUMENTATION INTO TECHDOCS FROM A REMOTE REPOSITORY

3

CHAPTER 2. SEARCHING FOR RELEVANT CONTENT IN TECHDOCS
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

4

CHAPTER 3. ACCESSING AND READING DOCUMENTATION IN TECHDOCS
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

5

CHAPTER 4. MAKING CHANGES TO PROJECT DOCUMENTATION IN TECHDOCS
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

6

CHAPTER 5. ADDING VIDEO CONTENT TO ENHANCE TECHDOCS
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

7

CHAPTER 6. STREAMLINING DOCUMENTATION BUILDS USING GITHUB ACTIONS
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

9

1

Red Hat Developer Hub 1.8 Manage and consume technical documentation within Red Hat Developer Hub

2

CHAPTER 1. ADDING DOCUMENTATION TO TECHDOCS FOR YOUR PROJECT

CHAPTER 1. ADDING DOCUMENTATION TO TECHDOCS FOR
YOUR PROJECT

After an administrator configures the TechDocs plugin, a developer can add documentation to
TechDocs by importing it from a remote repository. Any authorized user or group can access the
documentation that is imported into the TechDocs plugin.

1.1. IMPORTING DOCUMENTATION INTO TECHDOCS FROM A REMOTE
REPOSITORY

Teams can store their documentation files in the same remote repository where they store their code
files. You can import documentation into your TechDocs plugin from a remote repository that contains
the documentation files that your team uses.

Prerequisites

Your organization has documentation files stored in a remote repository.

You have a mkdocs.yaml file in the root directory of your repository.

You have the catalog.entity.create and catalog.location.create permissions to import
documentation into TechDocs from a remote repository.

Procedure

1.  In your Red Hat Developer Hub instance, click Catalog > Self-service > Register Existing

Component.

2.  In the Select URL box, enter the URL to the  catalog-info.yaml file that you want to import

from your repository using the following format:
https://github.com/<project_name>/<repo_name>/blob/<branch_name>/<file_directory>/c
atalog-info.yaml

3.  Click Analyze

4.  Click Finish

Verification

1.  In the Red Hat Developer Hub navigation menu, click Docs.

2.  Verify that the documentation that you imported is listed in the table on the Documentation

page.

3

Red Hat Developer Hub 1.8 Manage and consume technical documentation within Red Hat Developer Hub

CHAPTER 2. SEARCHING FOR RELEVANT CONTENT IN
TECHDOCS

By default, the TechDocs plugin Documentation page shows all of the documentation that your
organization has imported into your Red Hat Developer Hub instance. You can use any combination of
the following methods to find the documentation that you want to view:

Enter a keyword in the search bar to see all documents that contain the keyword anywhere in
the document.

Filter by Owner to see only documents that are owned by a particular user or group in your
organization.

Filter by Tags to see only documents that contain a particular tag.

Filter by Owned to see only documents that are owned by you or by a group that you belong

Filter by Starred to see only documents that you have added to favorites.

By default, the All field shows the total number of documents that have been imported into TechDocs. If
you search or use filters, the All field shows the number of documents that meet the search and filter
criteria that you applied.

Prerequisites

The TechDocs plugin is enabled and configured

Documentation is imported into TechDocs

You have the required roles and permissions to add and view documentation to TechDocs

Procedure

1.  In the Red Hat Developer Hub navigation menu, click Docs.

2.  On the Documentation page, use the search bar, filters, or both to locate the document that

you want to view.

4

CHAPTER 3. ACCESSING AND READING DOCUMENTATION IN TECHDOCS

CHAPTER 3. ACCESSING AND READING DOCUMENTATION IN
TECHDOCS

In TechDocs, a document might be part of a book that contains other documents that are related to the
same topic.

Clicking the name of a document in the table on the Documentation page opens the document in a
book page. The name of the book is displayed on book the page. The book page contains the following
elements:

The contents of the document.

A search bar that you can use to search for keywords within the document.

A navigation menu that you can use to navigate to other documents in the book.

A Table of contents that you can use to navigate to other sections of the document.

A Next button that you can use to navigate to the next sequential document in the book.

You can use the elements on the book page to search, view, and navigate the documentation in the
book.

Prerequisites

The TechDocs plugin in enabled and configured

Documentation is imported into TechDocs

You have the required roles and permissions to add and view documentation to TechDocs

Optional: TechDocs add-ons are installed and configured

Procedure

1.  In the Red Hat Developer Hub navigation menu, click Docs.

2.  In the Documentation table, click the name of the document that you want to view.

3.  On the book page, you can do any of the following optional actions:

Use installed add-ons that extend the functionality of the default TechDocs plugin.

Use the search bar to find keywords within the document.

Use any of the following methods to navigate the documentation in the book:

Use the Table of contents to navigate the any section of the document.

Use the navigation menu to navigate to any document in the book.

Click Next to navigate to the next sequential document in the book.

5

Red Hat Developer Hub 1.8 Manage and consume technical documentation within Red Hat Developer Hub

CHAPTER 4. MAKING CHANGES TO PROJECT
DOCUMENTATION IN TECHDOCS

You can edit a document in your TechDocs plugin directly from the document book page. Any
authorized user in your organization can edit a document regardless of whether or not they are the
owner of the document.

Procedure

1.  In the Red Hat Developer Hub navigation menu, click Docs.

2.  In the Documentation table, click the name of the document that you want to edit.

3.  In the document, click the Edit this page icon to open the document in your remote repository.

4.  In your remote repository, edit the document as needed.

5.  Use the repository provider UI and your usual team processes to commit and merge your

changes.

6

CHAPTER 5. ADDING VIDEO CONTENT TO ENHANCE TECHDOCS

CHAPTER 5. ADDING VIDEO CONTENT TO ENHANCE
TECHDOCS

You can use <iframe> elements to add video content to enhance your experience with TechDocs.

Prerequisites

An administrator has configured your AWS S3 bucket to store TechDocs sites.

An administrator has configured the appropriate techdocs.sanitizer.allowedIframeHosts and
backend.csp settings in your  app-config.yaml file.

Procedure

1.  In the section of the TechDocs file that you want to embed a video into, add the following

configuration:

<iframe
  width="<video_width>"
  height="<video_height>"
  src="<video_url>"
  title="<video_title>"
  frameborder="<frame_border>"
  allow="picture-in-picture"
  allowfullscreen>
</iframe>

where

<video_width>

Specifies the width of the video in number of pixels, for example, 672.

<video_height>

Specifies the height of the video in number of pixels, for example, 378.

<video_url>

Specifies the url of the video, for example, https://www.youtube.com/watch?
v=LB1w8hjBt5k.

<video_title>

Specifies the title of the video, for example, Red Hat Developer Hub Overview Video.

<frame_border>

Specifies the size of the frame border in number of pixels, for example, 0. Use a value of  0 for
no border.

NOTE

TechDocs uses DOMPurify to sanitize HTML. To prevent DOMPurify from
removing the <iframe> elements, you must list every permitted video host,
such as www.youtube.com, under the
techdocs.sanitizer.allowedIframeHosts section of your  app-config.yaml
file. You must also add the video host to the backend.csp section of your
app-config.yaml file.

7

Red Hat Developer Hub 1.8 Manage and consume technical documentation within Red Hat Developer Hub

2.  In the frame-src and allowedIframeHosts fields of your  app-config.yaml file, add any video

hosts that you want to use. You can add multiple hosts. For example:

backend:
        csp:
connect-src: ['https:']
frame-src: ['https://www.youtube.com/']
techdocs:
  builder: external
  sanitizer:
    allowedIframeHosts:
      - www.youtube.com
      - <additional_video_host_url>
  publisher:
    type: awsS3
    awsS3:
      bucketName: ${AWS_S3_BUCKET_NAME}
      accountId: ${AWS_ACCOUNT_ID}
      region: ${AWS_REGION}

8

CHAPTER 6. STREAMLINING DOCUMENTATION BUILDS USING GITHUB ACTIONS

CHAPTER 6. STREAMLINING DOCUMENTATION BUILDS
USING GITHUB ACTIONS

Red Hat Developer Hub (RHDH) includes a built-in TechDocs builder, however, the default setup is not
intended for production use. Deploying TechDocs documentation in a production environment involves
the following actions:

Building the documentation in a CI/CD system

Publishing the generated documentation site to external object storage, such as AWS S3, to
ensure that the generated documentation persists between restarts of RHDH and can handle
larger documentation workloads.

Configuring TechDocs in your RHDH deployment to run in read-only mode so that
TechDocs reads the static generated documentation files from the cloud storage bucket
without attempting to generate them at runtime.

You can implement a TechDocs pipeline using GitHub Actions to automatically generate and publish
your TechDocs whenever a user in your organization makes a change to a documentation file stored in
your GitHub repository.

Prerequisites

The TechDocs plugin is enabled and configured on your RHDH instance.

Your organization has documentation files stored in a remote repository.

You have an mkdocs.yaml file located in the root directory of your repository.

You have the catalog.entity.create and catalog.location.create permissions to import
documentation into TechDocs from a remote repository.

You have an AWS S3 bucket to store your TechDocs sites.

Minimal IAM Policies are configured for your S3 bucket, granting both Write and Read access.

An administrator has created an IAM User, attached the necessary policy, and generated an
access key in the AWS console.

Procedure

1.  Set up the GitHub Actions workflow.

a.  On GitHub, create a fork of the RHDH TechDocs Pipeline repository.

NOTE

The rhdh-techdocs-pipeline repository contains a  generate-and-publish-
techdocs.yaml workflow that automatically generates TechDocs from the
docs folder and publishes them to an Amazon S3 bucket.

b.  Use the GitHub GUI to make sure that all of the permissions required to run the workflow

are enabled.

c.  Add the Repository secrets required to connect the workflow to your AWS account, for

9

Red Hat Developer Hub 1.8 Manage and consume technical documentation within Red Hat Developer Hub

c.  Add the Repository secrets required to connect the workflow to your AWS account, for

example, TECHDOCS_S3_BUCKET_NAME, AWS_ACCESS_KEY_ID,
AWS_SECRET_ACCESS_KEY, AWS_REGION.

NOTE

The default mkdocs.yaml file in the  rhdh-techdocs-pipeline workflow
installs the techdocs-core and minify plugins.

d.  Optional: Customize the default structure or files of the rhdh-techdocs-pipeline

repository to meet the needs of your organization.

e.  Optional: Add other mkdocs plugins that you want to use by adding the name of the plugins
to the plugins section of the  mkdocs.yaml file and to the  steps.name: install mkdocs
and mkdocs plugins section of the  generate-and-publish-techdocs.yaml file.

2.  . In the navigation menu of the OpenShift Container Platform console, click ConfigMaps and

select your RHDH app-config.yaml file.

3.  Update the app-config.yaml file to enable your Amazon S3 bucket to serve TechDocs to your

RHDH instance. For example:

techdocs:
  builder: external
  publisher:
    type: awsS3
    awsS3:
      bucketName: ${AWS_S3_BUCKET_NAME}
      accountId: ${AWS_ACCOUNT_ID}
      region: ${AWS_REGION}

aws:
  accounts:
    - accountId: ${AWS_ACCOUNT_ID}
      accessKeyId: ${AWS_ACCESS_KEY_ID}
      secretAccessKey: ${AWS_SECRET_ACCESS_KEY}

catalog:
     locations:
        - type: url
          target: https://github.com/<your_org>/rhdh-techdocs-pipeline/blob/main/catalog-
info.yaml

4.  Click Save.

5.  In the navigation menu of the OpenShift Container Platform console, click Topology and

restart the pod.

NOTE

Changes to the docs folder or the mkdocs.yaml file trigger the  rhdh-techdocs-
pipeline workflow to run. After the  rhdh-techdocs-pipeline workflow runs
successfully, the generated TechDocs are uploaded to your Amazon S3 bucket.

10

CHAPTER 6. STREAMLINING DOCUMENTATION BUILDS USING GITHUB ACTIONS

Verification

1.  Go to your RHDH instance and click Docs to see the TechDocs served from your Amazon S3

bucket.

11

