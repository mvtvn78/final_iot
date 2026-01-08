import { Button, Input, Tooltip } from "antd";
import { ArrowLeft, ImageIcon } from "lucide-react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Menu from "../../layout/menu";

export default function index() {
  const navigate = useNavigate();
  const [houseName, setHouseName] = useState("My Home");

  useEffect(() => {
    // Load house name from localStorage if exists
    const storedHouseName = localStorage.getItem("houseName");
    if (storedHouseName) {
      setHouseName(storedHouseName);
      
      // Check if rooms exist
      const storedRooms = localStorage.getItem("rooms");
      const rooms = storedRooms ? JSON.parse(storedRooms) : [];
      
      if (rooms.length > 0) {
        // If rooms exist, redirect to add-devices or rooms
        const connectedDevices = localStorage.getItem("connectedDevices");
        const devices = connectedDevices ? JSON.parse(connectedDevices) : [];
        
        if (devices.length > 0) {
          // If devices exist, redirect to rooms page
          navigate("/rooms", { replace: true });
        } else {
          // If no devices but has rooms, redirect to add-devices
          navigate("/spaces/add-devices", { replace: true });
        }
      }
    }
  }, [navigate]);

  return (
    <div className="flex">
      <div className="w-[298px]">
        <Menu />
      </div>
      <div className="flex-1 flex flex-col">
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
              <p className="text-base text-white/60">Add the first details.</p>
            </div>

            {/* Step Indicator */}
            <div className="flex flex-col items-end">
              <span className="text-sm text-white/60">Step</span>
              <span className="text-sm font-medium text-white">1/7</span>
            </div>
          </div>
        </div>

        {/* Main Content */}
        <div className="flex-1 flex items-center justify-center px-10 py-12 relative">
          <div className="w-full max-w-4xl">
            {/* House Image Card */}
            <div className="relative mb-8">
              <div className="relative w-full h-[400px] rounded-2xl overflow-hidden border-2 border-white shadow-xl">
                <img
                  src={"/image-home-new.png"}
                  alt="new home"
                  className="w-full h-full"
                />
                {/* Upload Icon */}
                <button className="absolute top-4 right-4 w-10 h-10 bg-blue-400 hover:bg-blue-500 rounded-lg flex items-center justify-center shadow-lg transition-colors">
                  <ImageIcon className="text-white" size={20} />
                </button>
              </div>

              {/* Form Section */}
              <div className="mt-8 space-y-6">
                {/* House Name Input */}
                <div className="flex flex-col items-center justify-center">
                  <label className="block text-base font-bold text-[#5C6169] mb-3 text-center">
                    What's your house name?
                  </label>
                  <Input
                    value={houseName}
                    onChange={(e) => setHouseName(e.target.value)}
                    placeholder="My Home"
                    className="w-full max-w-md h-12 text-base"
                  />
                </div>

                {/* Suggestions */}
                <div className="flex flex-col items-center justify-center">
                  <label className="block text-base font-bold text-[#5C6169] mb-3">
                    No inspiration? Try one of these names.
                  </label>
                  <div className="flex gap-3 flex-wrap">
                    <Button
                      disabled={true}
                      className={`h-10! px-6 rounded-lg transition-all ${
                        houseName === "Home"
                          ? "bg-blue-500 text-white border-blue-500"
                          : "bg-gray-200 text-gray-700 border-gray-200 hover:bg-gray-300"
                      }`}
                    >
                      Home
                    </Button>
                    <Button
                      disabled={true}
                      className={`h-10! px-6 rounded-lg transition-all ${
                        houseName === "Office"
                          ? "bg-blue-500 text-white border-blue-500"
                          : "bg-gray-200 text-gray-700 border-gray-200 hover:bg-gray-300"
                      }`}
                    >
                      Office
                    </Button>
                    <Button
                      disabled={true}
                      className={`h-10! px-6 rounded-lg transition-all ${
                        houseName === "My happy place"
                          ? "bg-blue-500 text-white border-blue-500"
                          : "bg-gray-200 text-gray-700 border-gray-200 hover:bg-gray-300"
                      }`}
                    >
                      My happy place
                    </Button>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="sticky bottom-0 bg-white border-t border-gray-200 shadow-lg">
          <div className="px-10 py-4 flex justify-between items-center">
            <span className="text-base text-gray-600 font-medium">
              Name your new space
            </span>
            <Button
              type="primary"
              className="bg-blue-500 hover:bg-blue-600 h-10! rounded-lg font-medium w-[200px]"
              onClick={() => {
                localStorage.setItem("houseName", houseName);
                navigate("/spaces/add-room");
              }}
            >
              Continue
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
