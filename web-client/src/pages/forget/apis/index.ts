import { BASE_API } from "../../../apis";
import type { BaseResponse } from "../../../interfaces/response.interface";
import type { ForgetPasswordRequest } from "../interfaces";

export const forgetPassword = async (data: ForgetPasswordRequest) => {
    const response = await BASE_API.post<BaseResponse<any>>("user/forgot", data);
    return response.data;
};