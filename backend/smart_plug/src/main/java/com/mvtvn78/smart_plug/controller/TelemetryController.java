package com.mvtvn78.smart_plug.controller;

import com.mvtvn78.smart_plug.model.Telemetry;
import com.mvtvn78.smart_plug.repository.TelemetryRepository;
import com.mvtvn78.smart_plug.service.TelemetryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
@CrossOrigin("*")
@RestController
@RequestMapping("/telemetry")
public class TelemetryController {
    @Autowired
    private TelemetryService telemetryService;
    @GetMapping("/{deviceId}")
    public List<Telemetry> getByDevice(@PathVariable Long deviceId) {
        return telemetryService.getAllByDeviceId(deviceId);
    }
}