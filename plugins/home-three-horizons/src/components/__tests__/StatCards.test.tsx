import React from 'react';
import { render, screen } from '@testing-library/react';
import { TestApiProvider } from '@backstage/test-utils';
import { catalogApiRef } from '@backstage/plugin-catalog-react';
import { StatCards } from '../StatCards';

const mockCatalogApi = {
  getEntities: jest.fn(),
};

function setup(entityCounts: { components: number; apis: number; templates: number }) {
  mockCatalogApi.getEntities.mockImplementation(async (req: { filter: { kind: string } }) => {
    const kind = req.filter.kind;
    const count =
      kind === 'Component'
        ? entityCounts.components
        : kind === 'API'
        ? entityCounts.apis
        : kind === 'Template'
        ? entityCounts.templates
        : 0;
    return { items: Array.from({ length: count }, (_, i) => ({ metadata: { name: `${kind}-${i}` } })) };
  });

  return render(
    <TestApiProvider apis={[[catalogApiRef, mockCatalogApi]]}>
      <StatCards />
    </TestApiProvider>,
  );
}

describe('StatCards', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders entity counts from catalog API', async () => {
    setup({ components: 12, apis: 5, templates: 8 });

    expect(await screen.findByText('12')).toBeInTheDocument();
    expect(screen.getByText('5')).toBeInTheDocument();
    expect(screen.getByText('8')).toBeInTheDocument();
    expect(screen.getByText('3')).toBeInTheDocument(); // Horizons is static
  });

  it('renders labels for all stat cards', async () => {
    setup({ components: 1, apis: 1, templates: 1 });

    expect(await screen.findByText('Components')).toBeInTheDocument();
    expect(screen.getByText('APIs')).toBeInTheDocument();
    expect(screen.getByText('Templates')).toBeInTheDocument();
    expect(screen.getByText('Horizons')).toBeInTheDocument();
  });

  it('renders zero counts correctly', async () => {
    setup({ components: 0, apis: 0, templates: 0 });

    const zeros = await screen.findAllByText('0');
    expect(zeros).toHaveLength(3); // 3 zeros + 1 static "3" for Horizons
  });
});
