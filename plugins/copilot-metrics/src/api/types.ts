/** Microsoft 4-color palette */
export const MS_COLORS = {
  blue: '#00A4EF',
  green: '#7FBA00',
  yellow: '#FFB900',
  red: '#F25022',
} as const;

/** Date range for filtering metrics */
export type DateRange = '7d' | '14d' | '28d';

export const DATE_RANGE_LABELS: Record<DateRange, string> = {
  '7d': 'Last 7 days',
  '14d': 'Last 14 days',
  '28d': 'Last 28 days',
};

/** Copilot IDE code completion metrics for a single day */
export interface CopilotDayMetrics {
  date: string;
  total_active_users: number;
  total_engaged_users: number;
  copilot_ide_code_completions: {
    total_engaged_users: number;
    editors: {
      name: string;
      total_engaged_users: number;
      models: {
        name: string;
        total_engaged_users: number;
        languages: {
          name: string;
          total_engaged_users: number;
          total_code_suggestions: number;
          total_code_acceptances: number;
          total_code_lines_suggested: number;
          total_code_lines_accepted: number;
        }[];
      }[];
    }[];
  };
  copilot_ide_chat?: {
    total_engaged_users: number;
    editors: {
      name: string;
      total_engaged_users: number;
      models: {
        name: string;
        total_engaged_users: number;
        total_chat_copy_events: number;
        total_chat_insertion_events: number;
        total_chat_turns: number;
      }[];
    }[];
  };
  copilot_dotcom_chat?: {
    total_engaged_users: number;
    models: {
      name: string;
      total_engaged_users: number;
      total_chat_turns: number;
    }[];
  };
  copilot_dotcom_pull_requests?: {
    total_engaged_users: number;
    repositories: {
      name: string;
      total_engaged_users: number;
      models: {
        name: string;
        total_pr_summaries_created: number;
      }[];
    }[];
  };
}

/** Seat billing information */
export interface CopilotBilling {
  seat_breakdown: {
    total: number;
    active_this_cycle: number;
    inactive_this_cycle: number;
    added_this_cycle: number;
  };
  seat_management_setting: string;
}

/** Aggregated language stats */
export interface LanguageStat {
  name: string;
  suggestions: number;
  acceptances: number;
  rate: number;
}

/** Aggregated editor stats */
export interface EditorStat {
  name: string;
  users: number;
  percentage: number;
}

/** Trend data point for sparklines */
export interface TrendPoint {
  date: string;
  value: number;
}

/** Team-level metrics summary */
export interface TeamMetrics {
  slug: string;
  name: string;
  activeUsers: number;
  engagedUsers: number;
  acceptanceRate: number;
}
