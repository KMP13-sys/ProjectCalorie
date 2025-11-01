// การตั้งค่า URL ของ Backend APIs
export const API_CONFIG = {
  // Node.js Backend (port 4000)
  NODE_API_URL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:4000',

  // Flask ML Server (port 5000)
  FLASK_API_URL: process.env.NEXT_PUBLIC_FLASK_API_URL || 'http://localhost:5000',
} as const;

// ฟังก์ชันดึง URL ของ Node.js Backend
export const getNodeApiUrl = (): string => API_CONFIG.NODE_API_URL;

// ฟังก์ชันดึง URL ของ Flask ML Server
export const getFlaskApiUrl = (): string => API_CONFIG.FLASK_API_URL;

export default API_CONFIG;
