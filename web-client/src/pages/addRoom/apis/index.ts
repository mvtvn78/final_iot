import { BASE_API } from "../../../apis";
import type { Room } from "../interfaces";


export const createRoom = async (room: Room) => {
  const token = localStorage.getItem("token");

  const response = await BASE_API.post("rooms", room, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response;
};
