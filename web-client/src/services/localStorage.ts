// LocalStorage Service - Centralized storage management
class LocalStorageService {
  private static instance: LocalStorageService;

  private constructor() {}

  static getInstance(): LocalStorageService {
    if (!LocalStorageService.instance) {
      LocalStorageService.instance = new LocalStorageService();
    }
    return LocalStorageService.instance;
  }

  // Generic methods
  get<T>(key: string, defaultValue: T | null = null): T | null {
    try {
      const item = localStorage.getItem(key);
      if (item === null) {
        return defaultValue;
      }
      return JSON.parse(item) as T;
    } catch (error) {
      console.error(`Error reading from localStorage key "${key}":`, error);
      return defaultValue;
    }
  }

  set<T>(key: string, value: T): void {
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch (error) {
      console.error(`Error writing to localStorage key "${key}":`, error);
    }
  }

  remove(key: string): void {
    try {
      localStorage.removeItem(key);
    } catch (error) {
      console.error(`Error removing localStorage key "${key}":`, error);
    }
  }

  clear(): void {
    try {
      localStorage.clear();
    } catch (error) {
      console.error("Error clearing localStorage:", error);
    }
  }

  // Specific getters and setters for app data
  getToken(): string | null {
    return localStorage.getItem("token");
  }

  setToken(token: string): void {
    localStorage.setItem("token", token);
  }

  removeToken(): void {
    localStorage.removeItem("token");
  }

  getHouseName(): string | null {
    return localStorage.getItem("houseName");
  }

  setHouseName(name: string): void {
    localStorage.setItem("houseName", name);
  }

  getRooms<T>(): T[] {
    return this.get<T[]>("rooms", []) || [];
  }

  setRooms<T>(rooms: T[]): void {
    this.set("rooms", rooms);
  }

  getConnectedDevices(): string[] {
    return this.get<string[]>("connectedDevices", []) || [];
  }

  setConnectedDevices(devices: string[]): void {
    this.set("connectedDevices", devices);
  }

  getDeviceRoomMap(): Record<string, string> {
    return this.get<Record<string, string>>("deviceRoomMap", {}) || {};
  }

  setDeviceRoomMap(map: Record<string, string>): void {
    this.set("deviceRoomMap", map);
  }

  getUserProfile<T>(): T | null {
    return this.get<T>("userProfile", null);
  }

  setUserProfile<T>(profile: T): void {
    this.set("userProfile", profile);
  }

  getWeatherLocation(): { latitude: number; longitude: number } | null {
    return this.get<{ latitude: number; longitude: number }>("weatherLocation", null);
  }

  setWeatherLocation(location: { latitude: number; longitude: number }): void {
    this.set("weatherLocation", location);
  }
}

export const localStorageService = LocalStorageService.getInstance();

