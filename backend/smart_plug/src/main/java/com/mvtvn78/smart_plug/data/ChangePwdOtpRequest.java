package com.mvtvn78.smart_plug.data;

import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class ChangePwdOtpRequest {
    @NotBlank(message = "email không được trống")
    @Email(message = "email phải đúng định dạng")
    private String email;
    @NotNull(message = "otp không được null")
    @Positive(message = "otp phải là số dương")
    private Integer otp;
    @NotBlank(message = "newPwd không được trống")
    @Size(min = 8, message = "newPwd phải >= 8 ký tự")
    private String newPwd;
    @NotBlank(message = "confirmPwd  không được trống")
    @Size(min = 8, message = "confirmPwd  phải >= 8 ký tự")
    private String confirmPwd;
}
