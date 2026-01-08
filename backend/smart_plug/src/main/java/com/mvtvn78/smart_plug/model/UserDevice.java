package com.mvtvn78.smart_plug.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDateTime;

@NoArgsConstructor
@AllArgsConstructor
@Getter
@Setter
@Entity
public class UserDevice {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @ManyToOne(optional = false)
    @JoinColumn(
            name = "device_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_user_device_device")
    )
    private Device device;

    @ManyToOne(optional = false)
    @JoinColumn(
            name = "user_id",
            nullable = false,
            foreignKey = @ForeignKey(name = "fk_user_device_user")
    )
    private User user;
    private LocalDateTime createAt = LocalDateTime.now();
}
