package com.mvtvn78.smart_plug.repository;

import com.mvtvn78.smart_plug.model.Otp;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OtpRepository extends JpaRepository<Otp, Long> {
    Otp findByEmailAndValue(String email, Integer value);
}
