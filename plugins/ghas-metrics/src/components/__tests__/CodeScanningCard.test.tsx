import React from 'react';
import { render, screen } from '@testing-library/react';
import { CodeScanningCard } from '../CodeScanningCard';
import { CodeScanningAlert } from '../../api/types';

const mockAlerts: CodeScanningAlert[] = [
  {
    number: 1,
    state: 'open',
    rule: { severity: 'critical', description: 'SQL Injection' },
    tool: { name: 'CodeQL' },
    created_at: '2026-02-01T00:00:00Z',
    html_url: 'https://github.com/org/repo/security/alerts/1',
  },
  {
    number: 2,
    state: 'open',
    rule: { severity: 'high', description: 'XSS' },
    tool: { name: 'CodeQL' },
    created_at: '2026-02-02T00:00:00Z',
    html_url: 'https://github.com/org/repo/security/alerts/2',
  },
  {
    number: 3,
    state: 'open',
    rule: { severity: 'medium', description: 'CSRF' },
    tool: { name: 'CodeQL' },
    created_at: '2026-02-03T00:00:00Z',
    html_url: 'https://github.com/org/repo/security/alerts/3',
  },
];

const fixedAlerts: CodeScanningAlert[] = [
  {
    number: 4,
    state: 'fixed',
    rule: { severity: 'high', description: 'Path Traversal' },
    tool: { name: 'CodeQL' },
    created_at: '2026-01-15T00:00:00Z',
    fixed_at: '2026-02-01T00:00:00Z',
    html_url: 'https://github.com/org/repo/security/alerts/4',
  },
];

describe('CodeScanningCard', () => {
  it('renders the total open alert count', () => {
    render(<CodeScanningCard openAlerts={mockAlerts} fixedAlerts={fixedAlerts} />);
    expect(screen.getByText('3')).toBeInTheDocument();
  });

  it('renders severity badges', () => {
    render(<CodeScanningCard openAlerts={mockAlerts} fixedAlerts={fixedAlerts} />);
    expect(screen.getByText('critical: 1')).toBeInTheDocument();
    expect(screen.getByText('high: 1')).toBeInTheDocument();
    expect(screen.getByText('medium: 1')).toBeInTheDocument();
  });

  it('renders fixed count text', () => {
    render(<CodeScanningCard openAlerts={mockAlerts} fixedAlerts={fixedAlerts} />);
    expect(screen.getByText('1 fixed this period')).toBeInTheDocument();
  });

  it('renders with empty alerts', () => {
    render(<CodeScanningCard openAlerts={[]} fixedAlerts={[]} />);
    expect(screen.getByText('0')).toBeInTheDocument();
    expect(screen.getByText('0 fixed this period')).toBeInTheDocument();
  });
});
