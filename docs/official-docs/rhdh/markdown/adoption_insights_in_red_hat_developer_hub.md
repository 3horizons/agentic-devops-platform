Red Hat Developer Hub 1.8

Adoption Insights in Red Hat Developer Hub

Delivering detailed analytics on adoption and engagement within your internal
developer portal

Last Updated: 2026-02-18

Red Hat Developer Hub 1.8 Adoption Insights in Red Hat Developer Hub

Delivering detailed analytics on adoption and engagement within your internal developer portal

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

As a platform engineer, you can configure Adoption Insights in Red Hat Developer Hub (RHDH) to
visualize key metrics and trends to get information about the usage of RHDH in your organization.

Table of Contents

Table of Contents

CHAPTER 1. ADOPTION INSIGHTS
. . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

3

1.1. CONFIGURING THE ADOPTION INSIGHTS PLUGIN IN RED HAT DEVELOPER HUB

1.2. CUSTOMIZING THE ADOPTION INSIGHTS PLUGIN IN RED HAT DEVELOPER HUB
1.3. USING ADOPTION INSIGHTS IN RED HAT DEVELOPER HUB

1.3.1. Setting the duration of data metrics

1.4. VIEWING THE ADOPTION INSIGHTS CARD

1.4.1. Viewing the active users

1.4.2. Viewing the total number of users
1.4.3. Viewing the top catalog entities

1.4.4. Viewing the top 3 templates
1.4.5. Viewing the top 3 techdocs

1.4.6. Viewing the top 3 plugins

1.5. MODIFYING THE NUMBER OF DISPLAYED RECORDS
1.6. FILTERING RECORDS TO DISPLAY SPECIFIC CATALOG ENTITIES IN TOP CATALOG ENTITIES

1.7. VIEWING SEARCHES

4

5
6

6
7

7

7
8

8
8

9

9
10

10

1

Red Hat Developer Hub 1.8 Adoption Insights in Red Hat Developer Hub

2

CHAPTER 1. ADOPTION INSIGHTS

CHAPTER 1. ADOPTION INSIGHTS

The Red Hat Developer Hub instance includes the Adoption Insights plugin preinstalled and enabled by
default.

As organizations generate an increasing number of data events, there is a growing need for detailed
insights into the adoption and engagement metrics of the internal developer portal. These insights help
platform engineers make data-driven decisions to improve its performance, usability, and translate them
into actionable insights.

You can use Adoption Insights in Red Hat Developer Hub to visualize key metrics and trends to get
information about the usage of Developer Hub in your organization. The information provided by
Adoption Insights in Developer Hub helps you pinpoint areas of improvement, highlights popular
features, and evaluates progress toward adoption goals. You can also monitor user growth against
licensed users and identify trends over time.

The Adoption Insights dashboard in Developer Hub includes the following cards:

Active users

Total number of users

Top catalog entities

Top 3 templates

Top 3 techdocs

Top 3 plugins

Portal searches

3

Red Hat Developer Hub 1.8 Adoption Insights in Red Hat Developer Hub

1.1. CONFIGURING THE ADOPTION INSIGHTS PLUGIN IN RED HAT
DEVELOPER HUB

The Adoption Insights plugin is preinstalled and enabled on a Developer Hub instance by default. You
can disable or enable the Adoption Insights plugin and change other parameters, by configuring the app-
config ConfigMap, which is created by the Red Hat Developer Hub Helm chart or Operator.

IMPORTANT

4

CHAPTER 1. ADOPTION INSIGHTS

IMPORTANT

If you previously used the Developer Preview of the Adoption Insights plugin and enabled
the plugin manually, you must remove those earlier plugins as they are no longer required,
and Adoption Insights is enabled by default.

In your dynamic plugins ConfigMap, for example: dynamic-plugins-rhdh.yaml, remove
the references to red-hat-developer-hub-backstage-plugin-adoption-insights, red-
hat-developer-hub-backstage-plugin-adoption-insights-backend, and red-hat-
developer-hub-backstage-plugin-analytics-module-adoption-insights. Additionally
update the package.disabled value of the backstage-community-plugin-analytics-
provider-segment plugin to  false as shown in the following example:

dynamic-plugins.yaml fragment

plugins:
  - package: ./dynamic-plugins/dist/backstage-community-plugin-analytics-provider-
segment
    disabled: false

1.2. CUSTOMIZING THE ADOPTION INSIGHTS PLUGIN IN RED HAT
DEVELOPER HUB

You can customize the Adoption Insights plugin to suit your needs by disabling or re-enabling it, and
adjusting other settings as needed.

Procedure

To customize maxBufferSize, flushInterval, debug, and licensedUsers in the Adoption
Insights plugin, in your Red Hat Developer Hub app-config.yaml file, update the relevant
settings as shown in the following code:

app:
  analytics:
    adoptionInsights:
      maxBufferSize: _<maximum_buffer_size>_  1
      flushInterval: _<flush_interval>_  2
      debug: _<debug_value>_  3
      licensedUsers: _<licensed_users>_  4

1

2

3

4

(Optional) Specifies the maximum buffer size for event batching. The default value is 20.

(Optional) Specifies the flush interval in milliseconds for event batching. The default value
is 5000ms.

(Optional) The default value is false.

(Optional) Specifies the maximum number of licensed users who can access the RHDH
instance. The default value is 100.

To disable the Adoption Insights plugin, in your dynamic plugins ConfigMap, for example

5

Red Hat Developer Hub 1.8 Adoption Insights in Red Hat Developer Hub

To disable the Adoption Insights plugin, in your dynamic plugins ConfigMap, for example
dynamic-plugins-rhdh.yaml file, update the package.disabled value of the plugin to  true as
shown in the following example:

  - package: ./dynamic-plugins/dist/red-hat-developer-hub-backstage-plugin-adoption-insights
    disabled: true
  - package: ./dynamic-plugins/dist/red-hat-developer-hub-backstage-plugin-adoption-
insights-backend-dynamic
    disabled: true
  - package: ./dynamic-plugins/dist/red-hat-developer-hub-backstage-plugin-analytics-
module-adoption-insights-dynamic
    disabled: true

Optional: Configure the required RBAC permission for the users who are not administrators as
shown in the following example:

p, role:default/_<your_team>_, adoption-insights.events.read, read, allow
g, user:default/_<your_user>_, role:default/_<your_team>_

See Permission policies in Red Hat Developer Hub .

1.3. USING ADOPTION INSIGHTS IN RED HAT DEVELOPER HUB

In the Developer Hub application, on the navigation menu, click Administration → Adoption Insights.

1.3.1. Setting the duration of data metrics

You can set the data metrics duration using any of the time ranges, such as Today, Last week, Last
month, Last 28 days (default), Last year, or Date range…​.

Procedure

1.  On the top of the screen, click the dropdown list to display the choices.

2.  Select the duration choice for which you want to see the data metrics.

6

CHAPTER 1. ADOPTION INSIGHTS

1.4. VIEWING THE ADOPTION INSIGHTS CARD

1.4.1. Viewing the active users

The Active users card displays the total number of active users over a specified date and time period.
You can export the user data in a .csv format.

Returning users: Existing users who have logged into Developer Hub previously

New users: New users who have registered and logged into Developer Hub for the first time

Procedure

To view the list of active users in your Red Hat Developer Hub instance, go to Administration →
Adoption Insights, see the Active users card.

To view the exact number of users for a particular day, hover over the corresponding date in the
Active users card.

To export the user data in a .csv format, click the Export CSV link.

1.4.2. Viewing the total number of users

This card displays the total number of users that have license to use Red Hat Developer Hub. It also
provides a comparison of the number of Logged-in users and Licensed users in numeric and
percentage form.

Logged-in users: Total number of users, including licensed and unlicensed users, currently
logged in to Developer Hub.

Licensed users: Total number of licensed users logged in to Developer Hub. You can set the
target for the number of licensed users in your Developer Hub app-config.yaml file.

Procedure

To view the total number of users in your Developer Hub instance in numeric and percentage
forms, go to Administration → Adoption Insights and see the Total number of users card.

7

Red Hat Developer Hub 1.8 Adoption Insights in Red Hat Developer Hub

To view a percentage representation of the total number of logged-in users among the total
number of licensed users, hover over the tooltip in the Total number of users card.

1.4.3. Viewing the top catalog entities

This card lists the most viewed catalog entities (like components, APIs, and so on) and documentation
entries, including usage statistics, in a table.

Each item displays the following details:

Name: Name of the catalog

Kind: Type of the catalog

Last used: The last time the catalog was used

Views: The number of times the catalog was viewed

Procedure

To view the most commonly used catalog entities in your Developer Hub instance, go to
Administration → Adoption Insights and see the Top catalog entities card.

To know more about the displayed catalog entity, hover over the catalog entity name.

1.4.4. Viewing the top 3 templates

This card lists the three most commonly used templates in a table. You can click the down arrow next to
3 rows to view the full list of the commonly used templates.

Name: Name of the template

Mostly in use by: Type of user using this template most frequently

Executions: Number of times this template was used

Procedure

To view the most commonly used templates in your Developer Hub instance, go to
Administration → Adoption Insights and see the Top 3 templates card.

To know more about the displayed template, hover over the template name.

1.4.5. Viewing the top 3 techdocs

This card lists the most viewed documentation entries, including the total views, in a table.

Name: Title of the document

Entity: Type of document

Last used: The last time the document was viewed

Views: Number of times the document was visited

8

CHAPTER 1. ADOPTION INSIGHTS

Procedure

To view the most commonly used templates in your Developer Hub instance, go to
Administration → Adoption Insights and see the Top 3 techdocs card.

To know more about the displayed techdocs, hover over the name of the techdoc.

1.4.6. Viewing the top 3 plugins

This card lists the three most commonly used plugins in a table. You can click the down arrow next to 3
rows to view the full list of the commonly used plugins.

Name: Name of the plugin

Trend: Popularity of the plugin as a graph

Views: Number of times this plugin was seen

Procedure

To view the most commonly used plugins and the plugin page visit trends in your Developer Hub
instance, go to Administration → Adoption Insights and see the Top 3 plugins card.

To know more about the displayed plugin, hover over the plugin name.

1.5. MODIFYING THE NUMBER OF DISPLAYED RECORDS

You can modify the number of displayed records in Adoption Insights for the following cards.

Top catalog entities

Top 3 templates

Top 3 techdocs

Top 3 plugins

You can select any of the following number of records for display:

Top 3

Top 5

Top 10

Top 20

By default, the top three most viewed catalog entities are displayed.

Procedure

Go to Administration → Adoption Insights and click the Down arrow next to  3 rows to change
the number of displayed records.

9

Red Hat Developer Hub 1.8 Adoption Insights in Red Hat Developer Hub

1.6. FILTERING RECORDS TO DISPLAY SPECIFIC CATALOG ENTITIES
IN TOP CATALOG ENTITIES

You can use the dropdown filter in the title to filter the table display by any of the items. By default, the
Top catalog entities card displays all of the items in your Developer Hub instance.

Procedure

To view a specific catalog entity in the table, complete the following step:

Go to Administration → Adoption Insights, click the dropdown filter on the  Top catalog
entities card, and select the item that you want to view.

1.7. VIEWING SEARCHES

In the searches card, you can view the following data:

Visualizes the number of portal searches and trends over time as a graph

Displays the total for the period in the card title

Clarifies the average number each hour/day/week/month depending on the time period chosen

10

