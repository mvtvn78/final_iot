import { Avatar, Button, Dropdown, List, Tag } from "antd";
import type { MenuProps } from "antd";
import { Mail, MoreVertical, Phone } from "lucide-react";
import Menu from "../../../layout/menu";

interface MemberItem {
  id: string;
  name: string;
  role: "Owner" | "Admin" | "Member" | "Guest";
  email: string;
  phone?: string;
  avatarUrl?: string;
  status: "online" | "offline";
}

const MOCK_MEMBERS: MemberItem[] = [
  {
    id: "1",
    name: "Kristin Watson",
    role: "Owner",
    email: "kristin@example.com",
    phone: "+44 123 456 789",
    avatarUrl: "https://i.pravatar.cc/150?img=47",
    status: "online",
  },
  {
    id: "2",
    name: "Devon Lane",
    role: "Admin",
    email: "devon@example.com",
    phone: "+44 987 654 321",
    avatarUrl: "https://i.pravatar.cc/150?img=12",
    status: "offline",
  },
  {
    id: "3",
    name: "Courtney Henry",
    role: "Member",
    email: "courtney@example.com",
    avatarUrl: "https://i.pravatar.cc/150?img=25",
    status: "online",
  },
];

export default function MembersPage() {
  const houseName = localStorage.getItem("houseName") || "My Home";

  const getRoleColor = (role: MemberItem["role"]) => {
    switch (role) {
      case "Owner":
        return "gold";
      case "Admin":
        return "blue";
      case "Member":
        return "green";
      default:
        return "default";
    }
  };

  const getStatusDot = (status: MemberItem["status"]) => (
    <span
      className={`inline-block w-2 h-2 rounded-full ${
        status === "online" ? "bg-green-500" : "bg-gray-400"
      }`}
    />
  );

  const getMenuItems = (memberId: string): MenuProps["items"] => [
    {
      key: "edit",
      label: "Edit member",
      onClick: () => console.log("Edit member", memberId),
    },
    {
      key: "remove",
      label: "Remove from home",
      danger: true,
      onClick: () => console.log("Remove member", memberId),
    },
  ];

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div className="w-[298px] shrink-0">
        <Menu />
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Header bar */}
        <div className="bg-[#222833] px-8 py-6">
          <div className="flex items-center justify-between">
            <div className="flex flex-col gap-1 text-white">
              <h1 className="text-2xl font-bold">Members</h1>
              <p className="text-sm text-white/70">
                Manage who can access and control your smart home.
              </p>
            </div>

            <div className="flex items-center gap-3">
              <span className="text-sm text-white/70">
                Home: <span className="font-medium text-white">{houseName}</span>
              </span>
              <Button
                type="primary"
                className="bg-blue-500 hover:bg-blue-600 h-10! rounded-lg font-medium"
              >
                Invite member
              </Button>
            </div>
          </div>
        </div>

        {/* Main content */}
        <div className="flex-1 overflow-y-auto px-8 py-6">
          <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6">
            <div className="flex items-center justify-between mb-4">
              <div>
                <h2 className="text-xl font-semibold text-gray-800">
                  Your Members
                </h2>
                <p className="text-sm text-gray-500">
                  {MOCK_MEMBERS.length} people have access to this home.
                </p>
              </div>
            </div>

            <List
              itemLayout="horizontal"
              dataSource={MOCK_MEMBERS}
              renderItem={(member) => (
                <List.Item
                  actions={[
                    <Dropdown
                      key="more"
                      menu={{ items: getMenuItems(member.id) }}
                      trigger={["click"]}
                    >
                      <button className="w-8 h-8 flex items-center justify-center rounded-lg bg-gray-100 hover:bg-gray-200 transition-colors">
                        <MoreVertical size={16} className="text-gray-500" />
                      </button>
                    </Dropdown>,
                  ]}
                >
                  <List.Item.Meta
                    avatar={
                      <Avatar
                        src={member.avatarUrl}
                        size={48}
                        style={{ backgroundColor: "#2563eb" }}
                      >
                        {member.name.charAt(0)}
                      </Avatar>
                    }
                    title={
                      <div className="flex items-center gap-2">
                        <span className="text-gray-900 font-medium">
                          {member.name}
                        </span>
                        <Tag color={getRoleColor(member.role)}>
                          {member.role}
                        </Tag>
                        {getStatusDot(member.status)}
                      </div>
                    }
                    description={
                      <div className="flex flex-wrap items-center gap-4 text-sm text-gray-500">
                        <span className="flex items-center gap-1">
                          <Mail size={14} /> {member.email}
                        </span>
                        {member.phone && (
                          <span className="flex items-center gap-1">
                            <Phone size={14} /> {member.phone}
                          </span>
                        )}
                      </div>
                    }
                  />
                </List.Item>
              )}
            />
          </div>
        </div>
      </div>
    </div>
  );
}


