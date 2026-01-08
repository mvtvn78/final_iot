// Weather WebSocket Service
export interface WeatherData {
  temperature: number;
  humidity: number;
  timestamp: number;
}

export type WeatherDataCallback = (data: WeatherData) => void;

class WeatherWebSocketService {
  private ws: WebSocket | null = null;
  private callbacks: WeatherDataCallback[] = [];
  private reconnectAttempts = 0;
  private maxReconnectAttempts = 5;
  private reconnectDelay = 3000;
  private isConnecting = false;

  connect() {
    if (this.ws?.readyState === WebSocket.OPEN || this.isConnecting) {
      return;
    }

    this.isConnecting = true;
    const deviceId = localStorage.getItem("deviceId");
    const token = localStorage.getItem("token");

    if (!deviceId || !token) {
      console.warn("DeviceId or token not found in localStorage");
      this.isConnecting = false;
      return;
    }

    try {
      const wsUrl = `http://slothz.ddns.net:22021/iot?deviceId=${deviceId}&token=${token}`;
      this.ws = new WebSocket(wsUrl);

      this.ws.onopen = () => {
        console.log("Weather WebSocket connected");
        this.isConnecting = false;
        this.reconnectAttempts = 0;
      };

      this.ws.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          
          // Check if data contains temperature and humidity
          if (data.temperature !== undefined && data.humidity !== undefined) {
            const weatherData: WeatherData = {
              temperature: parseFloat(data.temperature) || 0,
              humidity: parseFloat(data.humidity) || 0,
              timestamp: Date.now(),
            };
            
            // Notify all callbacks
            this.callbacks.forEach((callback) => callback(weatherData));
          }
        } catch (error) {
          console.error("Error parsing WebSocket message:", error);
        }
      };

      this.ws.onerror = (error) => {
        console.error("WebSocket error:", error);
        this.isConnecting = false;
      };

      this.ws.onclose = () => {
        console.log("WebSocket disconnected");
        this.isConnecting = false;
        this.ws = null;
        
        // Attempt to reconnect
        if (this.reconnectAttempts < this.maxReconnectAttempts) {
          this.reconnectAttempts++;
          setTimeout(() => {
            this.connect();
          }, this.reconnectDelay);
        }
      };
    } catch (error) {
      console.error("Error creating WebSocket:", error);
      this.isConnecting = false;
    }
  }

  disconnect() {
    if (this.ws) {
      this.ws.close();
      this.ws = null;
    }
    this.callbacks = [];
    this.reconnectAttempts = 0;
  }

  subscribe(callback: WeatherDataCallback) {
    this.callbacks.push(callback);
    
    // Connect if not already connected
    if (!this.ws || this.ws.readyState !== WebSocket.OPEN) {
      this.connect();
    }
    
    // Return unsubscribe function
    return () => {
      this.callbacks = this.callbacks.filter((cb) => cb !== callback);
    };
  }

  isConnected(): boolean {
    return this.ws?.readyState === WebSocket.OPEN;
  }
}

// Singleton instance
export const weatherSocketService = new WeatherWebSocketService();

// Helper function to calculate rain probability
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
  humidity: number
): string {
  const rainProbability = calculateRainProbability(temperature, humidity);
  
  if (rainProbability > 70) {
    return "Rainy";
  } else if (rainProbability > 50) {
    return "Cloudy";
  } else if (rainProbability > 30) {
    return "Partly Cloudy";
  } else {
    return "Sunny";
  }
}

