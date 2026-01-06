// Application Constants

// API Configuration
export const API_CONFIG = {
  BASE_URL: "http://slothz.ddns.net:22021/",
  TIMEOUT: 10000,
  WEBSOCKET_URL: "ws://slothz.ddns.net:22021/iot",
} as const;

// LocalStorage Keys
export const STORAGE_KEYS = {
  TOKEN: "token",
  HOUSE_NAME: "houseName",
  ROOMS: "rooms",
  CONNECTED_DEVICES: "connectedDevices",
  DEVICE_ROOM_MAP: "deviceRoomMap",
  USER_PROFILE: "userProfile",
  WEATHER_LOCATION: "weatherLocation",
  USER_NAME: "userName",
  EMAIL: "email",
  OTP: "otp",
} as const;

// Routes
export const ROUTES = {
  HOME: "/",
  SPLASH: "/",
  LOGIN: "/login",
  REGISTER: "/register",
  FORGET: "/forget",
  RESET: "/reset",
  VERIFY_CODE: "/verify-code",
  SUCCESS: "/success",
  ROOMS: "/rooms",
  DEVICES: "/devices",
  MEMBERS: "/members",
  STATISTICS: "/statistics",
  SPACES: "/spaces",
  SPACES_NO_DEVICE: "/spaces/no-device",
  SPACES_NEW_HOME: "/spaces/new-home",
  SPACES_ADD_ROOM: "/spaces/add-room",
  SPACES_ADD_DEVICES: "/spaces/add-devices",
  SPACES_LINK_DEVICE: "/spaces/link-device",
  PROFILE: "/profile",
  DEVICE_DETAIL: "/device",
} as const;

// WebSocket Configuration
export const WEBSOCKET_CONFIG = {
  MAX_RECONNECT_ATTEMPTS: 5,
  RECONNECT_DELAY: 3000,
} as const;

// Weather API Configuration
export const WEATHER_CONFIG = {
  UPDATE_INTERVAL: 60000, // 60 seconds
  DEFAULT_LATITUDE: 51.5074, // London, UK
  DEFAULT_LONGITUDE: -0.1278,
} as const;

// Device Status
export const DEVICE_STATUS = {
  ON: 1,
  OFF: 0,
} as const;

// Notification Duration
export const NOTIFICATION_DURATION = {
  SHORT: 2,
  MEDIUM: 3,
  LONG: 5,
} as const;

