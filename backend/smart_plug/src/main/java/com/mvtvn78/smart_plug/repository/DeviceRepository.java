package com.mvtvn78.smart_plug.repository;

import com.mvtvn78.smart_plug.model.Device;
import org.springframework.data.jpa.repository.JpaRepository;

public interface DeviceRepository extends JpaRepository<Device, Long> {
    Device findByTopicData(String topicData);

    Device findByTopicRelay(String topicRelay);
}