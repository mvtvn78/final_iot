package com.mvtvn78.smart_plug.repository;

import com.mvtvn78.smart_plug.model.Telemetry;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface TelemetryRepository extends JpaRepository<Telemetry, Long> {
    List<Telemetry> findByDeviceId(Long deviceId);
}
