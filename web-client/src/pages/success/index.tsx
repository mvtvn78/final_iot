import { Button } from "antd";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

export default function Success() {
  const navigate = useNavigate();
  const [userName, setUserName] = useState("");
  const handleGetStarted = () => {
    navigate("/spaces/no-device");
  };

  useEffect(() => {
    const userName = localStorage.getItem("userName");
    if (!userName) {
      navigate("/login");
    }
    setUserName(userName || "");
  }, []);

  return (
    <div className="min-h-screen w-screen bg-white flex flex-col items-center justify-center px-6 py-12">
      {/* Central Circle Area with Avatar and Device Icons */}
      <div className="relative w-80 h-80 mb-8">
        {/* Concentric Circles */}
        <div className="absolute inset-0 flex items-center justify-center">
          {/* Outer Circle */}
          <div className="absolute w-full h-full border-2 border-gray-200 rounded-full"></div>
          {/* Middle Circle */}
          <div className="absolute w-3/4 h-3/4 border border-gray-200 rounded-full"></div>
          {/* Inner Circle */}
          <div className="absolute w-1/2 h-1/2 border border-gray-200 rounded-full"></div>
        </div>

        {/* Connection Dots */}
        <div className="absolute inset-0 flex items-center justify-center">
          {/* Dots on circles */}
          {Array.from({ length: 12 }).map((_, i) => {
            const angle = (i * 30 - 90) * (Math.PI / 180);
            const radius = 140;
            const x = Math.cos(angle) * radius;
            const y = Math.sin(angle) * radius;
            return (
              <div
                key={i}
                className="absolute w-2 h-2 bg-gray-300 rounded-full"
                style={{
                  left: `calc(50% + ${x}px)`,
                  top: `calc(50% + ${y}px)`,
                  transform: "translate(-50%, -50%)",
                }}
              ></div>
            );
          })}
        </div>

        {/* Avatar in Center */}
        <div className="absolute inset-0 flex items-center justify-center">
          <div className="w-32 h-32 rounded-full overflow-hidden bg-gradient-to-br from-blue-400 to-purple-500 border-4 border-white shadow-lg">
            <img
              src="https://i.pravatar.cc/150?img=47"
              alt="Kristin"
              className="w-full h-full object-cover"
              onError={(e) => {
                const target = e.target as HTMLImageElement;
                target.style.display = "none";
                if (target.nextElementSibling) {
                  (target.nextElementSibling as HTMLElement).style.display =
                    "flex";
                }
              }}
            />
            <div
              className="w-full h-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold text-4xl"
              style={{ display: "none" }}
            >
              K
            </div>
          </div>
        </div>

        {/* Device Icons on Outer Circle */}
        {/* Lamp Icon - Top Left */}
        <div
          className="absolute"
          style={{
            top: "10%",
            left: "15%",
            transform: "translate(-50%, -50%)",
          }}
        >
          <div className="w-16 h-16 bg-white rounded-full shadow-lg flex items-center justify-center border-2 border-gray-100">
            <svg
              className="w-8 h-8 text-amber-600"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path d="M11 3a1 1 0 10-2 0v1a1 1 0 102 0V3zM15.657 5.757a1 1 0 00-1.414-1.414l-.707.707a1 1 0 001.414 1.414l.707-.707zM18 10a1 1 0 01-1 1h-1a1 1 0 110-2h1a1 1 0 011 1zM5.05 6.464A1 1 0 106.464 5.05l-.707-.707a1 1 0 00-1.414 1.414l.707.707zM5 10a1 1 0 01-1 1H3a1 1 0 110-2h1a1 1 0 011 1zM8 16v-1h4v1a2 2 0 11-4 0zM12 14a.5.5 0 10.5.5A.5.5 0 0012 14z" />
            </svg>
          </div>
        </div>

        {/* Smart Home Device - Top Right */}
        <div
          className="absolute"
          style={{
            top: "10%",
            right: "15%",
            transform: "translate(50%, -50%)",
          }}
        >
          <div className="w-16 h-16 bg-white rounded-lg shadow-lg flex items-center justify-center border-2 border-gray-100">
            <svg
              className="w-8 h-8 text-blue-500"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
            </svg>
          </div>
        </div>

        {/* Sensor Device - Bottom Right */}
        <div
          className="absolute"
          style={{
            bottom: "10%",
            right: "15%",
            transform: "translate(50%, 50%)",
          }}
        >
          <div className="w-14 h-14 bg-white rounded-full shadow-lg flex items-center justify-center border-2 border-gray-100">
            <svg
              className="w-7 h-7 text-gray-600"
              fill="currentColor"
              viewBox="0 0 20 20"
            >
              <path
                fillRule="evenodd"
                d="M11.3 1.046A1 1 0 0112 2v5h4a1 1 0 01.82 1.573l-7 10A1 1 0 018 18v-5H4a1 1 0 01-.82-1.573l7-10a1 1 0 011.12-.38z"
                clipRule="evenodd"
              />
            </svg>
          </div>
        </div>
      </div>

      {/* Welcome Text */}
      <div className="text-center mb-8">
        <h1 className="text-4xl font-bold text-gray-800 mb-2">
          Hello, {userName}!
        </h1>
        <p className="text-lg text-gray-500">Good morning, welcome back.</p>
      </div>

      {/* Get Started Button */}
      <Button
        onClick={handleGetStarted}
        type="primary"
        className=" text-white font-semibold rounded-2xl duration-200 w-[320px]! h-10!"
      >
        Get started
      </Button>
    </div>
  );
}
