// Weather API Service using Open-Meteo (Free weather API)
export interface WeatherData {
  temperature: number;
  humidity: number;
  timestamp: number;
  rainProbability?: number;
}

export type WeatherDataCallback = (data: WeatherData) => void;

class WeatherApiService {
  private callbacks: WeatherDataCallback[] = [];
  private intervalId: ReturnType<typeof setInterval> | null = null;
  private updateInterval = 60000; // Update every 60 seconds
  private currentData: WeatherData | null = null;
  private latitude = 51.5074; // Default: London, UK
  private longitude = -0.1278;
  private isLocationRequested = false;

  constructor() {
    // Try to get location from localStorage first
    const savedLocation = localStorage.getItem("weatherLocation");
    if (savedLocation) {
      try {
        const location = JSON.parse(savedLocation);
        this.latitude = location.latitude || this.latitude;
        this.longitude = location.longitude || this.longitude;
      } catch (error) {
        console.error("Error parsing saved location:", error);
      }
    }
  }

  async getCurrentLocation(): Promise<{ latitude: number; longitude: number } | null> {
    return new Promise((resolve) => {
      if (!navigator.geolocation) {
        console.warn("Geolocation is not supported by this browser");
        resolve(null);
        return;
      }

      navigator.geolocation.getCurrentPosition(
        (position) => {
          const location = {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
          };
          
          // Save to localStorage
          localStorage.setItem("weatherLocation", JSON.stringify(location));
          
          this.latitude = location.latitude;
          this.longitude = location.longitude;
          
          console.log("Location obtained:", location);
          resolve(location);
        },
        (error) => {
          console.warn("Error getting location:", error.message);
          // Use default location if geolocation fails
          resolve(null);
        },
        {
          enableHighAccuracy: true,
          timeout: 10000,
          maximumAge: 300000, // Cache for 5 minutes
        }
      );
    });
  }

  setLocation(latitude: number, longitude: number) {
    this.latitude = latitude;
    this.longitude = longitude;
    localStorage.setItem(
      "weatherLocation",
      JSON.stringify({ latitude, longitude })
    );
    // Fetch immediately when location changes
    this.fetchWeatherData();
  }

  async fetchWeatherData(): Promise<WeatherData | null> {
    try {
      // Using Open-Meteo API (free, no API key required)
      const url = `https://api.open-meteo.com/v1/forecast?latitude=${this.latitude}&longitude=${this.longitude}&current=temperature_2m,relative_humidity_2m,precipitation_probability&timezone=auto`;
      
      const response = await fetch(url);
      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      const data = await response.json();

      if (data.current) {
        const weatherData: WeatherData = {
          temperature: data.current.temperature_2m || 0,
          humidity: data.current.relative_humidity_2m || 0,
          rainProbability: data.current.precipitation_probability || 0,
          timestamp: Date.now(),
        };

        this.currentData = weatherData;
        
        // Notify all callbacks
        this.callbacks.forEach((callback) => callback(weatherData));
        
        return weatherData;
      }
    } catch (error) {
      console.error("Error fetching weather data:", error);
      // Return cached data if available
      if (this.currentData) {
        return this.currentData;
      }
    }
    return null;
  }

  async start() {
    // Get current location first if not already requested
    if (!this.isLocationRequested) {
      this.isLocationRequested = true;
      await this.getCurrentLocation();
    }
    
    // Fetch immediately
    await this.fetchWeatherData();
    
    // Then fetch periodically
    if (this.intervalId) {
      clearInterval(this.intervalId);
    }
    
    this.intervalId = setInterval(() => {
      this.fetchWeatherData();
    }, this.updateInterval);
  }

  stop() {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  subscribe(callback: WeatherDataCallback) {
    this.callbacks.push(callback);
    
    // Start fetching if not already started
    if (!this.intervalId) {
      this.start();
    }
    
    // Send current data immediately if available
    if (this.currentData) {
      callback(this.currentData);
    }
    
    // Return unsubscribe function
    return () => {
      this.callbacks = this.callbacks.filter((cb) => cb !== callback);
      // Stop if no more callbacks
      if (this.callbacks.length === 0) {
        this.stop();
      }
    };
  }

  async refreshLocation() {
    // Force refresh location
    this.isLocationRequested = false;
    await this.getCurrentLocation();
    await this.fetchWeatherData();
  }

  getCurrentData(): WeatherData | null {
    return this.currentData;
  }
}

// Singleton instance
export const weatherApiService = new WeatherApiService();

// Helper function to calculate rain probability based on humidity and temperature
export function calculateRainProbability(
  temperature: number,
  humidity: number
): number {
  // Rain probability calculation based on temperature and humidity
  // Higher humidity + lower temperature = higher rain probability
  
  // Normalize temperature (assume optimal range is 15-25°C)
  const tempFactor = Math.max(0, Math.min(1, (25 - temperature) / 15));
  
  // Humidity factor (higher humidity = higher chance)
  const humidityFactor = humidity / 100;
  
  // Combine factors (weighted average)
  const rainProbability = (tempFactor * 0.4 + humidityFactor * 0.6) * 100;
  
  return Math.round(Math.max(0, Math.min(100, rainProbability)));
}

// Helper function to get weather description based on temperature and humidity
export function getWeatherDescription(
  temperature: number,
  humidity: number,
  rainProbability?: number
): string {
  const calculatedRainProb = rainProbability !== undefined 
    ? rainProbability 
    : calculateRainProbability(temperature, humidity);
  
  if (calculatedRainProb > 70) {
    return "Rainy";
  } else if (calculatedRainProb > 50) {
    return "Cloudy";
  } else if (calculatedRainProb > 30) {
    return "Partly Cloudy";
  } else {
    return "Sunny";
  }
}

