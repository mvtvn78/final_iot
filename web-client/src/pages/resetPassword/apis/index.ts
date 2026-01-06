import { BASE_API } from "../../../apis";
import type { BaseResponse } from "../../../interfaces/response.interface";
import type { ResetPasswordRequest } from "../interfaces";

export const resetPassword = async (data: ResetPasswordRequest) => {
    const response = await BASE_API.put<BaseResponse<any>>("user/forgot-password", data);
    return response.data;
};