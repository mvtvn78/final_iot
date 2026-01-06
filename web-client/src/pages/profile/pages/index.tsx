import { Avatar, Button, Form, Input, Tabs } from "antd";
import { Camera } from "lucide-react";
import { useEffect } from "react";
import Menu from "../../../layout/menu";

interface ProfileFormValues {
  fullName: string;
  phone: string;
  email: string;
}

const PROFILE_STORAGE_KEY = "userProfile";

export default function ProfilePage() {
  const [form] = Form.useForm<ProfileFormValues>();

  useEffect(() => {
    try {
      const stored = localStorage.getItem(PROFILE_STORAGE_KEY);
      if (stored) {
        const parsed: ProfileFormValues = JSON.parse(stored);
        form.setFieldsValue(parsed);
      } else {
        const userName = localStorage.getItem("userName") || "Kristin Jones";
        form.setFieldsValue({
          fullName: userName,
          phone: "+49 30 901820",
          email: "kristin@gmail.com",
        });
      }
    } catch (error) {
      console.error("Error loading profile from storage:", error);
    }
  }, [form]);

  const handleSave = (values: ProfileFormValues) => {
    localStorage.setItem(PROFILE_STORAGE_KEY, JSON.stringify(values));
  };

  const items = [
    {
      key: "account",
      label: "Account information",
      children: (
        <Form
          form={form}
          layout="vertical"
          onFinish={handleSave}
          className="max-w-xl mx-auto mt-8"
        >
          <Form.Item<ProfileFormValues>
            name="fullName"
            label="Full Name"
            rules={[{ required: true, message: "Please enter your full name" }]}
          >
            <Input placeholder="Full name" className="h-11" />
          </Form.Item>

          <Form.Item<ProfileFormValues> name="phone" label="Phone">
            <Input placeholder="+49 30 901820" className="h-11" />
          </Form.Item>

          <Form.Item<ProfileFormValues>
            name="email"
            label="Email"
            rules={[
              { required: true, message: "Please enter your email" },
              { type: "email", message: "Invalid email address" },
            ]}
          >
            <Input placeholder="kristin@gmail.com" className="h-11" />
          </Form.Item>

          <div className="mt-10 flex justify-end">
            <Button
              type="primary"
              htmlType="submit"
              className="px-10 h-10! rounded-full bg-blue-500 hover:bg-blue-600"
            >
              Save updates
            </Button>
          </div>
        </Form>
      ),
    },
    {
      key: "password",
      label: "Change Password",
      children: (
        <div className="text-center text-gray-400 mt-10">
          Change password settings will be implemented later.
        </div>
      ),
    },
    {
      key: "notifications",
      label: "Notifications",
      children: (
        <div className="text-center text-gray-400 mt-10">
          Notification settings will be implemented later.
        </div>
      ),
    },
    {
      key: "preferences",
      label: "Preferences",
      children: (
        <div className="text-center text-gray-400 mt-10">
          Preferences will be implemented later.
        </div>
      ),
    },
  ];

  return (
    <div className="flex h-screen bg-[#F5F7FA]">
      {/* Sidebar */}
      <div className="w-[298px] shrink-0">
        <Menu />
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header */}
        <div className="px-8 py-6 border-b border-gray-200 bg-white">
          <h1 className="text-2xl font-semibold text-gray-800">Profile</h1>
        </div>

        {/* Content */}
        <div className="flex-1 overflow-y-auto py-8">
          <div className="max-w-4xl mx-auto px-8">
            {/* Tabs */}
            <div className="flex justify-center mb-8">
              <Tabs
                defaultActiveKey="account"
                items={items}
                className="w-full"
                tabBarGutter={40}
                centered
              />
            </div>

            {/* Avatar section */}
            <div className="flex flex-col items-center mt-[-80px] mb-8 pointer-events-none">
              <div className="relative w-40 h-40 rounded-full bg-blue-50 flex items-center justify-center shadow-md">
                <Avatar
                  src="https://i.pravatar.cc/200?img=47"
                  size={128}
                  className="border-4 border-white shadow-lg"
                />
                <button className="absolute bottom-4 left-1/2 -translate-x-1/2 w-10 h-10 rounded-full bg-blue-500 flex items-center justify-center text-white shadow-md pointer-events-auto">
                  <Camera size={18} />
                </button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}


