package com.mvtvn78.smart_plug.controller;

import com.mvtvn78.smart_plug.data.*;
import com.mvtvn78.smart_plug.model.User;
import com.mvtvn78.smart_plug.service.UserService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;
@Validated
@RestController
@RequestMapping("/user")
public class UserController {
    @Autowired
    private UserService userService;
    @GetMapping
    public ResponseEntity<ServiceResponse> getInfo() {
        ServiceResponse response = userService.getInfo();
        return ResponseEntity.status(response.getStatusCode()).body(response);
    }
    @RequestMapping(value = "/login", method = RequestMethod.POST, headers = "Accept=application/json")
    public ResponseEntity<ServiceResponse> login(@Valid @RequestBody LoginRequest request) {
        ServiceResponse response = userService.login(request);
        return ResponseEntity.status(response.getStatusCode()).body(response);
    }
    @RequestMapping(value = "/register", method = RequestMethod.POST)
    public ResponseEntity<ServiceResponse> createUser(@Valid @RequestBody RegisterRequest request) {
        ServiceResponse serviceResponse = userService.register(request);
        return ResponseEntity.status(serviceResponse.getStatusCode()).body(serviceResponse);
    }
    @RequestMapping(value = "/password",method = RequestMethod.PUT)
    public ResponseEntity<ServiceResponse> changePwd(@Valid @RequestBody ChangePwdRequest request) {
        ServiceResponse serviceResponse = userService.changePassword(request);
        return ResponseEntity.status(serviceResponse.getStatusCode()).body(serviceResponse);
    }
    @RequestMapping(value = "/full-name",method = RequestMethod.PUT)
    public ResponseEntity<ServiceResponse> changeFullName(@Valid @RequestBody ChangeFullNameRequest request) {
        ServiceResponse serviceResponse = userService.changeFullName(request);
        return ResponseEntity.status(serviceResponse.getStatusCode()).body(serviceResponse);
    }
    @RequestMapping(value = "/forgot",method = RequestMethod.POST)
    public ResponseEntity<ServiceResponse> forgot(@Valid @RequestBody ForgotPwdRequest request) {
        ServiceResponse serviceResponse = userService.forgot(request);
        return ResponseEntity.status(serviceResponse.getStatusCode()).body(serviceResponse);
    }
    @RequestMapping(value = "/forgot-password", method = RequestMethod.PUT)
    public ResponseEntity<ServiceResponse> forgotPassword(@Valid @RequestBody ChangePwdOtpRequest request) {
        ServiceResponse serviceResponse = userService.changePasswordWithOtp(request);
        return ResponseEntity.status(serviceResponse.getStatusCode()).body(serviceResponse);
    }
}
