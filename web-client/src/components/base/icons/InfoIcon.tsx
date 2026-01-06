type PropTypes = {
  className?: string;
  height?: string | number;
  width?: string | number;
};

export default function InfoIcon({
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
      <rect y="0.5" width="24" height="24" rx="12" fill="#1890FF" />
      <path
        d="M12 17V11M12 7H12.01"
        stroke="white"
        strokeWidth="2"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </svg>
  );
}
