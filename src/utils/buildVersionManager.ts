/**
 * Build Version Manager
 * 
 * Ensures fresh browser state when new code is deployed via GitHub.
 * Clears ALL stale localStorage/sessionStorage and forces re-render on version mismatch.
 */

// BUILD_VERSION is updated automatically when code changes are detected
// Format: ISO timestamp - changes every deployment
// To force a version bump, update this timestamp
const BUILD_VERSION = '2026-01-16T13:00:00Z';
const VERSION_KEY = 'app_build_version';

// Keys that should NEVER be cleared (auth session data managed by Supabase)
const PROTECTED_KEYS = [
  'sb-', // Supabase auth session keys (sb-{project-ref}-auth-token)
  'supabase.auth.token',
  'app_build_version',
];

// Keys prefixes to ALWAYS clear on version change (explicit stale keys)
const ALWAYS_CLEAR_PREFIXES = [
  'nav_customization_',
  'cached_',
  'offline_',
  'sidebar_',
  'filter_',
  'sort_',
  'view_',
  'tab_',
  'form_',
  'draft_',
  'search_',
  'preference_',
  'collapsed_',
  'expanded_',
  'selected_',
  'last_',
  'temp_',
  'ui_',
  'state_',
  'module_',
  'dashboard_',
  'settings_',
  'cache_',
];

export interface VersionCheckResult {
  isNewVersion: boolean;
  previousVersion: string | null;
  currentVersion: string;
  clearedKeys: string[];
}

/**
 * Check if a key is protected (should not be cleared)
 */
const isProtectedKey = (key: string): boolean => {
  return PROTECTED_KEYS.some(prefix => key.startsWith(prefix));
};

/**
 * Check if a key should be cleared on version change
 */
const shouldClearKey = (key: string): boolean => {
  if (isProtectedKey(key)) return false;
  return ALWAYS_CLEAR_PREFIXES.some(prefix => key.startsWith(prefix));
};

/**
 * Check if the current build is newer than what's stored in browser
 * If so, clear ALL stale state to ensure fresh rendering across all modules
 */
export const checkAndClearStaleState = (): VersionCheckResult => {
  const storedVersion = localStorage.getItem(VERSION_KEY);
  const isNewVersion = storedVersion !== BUILD_VERSION;
  const clearedKeys: string[] = [];

  if (isNewVersion) {
    console.log(`[BuildVersion] New version detected: ${BUILD_VERSION} (was: ${storedVersion})`);
    
    // Collect all keys to remove from localStorage
    const keysToRemove: string[] = [];
    
    for (let i = 0; i < localStorage.length; i++) {
      const key = localStorage.key(i);
      if (key && shouldClearKey(key)) {
        keysToRemove.push(key);
      }
    }
    
    // Remove collected keys
    keysToRemove.forEach(key => {
      localStorage.removeItem(key);
      clearedKeys.push(key);
    });
    
    // Clear ALL sessionStorage (session data is temporary anyway)
    const sessionKeys: string[] = [];
    for (let i = 0; i < sessionStorage.length; i++) {
      const key = sessionStorage.key(i);
      if (key) sessionKeys.push(key);
    }
    sessionKeys.forEach(key => {
      sessionStorage.removeItem(key);
      clearedKeys.push(`session:${key}`);
    });
    
    // Update stored version
    localStorage.setItem(VERSION_KEY, BUILD_VERSION);
    
    if (clearedKeys.length > 0) {
      console.log(`[BuildVersion] Cleared ${clearedKeys.length} stale keys across all modules`);
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
 * Force clear all app state (for manual reset) - clears everything except auth
 */
export const forceResetAllState = (): void => {
  const keysToRemove: string[] = [];
  
  // Collect ALL non-protected keys to remove
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && !isProtectedKey(key)) {
      keysToRemove.push(key);
    }
  }
  
  // Remove collected keys
  keysToRemove.forEach(key => localStorage.removeItem(key));
  
  // Clear all session storage
  sessionStorage.clear();
  
  // Update version
  localStorage.setItem(VERSION_KEY, BUILD_VERSION);
  
  console.log(`[BuildVersion] Force reset completed - cleared ${keysToRemove.length} keys`);
};

/**
 * Clear specific module state (for targeted resets)
 */
export const clearModuleState = (modulePrefix: string): void => {
  const keysToRemove: string[] = [];
  
  for (let i = 0; i < localStorage.length; i++) {
    const key = localStorage.key(i);
    if (key && key.startsWith(modulePrefix)) {
      keysToRemove.push(key);
    }
  }
  
  keysToRemove.forEach(key => localStorage.removeItem(key));
  console.log(`[BuildVersion] Cleared ${keysToRemove.length} keys for module: ${modulePrefix}`);
};
