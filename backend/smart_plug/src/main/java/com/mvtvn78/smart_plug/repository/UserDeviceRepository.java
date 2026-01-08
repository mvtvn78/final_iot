package com.mvtvn78.smart_plug.repository;

import com.mvtvn78.smart_plug.model.Device;
import com.mvtvn78.smart_plug.model.UserDevice;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;
import java.util.Optional;

public interface UserDeviceRepository extends JpaRepository<UserDevice, Long> {

    Optional<UserDevice> findByUser_IdAndDevice_Id(Long userId, Long deviceId);

    boolean existsByUser_IdAndDevice_Id(Long userId, Long deviceId);
    long deleteByUser_IdAndDevice_Id(Long userId, Long deviceId);
    @Query("""
        select ud.device
        from UserDevice ud
        where ud.user.id = :userId
    """)
    List<Device> findDevicesByUserId(Long userId);
}