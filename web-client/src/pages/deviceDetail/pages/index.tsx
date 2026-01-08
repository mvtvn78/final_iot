import { Button, Card, Switch } from "antd";
import { ArrowLeft, Power, Zap } from "lucide-react";
import { useCallback, useEffect, useMemo, useState } from "react";
import { useNavigate, useParams } from "react-router-dom";
import { openNotification } from "../../../components/base/notification";
import Menu from "../../../layout/menu";
import {
  deviceSocketService,
  type DeviceData,
} from "../../../services/deviceSocket";
import { controlDevice, getDevice } from "../../spaces/apis";

interface DeviceInfo {
  id: string;
  name: string;
  image: string;
  room: string;
}

export default function DeviceDetailPage() {
  const { deviceId } = useParams<{ deviceId: string }>();
  const navigate = useNavigate();
  const [deviceInfo, setDeviceInfo] = useState<DeviceInfo | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isOn, setIsOn] = useState(false);
  const [power, setPower] = useState<string>("0");
  const [timestamp, setTimestamp] = useState<number>(0);
  const [isControlling, setIsControlling] = useState(false);

  useEffect(() => {
    if (!deviceId) {
      navigate("/spaces", { replace: true });
      return;
    }

    // Load device info from API
    const loadDeviceInfo = async () => {
      try {
        setIsLoading(true);
        const response = await getDevice();
        const apiDevices = response.data || response || [];
        const device = apiDevices.find(
          (d: any) =>
            d.id?.toString() === deviceId || d._id?.toString() === deviceId
        );

        if (device) {
          // Load device-room mapping from localStorage
          const deviceRoomMapRaw = localStorage.getItem("deviceRoomMap");
          const deviceRoomMap = deviceRoomMapRaw
            ? (JSON.parse(deviceRoomMapRaw) as Record<string, string>)
            : {};

          const devicePayload = device.payload || 0;
          const deviceIsOn = devicePayload === 1;

          setDeviceInfo({
            id: device.id?.toString() || device._id?.toString() || deviceId,
            name: device.name || "Unknown Device",
            image: device.image || "/image-home-new.png",
            room: deviceRoomMap[deviceId] || device.room || "Living Room",
          });

          // Set initial state
          setIsOn(deviceIsOn);
          setPower(device.power || "0");
          setTimestamp(device.ts || 0);
        } else {
          openNotification({
            type: "error",
            title: "Error",
            message: "Device not found",
          });
          navigate("/spaces", { replace: true });
        }
      } catch (error) {
        console.error("Error loading device info:", error);
        openNotification({
          type: "error",
          title: "Error",
          message: "Failed to load device information",
        });
        navigate("/spaces", { replace: true });
      } finally {
        setIsLoading(false);
      }
    };

    loadDeviceInfo();
  }, [deviceId, navigate]);

  // Subscribe to WebSocket for real-time updates (auto-connect on mount)
  useEffect(() => {
    if (!deviceId) {
      return;
    }

    // Connect WebSocket immediately to get current device state
    const unsubscribe = deviceSocketService.subscribe(
      deviceId,
      (deviceData: DeviceData) => {
        // Update power and timestamp from WebSocket
        setPower(deviceData.power || "0");
        setTimestamp(deviceData.ts || Date.now());

        // Update device state based on WebSocket data
        // stateRelay indicates current device state (true = ON, false = OFF)
        const isDeviceOn = deviceData.stateRelay === true || deviceData.stateRelay === "true";
        setIsOn(isDeviceOn);
        
        // If device is OFF, reset power and timestamp
        if (!isDeviceOn) {
          setPower("0");
          setTimestamp(0);
        }
      },
      (deviceId) => {
        // Callback when WebSocket connects successfully
        console.log(
          `✅ WebSocket connected successfully for device ${deviceId}`
        );
      }
    );

    return () => {
      unsubscribe();
    };
  }, [deviceId]); // Re-subscribe when deviceId changes

  const handleToggle = useCallback(
    async (checked: boolean) => {
      if (!deviceId) return;

      // Optimistic update - update UI immediately for instant feedback
      const previousState = isOn;
      setIsOn(checked);
      setIsControlling(true);

      // Clear real-time data when device is turned off
      if (!checked) {
        setPower("0");
        setTimestamp(0);
      }

      try {
        const status = checked ? 1 : 0;
        await controlDevice(deviceId, status);

        // Success - state already updated optimistically
        openNotification({
          type: "success",
          title: "Success",
          message: `Device ${
            checked ? "turned on" : "turned off"
          } successfully`,
        });
      } catch (error) {
        console.error("Error controlling device:", error);
        // Revert optimistic update on error
        setIsOn(previousState);
        openNotification({
          type: "error",
          title: "Failed",
          message: "Failed to control device. Please try again.",
        });
      } finally {
        setIsControlling(false);
      }
    },
    [deviceId, isOn]
  );

  const formatTimestamp = (ts: number) => {
    if (!ts) return "N/A";
    const date = new Date(ts * 1000); // Convert to milliseconds
    return date.toLocaleString();
  };

  // Memoize image source to prevent unnecessary re-renders
  const deviceImageSrc = useMemo(() => {
    return isOn ? "/image-den-sang.png" : "/image-den-tat.png";
  }, [isOn]);

  // Preload both images to prevent flickering
  useEffect(() => {
    const imgOn = new Image();
    imgOn.src = "/image-den-sang.png";
    const imgOff = new Image();
    imgOff.src = "/image-den-tat.png";
  }, []);

  if (isLoading) {
    return (
      <div className="flex h-screen bg-gray-50">
        <div className="w-[298px] shrink-0">
          <Menu />
        </div>
        <div className="flex-1 flex items-center justify-center">
          <div className="text-gray-500">Loading device information...</div>
        </div>
      </div>
    );
  }

  if (!deviceInfo) {
    return null;
  }

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="w-[298px] shrink-0">
        <Menu />
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="bg-white border-b border-gray-200 px-8 py-4">
          <div className="flex items-center gap-4">
            <Button
              icon={<ArrowLeft size={18} />}
              onClick={() => navigate(-1)}
              className="flex items-center"
            >
              Back
            </Button>
            <h1 className="text-2xl font-bold text-gray-800">
              {deviceInfo.name}
            </h1>
            <span className="text-sm text-gray-500">({deviceInfo.room})</span>
          </div>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto px-8 py-6">
          <div className="max-w-4xl mx-auto space-y-6">
            {/* Device Image and Control */}
            <Card className="shadow-sm">
              <div className="flex flex-col items-center gap-6">
                {/* Device Image */}
                <div className="w-64 h-64 rounded-2xl bg-gray-100 flex items-center justify-center p-8 shadow-lg overflow-hidden">
                  <img
                    key={deviceImageSrc}
                    src={deviceImageSrc}
                    alt={deviceInfo.name}
                    className="w-full h-full object-contain transition-all duration-300 ease-in-out"
                    style={{
                      opacity: isControlling ? 0.7 : 1,
                      transform: isControlling ? "scale(0.95)" : "scale(1)",
                    }}
                    onError={(e) => {
                      (e.target as HTMLImageElement).src =
                        "/image-home-new.png";
                    }}
                  />
                </div>

                {/* Toggle Switch */}
                <div className="flex flex-col items-center gap-3">
                  <div className="flex items-center gap-3">
                    <span className="text-lg font-medium text-gray-700">
                      {isOn ? "ON" : "OFF"}
                    </span>
                    <Switch
                      checked={isOn}
                      onChange={handleToggle}
                      disabled={isControlling}
                      size="default"
                      className="bg-gray-300"
                    />
                  </div>
                  {isControlling && (
                    <span className="text-sm text-gray-500">
                      Controlling device...
                    </span>
                  )}
                </div>
              </div>
            </Card>

            {/* Real-time Statistics */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
              {/* Power Card */}
              <Card className="shadow-sm">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-lg bg-blue-100 flex items-center justify-center">
                    <Zap className="text-blue-600" size={24} />
                  </div>
                  <div className="flex-1">
                    <p className="text-sm text-gray-500 mb-1">Power</p>
                    <p className="text-2xl font-bold text-gray-800">
                      {power} W
                    </p>
                  </div>
                </div>
              </Card>

              {/* Status Card */}
              <Card className="shadow-sm">
                <div className="flex items-center gap-4">
                  <div
                    className={`w-12 h-12 rounded-lg flex items-center justify-center ${
                      isOn ? "bg-green-100" : "bg-gray-100"
                    }`}
                  >
                    <Power
                      className={isOn ? "text-green-600" : "text-gray-600"}
                      size={24}
                    />
                  </div>
                  <div className="flex-1">
                    <p className="text-sm text-gray-500 mb-1">Status</p>
                    <p
                      className={`text-2xl font-bold ${
                        isOn ? "text-green-600" : "text-gray-600"
                      }`}
                    >
                      {isOn ? "ON" : "OFF"}
                    </p>
                  </div>
                </div>
              </Card>

              {/* Timestamp Card */}
              <Card className="shadow-sm">
                <div className="flex items-center gap-4">
                  <div className="w-12 h-12 rounded-lg bg-purple-100 flex items-center justify-center">
                    <svg
                      className="text-purple-600"
                      width="24"
                      height="24"
                      viewBox="0 0 24 24"
                      fill="none"
                      stroke="currentColor"
                      strokeWidth="2"
                    >
                      <circle cx="12" cy="12" r="10" />
                      <polyline points="12 6 12 12 16 14" />
                    </svg>
                  </div>
                  <div className="flex-1">
                    <p className="text-sm text-gray-500 mb-1">Last Update</p>
                    <p className="text-sm font-medium text-gray-800">
                      {formatTimestamp(timestamp)}
                    </p>
                  </div>
                </div>
              </Card>
            </div>

            {/* Device Information */}
            <Card className="shadow-sm">
              <h2 className="text-xl font-bold text-gray-800 mb-4">
                Device Information
              </h2>
              <div className="grid grid-cols-2 gap-4">
                <div>
                  <p className="text-sm text-gray-500 mb-1">Device Name</p>
                  <p className="text-base font-medium text-gray-800">
                    {deviceInfo.name}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500 mb-1">Room</p>
                  <p className="text-base font-medium text-gray-800">
                    {deviceInfo.room}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500 mb-1">Device ID</p>
                  <p className="text-base font-medium text-gray-800">
                    {deviceInfo.id}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-500 mb-1">Connection</p>
                  <p className="text-base font-medium text-green-600">
                    Connected
                  </p>
                </div>
              </div>
            </Card>
          </div>
        </div>
      </div>
    </div>
  );
}
