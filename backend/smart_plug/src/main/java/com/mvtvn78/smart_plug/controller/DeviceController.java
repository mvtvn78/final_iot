package com.mvtvn78.smart_plug.controller;

import com.mvtvn78.smart_plug.data.ServiceResponse;
import com.mvtvn78.smart_plug.model.Device;
import com.mvtvn78.smart_plug.model.User;
import com.mvtvn78.smart_plug.repository.DeviceRepository;
import com.mvtvn78.smart_plug.repository.UserDeviceRepository;
import com.mvtvn78.smart_plug.repository.UserRepository;
import com.mvtvn78.smart_plug.service.MqttPublisherService;
import com.mvtvn78.smart_plug.service.UserDeviceService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
@CrossOrigin("*")
@RestController
@RequestMapping("/devices")
public class DeviceController {
    @Autowired
    private DeviceRepository deviceRepository;
    @Autowired
    private MqttPublisherService mqttPublisherService;
    @Autowired
    private MqttPahoMessageDrivenChannelAdapter mqttAdapter;
    @Autowired
    private UserDeviceService userDeviceService;
    @GetMapping
    public List<Device> getAllDevices() {
        return userDeviceService.getListOfDevices();
    }
    @PostMapping
    public ResponseEntity<ServiceResponse> createDevice(@RequestBody Device device) {
        ServiceResponse response = new ServiceResponse();
        Device findDeviceData = deviceRepository.findByTopicData(device.getTopicData());
        Device findDeviceRelay = deviceRepository.findByTopicRelay(device.getTopicRelay());
        if(findDeviceData == null &&  findDeviceRelay == null){
            mqttAdapter.addTopic(device.getTopicData(), 1);
            deviceRepository.save(device);
            response.setStatusCode(HttpStatus.OK.value());
            response.setData(device);
            return ResponseEntity.status(response.getStatusCode()).body(response);
        }
        if(findDeviceData == null ||  findDeviceRelay == null){
            response.setStatusCode(HttpStatus.CONFLICT.value());
            response.setData(null);
            return ResponseEntity.status(response.getStatusCode()).body(response);
        }
        if(!findDeviceData.getId().equals(findDeviceRelay.getId())){
            response.setStatusCode(HttpStatus.CONFLICT.value());
            response.setData(null);
        }
        else{
            response.setStatusCode(HttpStatus.OK.value());
            response.setData(findDeviceData);
        }
        return ResponseEntity.status(response.getStatusCode()).body(response);
    }
    @PostMapping("/{id}/control")
    public ResponseEntity<ServiceResponse>  controlDevice(@PathVariable Long id, @RequestBody String payload) {
        Device device = deviceRepository.findById(id).orElse(null);
        ServiceResponse response = userDeviceService.checkDevice(device);
        if(response.getStatusCode() == HttpStatus.OK.value()){
            mqttPublisherService.publish(device.getTopicRelay(), payload);
        }
        return ResponseEntity.status(response.getStatusCode()).body(response);
    }
}