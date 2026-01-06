import { useEffect, useRef, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
export default function VerifyCodePage() {
  const [code, setCode] = useState(["", "", "", "", "", ""]);
  const [email] = useState(localStorage.getItem("email") || "");
  const inputRefs = useRef<(HTMLInputElement | null)[]>([]);
  const navigate = useNavigate();
  useEffect(() => {
    // Auto focus first input
    inputRefs.current[0]?.focus();
  }, []);

  const handleChange = (index: number, value: string) => {
    // Only allow digits
    if (value && !/^\d$/.test(value)) return;

    const newCode = [...code];
    newCode[index] = value;
    setCode(newCode);

    // Auto move to next input
    if (value && index < 5) {
      inputRefs.current[index + 1]?.focus();
    }
  };

  const handleKeyDown = (
    index: number,
    e: React.KeyboardEvent<HTMLInputElement>
  ) => {
    // Handle backspace
    if (e.key === "Backspace" && !code[index] && index > 0) {
      inputRefs.current[index - 1]?.focus();
    }
    // Handle paste
    if (e.key === "v" && (e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      navigator.clipboard.readText().then((text) => {
        const digits = text.replace(/\D/g, "").slice(0, 6).split("");
        const newCode = [...code];
        digits.forEach((digit, i) => {
          if (i < 6) {
            newCode[i] = digit;
          }
        });
        setCode(newCode);
        const nextIndex = Math.min(digits.length, 5);
        inputRefs.current[nextIndex]?.focus();
      });
    }
  };

  const handleSubmit = async () => {
    const codeValue = code.join("");
    localStorage.setItem("otp", codeValue);
    navigate("/reset");
  };

  // const handleResend = () => {
  //   // Handle resend code logic
  //   console.log("Resending code to", email);
  // };

  return (
    <div className="flex h-screen w-screen ">
      {/* Left Section - Illustration & Marketing */}
      <div className="hidden lg:flex flex-col items-center">
        {/* House Illustration with Shield */}
        <div className="rounded-lg">
          <img src="/image-home2.png" alt="image-login" className="w-[858px]" />
        </div>

        {/* Title */}
        <h1 className="text-4xl font-bold text-gray-800 mb-2 text-center">
          Easy living with your smart home
          <span className="ml-2 text-yellow-500">💡</span>
        </h1>

        {/* Description */}
        <p className="text-gray-500 text-center text-lg max-w-md mt-4">
          Get you smart devices in one place and manage all of these with a few
          taps.
        </p>

        {/* Pagination Dots - 4 dots, 2nd one highlighted */}
        <div className="flex gap-2 mt-12">
          <div className="w-2 h-2 rounded-full bg-gray-300"></div>
          <div className="w-2 h-2 rounded-full bg-gray-300"></div>
          <div className="w-2 h-2 rounded-full bg-gray-300"></div>
          <div className="w-2 h-2 rounded-full  bg-blue-500"></div>
          <div className="w-2 h-2 rounded-full bg-gray-300"></div>
        </div>
      </div>

      {/* Right Section - Verify Code Form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center px-6 sm:px-12 bg-white">
        <div className="w-full max-w-md">
          {/* Title */}
          <h2 className="text-3xl font-bold text-gray-800 mb-2 text-center">
            Verify Code
          </h2>

          {/* Instructions */}
          <p className="text-gray-600 mb-8 text-center">
            We just sent a 6-digit verification code to{" "}
            <span className="text-gray-800 font-medium">{email}</span>. Enter
            the code in the box below to continue.
          </p>

          {/* Code Input Fields */}
          <form onSubmit={handleSubmit}>
            <div className="flex justify-center gap-3 mb-6">
              {code.map((digit, index) => (
                <input
                  key={index}
                  ref={(el) => {
                    inputRefs.current[index] = el;
                  }}
                  type="text"
                  inputMode="numeric"
                  maxLength={1}
                  value={digit}
                  onChange={(e) => handleChange(index, e.target.value)}
                  onKeyDown={(e) => handleKeyDown(index, e)}
                  className={`w-16 h-16 text-center text-2xl font-semibold border-2 rounded-lg focus:outline-none transition-colors duration-200 ${
                    digit
                      ? "border-blue-500 text-gray-800"
                      : index === code.findIndex((d) => d === "") ||
                        (code.every((d) => d !== "") && index === 5)
                      ? "border-blue-500 text-gray-800"
                      : "border-gray-300 text-gray-400"
                  }`}
                  autoFocus={index === 0}
                />
              ))}
            </div>

            {/* Resend Code Link */}
            <div className="text-center mb-6">
              <span className="text-gray-500 text-sm">
                Didn't receive a code?{" "}
              </span>
              <Link
                to="/forgotPassword"
                className="text-blue-500 hover:text-blue-600 text-sm font-medium"
              >
                Resend Code
              </Link>
            </div>

            {/* Next Button */}
            <button
              type="submit"
              disabled={!code.every((digit) => digit !== "")}
              className="w-full bg-blue-500 hover:bg-blue-600 disabled:bg-blue-300 disabled:cursor-not-allowed text-white font-semibold py-3 rounded-lg transition-colors duration-200"
            >
              Next
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
