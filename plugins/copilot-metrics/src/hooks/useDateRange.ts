import { useState, useCallback } from 'react';
import { DateRange } from '../api/types';

/** React state hook for date range selection. */
export function useDateRange(initial: DateRange = '28d') {
  const [range, setRange] = useState<DateRange>(initial);

  const handleChange = useCallback((newRange: DateRange) => {
    setRange(newRange);
  }, []);

  return { range, setRange: handleChange };
}
