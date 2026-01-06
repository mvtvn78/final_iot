// Device WebSocket Service
export interface DeviceData {
  deviceId: string;
  stateRelay: boolean;
  power: string;
  ts: number;
}

export type DeviceDataCallback = (data: DeviceData) => void;
export type DeviceConnectionCallback = (deviceId: string) => void;

class DeviceWebSocketService {
  private connections: Map<string, WebSocket> = new Map();
  private callbacks: Map<string, DeviceDataCallback[]> = new Map();
  private connectionCallbacks: Map<string, DeviceConnectionCallback[]> = new Map();
  private reconnectAttempts: Map<string, number> = new Map();
  private maxReconnectAttempts = 5;
  private reconnectDelay = 3000;
  private isConnecting: Map<string, boolean> = new Map();

  connect(deviceId: string) {
    // Check if already connected or connecting
    const ws = this.connections.get(deviceId);
    if (ws?.readyState === WebSocket.OPEN || this.isConnecting.get(deviceId)) {
      return;
    }

    this.isConnecting.set(deviceId, true);
    const token = localStorage.getItem("token");

    if (!token) {
      console.warn("Token not found in localStorage");
      this.isConnecting.set(deviceId, false);
      return;
    }

    try {
      // Use ws:// for WebSocket protocol
      const wsUrl = `ws://slothz.ddns.net:22021/iot?deviceId=${deviceId}&token=${token}`;
      const newWs = new WebSocket(wsUrl);

      newWs.onopen = () => {
        console.log(`✅ Device WebSocket connected successfully for device: ${deviceId}`);
        this.isConnecting.set(deviceId, false);
        this.reconnectAttempts.set(deviceId, 0);
        
        // Notify all connection callbacks
        const connectionCallbacks = this.connectionCallbacks.get(deviceId) || [];
        connectionCallbacks.forEach((callback) => callback(deviceId));
      };

      newWs.onmessage = (event) => {
        try {
          const data = JSON.parse(event.data);
          
          // Parse device data
          const deviceData: DeviceData = {
            deviceId,
            stateRelay: data.stateRelay === true || data.stateRelay === "true",
            power: data.power || "0",
            ts: data.ts || Date.now(),
          };

          // Notify all callbacks for this device
          const callbacks = this.callbacks.get(deviceId) || [];
          callbacks.forEach((callback) => callback(deviceData));
        } catch (error) {
          console.error(`Error parsing device data for ${deviceId}:`, error);
        }
      };

      newWs.onerror = (error) => {
        console.error(`WebSocket error for device ${deviceId}:`, error);
        this.isConnecting.set(deviceId, false);
      };

      newWs.onclose = () => {
        console.log(`WebSocket closed for device: ${deviceId}`);
        this.connections.delete(deviceId);
        this.isConnecting.set(deviceId, false);

        // Attempt to reconnect
        const attempts = this.reconnectAttempts.get(deviceId) || 0;
        if (attempts < this.maxReconnectAttempts) {
          this.reconnectAttempts.set(deviceId, attempts + 1);
          setTimeout(() => {
            this.connect(deviceId);
          }, this.reconnectDelay);
        }
      };

      this.connections.set(deviceId, newWs);
    } catch (error) {
      console.error(`Error connecting WebSocket for device ${deviceId}:`, error);
      this.isConnecting.set(deviceId, false);
    }
  }

  disconnect(deviceId: string) {
    const ws = this.connections.get(deviceId);
    if (ws) {
      console.log(`🔌 Device WebSocket disconnected for device: ${deviceId}`);
      ws.close();
      this.connections.delete(deviceId);
      this.callbacks.delete(deviceId);
      this.connectionCallbacks.delete(deviceId);
      this.reconnectAttempts.delete(deviceId);
      this.isConnecting.delete(deviceId);
    }
  }

  subscribe(
    deviceId: string,
    callback: DeviceDataCallback,
    onConnect?: DeviceConnectionCallback
  ) {
    if (!this.callbacks.has(deviceId)) {
      this.callbacks.set(deviceId, []);
    }
    this.callbacks.get(deviceId)!.push(callback);

    // Register connection callback if provided
    if (onConnect) {
      if (!this.connectionCallbacks.has(deviceId)) {
        this.connectionCallbacks.set(deviceId, []);
      }
      this.connectionCallbacks.get(deviceId)!.push(onConnect);
    }

    // Connect if not already connected
    this.connect(deviceId);

    // Return unsubscribe function
    return () => {
      const callbacks = this.callbacks.get(deviceId);
      if (callbacks) {
        const index = callbacks.indexOf(callback);
        if (index > -1) {
          callbacks.splice(index, 1);
        }
        
        // Disconnect if no more callbacks
        if (callbacks.length === 0) {
          this.disconnect(deviceId);
        }
      }

      // Remove connection callback
      if (onConnect) {
        const connCallbacks = this.connectionCallbacks.get(deviceId);
        if (connCallbacks) {
          const index = connCallbacks.indexOf(onConnect);
          if (index > -1) {
            connCallbacks.splice(index, 1);
          }
        }
      }
    };
  }

  unsubscribe(deviceId: string, callback: DeviceDataCallback) {
    const callbacks = this.callbacks.get(deviceId);
    if (callbacks) {
      const index = callbacks.indexOf(callback);
      if (index > -1) {
        callbacks.splice(index, 1);
      }
      
      // Disconnect if no more callbacks
      if (callbacks.length === 0) {
        this.disconnect(deviceId);
      }
    }
  }

  disconnectAll() {
    this.connections.forEach((ws, deviceId) => {
      ws.close();
    });
    this.connections.clear();
    this.callbacks.clear();
    this.reconnectAttempts.clear();
    this.isConnecting.clear();
  }
}

// Singleton instance
export const deviceSocketService = new DeviceWebSocketService();

