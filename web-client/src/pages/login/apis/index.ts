import { BASE_API } from "../../../apis";
import type { BaseResponseLogin } from "../../../interfaces/response.interface";
import type { LoginRequest } from "../interfaces";

export const login = async (data: LoginRequest) => {
    const response = await BASE_API.post<BaseResponseLogin>("user/login", data);
    return response.data;
};