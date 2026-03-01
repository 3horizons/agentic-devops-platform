import React from 'react';
import { Typography, Box, InputBase } from '@material-ui/core';
import { makeStyles } from '@material-ui/core/styles';
import SearchIcon from '@material-ui/icons/Search';
import { useNavigate } from 'react-router-dom';
import { MS_COLORS } from '../api/types';

interface HeroBannerProps {
  userName?: string;
}

const useStyles = makeStyles({
  banner: {
    background: `linear-gradient(135deg, ${MS_COLORS.blue} 0%, #0078D4 100%)`,
    borderRadius: 12,
    padding: '48px 40px',
    color: '#FFFFFF',
    marginBottom: 24,
    position: 'relative',
    overflow: 'hidden',
  },
  pattern: {
    position: 'absolute',
    top: 0,
    right: 0,
    bottom: 0,
    left: 0,
    opacity: 0.06,
    backgroundImage:
      'radial-gradient(circle at 1px 1px, white 1px, transparent 0)',
    backgroundSize: '32px 32px',
    pointerEvents: 'none',
  },
  content: {
    position: 'relative',
    zIndex: 1,
  },
  title: {
    fontSize: '2rem',
    fontWeight: 700,
    marginBottom: 8,
    letterSpacing: -0.5,
  },
  subtitle: {
    fontSize: '1rem',
    opacity: 0.9,
    maxWidth: 600,
    lineHeight: 1.5,
    marginBottom: 24,
  },
  searchWrapper: {
    display: 'flex',
    alignItems: 'center',
    backgroundColor: 'rgba(255,255,255,0.15)',
    borderRadius: 8,
    padding: '8px 16px',
    maxWidth: 500,
    backdropFilter: 'blur(4px)',
    transition: 'background-color 0.2s',
    '&:hover': {
      backgroundColor: 'rgba(255,255,255,0.22)',
    },
  },
  searchIcon: {
    color: 'rgba(255,255,255,0.7)',
    marginRight: 8,
  },
  searchInput: {
    color: '#FFFFFF',
    flex: 1,
    fontSize: '0.9rem',
    '&::placeholder': {
      color: 'rgba(255,255,255,0.6)',
      opacity: 1,
    },
  },
});

/** Hero banner with gradient background, welcome message, and search bar. */
export const HeroBanner = ({ userName }: HeroBannerProps) => {
  const classes = useStyles();
  const navigate = useNavigate();

  const greeting = userName ? `Welcome back, ${userName}` : 'Agentic DevOps Platform';

  const handleSearch = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Enter') {
      const query = (event.target as HTMLInputElement).value.trim();
      if (query) {
        navigate(`/search?query=${encodeURIComponent(query)}`);
      }
    }
  };

  return (
    <Box className={classes.banner}>
      <div className={classes.pattern} />
      <Box className={classes.content}>
        <Typography className={classes.title}>{greeting}</Typography>
        <Typography className={classes.subtitle}>
          Three Horizons Developer Hub — your central platform for services,
          APIs, templates, documentation, and AI-powered development.
        </Typography>
        <Box className={classes.searchWrapper}>
          <SearchIcon className={classes.searchIcon} />
          <InputBase
            className={classes.searchInput}
            placeholder="Search the catalog..."
            onKeyDown={handleSearch}
            inputProps={{ 'aria-label': 'Search the catalog' }}
          />
        </Box>
      </Box>
    </Box>
  );
};
