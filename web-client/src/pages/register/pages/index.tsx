import { Button, Checkbox, Form, Input } from "antd";
import { useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { openNotification } from "../../../components/base/notification";
import { register } from "../api";
import type { RegisterRequest } from "../interfaces";

export default function RegisterPage() {
  const navigate = useNavigate();
  const [isLoading, setIsLoading] = useState(false);
  const [isAcceptedTerms, setIsAcceptedTerms] = useState(false);
  const handleAcceptTerms = () => {
    setIsAcceptedTerms(!isAcceptedTerms);
  };
  const handleSubmit = async (values: RegisterRequest) => {
    setIsLoading(true);
    try {
      const response = await register(values);

      if (response.statusCode === 200) {
        openNotification({
          type: "success",
          title: "Success",
          message: "Register Successfully",
        });

        setTimeout(() => {
          navigate("/login");
        }, 500);
      }
    } catch (error) {
      openNotification({
        type: "error",
        title: "Failed",
        message: "Register Failed ? Please try again",
      });
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="flex h-screen w-screen">
      {/* Left Section - Illustration & Marketing */}
      <div className="hidden lg:flex flex-col items-center">
        {/* House Illustration */}
        <div className="rounded-lg">
          <img src="/image-home1.png" alt="image-login" className="w-[858px]" />
        </div>

        {/* Title */}
        <h1 className="text-[24px] font-bold text-gray-800 mb-2 text-center">
          Easy living with your smart home
          <span className="ml-2 text-yellow-500">💡</span>
        </h1>

        {/* Description */}
        <p className="text-gray-500 text-center text-lg max-w-md mt-4">
          Get you smart devices in one place and manage all of these with a few
          taps.
        </p>

        {/* Pagination Dots - First dot highlighted for register */}
        <div className="flex gap-2 mt-12">
          <div className="w-2 h-2 rounded-full bg-blue-500"></div>
          <div className="w-2 h-2 rounded-full bg-gray-300"></div>
          <div className="w-2 h-2 rounded-full bg-gray-300"></div>
          <div className="w-2 h-2 rounded-full bg-gray-300"></div>
        </div>
      </div>

      {/* Right Section - Register Form */}
      <div className="w-full lg:w-1/2 flex items-center justify-center px-6 sm:px-12 bg-white">
        <div className="w-full max-w-md">
          {/* Title */}
          <h2 className="text-3xl font-bold text-gray-800 mb-2">Sign up</h2>
          <p className="text-gray-600 mb-8">
            Create your account to get started.
          </p>

          <Form
            layout="vertical"
            onFinish={handleSubmit}
            initialValues={{ remember: true }}
            requiredMark={false}
          >
            <Form.Item<RegisterRequest>
              name="userName"
              required={false}
              validateTrigger={["onBlur", "onChange"]}
              label={
                <p className="lg:text-[16px] text-[14px] text-[#464646] font-medium">
                  User Name<span className="text-[#D32F2F] ml-1">*</span>
                </p>
              }
              rules={[
                {
                  required: true,
                  message: "Please input your user name",
                },
                {
                  min: 6,
                  message: "User name must be at least 6 characters",
                },
              ]}
            >
              <Input
                placeholder="User Name"
                allowClear
                className="w-full h-10!"
              />
            </Form.Item>
            <Form.Item<RegisterRequest>
              required={false}
              name="fullName"
              validateTrigger={["onBlur", "onChange"]}
              label={
                <p className="lg:text-[16px] text-[14px] text-[#464646] font-medium">
                  Full Name<span className="text-[#D32F2F] ml-1">*</span>
                </p>
              }
              rules={[
                {
                  required: true,
                  message: "Please input your full name",
                },
              ]}
            >
              <Input
                placeholder="Full Name"
                allowClear
                className="w-full h-10!"
              />
            </Form.Item>
            <Form.Item<RegisterRequest>
              required={false}
              name="email"
              validateTrigger={["onBlur", "onChange"]}
              label={
                <p className="lg:text-[16px] text-[14px] text-[#464646] font-medium">
                  Email<span className="text-[#D32F2F] ml-1">*</span>
                </p>
              }
              rules={[
                {
                  required: true,
                  message: "Please input your email",
                },
              ]}
            >
              <Input placeholder="Email" allowClear className="w-full h-10!" />
            </Form.Item>
            <Form.Item<RegisterRequest>
              required={false}
              name="password"
              validateTrigger={["onBlur", "onChange"]}
              label={
                <p className="lg:text-[16px] text-[14px] text-[#464646] font-medium">
                  Password<span className="text-[#D32F2F] ml-1">*</span>
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
                            new Error("Password must be at least 8 characters")
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
                placeholder="Password"
                allowClear
                className="w-full h-10!"
              />
            </Form.Item>
            <Form.Item<RegisterRequest>
              required={false}
              name="confirmPassword"
              dependencies={["password"]}
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
                    if (!value || getFieldValue("password") === value) {
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
                placeholder="Confirm Password"
                allowClear
                className="w-full h-10!"
              />
            </Form.Item>

            <div className="my-4">
              <Checkbox checked={isAcceptedTerms} onChange={handleAcceptTerms}>
                Accept Terms
              </Checkbox>
            </div>

            <Form.Item>
              <Button
                loading={isLoading}
                disabled={!isAcceptedTerms}
                type="primary"
                htmlType="submit"
                className="w-full h-10!"
              >
                Register
              </Button>
            </Form.Item>
          </Form>

          <div className="flex justify-center mt-4">
            <p className="text-gray-600">
              Already have an account?{" "}
              <Link
                className="text-blue-500 hover:text-blue-600 font-medium"
                to="/login"
              >
                Login
              </Link>
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
