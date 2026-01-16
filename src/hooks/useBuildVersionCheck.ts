import { useEffect, useState } from 'react';
import { checkAndClearStaleState, VersionCheckResult } from '@/utils/buildVersionManager';

/**
 * Hook to check build version on mount and clear stale state if needed.
 * This ensures fresh rendering when new code is deployed via GitHub.
 */
export const useBuildVersionCheck = () => {
  const [versionCheck, setVersionCheck] = useState<VersionCheckResult | null>(null);
  const [isReady, setIsReady] = useState(false);

  useEffect(() => {
    const result = checkAndClearStaleState();
    setVersionCheck(result);
    
    // If new version with cleared keys, give React Query cache time to invalidate
    if (result.isNewVersion && result.clearedKeys.length > 0) {
      // Small delay to ensure state is cleared before rendering
      const timer = setTimeout(() => {
        setIsReady(true);
      }, 50);
      return () => clearTimeout(timer);
    }
    
    setIsReady(true);
  }, []);

  return {
    versionCheck,
    isReady,
    isNewVersion: versionCheck?.isNewVersion ?? false,
  };
};
