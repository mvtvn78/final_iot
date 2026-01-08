package com.mvtvn78.smart_plug.util;

public class CommonUtil {
    public static final String ROLE_USER ="user";
    public static Long parseLongSafe(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        try {
            return Long.parseLong(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }

}
