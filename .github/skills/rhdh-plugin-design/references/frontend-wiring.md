# RHDH Frontend Wiring — Complete Reference

This document covers every frontend wiring mechanism available in RHDH 1.8 for dynamic plugins.

## Table of Contents

1. [dynamicRoutes](#dynamicroutes)
2. [mountPoints](#mountpoints)
3. [menuItems](#menuitems)
4. [entityTabs](#entitytabs)
5. [appIcons](#appicons)
6. [routeBindings](#routebindings)
7. [apiFactories](#apifactories)
8. [translationResources](#translationresources)

---

## dynamicRoutes

Register a top-level route in the RHDH application. Used for full-page custom views.

```yaml
dynamicPlugins:
  frontend:
    plugin-name:
      dynamicRoutes:
        - path: /my-page            # URL path
          importName: MyComponent     # Exported React component name
          menuItem:                   # Optional sidebar entry
            icon: HomeIcon            # Material UI icon name
            text: My Page             # Sidebar label
          config:                     # Optional route config
            props:
              title: "My Custom Page"
```

**Key rules:**
- `importName` must match exactly what the plugin exports
- `path: /` replaces the default home page
- `menuItem` is optional — without it, the page exists but has no sidebar entry
- Multiple `dynamicRoutes` can be defined per plugin

**Available icons for menuItem:**
HomeIcon, CategoryIcon, ExtensionIcon, CreateComponentIcon, LibraryBooksIcon, GroupIcon, NotificationsIcon, AdminPanelSettingsIcon, SettingsIcon, SchoolIcon, ChatIcon, DashboardIcon, StorageIcon, SecurityIcon, BuildIcon, CodeIcon, CloudIcon, MonitorIcon

---

## mountPoints

Inject a component into a specific slot on an existing Backstage page. Slots are defined by the page's layout and identified by mount point IDs.

```yaml
dynamicPlugins:
  frontend:
    plugin-name:
      mountPoints:
        - mountPoint: entity.page.overview/cards    # Target slot
          importName: MyCardComponent                 # Exported component
          config:
            layout:
              gridColumn: "1 / -1"                   # CSS grid column span
              gridRowStart: 1                         # Grid row position
            if:                                       # Conditional display
              allOf:
                - isKind: component                   # Only show for components
              anyOf:
                - hasAnnotation: my.annotation/key
```

**Common mount points:**

| Mount Point ID | Location | Description |
|----------------|----------|-------------|
| `entity.page.overview/cards` | Entity overview page | Card widgets |
| `entity.page.overview/context` | Entity overview page | Context providers |
| `entity.page.*/cards` | Any entity page | Card widgets |
| `search.page.results` | Search results page | Custom result types |
| `search.page.filters` | Search page | Custom filters |
| `search.page.types` | Search page | Custom search types |

**Conditional display operators:**
- `isKind: component | api | template | system | domain | group | user`
- `isType: service | website | library`
- `hasAnnotation: annotation/key`
- `isNamespace: default`

---

## menuItems

Add entries to the sidebar navigation. Can point to internal routes or external URLs.

```yaml
dynamicPlugins:
  frontend:
    plugin-name:
      menuItems:
        - text: Learning Paths          # Display label
          icon: SchoolIcon              # Material UI icon
          to: /learning-paths           # Internal route or external URL
          importance: high              # high | medium | low (affects sort order)
```

**Notes:**
- Items with `importance: high` appear at the top of the sidebar
- External URLs open in a new tab
- Order within the same importance level follows config order

---

## entityTabs

Add custom tabs to entity detail pages (Component, API, System, etc.).

```yaml
dynamicPlugins:
  frontend:
    plugin-name:
      entityTabs:
        - path: /my-tab               # Tab URL path (appended to entity URL)
          title: My Tab                # Tab label
          mountPoint: entity.page.my-tab  # Mount point for tab content
```

Then use `mountPoints` to add content to the tab:
```yaml
      mountPoints:
        - mountPoint: entity.page.my-tab/cards
          importName: MyTabContent
```

---

## appIcons

Register custom SVG icons that can be referenced by name in `menuItem.icon`.

```yaml
dynamicPlugins:
  frontend:
    plugin-name:
      appIcons:
        - name: myCustomIcon
          importName: MyCustomIconComponent
```

The icon component should export a React component wrapping an SVG:
```typescript
export const MyCustomIconComponent = () => (
  <SvgIcon><path d="M12 2L2 7l10 5 10-5-10-5z" /></SvgIcon>
);
```

---

## routeBindings

Connect one plugin's routes to another plugin's route references. Required when a plugin has `ExternalRouteRef` dependencies.

```yaml
dynamicPlugins:
  frontend:
    plugin-name:
      routeBindings:
        targets:
          - importName: catalogPlugin.routes.catalogIndex
        bindings:
          - bindTarget: catalogPlugin.routes.catalogIndex
            bindMap:
              createComponent: scaffolderPlugin.routes.root
```

---

## apiFactories

Register custom API implementations that other plugins can consume via `useApi()`.

```yaml
dynamicPlugins:
  frontend:
    plugin-name:
      apiFactories:
        - importName: myCustomApiFactory
```

The factory should use `createApiFactory`:
```typescript
export const myCustomApiFactory = createApiFactory({
  api: myCustomApiRef,
  deps: { fetchApi: fetchApiRef, configApi: configApiRef },
  factory: ({ fetchApi, configApi }) =>
    new MyCustomApiClient({ fetchApi, configApi }),
});
```

---

## translationResources

Provide i18n translation overrides for plugin text.

```yaml
dynamicPlugins:
  frontend:
    plugin-name:
      translationResources:
        - importName: myTranslations
```

---

## Configuration Precedence

When multiple plugins define the same route or mount point:
1. Last plugin in `dynamic-plugins-config.yaml` wins for routes
2. Mount points are additive (all components render)
3. Menu items are sorted by `importance` then config order
