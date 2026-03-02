import React, { useMemo, useState } from 'react';
import {
  Card,
  CardContent,
  Typography,
  Box,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  TableSortLabel,
  TablePagination,
  LinearProgress,
} from '@material-ui/core';
import CheckCircleIcon from '@material-ui/icons/CheckCircle';
import CancelIcon from '@material-ui/icons/Cancel';
import { makeStyles } from '@material-ui/core/styles';
import { RepoCoverage, MS_COLORS, SEVERITY_COLORS } from '../api/types';

interface RepoCoverageTableProps {
  repos: RepoCoverage[];
}

const useStyles = makeStyles({
  card: {
    height: '100%',
  },
  header: {
    display: 'flex',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 12,
  },
  label: {
    fontSize: '0.75rem',
    color: '#888',
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  coveragePct: {
    fontSize: '1.25rem',
    fontWeight: 700,
    color: MS_COLORS.blue,
  },
  progress: {
    height: 8,
    borderRadius: 4,
    marginBottom: 16,
    backgroundColor: '#E0E0E0',
  },
  bar: {
    backgroundColor: MS_COLORS.green,
    borderRadius: 4,
  },
  enabled: {
    color: MS_COLORS.green,
    fontSize: '1rem',
  },
  disabled: {
    color: '#CCC',
    fontSize: '1rem',
  },
  alertsBadge: {
    fontWeight: 600,
    fontSize: '0.8rem',
  },
  repoName: {
    fontWeight: 500,
  },
  tableContainer: {
    maxHeight: 400,
  },
});

type SortKey = 'name' | 'openAlerts';
type SortDir = 'asc' | 'desc';

/** Table showing per-repo GHAS feature coverage and open alert counts. */
export const RepoCoverageTable = ({ repos }: RepoCoverageTableProps) => {
  const classes = useStyles();
  const [sortBy, setSortBy] = useState<SortKey>('openAlerts');
  const [sortDir, setSortDir] = useState<SortDir>('desc');
  const [page, setPage] = useState(0);
  const rowsPerPage = 10;

  const fullCoverage = useMemo(
    () =>
      repos.filter(
        r => r.codeScanning && r.secretScanning && r.dependabot && r.pushProtection,
      ).length,
    [repos],
  );

  const coveragePct =
    repos.length > 0 ? Math.round((fullCoverage / repos.length) * 100) : 0;

  const sorted = useMemo(() => {
    const copy = [...repos];
    copy.sort((a, b) => {
      const aVal = sortBy === 'name' ? a.name : a.openAlerts;
      const bVal = sortBy === 'name' ? b.name : b.openAlerts;
      if (aVal < bVal) return sortDir === 'asc' ? -1 : 1;
      if (aVal > bVal) return sortDir === 'asc' ? 1 : -1;
      return 0;
    });
    return copy;
  }, [repos, sortBy, sortDir]);

  const paginated = sorted.slice(
    page * rowsPerPage,
    page * rowsPerPage + rowsPerPage,
  );

  const handleSort = (key: SortKey) => {
    if (sortBy === key) {
      setSortDir(prev => (prev === 'asc' ? 'desc' : 'asc'));
    } else {
      setSortBy(key);
      setSortDir('desc');
    }
  };

  const FeatureIcon = ({ enabled }: { enabled: boolean }) =>
    enabled ? (
      <CheckCircleIcon className={classes.enabled} />
    ) : (
      <CancelIcon className={classes.disabled} />
    );

  return (
    <Card className={classes.card} variant="outlined">
      <CardContent>
        <Box className={classes.header}>
          <Typography className={classes.label}>
            Repository Coverage
          </Typography>
          <Typography className={classes.coveragePct}>
            {coveragePct}% Full GHAS
          </Typography>
        </Box>
        <LinearProgress
          variant="determinate"
          value={coveragePct}
          className={classes.progress}
          classes={{ bar: classes.bar }}
        />
        <TableContainer className={classes.tableContainer}>
          <Table size="small" stickyHeader>
            <TableHead>
              <TableRow>
                <TableCell>
                  <TableSortLabel
                    active={sortBy === 'name'}
                    direction={sortBy === 'name' ? sortDir : 'asc'}
                    onClick={() => handleSort('name')}
                  >
                    Repository
                  </TableSortLabel>
                </TableCell>
                <TableCell align="center">Code Scan</TableCell>
                <TableCell align="center">Secrets</TableCell>
                <TableCell align="center">Dependabot</TableCell>
                <TableCell align="center">Push Protect</TableCell>
                <TableCell align="right">
                  <TableSortLabel
                    active={sortBy === 'openAlerts'}
                    direction={sortBy === 'openAlerts' ? sortDir : 'desc'}
                    onClick={() => handleSort('openAlerts')}
                  >
                    Alerts
                  </TableSortLabel>
                </TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {paginated.map(repo => (
                <TableRow key={repo.name} hover>
                  <TableCell className={classes.repoName}>
                    {repo.name}
                  </TableCell>
                  <TableCell align="center">
                    <FeatureIcon enabled={repo.codeScanning} />
                  </TableCell>
                  <TableCell align="center">
                    <FeatureIcon enabled={repo.secretScanning} />
                  </TableCell>
                  <TableCell align="center">
                    <FeatureIcon enabled={repo.dependabot} />
                  </TableCell>
                  <TableCell align="center">
                    <FeatureIcon enabled={repo.pushProtection} />
                  </TableCell>
                  <TableCell align="right">
                    <span
                      className={classes.alertsBadge}
                      style={{
                        color:
                          repo.openAlerts > 10
                            ? SEVERITY_COLORS.critical
                            : repo.openAlerts > 0
                            ? SEVERITY_COLORS.medium
                            : MS_COLORS.green,
                      }}
                    >
                      {repo.openAlerts}
                    </span>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        </TableContainer>
        {repos.length > rowsPerPage && (
          <TablePagination
            component="div"
            count={repos.length}
            page={page}
            onPageChange={(_, p) => setPage(p)}
            rowsPerPage={rowsPerPage}
            rowsPerPageOptions={[]}
          />
        )}
      </CardContent>
    </Card>
  );
};
