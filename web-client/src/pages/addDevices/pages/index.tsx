import { Button, Input, Tooltip } from "antd";
import { ArrowLeft, Edit, Plus, Search } from "lucide-react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Menu from "../../../layout/menu";
import { getDevice } from "../../spaces/apis";

interface NearbyDevice {
  id: string;
  name: string;
  image: string;
  status: "not connected" | "connected";
}

export default function AddDevicesPage() {
  const navigate = useNavigate();
  const [devices, setDevices] = useState<NearbyDevice[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState("");
  const [connectedDevices, setConnectedDevices] = useState<string[]>([]);

  // Get house data from localStorage
  const houseName = localStorage.getItem("houseName") || "My Home";
  const houseAddress = "11-5 Raddington Rd, London, UK";

  // Load rooms from localStorage to get room count
  const [roomCount, setRoomCount] = useState(0);
  useEffect(() => {
    try {
      // Check if house name exists, if not redirect to new-home
      const houseName = localStorage.getItem("houseName");
      if (!houseName) {
        navigate("/spaces/new-home", { replace: true });
        return;
      }

      // Check if rooms exist, if not redirect to add-room
      const storedRooms = localStorage.getItem("rooms");
      if (!storedRooms) {
        navigate("/spaces/add-room", { replace: true });
        return;
      }

      const rooms = JSON.parse(storedRooms);
      setRoomCount(rooms.length || 0);

      // If no rooms, redirect to add-room
      if (rooms.length === 0) {
        navigate("/spaces/add-room", { replace: true });
      }
    } catch (error) {
      console.error("Error loading rooms:", error);
    }
  }, [navigate]);

  // Load devices from API
  useEffect(() => {
    const loadDevices = async () => {
      try {
        setIsLoading(true);
        const response = await getDevice();
        const apiDevices = response.data || response || [];

        // Load connected devices from localStorage
        const storedDevices = localStorage.getItem("connectedDevices");
        const connected = storedDevices ? JSON.parse(storedDevices) : [];
        setConnectedDevices(connected);

        // Map API devices to NearbyDevice interface
        const mappedDevices: NearbyDevice[] = apiDevices.map(
          (apiDevice: any) => {
            const deviceId =
              apiDevice.id?.toString() || apiDevice._id?.toString() || "";
            return {
              id: deviceId,
              name: apiDevice.name || "Unknown Device",
              image: apiDevice.image || "/image-home-new.png",
              status: connected.includes(deviceId)
                ? "connected"
                : "not connected",
            };
          }
        );

        setDevices(mappedDevices);
      } catch (error) {
        console.error("Error loading devices:", error);
        // Fallback: try to get from localStorage
        const storedDevices = localStorage.getItem("connectedDevices");
        const connected = storedDevices ? JSON.parse(storedDevices) : [];
        setConnectedDevices(connected);
        setDevices([]);
      } finally {
        setIsLoading(false);
      }
    };

    loadDevices();
  }, []);

  const deviceCount = connectedDevices.length;
  const memberCount = 0;

  const filteredDevices = devices.filter((device) =>
    device.name.toLowerCase().includes(searchQuery.toLowerCase())
  );

  const handleAddDevice = (deviceId: string) => {
    const device = devices.find((d) => d.id === deviceId);
    if (device) {
      navigate(`/spaces/link-device/${device.id}`, {
        state: {
          id: device.id,
          name: device.name,
          image: device.image,
        },
      });
    }
  };

  const handleRemoveDevice = (deviceId: string) => {
    const updated = connectedDevices.filter((id) => id !== deviceId);
    setConnectedDevices(updated);
    localStorage.setItem("connectedDevices", JSON.stringify(updated));

    // Update device status
    setDevices((prev) =>
      prev.map((d) =>
        d.id === deviceId ? { ...d, status: "not connected" } : d
      )
    );

    // Also remove from deviceRoomMap if exists
    try {
      const deviceRoomMapRaw = localStorage.getItem("deviceRoomMap");
      if (deviceRoomMapRaw) {
        const deviceRoomMap = JSON.parse(deviceRoomMapRaw);
        delete deviceRoomMap[deviceId];
        localStorage.setItem("deviceRoomMap", JSON.stringify(deviceRoomMap));
      }
    } catch (error) {
      console.error("Error removing device from room map:", error);
    }
  };

  const handleContinue = () => {
    // Navigate to Step 5: Members
    navigate("/members");
  };

  const handleSkip = () => {
    // Skip to Step 5: Members
    navigate("/members");
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="w-[298px] shrink-0">
        <Menu />
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="relative bg-[#222833] px-8 py-6">
          <div className="relative flex justify-between items-start">
            {/* Back Button */}
            <div className="flex items-center">
              <Tooltip title="Back">
                <button
                  onClick={() => navigate(-1)}
                  className="cursor-pointer bg-[#555B66] hover:bg-[#555B66]/80 w-10 h-10 flex justify-center items-center rounded-lg transition-colors"
                >
                  <ArrowLeft className="text-white" size={18} />
                </button>
              </Tooltip>
            </div>

            {/* Title Section */}
            <div className="flex flex-col items-center gap-2">
              <h2 className="text-2xl font-bold text-white">
                Create a new space
              </h2>
              <p className="text-base text-white/60">Connect your devices</p>
            </div>

            {/* Step Indicator */}
            <div className="flex flex-col items-end">
              <span className="text-sm text-white/60">Step</span>
              <span className="text-sm font-medium text-white">4/7</span>
            </div>
          </div>
        </div>

        {/* Main Content Area */}
        <div className="flex-1 overflow-y-auto px-10 py-8">
          <div className="max-w-6xl mx-auto space-y-8">
            {/* My Home Card */}
            <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6">
              <div className="flex items-start gap-6">
                {/* House Image */}
                <div className="w-32 h-32 rounded-xl overflow-hidden shrink-0">
                  <img
                    src="/image-home-new.png"
                    alt="My Home"
                    className="w-full h-full object-cover"
                    onError={(e) => {
                      (e.target as HTMLImageElement).src =
                        "/Gemini_Generated_Image_3luje73luje73luj.png";
                    }}
                  />
                </div>

                {/* House Info */}
                <div className="flex-1 min-w-0">
                  <div className="flex items-center gap-2 mb-2">
                    <h3 className="text-2xl font-bold text-gray-800">
                      {houseName}
                    </h3>
                    <button className="p-1 hover:bg-gray-100 rounded transition-colors">
                      <Edit className="text-gray-500" size={16} />
                    </button>
                  </div>
                  <p className="text-base text-gray-600 mb-4">{houseAddress}</p>

                  {/* Stats Badges */}
                  <div className="flex gap-3 flex-wrap">
                    <div className="flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-full">
                      <div className="w-2 h-2 bg-green-500 rounded-full"></div>
                      <span className="text-sm font-medium text-gray-700">
                        {roomCount} Rooms
                      </span>
                    </div>
                    <div className="flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-full">
                      <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                      <span className="text-sm font-medium text-gray-700">
                        {deviceCount} Devices
                      </span>
                    </div>
                    <div className="flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-full">
                      <div className="w-2 h-2 bg-purple-500 rounded-full"></div>
                      <span className="text-sm font-medium text-gray-700">
                        {memberCount} Members
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>

            {/* Link smart devices Section */}
            <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6">
              <div className="mb-6">
                <h3 className="text-2xl font-bold text-gray-800 mb-2">
                  Link smart devices
                </h3>
                <p className="text-base text-gray-600">
                  Current devices nearby
                </p>
              </div>

              {/* Search Bar */}
              <div className="mb-6">
                <Input
                  placeholder="Search"
                  prefix={<Search className="text-gray-400" size={18} />}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="h-12 text-base"
                  size="large"
                />
              </div>

              {/* Devices Grid */}
              {isLoading ? (
                <div className="text-center py-12">
                  <p className="text-gray-500">Loading devices...</p>
                </div>
              ) : filteredDevices.length === 0 ? (
                <div className="text-center py-12">
                  <p className="text-gray-500">No devices found</p>
                </div>
              ) : (
                <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
                  {filteredDevices.map((device) => (
                    <div
                      key={device.id}
                      className="relative bg-white border border-gray-200 rounded-xl p-6 hover:shadow-lg transition-all duration-200"
                    >
                      {/* Device Image */}
                      <div className="flex justify-center mb-4">
                        <div className="w-24 h-24 rounded-full bg-gray-100 overflow-hidden flex items-center justify-center">
                          <img
                            src={device.image}
                            alt={device.name}
                            className="w-full h-full object-cover"
                            onError={(e) => {
                              (e.target as HTMLImageElement).src =
                                "/image-home-new.png";
                            }}
                          />
                        </div>
                      </div>

                      {/* Device Name */}
                      <h4 className="text-lg font-semibold text-gray-800 mb-2 text-center">
                        {device.name}
                      </h4>

                      {/* Status */}
                      <p className="text-sm text-gray-500 mb-4 text-center">
                        {device.status === "connected" ? (
                          <span className="text-green-600">Connected</span>
                        ) : (
                          <span className="text-gray-400">not connected</span>
                        )}
                      </p>

                      {/* Add/Remove Button */}
                      <div className="flex justify-center">
                        {device.status === "connected" ? (
                          <button
                            onClick={() => handleRemoveDevice(device.id)}
                            className="w-10 h-10 rounded-full bg-red-500 hover:bg-red-600 text-white flex items-center justify-center transition-colors"
                          >
                            <span className="text-xl font-bold">×</span>
                          </button>
                        ) : (
                          <button
                            onClick={() => handleAddDevice(device.id)}
                            className="w-10 h-10 rounded-full bg-blue-500 hover:bg-blue-600 text-white flex items-center justify-center transition-colors"
                          >
                            <Plus className="text-white" size={20} />
                          </button>
                        )}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>

        {/* Bottom Action Bar */}
        <div className="sticky bottom-0 bg-white border-t border-gray-200 shadow-lg">
          <div className="px-10 py-4 flex justify-between items-center">
            <span className="text-base text-gray-600 font-medium">
              Add all your devices and go to the next step.
            </span>
            <div className="flex gap-3">
              <Button
                onClick={handleSkip}
                className="h-10! px-6 rounded-lg font-medium border-gray-300 text-gray-700 hover:bg-gray-50"
              >
                Skip
              </Button>
              <Button
                type="primary"
                onClick={handleContinue}
                className="bg-blue-500 hover:bg-blue-600 h-10! px-6 rounded-lg font-medium"
              >
                Continue
              </Button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
