import type { MenuProps } from "antd";
import {
  Button,
  Dropdown,
  Form,
  Input,
  Modal,
  Radio,
  Slider,
  Tooltip,
} from "antd";
import {
  ArrowLeft,
  Edit,
  ImageIcon,
  MoreVertical,
  Plus,
  X,
} from "lucide-react";
import { useEffect, useState } from "react";
import { useNavigate } from "react-router-dom";
import Menu from "../../../layout/menu";
import { getDevice } from "../../spaces/apis";
import type { Device, Room } from "../interfaces";

export default function AddRoomPage() {
  const navigate = useNavigate();
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [form] = Form.useForm();

  // Load rooms from localStorage
  const loadRoomsFromStorage = (): Room[] => {
    try {
      const storedRooms = localStorage.getItem("rooms");
      return storedRooms ? JSON.parse(storedRooms) : [];
    } catch (error) {
      console.error("Error loading rooms from localStorage:", error);
      return [];
    }
  };

  const [rooms, setRooms] = useState<Room[]>(loadRoomsFromStorage());

  // Get house data from localStorage or default values
  const houseName = localStorage.getItem("houseName") || "My Home";
  const houseAddress = "11-5 Raddington Rd, London, UK";
  const roomCount = rooms.length;
  const deviceCount = 0;
  const memberCount = 0;

  // Get device
  const [devices, setDevices] = useState<Device[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [roomImage, setRoomImage] = useState<string>("/image-home-new.png");

  useEffect(() => {
    getDevice().then((res) => {
      setDevices(res.data);
    });
    // Load rooms from localStorage on mount
    const loadedRooms = loadRoomsFromStorage();
    setRooms(loadedRooms);
    
    // Check if house name exists, if not redirect to new-home
    const houseName = localStorage.getItem("houseName");
    if (!houseName) {
      navigate("/spaces/new-home", { replace: true });
    }
  }, [navigate]);

  // Initialize form with default values
  useEffect(() => {
    if (isModalOpen) {
      form.setFieldsValue({
        name: "Living room",
        size: 20,
        unit: "m²",
      });
    }
  }, [isModalOpen, form]);

  console.log(devices);

  const handleContinue = () => {
    // Navigate to Step 4: Add Devices (Link smart devices)
    navigate("/spaces/add-devices");
  };

  const handleSkip = () => {
    // Skip to Step 4: Add Devices (Link smart devices)
    navigate("/spaces/add-devices");
  };

  // Save rooms to localStorage
  const saveRoomsToStorage = (roomsToSave: Room[]) => {
    try {
      localStorage.setItem("rooms", JSON.stringify(roomsToSave));
    } catch (error) {
      console.error("Error saving rooms to localStorage:", error);
    }
  };

  // Add room
  const handleAddRoom = async (values: any) => {
    setIsLoading(true);
    try {
      const newRoom: Room = {
        id: Date.now().toString(),
        name: values.name,
        size: values.size,
        unit: values.unit,
        image: roomImage,
        deviceCount: 0, // Default device count
      };

      // Add to local state
      const updatedRooms = [...rooms, newRoom];
      setRooms(updatedRooms);

      // Save to localStorage
      saveRoomsToStorage(updatedRooms);

      setIsModalOpen(false);
      form.resetFields();
      setRoomImage("/image-home-new.png");
    } catch (error) {
      console.error("Error adding room:", error);
    } finally {
      setIsLoading(false);
    }
  };

  // Handle room menu actions
  const handleRoomMenuClick = (key: string, roomId: string) => {
    if (key === "edit") {
      // TODO: Implement edit room
      console.log("Edit room:", roomId);
    } else if (key === "delete") {
      const updatedRooms = rooms.filter((room) => room.id !== roomId);
      setRooms(updatedRooms);
      saveRoomsToStorage(updatedRooms);
    }
  };

  const getRoomMenuItems = (roomId: string): MenuProps["items"] => [
    {
      key: "edit",
      label: "Edit",
      onClick: () => handleRoomMenuClick("edit", roomId),
    },
    {
      key: "delete",
      label: "Delete",
      danger: true,
      onClick: () => handleRoomMenuClick("delete", roomId),
    },
  ];

  return (
    <>
      {/* Modal add device */}
      {/* <Modal
        open={isModalOpen}
        onCancel={() => setIsModalOpen(false)}
        footer={null}
      >
        <div>
          <h2 className="text-2xl font-bold text-gray-800 mb-4">Add Device</h2>
          <Form
            layout="vertical"
            onFinish={handleAddDevice}
            requiredMark={false}
          >
            <Form.Item
              name="deviceId"
              label={
                <p className="lg:text-[16px] text-[14px] text-[#464646] font-medium">
                  Device
                  <span className="text-[#D32F2F] ml-1">*</span>
                </p>
              }
              rules={[{ required: true, message: "Please select a device" }]}
              validateTrigger={["onBlur", "onChange"]}
            >
              <Select
                placeholder="Select device"
                allowClear
                className="w-full h-10!"
                options={devices.map((device) => ({
                  label: device.name,
                  value: device.id,
                }))}
              />
            </Form.Item>
            <Button
              type="primary"
              htmlType="submit"
              className="w-full h-10!"
              loading={isLoading}
            >
              Add device
            </Button>
          </Form>
        </div>
      </Modal> */}

      {/* Add room Modal */}
      <Modal
        open={isModalOpen}
        onCancel={() => {
          setIsModalOpen(false);
          form.resetFields();
          setRoomImage("/image-home-new.png");
        }}
        footer={null}
        width={600}
        closeIcon={<X className="text-gray-500" size={20} />}
        className="add-room-modal"
      >
        <div className="py-2">
          <h2 className="text-2xl font-bold text-gray-800 mb-6">Add a room</h2>

          {/* Room Image */}
          <div className="relative mb-6">
            <div className="w-full h-64 rounded-xl overflow-hidden bg-gray-100">
              <img
                src={roomImage}
                alt="Room"
                className="w-full h-full object-cover"
                onError={(e) => {
                  (e.target as HTMLImageElement).src = "/image-home-new.png";
                }}
              />
            </div>
            <button
              className="absolute top-4 right-4 bg-white/90 hover:bg-white p-2 rounded-lg shadow-md transition-colors"
              onClick={() => {
                // TODO: Implement image upload
                console.log("Change room image");
              }}
            >
              <ImageIcon className="text-gray-600" size={20} />
            </button>
          </div>

          <Form
            form={form}
            layout="vertical"
            onFinish={handleAddRoom}
            requiredMark={false}
            initialValues={{
              name: "Living room",
              size: 20,
              unit: "m²",
            }}
          >
            {/* Room Name */}
            <Form.Item
              name="name"
              label={
                <p className="text-base text-gray-700 font-medium mb-2">
                  What's your room name?
                </p>
              }
              rules={[{ required: true, message: "Please enter room name" }]}
            >
              <Input
                placeholder="Enter room name"
                className="h-12 text-base"
                size="large"
              />
            </Form.Item>

            {/* Room Size Section */}
            <div className="mb-6">
              <p className="text-base text-gray-700 font-medium mb-4">
                What's your room size?
              </p>

              {/* Unit Radio Buttons */}
              <Form.Item name="unit" className="mb-4">
                <Radio.Group>
                  <Radio value="m²">size in m²</Radio>
                  <Radio value="ft²">size in ft²</Radio>
                </Radio.Group>
              </Form.Item>

              {/* Size Display and Controls */}
              <Form.Item
                shouldUpdate={(prevValues, curValues) =>
                  prevValues?.size !== curValues?.size ||
                  prevValues?.unit !== curValues?.unit
                }
              >
                {({ getFieldValue }) => {
                  const size = getFieldValue("size") || 20;
                  const unit = getFieldValue("unit") || "m²";
                  return (
                    <div className="mb-4">
                      <div className="text-5xl font-bold text-blue-500 mb-6 text-center">
                        {size} {unit}
                      </div>

                      {/* Slider */}
                      <Form.Item name="size" noStyle>
                        <Slider
                          min={5}
                          max={200}
                          step={1}
                          tooltip={{ formatter: (val) => `${val} ${unit}` }}
                          className="w-full mb-4"
                        />
                      </Form.Item>

                      {/* Size Input */}
                      <Form.Item name="size" noStyle>
                        <Input
                          type="number"
                          min={5}
                          max={200}
                          onChange={(e) => {
                            const numValue = parseInt(e.target.value) || 5;
                            const clampedValue = Math.min(
                              Math.max(numValue, 5),
                              200
                            );
                            form.setFieldsValue({ size: clampedValue });
                          }}
                          className="h-12 text-center text-lg font-semibold"
                          size="large"
                        />
                      </Form.Item>
                    </div>
                  );
                }}
              </Form.Item>
            </div>

            {/* Continue Button */}
            <Button
              type="primary"
              htmlType="submit"
              className="w-full h-12 bg-blue-500 hover:bg-blue-600 text-base font-medium rounded-lg"
              loading={isLoading}
            >
              Continue
            </Button>
          </Form>
        </div>
      </Modal>
      
      <div className="flex">
        <div className="w-[298px]">
          <Menu />
        </div>
        <div className="flex-1 flex flex-col">
          {/* Header */}
          <div className="relative bg-[#222833] px-8 py-6 rounded-b-2xl">
            {/* Background Pattern */}
            <div className="absolute inset-0 opacity-10 overflow-hidden rounded-b-2xl">
              <svg
                className="absolute bottom-0 w-full"
                viewBox="0 0 1200 100"
                preserveAspectRatio="none"
              >
                <path
                  d="M0,50 Q300,20 600,50 T1200,50 L1200,100 L0,100 Z"
                  fill="white"
                />
              </svg>
            </div>

            <div className="relative flex justify-between items-start">
              {/* Back Button */}
              <div className="flex items-center">
                <Tooltip title="Back">
                  <button
                    onClick={() => navigate(-1)}
                    className="cursor-pointer bg-[#555B66] hover:bg-[#555B66]/80 w-10 h-10 flex justify-center items-center rounded-lg transition-colors"
                  >
                    <ArrowLeft className="text-white" size={18} />
                  </button>
                </Tooltip>
              </div>

              {/* Title Section */}
              <div className="flex flex-col items-center gap-2">
                <h2 className="text-2xl font-bold text-white">
                  Create a new space
                </h2>
                <p className="text-base text-white/60">Organise your space</p>
              </div>

              {/* Step Indicator */}
              <div className="flex flex-col items-end">
                <span className="text-sm text-white/60">Step</span>
                <span className="text-sm font-medium text-white">3/7</span>
              </div>
            </div>
          </div>

          {/* Main Content */}
          <div className="flex-1 px-10 py-8 overflow-y-auto">
            <div className="max-w-6xl mx-auto space-y-8">
              {/* My Home Card */}
              <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6">
                <div className="flex items-start gap-6">
                  {/* House Image */}
                  <div className="w-32 h-32 rounded-xl overflow-hidden shrink-0">
                    <img
                      src="/image-home-new.png"
                      alt="My Home"
                      className="w-full h-full object-cover"
                      onError={(e) => {
                        (e.target as HTMLImageElement).src =
                          "/Gemini_Generated_Image_3luje73luje73luj.png";
                      }}
                    />
                  </div>

                  {/* House Info */}
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 mb-2">
                      <h3 className="text-2xl font-bold text-gray-800">
                        {houseName}
                      </h3>
                      <button className="p-1 hover:bg-gray-100 rounded transition-colors">
                        <Edit className="text-gray-500" size={16} />
                      </button>
                    </div>
                    <p className="text-base text-gray-600 mb-4">
                      {houseAddress}
                    </p>

                    {/* Stats Badges */}
                    <div className="flex gap-3 flex-wrap">
                      <div className="flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-full">
                        <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                        <span className="text-sm font-medium text-gray-700">
                          {roomCount} Rooms
                        </span>
                      </div>
                      <div className="flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-full">
                        <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                        <span className="text-sm font-medium text-gray-700">
                          {deviceCount} Devices
                        </span>
                      </div>
                      <div className="flex items-center gap-2 bg-gray-100 px-4 py-2 rounded-full">
                        <div className="w-2 h-2 bg-blue-500 rounded-full"></div>
                        <span className="text-sm font-medium text-gray-700">
                          {memberCount} Members
                        </span>
                      </div>
                    </div>
                  </div>
                </div>
              </div>

              {/* Add Rooms Section */}
              <div className="bg-white rounded-2xl shadow-lg border border-gray-200 p-6">
                <div className="flex items-start justify-between mb-6">
                  <div>
                    <h3 className="text-2xl font-bold text-gray-800 mb-2">
                      Add rooms
                    </h3>
                    <p className="text-base text-gray-600">
                      Organize your space by adding and customizing rooms
                    </p>
                  </div>
                  <Button
                    type="primary"
                    icon={<Plus size={18} />}
                    onClick={() => setIsModalOpen(true)}
                    className="bg-blue-500 hover:bg-blue-600 h-10! px-6 rounded-lg font-medium flex items-center gap-2"
                  >
                    Add new rooms
                  </Button>
                </div>

                {/* Empty State */}
                {rooms.length === 0 && (
                  <div className="flex flex-col items-center justify-center py-12">
                    <div className="w-[400px] h-[400px] mb-4">
                      <img
                        className="w-full h-full object-cover"
                        src="/Gemini_Generated_Image_3luje73luje73luj.png"
                        alt="No rooms"
                      />
                    </div>
                    <p className="text-base text-gray-500">
                      You have 0 rooms added
                    </p>
                  </div>
                )}

                {/* Rooms Grid (when rooms exist) */}
                {rooms.length > 0 && (
                  <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4">
                    {rooms.map((room) => (
                      <div
                        key={room.id}
                        className="relative bg-white border border-gray-200 rounded-xl overflow-hidden hover:shadow-lg transition-all duration-200 group"
                      >
                        {/* Room Image */}
                        <div className="relative w-full h-48 overflow-hidden bg-gray-100">
                          <img
                            src={room.image || "/image-home-new.png"}
                            alt={room.name}
                            className="w-full h-full object-cover"
                            onError={(e) => {
                              (e.target as HTMLImageElement).src =
                                "/image-home-new.png";
                            }}
                          />
                          {/* Menu Button */}
                          <div className="absolute top-3 right-3 opacity-0 group-hover:opacity-100 transition-opacity">
                            <Dropdown
                              menu={{ items: getRoomMenuItems(room.id!) }}
                              trigger={["click"]}
                              placement="bottomRight"
                            >
                              <button
                                className="bg-white/90 hover:bg-white p-2 rounded-lg shadow-md transition-colors"
                                onClick={(e) => e.stopPropagation()}
                              >
                                <MoreVertical
                                  className="text-gray-600"
                                  size={18}
                                />
                              </button>
                            </Dropdown>
                          </div>
                        </div>

                        {/* Room Info */}
                        <div className="p-4">
                          <h4 className="text-lg font-semibold text-gray-800 mb-1">
                            {room.name}
                          </h4>
                          <p className="text-sm text-gray-600">
                            {room.size} {room.unit}
                          </p>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Bottom Action Bar */}
          <div className="sticky bottom-0 bg-white border-t border-gray-200 shadow-lg">
            <div className="px-10 py-4 flex justify-between items-center">
              <span className="text-base text-gray-600 font-medium">
                Add all your rooms and go to the next step.
              </span>
              <div className="flex gap-3">
                <Button
                  onClick={handleSkip}
                  className="h-10! px-6 rounded-lg font-medium border-gray-300 text-gray-700 hover:bg-gray-50"
                >
                  Skip
                </Button>
                <Button
                  type="primary"
                  onClick={handleContinue}
                  className="bg-blue-500 hover:bg-blue-600 h-10! px-6 rounded-lg font-medium"
                >
                  Continue
                </Button>
              </div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
}
