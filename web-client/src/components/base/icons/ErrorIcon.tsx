type PropTypes = {
  className?: string;
  height?: string | number;
  width?: string | number;
};

export default function ErrorIcon({
  className,
  height = 24,
  width = 24,
}: PropTypes) {
  return (
    <svg
      className={className}
      width={width}
      height={height}
      viewBox="0 0 24 25"
      fill="none"
      xmlns="http://www.w3.org/2000/svg"
    >
      <rect y="0.5" width="24" height="24" rx="12" fill="#FF4D4F" />
      <path
        d="M15 9.5L9 15.5M9 9.5L15 15.5"
        stroke="white"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
