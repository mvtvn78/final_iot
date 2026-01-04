package com.mvtvn78.smart_plug;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.integration.config.EnableIntegration;
// Tich Hop MQTT
@EnableIntegration
@SpringBootApplication
public class SmartPlugApplication {
	public static void main(String[] args) {
		SpringApplication.run(SmartPlugApplication.class, args);
	}
}
