# ADR-002: Custom My Group Dashboard Plugin Architecture

## Status: Accepted

## Context

The Three Horizons Portal reference template includes a "My Group" page that shows a team-scoped dashboard with the current user's group context: group header with team name, 4 stat cards (Components, Members, APIs, Deployments owned by the team), a team members table, and a table of components owned by the team. RHDH 1.8 does not provide a native "My Group" page. The closest built-in feature is the `org` plugin which shows group entities, but it lacks the team-scoped dashboard view with stat cards and owner-filtered tables.

**Decision Framework result:** No existing dynamic plugin provides this view. A custom dynamic plugin is needed.

## Decision

Build a **custom RHDH dynamic plugin** (`@internal/plugin-my-group-dashboard`) that provides a team-scoped dashboard at `/my-group`. The plugin uses `identityApiRef` to resolve the current user's group membership, then queries `catalogApiRef` to fetch all entities owned by that group.

### Architecture

```
MyGroupDashboard (dynamicRoutes: path=/my-group)
|
+-- GroupHeader
|   +-- GroupAvatar                   [Static/Gravatar]
|   +-- GroupName                     [catalogApiRef: kind=Group]
|   +-- GroupDescription              [catalogApiRef: metadata.description]
|   +-- MemberCount                   [catalogApiRef: relations.hasMember]
|
+-- GroupStats (Grid: 4 columns)
|   +-- StatCard[blue]  -- Components [catalogApiRef: kind=Component, spec.owner=group]
|   +-- StatCard[green] -- Members    [catalogApiRef: relations.hasMember count]
|   +-- StatCard[yellow]-- APIs       [catalogApiRef: kind=API, spec.owner=group]
|   +-- StatCard[red]   -- Resources  [catalogApiRef: kind=Resource, spec.owner=group]
|
+-- MemberList (Table)
|   +-- Avatar | Name | Role | Email  [catalogApiRef: kind=User, memberOf=group]
|
+-- OwnedComponents (Table)
    +-- Name | Type | Lifecycle | System  [catalogApiRef: spec.owner=group]
```

### Wiring

```yaml
dynamicPlugins:
  frontend:
    "@internal/plugin-my-group-dashboard":
      dynamicRoutes:
        - path: /my-group
          importName: MyGroupDashboard
          menuItem:
            icon: GroupIcon
            text: My Group
```

### Plugin Structure

```
plugins/my-group-dashboard/
+-- package.json
+-- tsconfig.json
+-- src/
|   +-- plugin.ts                  # createPlugin + createRoutableExtension
|   +-- index.ts                   # barrel export
|   +-- routes.ts                  # routeRef definitions
|   +-- components/
|   |   +-- MyGroupDashboard.tsx   # Page container with group resolution
|   |   +-- GroupHeader.tsx        # Team info header
|   |   +-- GroupStats.tsx         # 4 stat cards (reuse StatCard from home plugin)
|   |   +-- MemberList.tsx         # Team members table
|   |   +-- OwnedComponents.tsx   # Components owned by team table
|   +-- hooks/
|   |   +-- useCurrentGroup.ts    # identityApiRef -> group ref
|   |   +-- useGroupMembers.ts    # catalogApiRef: User entities
|   |   +-- useOwnedEntities.ts   # catalogApiRef: filtered by owner
|   +-- api/
|       +-- types.ts              # TypeScript interfaces
+-- dev/
|   +-- index.tsx
+-- dist-dynamic/
```

### Data Flow

```
Browser --> MyGroupDashboard
                |
                +--> useCurrentGroup() ------> identityApiRef.getBackstageIdentity()
                |                                |-> ownershipEntityRefs[0] => "group:default/team-platform"
                |
                +--> GroupHeader ------------> catalogApiRef.getEntityByRef("group:default/team-platform")
                |                                |-> metadata.name, metadata.description
                |                                |-> relations[hasMember] => member count
                |
                +--> useGroupMembers() ------> catalogApiRef.getEntities({
                |                                  filter: { kind: "User" }
                |                                }) => filter by memberOf relation
                |
                +--> useOwnedEntities() -----> catalogApiRef.getEntities({
                |                                  filter: {
                |                                    "spec.owner": "group:default/team-platform"
                |                                  }
                |                                }) => components, APIs, resources
                |
                +--> GroupStats -------------> Derived from useOwnedEntities counts
```

## Alternatives Considered

### Alternative 1: Use the built-in `@backstage/plugin-org`

The org plugin shows group entities with member lists and owned components.

**Rejected because:**
- It provides a generic entity view, not a team-scoped dashboard
- No stat cards for team metrics
- No owner-filtered component table
- Navigation is entity-detail-page centered, not a standalone dashboard

### Alternative 2: mountPoints on the existing org plugin pages

Add custom `mountPoint` components to the org plugin's group entity page.

**Rejected because:**
- The org plugin's entity page is a generic entity detail page, not a dashboard
- Adding stat cards via mountPoints would be scoped to `entity.page.overview/cards` which only renders when viewing a specific group entity, not as a standalone sidebar page
- Users want one-click access to "My Group" from the sidebar, not a 3-click path through Catalog > Groups > My Team

### Alternative 3: Configure `QuickAccessCard` to link to the org plugin

**Rejected because:**
- This just adds a link, not a dashboard
- The org plugin still lacks stat cards and team-scoped tables

## Consequences

### Positive
- Direct sidebar access to team context (one click from anywhere)
- Live team ownership data from Catalog API
- Encourages catalog-as-code (teams register components with `spec.owner`)
- Reuses `StatCard` component from Home Page plugin
- Small plugin (~6 components), low maintenance

### Negative
- Depends on catalog data quality (entities must have `spec.owner` set correctly)
- Current user must have a `memberOf` relation to a Group entity in the catalog
- Requires org.yaml or GitHub org discovery to populate groups/users
- ~2-3 days development effort

## Implementation Notes

**For @platform:**
1. Reuse `StatCard` component from `@internal/plugin-home-three-horizons` (or create shared package)
2. Use `identityApiRef.getBackstageIdentity()` to get `ownershipEntityRefs`
3. Handle edge case: user not assigned to any group (show "Join a team" message)
4. Use `<Table>` from `@backstage/core-components` for MemberList and OwnedComponents
5. Use MUI `Avatar` for member photos (Gravatar fallback)

**For @github-integration:**
- Ensure GitHub org discovery populates User and Group entities
- Configure `memberOf` relations from GitHub team membership

**For @test:**
- Mock `identityApiRef` to return a known group ref
- Mock `catalogApiRef` with realistic team data
- Test "no group" and "empty team" edge cases

**Effort estimate:** 2-3 days (implementation) + 0.5 day (tests) + 0.5 day (pipeline)
