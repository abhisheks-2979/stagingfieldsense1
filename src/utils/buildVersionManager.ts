/**
 * Build Version Manager
 * 
 * Ensures fresh browser state when new code is deployed via GitHub.
 * Clears stale localStorage/sessionStorage and forces re-render on version mismatch.
 */

// BUILD_VERSION is updated automatically when code changes are detected
// Format: ISO timestamp - changes every deployment
// To force a version bump, update this timestamp
const BUILD_VERSION = '2026-01-16T12:30:00Z';
const VERSION_KEY = 'app_build_version';
const STALE_KEYS_PREFIX = ['nav_customization_', 'cached_', 'offline_', 'sidebar_'];

export interface VersionCheckResult {
  isNewVersion: boolean;
  previousVersion: string | null;
  currentVersion: string;
  clearedKeys: string[];
}

/**
 * Check if the current build is newer than what's stored in browser
 * If so, clear stale state to ensure fresh rendering
 */
export const checkAndClearStaleState = (): VersionCheckResult => {
  const storedVersion = localStorage.getItem(VERSION_KEY);
  const isNewVersion = storedVersion !== BUILD_VERSION;
  const clearedKeys: string[] = [];

  if (isNewVersion) {
    console.log(`[BuildVersion] New version detected: ${BUILD_VERSION} (was: ${storedVersion})`);
    
    // Clear navigation customization and other stale keys
    const keysToRemove: string[] = [];
    
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && STALE_KEYS_PREFIX.some(prefix => key.startsWith(prefix))) {
        keysToRemove.push(key);
      }
    }
    
    keysToRemove.forEach(key => {
      localStorage.removeItem(key);
      clearedKeys.push(key);
    });
    
    // Also clear sessionStorage stale items
    for (let i = sessionStorage.length - 1; i >= 0; i--) {
      const key = sessionStorage.key(i);
      if (key && STALE_KEYS_PREFIX.some(prefix => key.startsWith(prefix))) {
        sessionStorage.removeItem(key);
        clearedKeys.push(`session:${key}`);
      }
    }
    
    // Update stored version
    localStorage.setItem(VERSION_KEY, BUILD_VERSION);
    
    if (clearedKeys.length > 0) {
      console.log(`[BuildVersion] Cleared ${clearedKeys.length} stale keys:`, clearedKeys);
    }
  }

  return {
    isNewVersion,
    previousVersion: storedVersion,
    currentVersion: BUILD_VERSION,
    clearedKeys,
  };
};

/**
 * Get current build version
 */
export const getBuildVersion = (): string => BUILD_VERSION;

/**
 * Force clear all app state (for manual reset)
 */
export const forceResetAllState = (): void => {
  const keysToRemove: string[] = [];
  
  // Collect keys to remove
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && STALE_KEYS_PREFIX.some(prefix => key.startsWith(prefix))) {
      keysToRemove.push(key);
    }
  }
  
  // Remove collected keys
  keysToRemove.forEach(key => localStorage.removeItem(key));
  
  // Clear session storage
  sessionStorage.clear();
  
  // Update version
  localStorage.setItem(VERSION_KEY, BUILD_VERSION);
  
  console.log('[BuildVersion] Force reset completed');
};
