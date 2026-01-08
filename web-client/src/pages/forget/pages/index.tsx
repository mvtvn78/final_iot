import { Button, Form, Input } from "antd";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { openNotification } from "../../../components/base/notification";
import { isValidEmail } from "../../../utils/checkData";
import { forgetPassword } from "../apis";

export default function ForgetPage() {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const onFinish = async (values: any) => {
    setIsLoading(true);
    try {
      const response = await forgetPassword(values);
      if (response.statusCode === 200) {
        localStorage.setItem("email", values.email);
        openNotification({
          type: "success",
          title: "Success",
          message: "Send OTP Successfully",
        });

        setTimeout(() => {
          navigate("/verify-code");
        }, 500);
      }
    } catch (error) {
      openNotification({
        type: "error",
        title: "Failed",
        message: "Send OTP Failed",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex h-screen bg-[#FAFAFA]">
      {/* Left Section - Illustration & Marketing */}
      <div className="flex flex-col items-center bg-[#FFFFFF] shadow-[2px_4px_20px_0px_rgba(0,0,0,0.12)]">
        {/* House Illustration */}
        <div className="rounded-lg">
          <img src="/image-home1.png" alt="image-login" className="w-[858px]" />
        </div>

        {/* Title */}
        <div className="flex flex-col items-center justify-center gap-4 mt-4">
          <h1 className="text-[24px] font-bold text-gray-800 mb-2 text-center">
            Easy living with your smart home
            <span className="ml-2 text-yellow-500">💡</span>
          </h1>

          {/* Description */}
          <p className="text-gray-500 text-center text-lg max-w-md">
            Get you smart devices in one place and manage all of these with a
            few taps.
          </p>

          {/* Pagination Dots */}
          <div className="flex gap-2">
            <div className="w-2 h-2 rounded-full bg-gray-300"></div>
            <div className="w-2 h-2 rounded-full bg-blue-500"></div>
            <div className="w-2 h-2 rounded-full bg-gray-300"></div>
            <div className="w-2 h-2 rounded-full bg-gray-300"></div>
          </div>
        </div>
      </div>

      {/* Right Section - Login Form */}
      <div className="flex-1 flex items-center justify-center px-6 sm:px-12 bg-white">
        <div className="w-full max-w-md">
          {/* Title */}
          <h2 className="text-3xl font-bold text-gray-800 mb-2">
            Forget Password
          </h2>
          <p className="text-gray-600 mb-8">
            Please enter your email to reset your password.
          </p>

          <Form layout="vertical" onFinish={onFinish} requiredMark="optional">
            <Form.Item
              name="email"
              label={
                <p className="lg:text-[16px] text-[14px] text-[#464646] font-medium">
                  Email<span className="text-[#D32F2F] ml-1">*</span>
                </p>
              }
              validateTrigger={["onBlur", "onChange"]}
              rules={[
                {
                  required: true,
                  validator: (_, value) =>
                    new Promise((resolve, reject) => {
                      if (!value) {
                        reject(new Error("Please enter your email"));
                      } else {
                        const DoudleDoRegex = /\.{2,}/;
                        if (!isValidEmail(value) || DoudleDoRegex.test(value)) {
                          reject(
                            new Error("Invalid email. Please check again")
                          );
                        } else {
                          resolve("");
                        }
                      }
                    }),
                },
              ]}
            >
              <Input
                placeholder="Email"
                autoFocus
                allowClear
                className="w-full h-10!"
              />
            </Form.Item>

            <Form.Item>
              <Button
                type="primary"
                htmlType="submit"
                loading={isLoading}
                className="w-full h-10!"
              >
                Send
              </Button>
            </Form.Item>
          </Form>
        </div>
      </div>
    </div>
  );
}
