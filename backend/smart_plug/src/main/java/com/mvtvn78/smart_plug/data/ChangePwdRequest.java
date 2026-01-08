package com.mvtvn78.smart_plug.data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class ChangePwdRequest {
    @NotBlank(message = "oldPwd không được trống")
    @Size(min = 8, message = "oldPwd phải >= 8 ký tự")
    private String oldPwd;
    @NotBlank(message = "newPwd không được trống")
    @Size(min = 8, message = "newPwd phải >= 8 ký tự")
    private String newPwd;
    @NotBlank(message = "confirmPwd  không được trống")
    @Size(min = 8, message = "confirmPwd  phải >= 8 ký tự")
    private String confirmPwd;
}
