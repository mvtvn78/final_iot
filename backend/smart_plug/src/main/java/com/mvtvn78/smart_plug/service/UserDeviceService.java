package com.mvtvn78.smart_plug.service;

import com.mvtvn78.smart_plug.data.*;
import com.mvtvn78.smart_plug.model.Device;
import com.mvtvn78.smart_plug.model.User;
import com.mvtvn78.smart_plug.model.UserDevice;
import com.mvtvn78.smart_plug.repository.DeviceRepository;
import com.mvtvn78.smart_plug.repository.UserDeviceRepository;
import com.mvtvn78.smart_plug.repository.UserRepository;
import com.mvtvn78.smart_plug.util.CommonUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.HashMap;
import java.util.List;

@Service
public class UserDeviceService {
    @Autowired
    private UserDeviceRepository userDeviceRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private DeviceRepository deviceRepository;
    @Transactional(rollbackFor = Exception.class)
    public ServiceResponse addDevice(UserDeviceRequest request) {
        HashMap<String, String> result = new HashMap<>();
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByUserName(userName);
        if(userDeviceRepository.existsByUser_IdAndDevice_Id(user.getId(), request.getDeviceId())) {
            result.put("message", "Device already assigned to user");
            return new ServiceResponse(HttpStatus.CONFLICT.value(), result);
        }
        Device device = deviceRepository.findById(request.getDeviceId()).orElse(null);
        if(device == null) {
            result.put("message", "Device not found");
            return new ServiceResponse(HttpStatus.NOT_FOUND.value(), result);
        }
        UserDevice userDevice = new UserDevice();
        userDevice.setUser(user);
        userDevice.setDevice(device);
        userDeviceRepository.save(userDevice);
        result.put("message", "Device added");
        return new ServiceResponse(HttpStatus.OK.value(),result);
    }
    @Transactional
    public ServiceResponse removeDeviceFromUser(UserDeviceRequest request) {
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByUserName(userName);
        Long userId = user.getId();
        Long deviceId = request.getDeviceId();
        HashMap<String, String> result = new HashMap<>();
        long remove = userDeviceRepository.deleteByUser_IdAndDevice_Id(userId, deviceId);
        if(remove > 0) {
            result.put("message", "Device removed successfully");
            return new ServiceResponse(HttpStatus.OK.value(), result);
        }
        result.put("message", "Device removed unsuccessfully");
        return new ServiceResponse(HttpStatus.NOT_FOUND.value(), result);
    }
    public ServiceResponse checkDevice(Device device) {
        HashMap<String, String> result = new HashMap<>();
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByUserName(userName);
        if (device != null && userDeviceRepository.existsByUser_IdAndDevice_Id(user.getId(), device.getId())) {
            result.put("message", "Published to " + device.getTopicRelay());
            return new ServiceResponse(HttpStatus.OK.value(), result);
        }
        result.put("message", "Device not assigned to user");
        return new ServiceResponse(HttpStatus.NOT_FOUND.value(), result);
    }
    public List<Device> getListOfDevices() {
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByUserName(userName);
        return userDeviceRepository.findDevicesByUserId(user.getId());
    }

}

