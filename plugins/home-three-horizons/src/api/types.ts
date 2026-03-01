/** Microsoft 4-color palette constants */
export const MS_COLORS = {
  blue: '#00A4EF',
  green: '#7FBA00',
  yellow: '#FFB900',
  red: '#F25022',
} as const;

/** Entity count for stat cards */
export interface EntityCount {
  label: string;
  count: number;
  color: string;
  icon: string;
  route: string;
}

/** Horizon card data */
export interface HorizonData {
  id: 'h1' | 'h2' | 'h3';
  title: string;
  subtitle: string;
  description: string;
  color: string;
  tags: string[];
  route: string;
}

/** Quick access link */
export interface QuickLink {
  title: string;
  description: string;
  icon: string;
  route: string;
  isExternal?: boolean;
}

/** Featured template from catalog */
export interface FeaturedTemplate {
  name: string;
  title: string;
  description: string;
  tags: string[];
  type: string;
  route: string;
}

/** Home page section configuration */
export interface HomePageConfig {
  horizons: HorizonData[];
  quickLinks: QuickLink[];
}

/** Default horizon card configuration */
export const HORIZONS: HorizonData[] = [
  {
    id: 'h1',
    title: 'H1 — Foundation',
    subtitle: 'Infrastructure & Platform',
    description:
      'Core infrastructure with IDP Portal, GitHub integration, Golden Path templates, CI/CD pipelines, and TechDocs.',
    color: MS_COLORS.blue,
    tags: ['IDP Portal', 'GitHub', 'Templates', 'CI/CD', 'TechDocs'],
    route: '/catalog?filters[tag]=h1-foundation',
  },
  {
    id: 'h2',
    title: 'H2 — Enhancement',
    subtitle: 'Intelligence & Automation',
    description:
      'AI-powered development with Copilot, Lightspeed chat, MCP servers, Azure AI Foundry, and automated testing.',
    color: MS_COLORS.green,
    tags: ['Copilot', 'Lightspeed', 'MCP', 'AI Foundry', 'Testing'],
    route: '/catalog?filters[tag]=h2-enhancement',
  },
  {
    id: 'h3',
    title: 'H3 — Innovation',
    subtitle: 'Autonomy & Self-Healing',
    description:
      'Autonomous operations with agent orchestration, self-healing infrastructure, predictive analytics, and optimization.',
    color: MS_COLORS.yellow,
    tags: ['Agents', 'Self-Healing', 'Predictive', 'Autonomous', 'Optimization'],
    route: '/catalog?filters[tag]=h3-innovation',
  },
];

/** Default quick access links */
export const QUICK_LINKS: QuickLink[] = [
  {
    title: 'Software Catalog',
    description: 'Browse all services, APIs, and components',
    icon: 'category',
    route: '/catalog',
  },
  {
    title: 'API Explorer',
    description: 'Discover and test APIs with Swagger/AsyncAPI',
    icon: 'extension',
    route: '/api-docs',
  },
  {
    title: 'Create Component',
    description: 'Scaffold a new service from Golden Path templates',
    icon: 'addCircle',
    route: '/create',
  },
  {
    title: 'Documentation',
    description: 'Browse TechDocs for all services',
    icon: 'libraryBooks',
    route: '/docs',
  },
];
