/** Microsoft 4-color palette */
export const MS_COLORS = {
  blue: '#00A4EF',
  green: '#7FBA00',
  yellow: '#FFB900',
  red: '#F25022',
} as const;

/** Severity color mapping for GHAS alerts */
export const SEVERITY_COLORS = {
  critical: '#D32F2F',
  high: '#F57C00',
  medium: '#FFB900',
  low: '#7FBA00',
  info: '#00A4EF',
} as const;

/** Date range for filtering */
export type DateRange = '7d' | '14d' | '28d' | '90d';

export const DATE_RANGE_LABELS: Record<DateRange, string> = {
  '7d': 'Last 7 days',
  '14d': 'Last 14 days',
  '28d': 'Last 28 days',
  '90d': 'Last 90 days',
};

/** Code scanning alert */
export interface CodeScanningAlert {
  number: number;
  state: 'open' | 'closed' | 'dismissed' | 'fixed';
  rule: {
    severity: 'critical' | 'high' | 'medium' | 'low' | 'warning' | 'note' | 'error';
    description: string;
  };
  tool: { name: string };
  created_at: string;
  fixed_at?: string;
  html_url: string;
}

/** Secret scanning alert */
export interface SecretScanningAlert {
  number: number;
  state: 'open' | 'resolved';
  secret_type: string;
  validity: 'active' | 'inactive' | 'unknown';
  created_at: string;
  resolved_at?: string;
}

/** Aggregated Dependabot summary (from backend) */
export interface DependabotSummary {
  total: number;
  by_severity: Record<string, number>;
  by_ecosystem: Record<string, number>;
  repos: { name: string; count: number; critical: number }[];
}

/** GHAS billing information */
export interface GhasBilling {
  total_advanced_security_committers: number;
  maximum_advanced_security_committers: number;
  repositories: {
    name: string;
    advanced_security_committers: number;
  }[];
}

/** MTTR metrics (from backend) */
export interface MttrMetrics {
  code_scanning_mttr_hours: number;
  secret_scanning_mttr_hours: number;
  dependabot_mttr_hours: number;
  trend: 'improving' | 'degrading' | 'stable';
}

/** Security trend data point */
export interface SecurityTrendPoint {
  date: string;
  opened: number;
  closed: number;
}

/** Severity distribution data */
export interface SeverityCount {
  severity: string;
  count: number;
  color: string;
}

/** Repository GHAS coverage */
export interface RepoCoverage {
  name: string;
  codeScanning: boolean;
  secretScanning: boolean;
  dependabot: boolean;
  pushProtection: boolean;
  openAlerts: number;
}
