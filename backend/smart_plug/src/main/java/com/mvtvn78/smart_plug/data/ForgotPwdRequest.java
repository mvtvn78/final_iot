package com.mvtvn78.smart_plug.data;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ForgotPwdRequest {
    @NotBlank(message = "email không được trống")
    @Email(message = "email phải đúng định dạng")
    private String email;
}
