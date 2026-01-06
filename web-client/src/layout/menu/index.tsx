import { Button, Modal } from "antd";
import { useState } from "react";
import { NavLink, useLocation, useNavigate } from "react-router-dom";

export default function Menu() {
  const navigate = useNavigate();
  const location = useLocation();
  const userName = localStorage.getItem("userName");
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const menuItems = [
    {
      id: "spaces",
      label: "Spaces",
      icon: (
        <svg className="w-5 h-5" fill="currentColor" viewBox="0 0 20 20">
          <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
          {/* Minus sign inside house */}
          <path d="M8 10h4a1 1 0 110 2H8a1 1 0 110-2z" />
        </svg>
      ),
      path: "/spaces",
    },
    {
      id: "rooms",
      label: "Rooms",
      icon: (
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
            d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7"
          />
        </svg>
      ),
      path: "/rooms",
    },
    {
      id: "devices",
      label: "Devices",
      icon: (
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
            d="M12 18h.01M8 21h8a2 2 0 002-2V5a2 2 0 00-2-2H8a2 2 0 00-2 2v14a2 2 0 002 2z"
          />
        </svg>
      ),
      path: "/devices",
    },
    {
      id: "members",
      label: "Members",
      icon: (
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
            d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"
          />
        </svg>
      ),
      path: "/members",
    },
    {
      id: "statistics",
      label: "Statistics",
      icon: (
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
            d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z"
          />
        </svg>
      ),
      path: "/statistics",
    },
    {
      id: "profile",
      label: "Profile & Settings",
      icon: (
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
            d="M5.121 17.804A13.937 13.937 0 0112 15c2.5 0 4.847.655 6.879 1.804M15 10a3 3 0 11-6 0 3 3 0 016 0z"
          />
        </svg>
      ),
      path: "/profile",
    },
  ];

  const handleLogoutConfirm = () => {
    setIsLoading(true);
    try {
      localStorage.removeItem("token");
      localStorage.removeItem("userName");
      setTimeout(() => {
        navigate("/login");
      }, 500);
    } catch (error) {
      console.error(error);
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <>
      {/* Modal đăng xuất */}
      <Modal
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        footer={null}
        centered
        width={400}
        className="logout-modal"
      >
        <div className="flex flex-col items-center text-center">
          {/* Icon */}
          <div className="w-16 h-16 rounded-full bg-red-50 flex items-center justify-center mb-4">
            <svg
              className="w-8 h-8 text-red-500"
              fill="none"
              stroke="currentColor"
              viewBox="0 0 24 24"
            >
              <path
                strokeLinecap="round"
                strokeLinejoin="round"
                strokeWidth={2}
                d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"
              />
            </svg>
          </div>

          {/* Title */}
          <h3 className="text-xl font-semibold text-gray-800 mb-2">
            Đăng xuất
          </h3>

          {/* Message */}
          <p className="text-gray-600 mb-6 leading-relaxed text-[16px] text-center">
            Bạn có chắc chắn muốn đăng xuất khỏi tài khoản của mình không?
          </p>

          {/* Buttons */}
          <div className="flex gap-3 w-full">
            <Button
              onClick={() => setIsModalOpen(false)}
              className="flex-1 h-10! border-gray-300 text-gray-700 hover:bg-gray-50"
              disabled={isLoading}
            >
              Hủy
            </Button>
            <Button
              type="primary"
              danger
              loading={isLoading}
              onClick={handleLogoutConfirm}
              className="flex-1 h-10! bg-red-500 hover:bg-red-600 border-red-500 hover:border-red-600"
            >
              Đăng xuất
            </Button>
          </div>
        </div>
      </Modal>
      <div className="h-screen bg-white border-r border-gray-200 flex flex-col">
        {/* Logo Section */}
        <div className="px-6 py-6 border-b border-gray-200">
          <div className="flex items-center gap-2">
            {/* House Icon with Wi-Fi Signals */}
            <div className="relative">
              <svg
                className="w-8 h-8 text-blue-500"
                fill="currentColor"
                viewBox="0 0 20 20"
              >
                <path d="M10.707 2.293a1 1 0 00-1.414 0l-7 7a1 1 0 001.414 1.414L4 10.414V17a1 1 0 001 1h2a1 1 0 001-1v-2a1 1 0 011-1h2a1 1 0 011 1v2a1 1 0 001 1h2a1 1 0 001-1v-6.586l.293.293a1 1 0 001.414-1.414l-7-7z" />
              </svg>
              {/* Wi-Fi Signals */}
              <div className="absolute -top-1 -right-1">
                <svg
                  className="w-4 h-4 text-blue-500"
                  fill="currentColor"
                  viewBox="0 0 20 20"
                >
                  <path
                    fillRule="evenodd"
                    d="M17.778 8.222c-4.296-4.296-11.26-4.296-15.556 0A1 1 0 01.808 6.808c5.076-5.076 13.308-5.076 18.384 0a1 1 0 01-1.414 1.414zM14.95 11.05a7 7 0 00-9.9 0 1 1 0 01-1.414-1.414 9 9 0 0112.728 0 1 1 0 01-1.414 1.414zM12.12 13.88a3 3 0 00-4.242 0 1 1 0 01-1.415-1.415 5 5 0 017.072 0 1 1 0 01-1.415 1.415zM10 16a1 1 0 011-1h.01a1 1 0 110 2H11a1 1 0 01-1-1z"
                    clipRule="evenodd"
                  />
                </svg>
              </div>
            </div>
            <span className="text-xl font-semibold text-gray-800">
              smarthouse
            </span>
          </div>
        </div>

        {/* User Profile Section */}
        <div className="px-6 py-4 border-b border-gray-200">
          <div className="flex items-center gap-3">
            {/* Avatar */}
            <div className="w-12 h-12 rounded-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold text-lg overflow-hidden">
              <img
                src="https://i.pravatar.cc/150?img=47"
                alt="User avatar"
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
                className="w-full h-full bg-gradient-to-br from-blue-400 to-purple-500 flex items-center justify-center text-white font-semibold text-lg"
                style={{ display: "none" }}
              >
                K
              </div>
            </div>
            <div>
              <p className="text-sm text-gray-500">Welcome home,</p>
              <p className="text-base font-semibold text-gray-800">
                {userName}
              </p>
            </div>
          </div>
        </div>

        {/* Navigation Menu */}
        <nav className="flex-1 px-4 py-4">
          <ul className="space-y-1">
            {menuItems.map((item) => {
              const isActive =
                location.pathname === item.path ||
                location.pathname.startsWith(item.path + "/");
              return (
                <li key={item.id}>
                  <NavLink
                    to={item.path}
                    className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-colors duration-200 ${
                      isActive
                        ? "bg-blue-50 text-blue-600"
                        : "text-gray-500 hover:bg-gray-50"
                    }`}
                  >
                    <span
                      className={isActive ? "text-blue-600" : "text-gray-400"}
                    >
                      {item.icon}
                    </span>
                    <span className="font-medium">{item.label}</span>
                  </NavLink>
                </li>
              );
            })}
          </ul>
        </nav>

        <div className="px-4 py-4 border-t border-gray-200">
          <Button
            onClick={() => {
              setIsModalOpen(true);
              console.log("click");
            }}
            type="primary"
            htmlType="button"
            danger
            className="w-full cursor-pointer flex items-center rounded-lg "
          >
            Log out
          </Button>
        </div>
      </div>
    </>
  );
}
