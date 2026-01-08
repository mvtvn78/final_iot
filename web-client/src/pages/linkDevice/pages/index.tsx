import { Button, Tooltip } from "antd";
import { ArrowLeft } from "lucide-react";
import { useEffect } from "react";
import { useLocation, useNavigate, useParams } from "react-router-dom";
import Menu from "../../../layout/menu";
import type { Room } from "../../addRoom/interfaces";

interface LocationState {
  id: string;
  name: string;
  image: string;
}

export default function LinkDevicePage() {
  const navigate = useNavigate();
  const params = useParams<{ id: string }>();
  const location = useLocation();
  const state = location.state as LocationState | null;

  const deviceId = state?.id || params.id || "";
  const defaultName = state?.name || "New device";
  const image = state?.image || "/image-home-new.png";

  const rooms: Room[] = (() => {
    try {
      const storedRooms = localStorage.getItem("rooms");
      if (storedRooms) {
        return JSON.parse(storedRooms);
      }
    } catch (error) {
      console.error("Error loading rooms for link device:", error);
    }
    return [];
  })();

  useEffect(() => {
    // Check if house name exists
    const houseName = localStorage.getItem("houseName");
    if (!houseName) {
      navigate("/spaces/new-home", { replace: true });
      return;
    }
    
    // Check if rooms exist, if not redirect to add-room
    if (rooms.length === 0) {
      navigate("/spaces/add-room", { replace: true });
      return;
    }
    
    // Check if deviceId exists
    if (!deviceId) {
      navigate("/spaces/add-devices", { replace: true });
      return;
    }
  }, [navigate, deviceId, rooms.length]);

  const handleContinue = (roomName: string) => {
    // Mark device as connected and associate with room (stored simply by id)
    try {
      const connected = JSON.parse(
        localStorage.getItem("connectedDevices") || "[]",
      ) as string[];
      if (!connected.includes(deviceId)) {
        connected.push(deviceId);
        localStorage.setItem("connectedDevices", JSON.stringify(connected));
      }

      const mapRaw = localStorage.getItem("deviceRoomMap");
      const map = mapRaw ? (JSON.parse(mapRaw) as Record<string, string>) : {};
      map[deviceId] = roomName;
      localStorage.setItem("deviceRoomMap", JSON.stringify(map));
    } catch (error) {
      console.error("Error saving device-room mapping:", error);
    }

    // Go back to add devices step
    navigate("/spaces/add-devices");
  };

  const handleSkip = () => {
    navigate("/spaces/add-devices");
  };

  const roomNames =
    rooms.length > 0
      ? rooms.map((r) => r.name)
      : ["Living room", "Kitchen", "Bedroom", "Bathroom"];

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
              <h2 className="text-2xl font-bold text-white">Link new device</h2>
              <p className="text-base text-white/60">Connect with your space</p>
            </div>

            {/* Step Indicator */}
            <div className="flex flex-col items-end">
              <span className="text-sm text-white/60">Step</span>
              <span className="text-sm font-medium text-white">4/7</span>
            </div>
          </div>
        </div>

        {/* Main Content Area */}
        <div className="flex-1 overflow-y-auto px-10 py-10 flex flex-col items-center">
          {/* Device Image */}
          <div className="relative mb-10">
            <div className="w-72 h-72 rounded-full bg-white shadow-xl flex items-center justify-center">
              <div className="w-56 h-56 rounded-full bg-gray-50 overflow-hidden flex items-center justify-center">
                <img
                  src={image}
                  alt={defaultName}
                  className="w-full h-full object-cover"
                  onError={(e) => {
                    (e.target as HTMLImageElement).src = "/image-home-new.png";
                  }}
                />
              </div>
            </div>
          </div>

          {/* Device Name (read-only for now) */}
          <div className="mb-8 text-center">
            <p className="text-sm text-gray-500 mb-3">
              What is your device name?
            </p>
            <div className="w-[320px] mx-auto">
              <input
                value={defaultName}
                readOnly
                className="w-full h-11 rounded-lg border border-gray-300 px-3 text-center text-sm text-gray-800 bg-gray-50"
              />
            </div>
          </div>

          {/* Room selection */}
          <div className="mb-8 text-center">
            <p className="text-sm text-gray-500 mb-3">
              Where is your device located?
            </p>
            <div className="flex flex-wrap justify-center gap-3">
              {roomNames.map((room) => (
                <button
                  key={room}
                  onClick={() => handleContinue(room)}
                  className="min-w-[110px] px-4 py-2 rounded-full text-sm font-medium bg-gray-100 text-gray-700 hover:bg-blue-500 hover:text-white transition-colors"
                >
                  {room}
                </button>
              ))}
            </div>
          </div>
        </div>

        {/* Bottom Action Bar */}
        <div className="sticky bottom-0 bg-white border-t border-gray-200 shadow-lg">
          <div className="px-10 py-4 flex justify-between items-center">
            <span className="text-base text-gray-600 font-medium">
              Customize and link your new device
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
                onClick={handleSkip}
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


