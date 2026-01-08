import { Select } from "antd";
import { Edit, Home } from "lucide-react";
import { useEffect, useState } from "react";
import Menu from "../../../layout/menu";
import {
  calculateRainProbability,
  getWeatherDescription,
  weatherApiService,
  type WeatherData,
} from "../../../services/weatherApi";
import type { Room } from "../interfaces";

export default function RoomsPage() {
  const [rooms, setRooms] = useState<Room[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [viewMode, setViewMode] = useState<"list" | "map">("list");
  const houseName = localStorage.getItem("houseName") || "My Home";

  // Weather data state
  const [weatherData, setWeatherData] = useState<WeatherData>({
    temperature: 23,
    humidity: 67,
    timestamp: Date.now(),
  });
  const [isGettingLocation, setIsGettingLocation] = useState(true);

  useEffect(() => {
    fetchRooms();

    // Get current location first, then subscribe to weather updates
    const initWeather = async () => {
      setIsGettingLocation(true);
      try {
        // Service will automatically get location when started
        const unsubscribe = weatherApiService.subscribe((data) => {
          setWeatherData(data);
          setIsGettingLocation(false);
        });

        return unsubscribe;
      } catch (error) {
        console.error("Error initializing weather:", error);
        setIsGettingLocation(false);
        return () => {};
      }
    };

    let unsubscribe: (() => void) | null = null;
    initWeather().then((unsub) => {
      unsubscribe = unsub;
    });

    // Cleanup on unmount
    return () => {
      if (unsubscribe) {
        unsubscribe();
      }
    };
  }, []);

  const fetchRooms = () => {
    setIsLoading(true);
    try {
      // Load rooms from localStorage
      const storedRooms = localStorage.getItem("rooms");
      if (storedRooms) {
        const parsedRooms: Room[] = JSON.parse(storedRooms);
        // Set deviceCount to 0 if not present (for backward compatibility)
        const roomsWithDeviceCount = parsedRooms.map((room) => ({
          ...room,
          deviceCount: room.deviceCount ?? 0,
        }));
        setRooms(roomsWithDeviceCount);
      } else {
        setRooms([]);
      }
    } catch (error) {
      console.error("Error loading rooms from localStorage:", error);
      setRooms([]);
    } finally {
      setIsLoading(false);
    }
  };

  const handleEditRoom = (roomId: string) => {
    // TODO: Navigate to edit room page or open edit modal
    console.log("Edit room:", roomId);
  };

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="w-[298px] shrink-0">
        <Menu />
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Dashboard Widgets Section */}
        <div className="bg-[#222833] px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-6">
              {/* Weather Widget */}
              <div className="flex items-center gap-3 text-white">
                <div className="w-12 h-12 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-mat-troi.png"
                    alt="Weather"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div>
                  <p className="text-xs text-white/60">
                    {getWeatherDescription(
                      weatherData.temperature,
                      weatherData.humidity,
                      weatherData.rainProbability
                    )}
                  </p>
                  <p className="text-lg font-semibold">
                    {weatherData.temperature.toFixed(1)}°
                  </p>
                </div>
              </div>

              {/* Humidity Widget */}
              <div className="flex items-center gap-3 text-white">
                <div className="w-10 h-10 bg-white/10 rounded-lg flex items-center justify-center">
                  <img
                    src="/image-giot-nuoc.png"
                    alt="Humidity"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div>
                  {isGettingLocation ? (
                    <>
                      <p className="text-xs text-white/60">Humidity</p>
                      <p className="text-lg font-semibold">--%</p>
                    </>
                  ) : (
                    <>
                      <p className="text-xs text-white/60">Humidity</p>
                      <div className="flex items-center gap-2">
                        <p className="text-lg font-semibold">
                          {weatherData.humidity.toFixed(0)}%
                        </p>
                        {(() => {
                          const rainProb =
                            weatherData.rainProbability !== undefined
                              ? weatherData.rainProbability
                              : calculateRainProbability(
                                  weatherData.temperature,
                                  weatherData.humidity
                                );
                          if (rainProb > 50) {
                            return (
                              <span className="text-xs bg-yellow-500/20 text-yellow-300 px-2 py-0.5 rounded">
                                Rain: {rainProb}%
                              </span>
                            );
                          }
                          return null;
                        })()}
                      </div>
                    </>
                  )}
                </div>
              </div>

              {/* Lights Widget */}
              <div className="flex items-center gap-3 text-white">
                <div className="w-12 h-12 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-bong-den.png"
                    alt="Lights"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div>
                  <p className="text-xs text-white/60">All lights on</p>
                  <p className="text-lg font-semibold">Home</p>
                </div>
              </div>

              {/* Music Widget */}
              <div className="flex items-center gap-3 text-white">
                <div className="w-12 h-12 rounded-lg bg-gray-700 flex items-center justify-center">
                  <img
                    src="/image-zing.png"
                    alt="Music"
                    className="w-full h-full object-cover rounded-xl"
                  />
                </div>
                <div>
                  <p className="text-xs text-white/60">Play music</p>
                  <p className="text-lg font-semibold">Living room</p>
                </div>
              </div>
            </div>

            {/* My Home Dropdown */}
            <Select
              value={houseName}
              className="w-40"
              suffixIcon={<Home size={16} />}
              options={[
                { label: houseName, value: houseName },
                // Add more homes if needed
              ]}
            />
          </div>
        </div>

        {/* Main Content Area */}
        <div className="flex-1 overflow-y-auto px-8 py-6">
          {/* Header */}
          <div className="mb-6">
            <h1 className="text-3xl font-bold text-gray-800 mb-6">Rooms</h1>

            {/* Your Rooms Section */}
            <div className="flex items-center justify-between mb-4">
              <h2 className="text-xl font-semibold text-gray-800">
                Your Rooms {rooms.length}
              </h2>

              {/* View Mode Toggle */}
              <div className="flex items-center gap-2 bg-gray-100 rounded-lg p-1">
                <button
                  onClick={() => setViewMode("map")}
                  className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
                    viewMode === "map"
                      ? "bg-white text-blue-600 shadow-sm"
                      : "text-gray-600 hover:text-gray-800"
                  }`}
                >
                  Map view
                </button>
                <button
                  onClick={() => setViewMode("list")}
                  className={`px-4 py-2 rounded-md text-sm font-medium transition-colors ${
                    viewMode === "list"
                      ? "bg-white text-blue-600 shadow-sm"
                      : "text-gray-600 hover:text-gray-800"
                  }`}
                >
                  List view
                </button>
              </div>
            </div>
          </div>

          {/* Rooms Grid */}
          {isLoading ? (
            <div className="flex items-center justify-center py-20">
              <div className="text-gray-500">Loading rooms...</div>
            </div>
          ) : rooms.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-20">
              <div className="w-64 h-64 mb-4">
                <img
                  className="w-full h-full object-cover"
                  src="/Gemini_Generated_Image_3luje73luje73luj.png"
                  alt="No rooms"
                />
              </div>
              <p className="text-base text-gray-500">No rooms found</p>
            </div>
          ) : (
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
              {rooms.map((room) => (
                <div
                  key={room.id}
                  className="relative bg-white rounded-xl overflow-hidden shadow-sm hover:shadow-lg transition-all duration-200 group border border-gray-200"
                >
                  {/* Edit Button */}
                  <button
                    onClick={() => handleEditRoom(room.id!)}
                    className="absolute top-3 left-3 z-10 bg-white/90 hover:bg-white p-2 rounded-lg shadow-md transition-all opacity-0 group-hover:opacity-100"
                  >
                    <Edit className="text-gray-600" size={18} />
                  </button>

                  {/* Room Image */}
                  <div className="relative w-full h-48 overflow-hidden bg-gray-100">
                    <img
                      src={room.image || "/image-home-new.png"}
                      alt={room.name}
                      className="w-full h-full object-cover"
                      onError={(e) => {
                        (e.target as HTMLImageElement).src =
                          "/image-home-new.png";
                      }}
                    />
                  </div>

                  {/* Room Info */}
                  <div className="p-4">
                    <h3 className="text-lg font-semibold text-gray-800 mb-1">
                      {room.name}
                    </h3>
                    <p className="text-sm text-gray-600">
                      {room.deviceCount || 0} devices
                    </p>
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
