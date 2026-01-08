import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";

export default function SplashPage() {
  const navigate = useNavigate();
  const [fadeOut, setFadeOut] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => {
      setFadeOut(true);
      setTimeout(() => {
      navigate("/login");
      }, 500);
    }, 2000); // 2 giây để hiển thị splash

    return () => clearTimeout(timer);
  }, [navigate]);

  return (
    <div
      className={`fixed inset-0 bg-gradient-to-br from-blue-600 via-cyan-500 to-blue-800 flex items-center justify-center transition-opacity duration-500 ${
        fadeOut ? "opacity-0" : "opacity-100"
      }`}
    >
      {/* Animated Background Elements */}
      <div className="absolute inset-0 overflow-hidden">
        {/* Circuit Pattern */}
        <svg
          className="absolute inset-0 w-full h-full opacity-20"
          viewBox="0 0 1200 800"
        >
          {/* Horizontal Lines */}
          <line
            x1="0"
            y1="200"
            x2="1200"
            y2="200"
            stroke="white"
            strokeWidth="2"
            className="animate-pulse"
          />
          <line
            x1="0"
            y1="400"
            x2="1200"
            y2="400"
            stroke="white"
            strokeWidth="2"
            className="animate-pulse"
            style={{ animationDelay: "0.5s" }}
          />
          <line
            x1="0"
            y1="600"
            x2="1200"
            y2="600"
            stroke="white"
            strokeWidth="2"
            className="animate-pulse"
            style={{ animationDelay: "1s" }}
          />
          {/* Vertical Lines */}
          <line
            x1="300"
            y1="0"
            x2="300"
            y2="800"
            stroke="white"
            strokeWidth="2"
            className="animate-pulse"
            style={{ animationDelay: "0.3s" }}
          />
          <line
            x1="600"
            y1="0"
            x2="600"
            y2="800"
            stroke="white"
            strokeWidth="2"
            className="animate-pulse"
            style={{ animationDelay: "0.7s" }}
          />
          <line
            x1="900"
            y1="0"
            x2="900"
            y2="800"
            stroke="white"
            strokeWidth="2"
            className="animate-pulse"
            style={{ animationDelay: "1.2s" }}
          />
          {/* Connection Nodes */}
          <circle
            cx="300"
            cy="200"
            r="8"
            fill="white"
            className="animate-ping"
          />
          <circle
            cx="600"
            cy="400"
            r="8"
            fill="white"
            className="animate-ping"
            style={{ animationDelay: "0.5s" }}
          />
          <circle
            cx="900"
            cy="600"
            r="8"
            fill="white"
            className="animate-ping"
            style={{ animationDelay: "1s" }}
          />
        </svg>

        {/* Floating IoT Icons */}
        <div className="absolute top-20 left-20 w-16 h-16 bg-white/20 rounded-full backdrop-blur-sm flex items-center justify-center animate-bounce">
          <svg
            className="w-8 h-8 text-white"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z"
            />
          </svg>
        </div>

        <div
          className="absolute top-40 right-32 w-12 h-12 bg-white/20 rounded-full backdrop-blur-sm flex items-center justify-center animate-bounce"
          style={{ animationDelay: "0.3s" }}
        >
          <svg
            className="w-6 h-6 text-white"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"
            />
          </svg>
        </div>

        <div
          className="absolute bottom-32 left-40 w-14 h-14 bg-white/20 rounded-full backdrop-blur-sm flex items-center justify-center animate-bounce"
          style={{ animationDelay: "0.6s" }}
        >
          <svg
            className="w-7 h-7 text-white"
            fill="none"
            stroke="currentColor"
            viewBox="0 0 24 24"
          >
            <path
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth={2}
              d="M3 12l2-2m0 0l7-7 7 7M5 10v10a1 1 0 001 1h3m10-11l2 2m-2-2v10a1 1 0 01-1 1h-3m-6 0a1 1 0 001-1v-4a1 1 0 011-1h2a1 1 0 011 1v4a1 1 0 001 1m-6 0h6"
            />
          </svg>
        </div>

        <div
          className="absolute bottom-20 right-20 w-10 h-10 bg-white/20 rounded-full backdrop-blur-sm flex items-center justify-center animate-bounce"
          style={{ animationDelay: "0.9s" }}
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
              d="M13 10V3L4 14h7v7l9-11h-7z"
            />
          </svg>
        </div>
      </div>

      {/* Main Content */}
      <div className="relative z-10 flex flex-col items-center justify-center">
        {/* Logo/Brand Area */}
        <div className="mb-8 transform transition-all duration-700 hover:scale-110">
          <div className="relative">
            {/* Main Logo Circle */}
            <div className="w-32 h-32 bg-white/30 backdrop-blur-md rounded-full flex items-center justify-center shadow-2xl border-4 border-white/50 animate-pulse">
              <svg
                className="w-16 h-16 text-white"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M9 3v2m6-2v2M9 19v2m6-2v2M5 9H3m2 6H3m18-6h-2m2 6h-2M7 19h10a2 2 0 002-2V7a2 2 0 00-2-2H7a2 2 0 00-2 2v10a2 2 0 002 2zM9 9h6v6H9V9z"
                />
              </svg>
            </div>
            {/* Rotating Ring */}
            <div className="absolute inset-0 w-32 h-32 border-4 border-transparent border-t-white/60 rounded-full animate-spin"></div>
          </div>
        </div>

        {/* App Name */}
        <h1 className="text-5xl font-bold text-white mb-4 drop-shadow-lg animate-fade-in">
          IoT Smart Home
        </h1>

        {/* Tagline */}
        <p className="text-xl text-white/90 mb-12 font-light drop-shadow-md">
          Connecting Your World, One Device at a Time
        </p>

        {/* Loading Indicator */}
        <div className="flex items-center space-x-2">
          <div className="w-3 h-3 bg-white rounded-full animate-bounce"></div>
          <div
            className="w-3 h-3 bg-white rounded-full animate-bounce"
            style={{ animationDelay: "0.2s" }}
          ></div>
          <div
            className="w-3 h-3 bg-white rounded-full animate-bounce"
            style={{ animationDelay: "0.4s" }}
          ></div>
        </div>
      </div>

      {/* Bottom Wave */}
      <div className="absolute bottom-0 left-0 right-0">
        <svg
          className="w-full h-24"
          viewBox="0 0 1200 120"
          preserveAspectRatio="none"
        >
          <path
            d="M0,60 Q300,20 600,60 T1200,60 L1200,120 L0,120 Z"
            fill="white"
            fillOpacity="0.1"
            className="animate-pulse"
          />
        </svg>
      </div>
    </div>
  );
}
