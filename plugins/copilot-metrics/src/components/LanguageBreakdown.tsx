import React, { useMemo } from 'react';
import { Card, CardContent, Typography } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import { Table, TableColumn } from '@backstage/core-components';
import { CopilotDayMetrics, LanguageStat } from '../api/types';

interface LanguageBreakdownProps {
  metrics: CopilotDayMetrics[];
}

const useStyles = makeStyles({
  card: {
    height: '100%',
  },
  label: {
    fontSize: '0.75rem',
    color: '#888',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
    marginBottom: 16,
  },
});

/** Table showing code suggestions by programming language. */
export const LanguageBreakdown = ({ metrics }: LanguageBreakdownProps) => {
  const classes = useStyles();

  const languages = useMemo(() => {
    const langMap = new Map<string, { suggestions: number; acceptances: number }>();

    metrics.forEach(day => {
      day.copilot_ide_code_completions?.editors?.forEach(editor => {
        editor.models?.forEach(model => {
          model.languages?.forEach(lang => {
            const existing = langMap.get(lang.name) ?? {
              suggestions: 0,
              acceptances: 0,
            };
            existing.suggestions += lang.total_code_suggestions;
            existing.acceptances += lang.total_code_acceptances;
            langMap.set(lang.name, existing);
          });
        });
      });
    });

    return Array.from(langMap.entries())
      .map(([name, stats]) => ({
        name,
        suggestions: stats.suggestions,
        acceptances: stats.acceptances,
        rate:
          stats.suggestions > 0
            ? Math.round((stats.acceptances / stats.suggestions) * 100)
            : 0,
      }))
      .sort((a, b) => b.suggestions - a.suggestions)
      .slice(0, 10);
  }, [metrics]);

  const columns: TableColumn<LanguageStat>[] = [
    { title: 'Language', field: 'name' },
    { title: 'Suggestions', field: 'suggestions', type: 'numeric' },
    { title: 'Accepted', field: 'acceptances', type: 'numeric' },
    {
      title: 'Rate',
      field: 'rate',
      type: 'numeric',
      render: (row: LanguageStat) => `${row.rate}%`,
    },
  ];

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Typography className={classes.label}>
          Language Breakdown (Top 10)
        </Typography>
        <Table
          title=""
          options={{ paging: false, search: false, toolbar: false }}
          columns={columns}
          data={languages}
        />
      </CardContent>
    </Card>
  );
};
