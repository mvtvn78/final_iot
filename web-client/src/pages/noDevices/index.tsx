import { Button, Image } from "antd";
import { useEffect } from "react";
import { useNavigate } from "react-router-dom";
import Menu from "../../layout/menu";
export default function index() {
  const navigate = useNavigate();

  useEffect(() => {
    // Check if house name exists
    const houseName = localStorage.getItem("houseName");
    if (houseName) {
      // Check if rooms exist
      const storedRooms = localStorage.getItem("rooms");
      const rooms = storedRooms ? JSON.parse(storedRooms) : [];
      
      if (rooms.length > 0) {
        // If rooms exist, redirect to rooms page
        navigate("/rooms", { replace: true });
      } else {
        // If no rooms but has house name, redirect to add-room
        navigate("/spaces/add-room", { replace: true });
      }
    }
  }, [navigate]);

  return (
    <div className="flex">
      <div className="w-[298px]">
        <Menu />
      </div>
      <div className="flex flex-1">
        <div className="flex items-center justify-center flex-col gap-4 flex-1 bg-[#FAFAFA]">
          <div className="flex flex-col items-center justify-center">
            <h1 className="text-2xl font-bold">
              Looks like you have no space set up
            </h1>
            <p className="text-gray-500">
              Add your house and start your smart life
            </p>
          </div>
          <div className="flex items-center justify-center">
            <Image src={"/image-no-device.png"} alt="no device" />
          </div>
          <div className="flex items-center justify-center">
            <Button
              className="text-[16px] font-bold h-10! w-[522px] rounded-2xl"
              type="primary"
              onClick={() => navigate("/spaces/new-home")}
            >
              Set up your space
            </Button>
          </div>
        </div>
      </div>
    </div>
  );
}
