package com.mvtvn78.smart_plug.data;


import lombok.AllArgsConstructor;
import lombok.Data;

@Data
@AllArgsConstructor
public class RegisterResponse {
    private Long userId;
    private String userName;
    private String email;
    private String fullName;
    private String role;
}
