import React from 'react';
import { render, screen } from '@testing-library/react';
import { RepoCoverageTable } from '../RepoCoverageTable';
import { RepoCoverage } from '../../api/types';

const mockRepos: RepoCoverage[] = [
  {
    name: 'api-gateway',
    codeScanning: true,
    secretScanning: true,
    dependabot: true,
    pushProtection: true,
    openAlerts: 0,
  },
  {
    name: 'frontend-app',
    codeScanning: true,
    secretScanning: true,
    dependabot: true,
    pushProtection: false,
    openAlerts: 5,
  },
  {
    name: 'legacy-service',
    codeScanning: false,
    secretScanning: false,
    dependabot: true,
    pushProtection: false,
    openAlerts: 12,
  },
];

describe('RepoCoverageTable', () => {
  it('renders repository names', () => {
    render(<RepoCoverageTable repos={mockRepos} />);

    expect(screen.getByText('api-gateway')).toBeInTheDocument();
    expect(screen.getByText('frontend-app')).toBeInTheDocument();
    expect(screen.getByText('legacy-service')).toBeInTheDocument();
  });

  it('renders coverage percentage', () => {
    render(<RepoCoverageTable repos={mockRepos} />);

    // 1 out of 3 repos has full GHAS = 33%
    expect(screen.getByText('33% Full GHAS')).toBeInTheDocument();
  });

  it('renders column headers', () => {
    render(<RepoCoverageTable repos={mockRepos} />);

    expect(screen.getByText('Repository')).toBeInTheDocument();
    expect(screen.getByText('Code Scan')).toBeInTheDocument();
    expect(screen.getByText('Secrets')).toBeInTheDocument();
    expect(screen.getByText('Dependabot')).toBeInTheDocument();
    expect(screen.getByText('Push Protect')).toBeInTheDocument();
    expect(screen.getByText('Alerts')).toBeInTheDocument();
  });

  it('renders alert counts', () => {
    render(<RepoCoverageTable repos={mockRepos} />);

    expect(screen.getByText('0')).toBeInTheDocument();
    expect(screen.getByText('5')).toBeInTheDocument();
    expect(screen.getByText('12')).toBeInTheDocument();
  });

  it('renders with empty repos', () => {
    render(<RepoCoverageTable repos={[]} />);
    expect(screen.getByText('0% Full GHAS')).toBeInTheDocument();
  });
});
