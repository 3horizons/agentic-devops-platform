import React from 'react';
import { render, screen } from '@testing-library/react';
import { PushProtectionCard } from '../PushProtectionCard';

describe('PushProtectionCard', () => {
  it('renders bypass and blocked counts', () => {
    render(
      <PushProtectionCard
        stats={{
          blocked: 15,
          bypassed: 3,
          bypassReasons: { manual_bypass: 3 },
        }}
      />,
    );

    expect(screen.getByText('3')).toBeInTheDocument();
    expect(screen.getByText('15 blocked this period')).toBeInTheDocument();
  });

  it('renders bypass reason badges', () => {
    render(
      <PushProtectionCard
        stats={{
          blocked: 10,
          bypassed: 5,
          bypassReasons: { manual_bypass: 3, false_positive: 2 },
        }}
      />,
    );

    expect(screen.getByText('manual_bypass: 3')).toBeInTheDocument();
    expect(screen.getByText('false_positive: 2')).toBeInTheDocument();
  });

  it('renders with undefined stats', () => {
    render(<PushProtectionCard />);
    expect(screen.getByText('0')).toBeInTheDocument();
    expect(screen.getByText('0 blocked this period')).toBeInTheDocument();
  });
});
