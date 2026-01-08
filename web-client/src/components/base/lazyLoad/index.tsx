import { Button, Spin } from "antd";
import React, { Suspense, useState } from "react";
class ErrorBoundary extends React.Component<
  { children: React.ReactNode },
  { hasError: boolean; error?: Error }
> {
  constructor(props: { children: React.ReactNode }) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError(error: Error) {
    return { hasError: true, error };
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="fixed inset-0 flex flex-col items-center justify-center z-50 bg-white/50">
          <div className="flex flex-col items-center max-w-[400px] text-center p-6">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="80"
              height="80"
              viewBox="0 0 24 24"
              className="text-red-500 mb-6"
            >
              <path
                fill="currentColor"
                d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-2h2v2zm0-4h-2V7h2v6z"
              />
            </svg>
            <h2 className="text-xl font-bold text-gray-800 mb-2">
              Đã xảy ra lỗi!
            </h2>
            <p className="text-gray-600 mb-6">
              Không thể tải nội dung này. Vui lòng thử làm mới trang hoặc quay
              lại sau.
            </p>
            <div className="flex gap-4">
              <Button
                type="default"
                onClick={() => window.history.back()}
                className="min-w-[120px] h-[40px] flex items-center justify-center"
              >
                Quay lại
              </Button>
              <Button
                type="primary"
                onClick={() => window.location.reload()}
                className="min-w-[120px] h-[40px] flex items-center justify-center"
              >
                Tải lại trang
              </Button>
            </div>
          </div>
        </div>
      );
    }
    return this.props.children;
  }
}

const LazyLoad = ({ children }: { children: React.ReactElement }) => {
  const [timeoutReached, setTimeoutReached] = useState(false);

  return (
    <ErrorBoundary>
      <Suspense
        fallback={
          <div className="fixed inset-0 flex flex-col items-center justify-center z-50 bg-[rgba(255,255,255,0.5)]">
            <Spin size="large" />
            <>
              {timeoutReached ? (
                <div className="flex flex-col items-center mt-4">
                  <p className="text-gray-600 mb-2">Đang tải lâu bất thường</p>
                  <p className="text-sm text-gray-500">
                    Vui lòng đợi trong giây lát...
                  </p>
                </div>
              ) : (
                <div className="text-gray-600 text-[16px] mt-4">
                  Đang tải dữ liệu...
                </div>
              )}
            </>
          </div>
        }
      >
        <TimeoutGuard onTimeout={() => setTimeoutReached(true)} />
        {children}
      </Suspense>
    </ErrorBoundary>
  );
};

const TimeoutGuard = ({ onTimeout }: { onTimeout: () => void }) => {
  React.useEffect(() => {
    const id = setTimeout(onTimeout, 15000);
    return () => clearTimeout(id);
  }, [onTimeout]);
  return null;
};

export default LazyLoad;
