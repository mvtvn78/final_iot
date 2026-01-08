type PropTypes = {
  className?: string;
  height?: string | number;
  width?: string | number;
};

export default function WarningIcon({
  className,
  height = 24,
  width = 24,
}: PropTypes) {
  return (
    <svg
      width={width}
      className={className}
      height={height}
      viewBox="0 0 24 25"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <rect y="0.5" width="24" height="24" rx="12" fill="#FAAD14" />
      <path
        d="M12 8V13M12 17H12.01"
        stroke="white"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
