package com.mvtvn78.smart_plug.service;

import com.mvtvn78.smart_plug.model.Telemetry;
import com.mvtvn78.smart_plug.model.User;
import com.mvtvn78.smart_plug.repository.TelemetryRepository;
import com.mvtvn78.smart_plug.repository.UserDeviceRepository;
import com.mvtvn78.smart_plug.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
public class TelemetryService {
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private TelemetryRepository telemetryRepository;
    @Autowired
    private UserDeviceRepository userDeviceRepository;
    public List<Telemetry> getAllByDeviceId(Long deviceId) {
        List<Telemetry>  list = new ArrayList<>();
        String userName = SecurityContextHolder.getContext().getAuthentication().getName();
        User user = userRepository.findByUserName(userName);
        if(userDeviceRepository.existsByUser_IdAndDevice_Id(user.getId(), deviceId)){
            list = telemetryRepository.findByDeviceId(deviceId);
        }
        return list;
    }
}
