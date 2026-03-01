import React, { useState } from 'react';
import {
  Header,
  Page,
  Content,
  HeaderTabs,
  InfoCard,
  StatusOK,
  StatusWarning,
  StatusError,
} from '@backstage/core-components';
import { Grid, Typography, Box, Chip } from '@material-ui/core';
import { DoraMetricsTab } from './DoraMetricsTab';
import { CopilotAnalyticsTab } from './CopilotAnalyticsTab';
import { SecurityPostureTab } from './SecurityPostureTab';
import { ProductivityTab } from './ProductivityTab';

const TABS = [
  {% if values.enableDora %}{ id: 'dora', label: 'DORA Metrics' },{% endif %}
  {% if values.enableCopilot %}{ id: 'copilot', label: 'Copilot Analytics' },{% endif %}
  {% if values.enableSecurity %}{ id: 'security', label: 'Security Posture' },{% endif %}
  {% if values.enableProductivity %}{ id: 'productivity', label: 'Developer Productivity' },{% endif %}
];

export const DashboardPage = () => {
  const [activeTab, setActiveTab] = useState(0);

  const renderTab = () => {
    const tab = TABS[activeTab];
    switch (tab?.id) {
      {% if values.enableDora %}case 'dora': return <DoraMetricsTab />;{% endif %}
      {% if values.enableCopilot %}case 'copilot': return <CopilotAnalyticsTab />;{% endif %}
      {% if values.enableSecurity %}case 'security': return <SecurityPostureTab />;{% endif %}
      {% if values.enableProductivity %}case 'productivity': return <ProductivityTab />;{% endif %}
      default: return <Typography>Select a tab</Typography>;
    }
  };

  return (
    <Page themeId="tool">
      <Header
        title="Engineering Intelligence"
        subtitle="Powered by GitHub APIs — Inspired by Faros AI"
      >
        <Chip label="H3 Innovation" color="primary" size="small" />
      </Header>
      <HeaderTabs
        tabs={TABS.map(t => ({ id: t.id, label: t.label }))}
        selectedIndex={activeTab}
        onChange={(index) => setActiveTab(index)}
      />
      <Content>
        <Box mt={2}>{renderTab()}</Box>
      </Content>
    </Page>
  );
};
