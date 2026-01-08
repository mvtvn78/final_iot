package com.mvtvn78.smart_plug.data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;
import lombok.Data;

@Data
public class LoginRequest {
    @NotBlank(message = "userName không được trống")
    private String userName;
    @NotBlank(message = "password không được trống")
    @Size(min = 8, message = "password phải >= 8 ký tự")
    private String password;
}
