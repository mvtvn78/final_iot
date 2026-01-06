import { Button, Form, Input } from "antd";
import { useState } from "react";
import { useNavigate } from "react-router-dom";
import { openNotification } from "../../../components/base/notification";
import { resetPassword } from "../apis";
import type { ResetPasswordRequest } from "../interfaces";

export default function ResetPasswordPage() {
  const [isLoading, setIsLoading] = useState(false);
  const [form] = Form.useForm();
  const navigate = useNavigate();
  const handleSubmit = async (values: ResetPasswordRequest) => {
    setIsLoading(true);
    const email = localStorage.getItem("email") || "";
    const otp = localStorage.getItem("otp") || "";
    const dataValues = {
      email,
      otp,
      newPwd: values.newPwd,
      confirmPwd: values.confirmPwd,
    };
    try {
      const response = await resetPassword(dataValues);
      if (response.statusCode === 200) {
        openNotification({
          type: "success",
          title: "Success",
          message: "Reset Password Successfully",
        });
        setTimeout(() => {
          navigate("/login");
        }, 500);
      }
    } catch (error) {
      openNotification({
        type: "error",
        title: "Failed",
        message: "Reset Password Failed",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex h-screen w-screen">
      {/* Left Section - Illustration & Marketing */}
      <div className="hidden lg:flex flex-col items-center">
        <div className="rounded-lg">
          <img src="/image-home1.png" alt="image-login" className="w-[858px]" />
        </div>

        <div className="flex flex-col items-center gap-4">
          {/* Title */}
          <h1 className="text-[24px] font-bold text-gray-800 text-center">
            Easy living with your smart home
            <span className="ml-2 text-yellow-500">💡</span>
          </h1>

          {/* Description */}
          <p className="text-gray-500 text-center text-lg max-w-md">
            Get you smart devices in one place and manage all of these with a
            few taps.
          </p>

          {/* Pagination Dots - 5 dots, 2nd one highlighted */}
          <div className="flex gap-2">
            <div className="w-2 h-2 rounded-full bg-gray-300"></div>
            <div className="w-2 h-2 rounded-full bg-gray-300"></div>
            <div className="w-2 h-2 rounded-full bg-blue-500"></div>
            <div className="w-2 h-2 rounded-full bg-gray-300"></div>
            <div className="w-2 h-2 rounded-full bg-gray-300"></div>
          </div>
        </div>
      </div>

      {/* Right Section - Reset Password Form */}
      <div className="flex-1 flex items-center justify-center px-6 sm:px-12 bg-white">
        <div className="w-full max-w-md">
          {/* Title */}
          <h2 className="text-3xl font-bold text-gray-800 mb-8 text-center">
            Reset password
          </h2>

          <Form onFinish={handleSubmit} layout="vertical" requiredMark={false}>
            <Form.Item<ResetPasswordRequest>
              name="newPwd"
              required={false}
              validateTrigger={["onBlur", "onChange"]}
              label={
                <p className="lg:text-[16px] text-[14px] text-[#464646] font-medium">
                  New Password<span className="text-[#D32F2F] ml-1">*</span>
                </p>
              }
              rules={[
                {
                  required: true,
                  validator: (_, value) => {
                    return new Promise((resolve, reject) => {
                      if (!value) {
                        return reject(new Error("Please enter your password"));
                      } else {
                        if (value.length < 8) {
                          return reject(
                            new Error("Password must be at least 8")
                          );
                        } else {
                          return resolve("");
                        }
                      }
                    });
                  },
                },
              ]}
            >
              <Input.Password
                className="w-full h-10!"
                placeholder="New Password"
              />
            </Form.Item>
            <Form.Item<ResetPasswordRequest>
              name="confirmPwd"
              required={false}
              validateTrigger={["onBlur", "onChange"]}
              label={
                <p className="lg:text-[16px] text-[14px] text-[#464646] font-medium">
                  Confirm Password<span className="text-[#D32F2F] ml-1">*</span>
                </p>
              }
              rules={[
                {
                  required: true,
                  message: "Please input your confirm password",
                },
                ({ getFieldValue }) => ({
                  validator(_, value) {
                    if (!value || getFieldValue("newPwd") === value) {
                      return Promise.resolve();
                    }
                    return Promise.reject(
                      new Error("The two passwords do not match!")
                    );
                  },
                }),
              ]}
            >
              <Input.Password
                className="w-full h-10!"
                placeholder="Confirm Password"
              />
            </Form.Item>
            <Form.Item>
              <Button
                loading={isLoading}
                type="primary"
                htmlType="submit"
                className="w-full h-10!"
              >
                Reset Password
              </Button>
            </Form.Item>
          </Form>
        </div>
      </div>
    </div>
  );
}
