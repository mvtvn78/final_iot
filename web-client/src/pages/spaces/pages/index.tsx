import { Switch } from "antd";
import { Home, Plus } from "lucide-react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import { openNotification } from "../../../components/base/notification";
import Menu from "../../../layout/menu";
import {
  deviceSocketService,
  type DeviceData,
} from "../../../services/deviceSocket";
import type { WeatherData } from "../../../services/weatherApi";
import { weatherApiService } from "../../../services/weatherApi";
import { controlDevice, getDevice } from "../apis";

interface Device {
  id: string;
  name: string;
  image: string;
  room: string;
  payload: number;
  power?: string;
  ts?: number;
}

export default function SpacesPage() {
  const navigate = useNavigate();
  const [isSetupComplete, setIsSetupComplete] = useState(false);
  const [devices, setDevices] = useState<Device[]>([]);
  const [weatherData, setWeatherData] = useState<WeatherData | null>(null);
  const [lightsOn, setLightsOn] = useState(true);
  const [musicPlaying] = useState(true);

  const houseName = localStorage.getItem("houseName") || "My Home";

  useEffect(() => {
    // Check if setup is complete
    const houseName = localStorage.getItem("houseName");
    const storedRooms = localStorage.getItem("rooms");
    const connectedDevices = localStorage.getItem("connectedDevices");

    if (!houseName) {
      navigate("/spaces/new-home", { replace: true });
      return;
    }

    const rooms = storedRooms ? JSON.parse(storedRooms) : [];
    if (rooms.length === 0) {
      navigate("/spaces/add-room", { replace: true });
      return;
    }

    const devices = connectedDevices ? JSON.parse(connectedDevices) : [];
    if (devices.length === 0) {
      navigate("/spaces/add-devices", { replace: true });
      return;
    }

    // Setup is complete
    setIsSetupComplete(true);

    // Load devices from API
    const loadDevices = async () => {
      try {
        const response = await getDevice();
        const apiDevices = response.data || response || [];

        // Load device-room mapping from localStorage
        const deviceRoomMapRaw = localStorage.getItem("deviceRoomMap");
        const deviceRoomMap = deviceRoomMapRaw
          ? (JSON.parse(deviceRoomMapRaw) as Record<string, string>)
          : {};

        // Map API devices to our Device interface
        const mappedDevices: Device[] = apiDevices.map((apiDevice: any) => ({
          id: apiDevice.id?.toString() || apiDevice._id?.toString() || "",
          name: apiDevice.name || "Unknown Device",
          image: apiDevice.image || "/image-home-new.png",
          room:
            deviceRoomMap[
              apiDevice.id?.toString() || apiDevice._id?.toString() || ""
            ] ||
            apiDevice.room ||
            "Living Room",
          payload: apiDevice.payload || 0,
        }));

        setDevices(mappedDevices);
      } catch (error) {
        console.error("Error loading devices from API:", error);
        // Fallback to localStorage if API fails
        const deviceRoomMapRaw = localStorage.getItem("deviceRoomMap");
        const deviceRoomMap = deviceRoomMapRaw
          ? (JSON.parse(deviceRoomMapRaw) as Record<string, string>)
          : {};

        const devicesFromStorage: Device[] = devices.map((deviceId: string) => {
          return {
            id: deviceId,
            name: `Device ${deviceId}`,
            image: "/image-home-new.png",
            room: deviceRoomMap[deviceId] || "Living Room",
            payload: 0,
          };
        });

        setDevices(devicesFromStorage);
      }
    };

    loadDevices();

    // Subscribe to weather updates
    const handleWeatherUpdate = (data: WeatherData) => {
      setWeatherData(data);
    };

    const unsubscribe = weatherApiService.subscribe(handleWeatherUpdate);
    weatherApiService.start();

    // Get initial weather data
    const currentData = weatherApiService.getCurrentData();
    if (currentData) {
      setWeatherData(currentData);
    }

    return () => {
      unsubscribe();
    };
  }, [navigate]);

  // Subscribe to WebSocket updates for all devices (auto-connect on mount)
  useEffect(() => {
    if (!isSetupComplete || devices.length === 0) {
      return;
    }

    const unsubscribes: (() => void)[] = [];

    // Connect WebSocket for all devices to get current state
    devices.forEach((device) => {
      const unsubscribe = deviceSocketService.subscribe(
        device.id,
        (deviceData: DeviceData) => {
          // Update device state based on WebSocket data
          // stateRelay indicates current device state (true = ON, false = OFF)
          const isDeviceOn = deviceData.stateRelay === true || deviceData.stateRelay === "true";
          
          setDevices((prev) => {
            const updated = prev.map((d) =>
              d.id === device.id
                ? {
                    ...d,
                    payload: isDeviceOn ? 1 : 0,
                    power: deviceData.power || "0",
                    ts: deviceData.ts || Date.now(),
                  }
                : d
            );

            // Update lights status if it's a lamp device
            const lampDevice = updated.find((d) => d.id === device.id);
            if (lampDevice?.name.toLowerCase().includes("lamp")) {
              const lampDevices = updated.filter((d) =>
                d.name.toLowerCase().includes("lamp")
              );
              const allLampsOn = lampDevices.every((d) => d.payload === 1);
              setLightsOn(allLampsOn);
            }

            return updated;
          });
        },
        (deviceId) => {
          // Callback when WebSocket connects successfully
          const deviceName =
            devices.find((d) => d.id === deviceId)?.name || deviceId;
          console.log(
            `✅ WebSocket connected successfully for device ${deviceName} (${deviceId})`
          );
        }
      );
      unsubscribes.push(unsubscribe);
    });

    return () => {
      unsubscribes.forEach((unsubscribe) => unsubscribe());
    };
  }, [isSetupComplete, devices.map((d) => d.id).join(",")]); // Re-subscribe when device IDs change

  const handleToggleDevice = async (deviceId: string, checked: boolean) => {
    // Optimistically update UI
    setDevices((prev) => {
      const updated = prev.map((d) =>
        d.id === deviceId ? { ...d, payload: checked ? 1 : 0 } : d
      );

      // Update lights status based on lamp devices
      const device = updated.find((d) => d.id === deviceId);
      if (device?.name.toLowerCase().includes("lamp")) {
        const lampDevices = updated.filter((d) =>
          d.name.toLowerCase().includes("lamp")
        );
        const allLampsOn = lampDevices.every((d) => d.payload === 1);
        setLightsOn(allLampsOn);
      }

      return updated;
    });

    // Call API to control device
    // Note: WebSocket is already connected and will automatically update state
    try {
      const status = checked ? 1 : 0;
      await controlDevice(deviceId, status);
      openNotification({
        type: "success",
        title: "Success",
        message: `Device ${checked ? "turned on" : "turned off"} successfully`,
      });
    } catch (error) {
      console.error("Error controlling device:", error);
      // Revert UI change on error
      setDevices((prev) => {
        const updated = prev.map((d) =>
          d.id === deviceId ? { ...d, payload: checked ? 0 : 1 } : d
        );

        // Update lights status
        const device = updated.find((d) => d.id === deviceId);
        if (device?.name.toLowerCase().includes("lamp")) {
          const lampDevices = updated.filter((d) =>
            d.name.toLowerCase().includes("lamp")
          );
          const allLampsOn = lampDevices.every((d) => d.payload === 1);
          setLightsOn(allLampsOn);
        }

        return updated;
      });
      openNotification({
        type: "error",
        title: "Failed",
        message: "Failed to control device. Please try again.",
      });
    }
  };

  // If setup is not complete, show loading or redirect (handled by useEffect)
  if (!isSetupComplete) {
    return (
      <div className="flex h-screen bg-gray-50">
        <div className="w-[298px] shrink-0">
          <Menu />
        </div>
        <div className="flex-1 flex items-center justify-center">
          <div className="text-gray-500">Loading...</div>
        </div>
      </div>
    );
  }

  const deviceCount = devices.length;
  const weatherDescription = weatherData
    ? weatherData.temperature > 20
      ? "Partly Cloudy"
      : "Cloudy"
    : "Loading...";
  const temperature = weatherData
    ? `${weatherData.temperature.toFixed(1)}°`
    : "--";
  const humidity = weatherData ? `${weatherData.humidity.toFixed(0)}%` : "--";

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="w-[298px] shrink-0">
        <Menu />
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="relative bg-[#222833] px-8 py-6 rounded-b-2xl">
          {/* Background Pattern */}
          <div className="absolute inset-0 opacity-10 overflow-hidden rounded-b-2xl">
            <svg
              className="absolute bottom-0 w-full"
              viewBox="0 0 1200 100"
              preserveAspectRatio="none"
            >
              <path
                d="M0,50 Q300,20 600,50 T1200,50 L1200,100 L0,100 Z"
                fill="white"
              />
            </svg>
          </div>

          <div className="relative space-y-6">
            {/* Top Row: Title and Home Selector */}
            <div className="flex items-center justify-between">
              <h1 className="text-2xl font-bold text-white">Spaces</h1>
              <div className="flex items-center gap-2 bg-white/10 hover:bg-white/15 rounded-lg px-3 py-2 cursor-pointer transition-colors">
                <div className="w-6 h-6 rounded-full overflow-hidden bg-gray-300 flex items-center justify-center shrink-0">
                  <img
                    src="/image-home-new.png"
                    alt="Home"
                    className="w-full h-full object-cover"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src =
                        "/image-home-new.png";
                    }}
                  />
                </div>
                <span className="text-white font-medium text-sm">
                  {houseName}
                </span>
                <svg
                  width="12"
                  height="12"
                  viewBox="0 0 12 12"
                  fill="none"
                  className="text-white ml-1"
                >
                  <path
                    d="M3 4.5L6 7.5L9 4.5"
                    stroke="currentColor"
                    strokeWidth="1.5"
                    strokeLinecap="round"
                    strokeLinejoin="round"
                  />
                </svg>
              </div>
            </div>

            {/* Status Widgets */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
              {/* Weather Widget */}
              <div className="bg-[#48505E] rounded-xl p-4 flex items-center gap-3">
                <div className="w-12 h-12 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-mat-troi.png"
                    alt="Weather"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div className="flex-1">
                  <p className="text-sm text-gray-400">Weather</p>
                  <p className="text-base font-semibold text-white">
                    {weatherDescription}
                  </p>
                  <p className="text-lg font-bold text-white">{temperature}</p>
                </div>
              </div>

              {/* Humidity Widget */}
              <div className="bg-[#48505E] rounded-xl p-4 flex items-center gap-3">
                <div className="w-12 h-12 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-giot-nuoc.png"
                    alt="Humidity"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div className="flex-1">
                  <p className="text-sm text-gray-400">Humidity</p>
                  <p className="text-lg font-bold text-white">{humidity}</p>
                </div>
              </div>

              {/* Lights Status Widget */}
              <div className="bg-[#48505E] rounded-xl p-4 flex items-center gap-3">
                <div className="w-12 h-12 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-bong-den.png"
                    alt="Lights"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div className="flex-1">
                  <p className="text-sm text-gray-400">Lights Status</p>
                  <p className="text-base font-semibold text-white">
                    {lightsOn ? "All lights on Home" : "Some lights off"}
                  </p>
                </div>
              </div>

              {/* Music Status Widget */}
              <div className="bg-[#48505E] rounded-xl p-4 flex items-center gap-3">
                <div className="w-12 h-12 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-zing.png"
                    alt="Music"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div className="flex-1">
                  <p className="text-sm text-gray-400">Music Status</p>
                  <p className="text-base font-semibold text-white">
                    {musicPlaying
                      ? "Play music Living room"
                      : "No music playing"}
                  </p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto px-8 py-6">
          <div className="max-w-7xl mx-auto space-y-6">
            {/* Your Devices Section */}
            <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
              <div className="flex items-center justify-between mb-6">
                <div className="flex items-center gap-3">
                  <h2 className="text-2xl font-bold text-[#48505E]">
                    Your Devices
                  </h2>
                  <span className="px-3 py-1 bg-gray-100 text-gray-600 rounded-full text-sm font-medium">
                    {deviceCount}
                  </span>
                </div>
              </div>

              {devices.length === 0 ? (
                <div className="text-center py-12">
                  <p className="text-gray-500">No devices connected yet</p>
                  <button
                    onClick={() => navigate("/spaces/add-devices")}
                    className="mt-4 text-blue-500 hover:text-blue-600"
                  >
                    Add devices
                  </button>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  {devices.map((device) => (
                    <div
                      key={device.id}
                      className="bg-white border border-gray-200 rounded-xl p-4 hover:shadow-md transition-shadow flex items-center gap-4"
                    >
                      {/* Device Image with circular background */}
                      <div className="shrink-0">
                        <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center p-2">
                          <img
                            src={
                              device.payload === 1
                                ? "/image-den-sang.png"
                                : "/image-den-tat.png"
                            }
                            alt={device.name}
                            className="w-full h-full object-contain"
                            onError={(e) => {
                              (e.target as HTMLImageElement).src =
                                device.payload === 1
                                  ? "/image-den-sang.png"
                                  : "/image-den-tat.png";
                            }}
                          />
                        </div>
                      </div>

                      {/* Device Info - Clickable */}
                      <div
                        className="flex-1 min-w-0 cursor-pointer"
                        onClick={() => navigate(`/device/${device.id}`)}
                      >
                        <h3 className="text-base font-semibold text-[#48505E] mb-1 hover:text-blue-600 transition-colors">
                          {device.name}
                        </h3>
                        <p className="text-sm text-gray-500">{device.room}</p>
                      </div>

                      {/* Toggle Switch */}
                      <div className="shrink-0">
                        <Switch
                          checked={device.payload === 1}
                          onChange={(checked) =>
                            handleToggleDevice(device.id, checked)
                          }
                          className="bg-gray-300"
                        />
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* Members Section */}
            <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
              <h2 className="text-2xl font-bold text-[#48505E] mb-4">
                Members
              </h2>
              <div className="flex items-center gap-3">
                {/* Mock member avatars */}
                {[1, 2, 3, 4].map((i) => (
                  <div
                    key={i}
                    className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold overflow-hidden"
                  >
                    <img
                      src={`https://i.pravatar.cc/150?img=${i + 10}`}
                      alt={`Member ${i}`}
                      className="w-full h-full object-cover"
                      onError={(e) => {
                        const target = e.target as HTMLImageElement;
                        target.style.display = "none";
                      }}
                    />
                  </div>
                ))}
                {/* Add Member Button */}
                <button className="w-12 h-12 rounded-full bg-blue-500 hover:bg-blue-600 flex items-center justify-center text-white transition-colors">
                  <Plus size={20} />
                </button>
              </div>
            </div>

            {/* Your Space Map Section */}
            <div className="bg-white rounded-2xl shadow-sm border border-gray-200 p-6">
              <h2 className="text-2xl font-bold text-[#48505E] mb-2">
                Your space map
              </h2>
              <p className="text-gray-600 mb-4">
                See your rooms and all the devices that are related to them.
              </p>
              <div className="w-full h-64 bg-gray-100 rounded-xl flex items-center justify-center border-2 border-dashed border-gray-300">
                <div className="text-center">
                  <Home className="text-gray-400 mx-auto mb-2" size={48} />
                  <p className="text-gray-500">Space map coming soon</p>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
