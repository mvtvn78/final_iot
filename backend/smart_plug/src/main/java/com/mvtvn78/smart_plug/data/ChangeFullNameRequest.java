package com.mvtvn78.smart_plug.data;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class ChangeFullNameRequest {
    @NotBlank(message = "fullName không được trống")
    private String fullName;
}
