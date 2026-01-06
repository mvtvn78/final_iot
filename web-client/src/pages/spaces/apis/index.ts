import { BASE_API } from "../../../apis";

// Api gửi yêu cầu bật/tắt thiết bị
// deviceId: ID của thiết bị
// status: 1 để bật, 0 để tắt
export const controlDevice = async (device_id: string, payload: number) => {
  const token = localStorage.getItem("token");
  const response = await BASE_API.post(
    `/devices/${device_id}/control`,
    {
      device_id,
      payload,
    },
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    }
  );
  return response.data;
};

export const getDevice = async () => {
    const token = localStorage.getItem("token");
  
    const response = await BASE_API.get("devices", {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    });
  
    return response.data;
  };
  