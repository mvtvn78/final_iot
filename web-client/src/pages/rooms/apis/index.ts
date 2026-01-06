import { BASE_API } from "../../../apis";
import type { Room } from "../interfaces";

export const getRooms = async () => {
  const token = localStorage.getItem("token");

  const response = await BASE_API.get("rooms", {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response;
};

export const getRoomById = async (roomId: string) => {
  const token = localStorage.getItem("token");

  const response = await BASE_API.get(`rooms/${roomId}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response;
};

export const updateRoom = async (roomId: string, room: Partial<Room>) => {
  const token = localStorage.getItem("token");

  const response = await BASE_API.put(`rooms/${roomId}`, room, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response;
};

export const deleteRoom = async (roomId: string) => {
  const token = localStorage.getItem("token");

  const response = await BASE_API.delete(`rooms/${roomId}`, {
    headers: {
      Authorization: `Bearer ${token}`,
    },
  });

  return response;
};

