import type { MenuProps } from "antd";
import { Button, Dropdown, Select, Switch, Tag } from "antd";
import { Edit, Home, MoreVertical, Plus } from "lucide-react";
import { useEffect, useMemo, useState } from "react";
import Menu from "../../../layout/menu";
import { getDevice } from "../../spaces/apis";

interface DeviceItem {
  id: string;
  name: string;
  room: string;
  type: "Light" | "Thermostat" | "Camera" | "Plug";
  status: "online" | "offline";
  isOn: boolean;
}

export default function DevicesPage() {
  const [devices, setDevices] = useState<DeviceItem[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [roomFilter, setRoomFilter] = useState<string | undefined>(undefined);
  const [typeFilter, setTypeFilter] = useState<string | undefined>(undefined);

  const houseName = localStorage.getItem("houseName") || "My Home";

  // Load devices from API
  useEffect(() => {
    const loadDevices = async () => {
      try {
        setIsLoading(true);
        const response = await getDevice();
        const apiDevices = response.data || response || [];

        // Load device-room mapping from localStorage
        const deviceRoomMapRaw = localStorage.getItem("deviceRoomMap");
        const deviceRoomMap = deviceRoomMapRaw
          ? (JSON.parse(deviceRoomMapRaw) as Record<string, string>)
          : {};

        // Map API devices to DeviceItem interface
        const mappedDevices: DeviceItem[] = apiDevices.map((apiDevice: any) => {
          const deviceId =
            apiDevice.id?.toString() || apiDevice._id?.toString() || "";
          const deviceRoom =
            deviceRoomMap[deviceId] || apiDevice.room || "Living Room";

          // Determine device type from name (simple heuristic)
          const nameLower = (apiDevice.name || "").toLowerCase();
          let deviceType: "Light" | "Thermostat" | "Camera" | "Plug" = "Light";
          if (nameLower.includes("camera") || nameLower.includes("cam")) {
            deviceType = "Camera";
          } else if (
            nameLower.includes("thermostat") ||
            nameLower.includes("sensor") ||
            nameLower.includes("temp")
          ) {
            deviceType = "Thermostat";
          } else if (
            nameLower.includes("plug") ||
            nameLower.includes("socket")
          ) {
            deviceType = "Plug";
          }

          return {
            id: deviceId,
            name: apiDevice.name || "Unknown Device",
            room: deviceRoom,
            type: deviceType,
            status: "online", // Assume online if device exists in API
            isOn: apiDevice.payload === 1,
          };
        });

        setDevices(mappedDevices);
      } catch (error) {
        console.error("Error loading devices:", error);
        // Fallback: try to get from localStorage
        const connectedDevicesRaw = localStorage.getItem("connectedDevices");
        const connectedDevices = connectedDevicesRaw
          ? (JSON.parse(connectedDevicesRaw) as string[])
          : [];

        const deviceRoomMapRaw = localStorage.getItem("deviceRoomMap");
        const deviceRoomMap = deviceRoomMapRaw
          ? (JSON.parse(deviceRoomMapRaw) as Record<string, string>)
          : {};

        const devicesFromStorage: DeviceItem[] = connectedDevices.map(
          (deviceId: string) => ({
            id: deviceId,
            name: `Device ${deviceId}`,
            room: deviceRoomMap[deviceId] || "Living Room",
            type: "Light",
            status: "offline",
            isOn: false,
          })
        );

        setDevices(devicesFromStorage);
      } finally {
        setIsLoading(false);
      }
    };

    loadDevices();
  }, []);

  const filteredDevices = useMemo(() => {
    return devices.filter((device) => {
      if (roomFilter && device.room !== roomFilter) return false;
      if (typeFilter && device.type !== typeFilter) return false;
      return true;
    });
  }, [devices, roomFilter, typeFilter]);

  const handleToggleDevice = (id: string, checked: boolean) => {
    setDevices((prev) =>
      prev.map((d) => (d.id === id ? { ...d, isOn: checked } : d))
    );
  };

  const getMenuItems = (deviceId: string): MenuProps["items"] => [
    {
      key: "edit",
      label: "Edit",
      icon: <Edit size={14} />,
      onClick: () => {
        // TODO: navigate to edit device
        console.log("Edit device", deviceId);
      },
    },
    {
      key: "remove",
      label: "Remove",
      danger: true,
      onClick: () => {
        setDevices((prev) => prev.filter((d) => d.id !== deviceId));
      },
    },
  ];

  const onlineCount = devices.filter((d) => d.status === "online").length;

  const rooms = Array.from(new Set(devices.map((d) => d.room)));

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="w-[298px] shrink-0">
        <Menu />
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header widgets */}
        <div className="bg-[#222833] px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-6">
              {/* Devices summary */}
              <div className="flex items-center gap-3 text-white">
                <div className="w-10 h-10 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-bong-den.png"
                    alt="Lights"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div>
                  <p className="text-xs text-white/60">Active devices</p>
                  <p className="text-lg font-semibold">
                    {onlineCount}/{devices.length}
                  </p>
                </div>
              </div>

              {/* Power usage placeholder */}
              <div className="flex items-center gap-3 text-white">
                <div className="w-10 h-10 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-may.png"
                    alt="Power usage"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div>
                  <p className="text-xs text-white/60">Estimated usage</p>
                  <p className="text-lg font-semibold">1.2 kWh</p>
                </div>
              </div>

              {/* Humidity placeholder */}
              <div className="flex items-center gap-3 text-white">
                <div className="w-10 h-10 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-giot-nuoc.png"
                    alt="Humidity"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div>
                  <p className="text-xs text-white/60">Average humidity</p>
                  <p className="text-lg font-semibold">65%</p>
                </div>
              </div>
            </div>

            {/* Home dropdown */}
            <Select
              value={houseName}
              className="w-40"
              suffixIcon={<Home size={16} />}
              options={[{ label: houseName, value: houseName }]}
            />
          </div>
        </div>

        {/* Main content area */}
        <div className="flex-1 overflow-y-auto px-8 py-6">
          {/* Header */}
          <div className="mb-6 flex items-center justify-between">
            <div>
              <h1 className="text-3xl font-bold text-gray-800 mb-1">Devices</h1>
              <p className="text-gray-500">
                Manage and monitor all devices in your home.
              </p>
            </div>

            <Button
              type="primary"
              icon={<Plus size={18} />}
              className="h-10! rounded-lg font-medium bg-blue-500 hover:bg-blue-600"
            >
              Add device
            </Button>
          </div>

          {/* Filters */}
          <div className="flex flex-wrap items-center gap-4 mb-6">
            <Select
              allowClear
              placeholder="Filter by room"
              className="w-48"
              value={roomFilter}
              onChange={(value) => setRoomFilter(value)}
              options={rooms.map((room) => ({
                value: room,
                label: room,
              }))}
            />
            <Select
              allowClear
              placeholder="Filter by type"
              className="w-48"
              value={typeFilter}
              onChange={(value) => setTypeFilter(value)}
              options={[
                { value: "Light", label: "Light" },
                { value: "Thermostat", label: "Thermostat" },
                { value: "Camera", label: "Camera" },
                { value: "Plug", label: "Smart plug" },
              ]}
            />
          </div>

          {/* Devices grid */}
          {isLoading ? (
            <div className="flex flex-col items-center justify-center py-20">
              <p className="text-base text-gray-500">Loading devices...</p>
            </div>
          ) : filteredDevices.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20">
              <p className="text-base text-gray-500 mb-2">
                No devices match your filters.
              </p>
              <p className="text-sm text-gray-400">
                Try changing filters or add a new device.
              </p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {filteredDevices.map((device) => (
                <div
                  key={device.id}
                  className="relative bg-white rounded-xl border border-gray-200 shadow-sm hover:shadow-lg transition-all duration-200 p-4 flex flex-col gap-3"
                >
                  {/* Top row: name + menu */}
                  <div className="flex items-start justify-between gap-2">
                    <div>
                      <p className="text-sm text-gray-500">{device.room}</p>
                      <h3 className="text-lg font-semibold text-gray-800">
                        {device.name}
                      </h3>
                    </div>
                    <Dropdown
                      menu={{ items: getMenuItems(device.id) }}
                      trigger={["click"]}
                      placement="bottomRight"
                    >
                      <button className="w-8 h-8 flex items-center justify-center rounded-lg bg-gray-100 hover:bg-gray-200 transition-colors">
                        <MoreVertical size={16} className="text-gray-500" />
                      </button>
                    </Dropdown>
                  </div>

                  {/* Status row */}
                  <div className="flex items-center justify-between">
                    <div className="flex items-center gap-2">
                      <Tag
                        color={device.status === "online" ? "green" : "default"}
                      >
                        {device.status === "online" ? "Online" : "Offline"}
                      </Tag>
                      <span className="text-sm text-gray-500">
                        {device.type}
                      </span>
                    </div>
                    <div className="flex items-center gap-2">
                      <span className="text-xs text-gray-500">
                        {device.isOn ? "On" : "Off"}
                      </span>
                      <Switch
                        checked={device.isOn}
                        disabled={device.status === "offline"}
                        onChange={(checked) =>
                          handleToggleDevice(device.id, checked)
                        }
                      />
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
