// ============================================
// API Configuration
// ============================================
// Central configuration for all backend API URLs
//
// Usage:
// - Development (Local): localhost
// - Production: Change to your production URLs

/**
 * API Configuration Object
 */
export const API_CONFIG = {
  // Node.js Backend (port 4000)
  NODE_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000',

  // Flask ML Server (port 5000)
  FLASK_API_URL: process.env.NEXT_PUBLIC_FLASK_API_URL || 'http://localhost:5000',
} as const;

/**
 * Get Node.js Backend URL
 */
export const getNodeApiUrl = (): string => API_CONFIG.NODE_API_URL;

/**
 * Get Flask ML Server URL
 */
export const getFlaskApiUrl = (): string => API_CONFIG.FLASK_API_URL;

export default API_CONFIG;
