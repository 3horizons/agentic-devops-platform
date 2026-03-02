import React from 'react';
import { render, screen } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { HeroBanner } from '../HeroBanner';

describe('HeroBanner', () => {
  it('renders welcome message when userName is provided', () => {
    render(
      <MemoryRouter>
        <HeroBanner userName="Paula" />
      </MemoryRouter>,
    );

    expect(screen.getByText('Welcome back, Paula')).toBeInTheDocument();
  });

  it('renders default title when userName is not provided', () => {
    render(
      <MemoryRouter>
        <HeroBanner />
      </MemoryRouter>,
    );

    expect(screen.getByText('Agentic DevOps Platform')).toBeInTheDocument();
  });

  it('renders the search bar', () => {
    render(
      <MemoryRouter>
        <HeroBanner />
      </MemoryRouter>,
    );

    expect(screen.getByPlaceholderText('Search the catalog...')).toBeInTheDocument();
  });

  it('renders Three Horizons subtitle', () => {
    render(
      <MemoryRouter>
        <HeroBanner />
      </MemoryRouter>,
    );

    expect(
      screen.getByText(/Three Horizons Developer Hub/),
    ).toBeInTheDocument();
  });
});
