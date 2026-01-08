package com.mvtvn78.smart_plug.controller;

import com.mvtvn78.smart_plug.data.LoginRequest;
import com.mvtvn78.smart_plug.data.ServiceResponse;
import com.mvtvn78.smart_plug.data.UserDeviceRequest;
import com.mvtvn78.smart_plug.service.UserDeviceService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/user-devices")
public class UserDeviceController {
    @Autowired
    private UserDeviceService userDeviceService;
    @PostMapping
    public ResponseEntity<ServiceResponse> addDevice(@Valid @RequestBody UserDeviceRequest request) {
        ServiceResponse response = userDeviceService.addDevice(request);
        return ResponseEntity.status(response.getStatusCode()).body(response);
    }
    @DeleteMapping
    public ResponseEntity<ServiceResponse> removeDevice(@Valid @RequestBody UserDeviceRequest request) {
        ServiceResponse response = userDeviceService.removeDeviceFromUser(request);
        return ResponseEntity.status(response.getStatusCode()).body(response);
    }
}
