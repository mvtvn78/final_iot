export interface ResetPasswordRequest {
    email: string;
    otp: string;
    newPwd: string;
    confirmPwd: string;
}