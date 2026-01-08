import { notification } from "antd";
import ErrorIcon from "../icons/ErrorIcon";
import InfoIcon from "../icons/InfoIcon";
import SuccessIcon from "../icons/SuccessIcon";
import WarningIcon from "../icons/WarningIcon";

interface NotificationProps {
  type: "success" | "warning" | "error" | "info";
  title?: string;
  message?: string;
  duration?: number;
  position?: "topLeft" | "topRight" | "bottomLeft" | "bottomRight" | "top";
  isCloseIcon?: boolean;
  key?: string;
}

const typeStyles = {
  success: {
    color: "#20AE5C",
    icon: <SuccessIcon />,
  },
  warning: {
    color: "#FAAD14",
    icon: <WarningIcon />,
  },
  error: {
    color: "#FF4D4F",
    icon: <ErrorIcon />,
  },
  info: {
    color: "#1890FF",
    icon: <InfoIcon />,
  },
};

export const openNotification = ({
  type,
  title,
  message,
  duration = 3,
  position = "topRight",
  isCloseIcon = true,
  key,
}: NotificationProps) => {
  const { color, icon } = typeStyles[type];

  // Use title for notification (message is deprecated in newer Ant Design versions)
  const notificationTitle = title || message;
  const notificationDescription = message && title ? message : undefined;

  notification.open({
    closable: isCloseIcon,
    message: notificationTitle ? (
      <div className="text-[18px] font-semibold text-[#4A4A4A]">
        {notificationTitle}
      </div>
    ) : undefined,
    description: notificationDescription ? (
      <p className="text-[16px] text-[#3D3D3D]">{notificationDescription}</p>
    ) : undefined,
    style: {
      borderLeft: `3px solid ${color}`,
      borderRadius: 8,
      backgroundColor: "#fff",
    },
    icon: icon,
    duration,
    placement: position,
    key: key ?? `${type}:${title ?? ""}:${message ?? ""}`,
  });
};
