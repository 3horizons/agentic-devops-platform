#!/usr/bin/env python3
"""
Validate RHDH dynamic plugin configuration files.

Checks:
1. dynamic-plugins-config.yaml syntax and structure
2. app-config.yaml branding section
3. Plugin wiring references (dynamicRoutes, mountPoints, menuItems)
4. Known icon names validation
5. Route path conflicts

Usage:
  python validate-plugin-config.py <path-to-dynamic-plugins-config.yaml> [<path-to-app-config.yaml>]
"""

import sys
import yaml
import re
from pathlib import Path

VALID_ICONS = {
    "HomeIcon", "CategoryIcon", "ExtensionIcon", "CreateComponentIcon",
    "LibraryBooksIcon", "GroupIcon", "NotificationsIcon",
    "AdminPanelSettingsIcon", "SettingsIcon", "SchoolIcon", "ChatIcon",
    "DashboardIcon", "StorageIcon", "SecurityIcon", "BuildIcon",
    "CodeIcon", "CloudIcon", "MonitorIcon", "SearchIcon",
    "PersonIcon", "StarIcon", "WarningIcon", "InfoIcon",
}

VALID_WIRING_KEYS = {
    "dynamicRoutes", "mountPoints", "menuItems", "entityTabs",
    "appIcons", "routeBindings", "apiFactories", "translationResources",
}

VALID_MOUNT_POINTS = {
    "entity.page.overview/cards",
    "entity.page.overview/context",
    "entity.page.ci-cd/cards",
    "entity.page.kubernetes/cards",
    "entity.page.api/cards",
    "entity.page.docs/cards",
    "search.page.results",
    "search.page.filters",
    "search.page.types",
}


def validate_dynamic_plugins_config(filepath: str) -> list[str]:
    """Validate dynamic-plugins-config.yaml"""
    errors = []
    warnings = []

    try:
        with open(filepath) as f:
            config = yaml.safe_load(f)
    except yaml.YAMLError as e:
        return [f"YAML parse error: {e}"], []
    except FileNotFoundError:
        return [f"File not found: {filepath}"], []

    if not config:
        return ["Empty configuration file"], []

    dp = config.get("dynamicPlugins", {})
    frontend = dp.get("frontend", {})

    if not frontend:
        warnings.append("No frontend plugins configured")
        return errors, warnings

    routes_seen = {}

    for plugin_name, plugin_config in frontend.items():
        prefix = f"[{plugin_name}]"

        # Check for unknown wiring keys
        for key in plugin_config:
            if key not in VALID_WIRING_KEYS and key not in ("enabled", "config"):
                warnings.append(f"{prefix} Unknown wiring key: '{key}'")

        # Validate dynamicRoutes
        for i, route in enumerate(plugin_config.get("dynamicRoutes", [])):
            route_prefix = f"{prefix} dynamicRoutes[{i}]"

            if "path" not in route:
                errors.append(f"{route_prefix} Missing required 'path'")
            else:
                path = route["path"]
                if not path.startswith("/"):
                    errors.append(f"{route_prefix} Path must start with '/': {path}")
                if path in routes_seen:
                    warnings.append(
                        f"{route_prefix} Route '{path}' conflicts with "
                        f"{routes_seen[path]} (last one wins)"
                    )
                routes_seen[path] = f"{plugin_name}.dynamicRoutes[{i}]"

            if "importName" not in route:
                errors.append(f"{route_prefix} Missing required 'importName'")

            menu_item = route.get("menuItem", {})
            if menu_item:
                icon = menu_item.get("icon", "")
                if icon and icon not in VALID_ICONS:
                    warnings.append(
                        f"{route_prefix} Unknown icon '{icon}'. "
                        f"Known icons: {', '.join(sorted(VALID_ICONS)[:5])}..."
                    )

        # Validate mountPoints
        for i, mp in enumerate(plugin_config.get("mountPoints", [])):
            mp_prefix = f"{prefix} mountPoints[{i}]"

            if "mountPoint" not in mp:
                errors.append(f"{mp_prefix} Missing required 'mountPoint'")

            if "importName" not in mp:
                errors.append(f"{mp_prefix} Missing required 'importName'")

        # Validate menuItems
        for i, mi in enumerate(plugin_config.get("menuItems", [])):
            mi_prefix = f"{prefix} menuItems[{i}]"

            if "text" not in mi:
                errors.append(f"{mi_prefix} Missing required 'text'")
            if "to" not in mi:
                errors.append(f"{mi_prefix} Missing required 'to'")

    return errors, warnings


def validate_app_config_branding(filepath: str) -> list[str]:
    """Validate app-config.yaml branding section"""
    errors = []
    warnings = []

    try:
        with open(filepath) as f:
            config = yaml.safe_load(f)
    except yaml.YAMLError as e:
        return [f"YAML parse error: {e}"], []
    except FileNotFoundError:
        return [f"File not found: {filepath}"], []

    app = config.get("app", {})
    branding = app.get("branding", {})

    if not branding:
        warnings.append("No branding section found in app-config.yaml")
        return errors, warnings

    # Check logo paths
    for logo_key in ["fullLogo", "iconLogo"]:
        logo = branding.get(logo_key, "")
        if logo and not (logo.startswith("/") or logo.startswith("http")):
            warnings.append(f"branding.{logo_key} should be an absolute path or URL: {logo}")

    # Check theme colors
    theme = branding.get("theme", {})
    light = theme.get("light", {})

    color_pattern = re.compile(r"^#[0-9A-Fa-f]{6}$")
    for key, value in light.items():
        if isinstance(value, str) and value.startswith("#"):
            if not color_pattern.match(value):
                errors.append(f"Invalid hex color for theme.light.{key}: {value}")

    return errors, warnings


def main():
    if len(sys.argv) < 2:
        print("Usage: validate-plugin-config.py <dynamic-plugins-config.yaml> [<app-config.yaml>]")
        sys.exit(1)

    all_errors = []
    all_warnings = []

    # Validate dynamic plugins config
    dp_file = sys.argv[1]
    print(f"\n--- Validating: {dp_file} ---")
    errors, warnings = validate_dynamic_plugins_config(dp_file)
    all_errors.extend(errors)
    all_warnings.extend(warnings)

    # Optionally validate app-config branding
    if len(sys.argv) > 2:
        ac_file = sys.argv[2]
        print(f"\n--- Validating branding: {ac_file} ---")
        errors, warnings = validate_app_config_branding(ac_file)
        all_errors.extend(errors)
        all_warnings.extend(warnings)

    # Report
    print("\n" + "=" * 60)
    if all_errors:
        print(f"\n  ERRORS ({len(all_errors)}):")
        for e in all_errors:
            print(f"    [x] {e}")

    if all_warnings:
        print(f"\n  WARNINGS ({len(all_warnings)}):")
        for w in all_warnings:
            print(f"    [!] {w}")

    if not all_errors and not all_warnings:
        print("\n  All checks passed!")

    print()
    sys.exit(1 if all_errors else 0)


if __name__ == "__main__":
    main()
