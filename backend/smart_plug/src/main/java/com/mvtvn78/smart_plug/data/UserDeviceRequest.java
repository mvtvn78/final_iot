package com.mvtvn78.smart_plug.data;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class UserDeviceRequest {
    @NotNull(message = "deviceId không được null")
    @Positive(message = "deviceId phải là số dương")
    private Long deviceId;
}
