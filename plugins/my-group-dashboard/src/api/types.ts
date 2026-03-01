/** Microsoft 4-color palette (shared with home plugin) */
export const MS_COLORS = {
  blue: '#00A4EF',
  green: '#7FBA00',
  yellow: '#FFB900',
  red: '#F25022',
} as const;

/** Group information resolved from the catalog */
export interface GroupInfo {
  name: string;
  displayName: string;
  description: string;
  entityRef: string;
}

/** Team member from catalog User entities */
export interface TeamMember {
  name: string;
  displayName: string;
  email: string;
  role: string;
  avatarUrl?: string;
  entityRef: string;
}

/** Owned entity (Component, API, Resource) */
export interface OwnedEntity {
  name: string;
  title: string;
  kind: string;
  type: string;
  lifecycle: string;
  system: string;
  entityRef: string;
}

/** Stat card data for the group dashboard */
export interface GroupStat {
  label: string;
  count: number;
  color: string;
}
