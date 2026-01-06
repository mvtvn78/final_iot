import { useNavigate } from "react-router-dom";

interface HomeInfo {
  name?: string;
  address?: string;
  thumbnail?: string;
  rooms?: number;
  devices?: number;
  members?: number;
}

interface HeaderProps {
  title?: string;
  subtitle?: string;
  currentStep?: number;
  totalSteps?: number;
  showBackButton?: boolean;
  onBack?: () => void;
  showHomeCard?: boolean;
  homeInfo?: HomeInfo;
  onEditHomeName?: () => void;
}

export default function Header({
  title = "Create a new space",
  subtitle = "Connect your devices",
  currentStep = 4,
  totalSteps = 7,
  showBackButton = true,
  onBack,
  showHomeCard = true,
  homeInfo,
  onEditHomeName,
}: HeaderProps) {
  const defaultHomeInfo: HomeInfo = {
    name: "My Home",
    address: "11-5 Raddington Rd, London, UK",
    thumbnail:
      "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=400&h=400&fit=crop",
    rooms: 4,
    devices: 0,
    members: 0,
  };

  const home = { ...defaultHomeInfo, ...homeInfo };
  const navigate = useNavigate();

  const handleBack = () => {
    if (onBack) {
      onBack();
    } else {
      navigate(-1);
    }
  };

  return (
    <div className=" bg-blue-900 text-white w-full p-5">
      {/* Background Pattern - Wavy Lines */}

      {/* Content */}
      <div className=" flex items-center justify-between">
        {/* Left Section - Back Button */}
        <div className="flex items-center gap-4">
          {showBackButton && (
            <button
              onClick={handleBack}
              className="w-10 h-10 rounded-full bg-gray-700 hover:bg-gray-600 flex items-center justify-center transition-colors duration-200"
              aria-label="Go back"
            >
              <svg
                className="w-5 h-5 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M15 19l-7-7 7-7"
                />
              </svg>
            </button>
          )}
        </div>

        {/* Center Section - Title and Subtitle */}
        <div className="flex-1 text-center">
          <h1 className="text-2xl font-semibold text-white mb-1">{title}</h1>
          <p className="text-sm text-gray-300">{subtitle}</p>
        </div>

        {/* Right Section - Progress Indicator */}
        <div className="flex items-center gap-2">
          <span className="text-sm text-gray-300">Step</span>
          <span className="text-xl font-bold text-white">
            {currentStep} | {totalSteps}
          </span>
        </div>
      </div>

      {/* Home Card - Overlapping with header */}
      {showHomeCard && (
        <div className="relative px-6 pb-6 -mb-6">
          <div className="bg-white rounded-2xl shadow-lg p-6 flex items-center gap-6">
            {/* House Thumbnail */}
            <div className="w-32 h-32 rounded-xl overflow-hidden flex-shrink-0">
              <img
                src={home.thumbnail}
                alt={home.name}
                className="w-full h-full object-cover"
                onError={(e) => {
                  const target = e.target as HTMLImageElement;
                  target.src =
                    "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='400' height='400'%3E%3Crect fill='%23E5E7EB' width='400' height='400'/%3E%3Cpath fill='%23F3F4F6' d='M200 100 L150 150 L250 150 Z'/%3E%3Crect fill='%233B82F6' x='180' y='130' width='40' height='40'/%3E%3Crect fill='%23D1D5DB' x='220' y='150' width='30' height='40'/%3E%3C/svg%3E";
                }}
              />
            </div>

            {/* Home Info */}
            <div className="flex-1">
              <div className="flex items-center gap-2 mb-2">
                <h2 className="text-2xl font-bold text-gray-800">
                  {home.name}
                </h2>
                <button
                  onClick={onEditHomeName}
                  className="text-blue-500 hover:text-blue-600 transition-colors"
                  aria-label="Edit home name"
                >
                  <svg
                    className="w-5 h-5"
                    fill="none"
                    stroke="currentColor"
                    viewBox="0 0 24 24"
                  >
                    <path
                      strokeLinecap="round"
                      strokeLinejoin="round"
                      strokeWidth={2}
                      d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z"
                    />
                  </svg>
                </button>
              </div>
              <p className="text-sm text-gray-500">{home.address}</p>
            </div>

            {/* Statistics */}
            <div className="flex items-center gap-4 flex-shrink-0">
              {/* Rooms */}
              <div className="bg-gray-50 rounded-lg px-4 py-3 flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-green-500"></div>
                <span className="text-sm font-medium text-gray-700">
                  {home.rooms} {home.rooms === 1 ? "Room" : "Rooms"}
                </span>
              </div>

              {/* Devices */}
              <div className="bg-gray-50 rounded-lg px-4 py-3 flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-blue-400"></div>
                <span className="text-sm font-medium text-gray-700">
                  {home.devices} {home.devices === 1 ? "Device" : "Devices"}
                </span>
              </div>

              {/* Members */}
              <div className="bg-gray-50 rounded-lg px-4 py-3 flex items-center gap-2">
                <div className="w-2 h-2 rounded-full bg-blue-400"></div>
                <span className="text-sm font-medium text-gray-700">
                  {home.members} {home.members === 1 ? "Member" : "Members"}
                </span>
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
