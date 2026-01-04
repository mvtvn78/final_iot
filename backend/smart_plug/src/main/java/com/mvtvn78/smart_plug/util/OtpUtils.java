package com.mvtvn78.smart_plug.util;

import com.mvtvn78.smart_plug.model.Otp;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Random;

public class OtpUtils {
    private static final int OTP_LENGTH = 6;

    /**
     * Tạo OTP 6 chữ số
     */
    public static int generateOtp() {
        Random random = new Random();
        int otp = 100000 + random.nextInt(900000); // 100000-999999
        return otp;
    }

    /**
     * Kiểm tra OTP còn hiệu lực (dưới 3 phút)
     */
    public static boolean isOtpValid(Otp otp) {
        if (otp == null || otp.getCreateAt() == null || otp.getActive()) {
            return false;
        }

        LocalDateTime now = LocalDateTime.now();
        Duration duration = Duration.between(otp.getCreateAt(), now);
        return duration.toMinutes() < 3; // <3 phút
    }
}
