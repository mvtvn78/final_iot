package com.mvtvn78.smart_plug.data;
import jakarta.validation.constraints.*;
import lombok.Data;

@Data
public class RegisterRequest {
    @NotBlank(message = "Username không được trống")
    @Size(min = 6, message = "Username phải >= 6 ký tự")
    private String userName;
    @NotBlank(message = "email không được trống")
    @Email(message = "email phải đúng định dạng")
    private String email;
    @NotBlank(message = "fullName không được trống")
    private String fullName;
    @NotBlank(message = "Password không được trống")
    @Size(min = 8, message = "Password phải >= 8 ký tự")
    private String password;
    @NotBlank(message = "confirmPassword không được trống")
    @Size(min = 8, message = "confirmPassword phải >= 8 ký tự")
    private String confirmPassword;
}
