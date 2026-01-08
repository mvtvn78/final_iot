type PropTypes = {
  className?: string;
  height?: string | number;
  width?: string | number;
};

export default function SuccessIcon({
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
      <rect y="0.5" width="24" height="24" rx="12" fill="#20AE5C" />
      <path
        d="M18 7.78613L9.75 16.3576L6 12.4615"
        stroke="white"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
