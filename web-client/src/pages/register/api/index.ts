import { BASE_API } from "../../../apis";
import type { BaseResponse } from "../../../interfaces/response.interface";
import type { RegisterRequest } from "../interfaces";

export const register = async (data: RegisterRequest) => {
  const response = await BASE_API.post<BaseResponse<RegisterRequest>>("user/register", data);
  return response.data;
};