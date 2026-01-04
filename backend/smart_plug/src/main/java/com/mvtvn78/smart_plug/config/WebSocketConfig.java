package com.mvtvn78.smart_plug.config;

import com.mvtvn78.smart_plug.interceptor.DeviceInterceptor;
import com.mvtvn78.smart_plug.repository.DeviceRepository;
import com.mvtvn78.smart_plug.ws.MyHandler;
import com.mvtvn78.smart_plug.ws.SessionManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.config.annotation.*;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {
    private final SessionManager sessionManager;
    private final DeviceInterceptor deviceInterceptor;
    public WebSocketConfig(SessionManager sessionManager, DeviceInterceptor deviceInterceptor) {
        this.sessionManager = sessionManager;
        this.deviceInterceptor = deviceInterceptor;
    }
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(myHandler(), "/iot")
                .addInterceptors(deviceInterceptor)
                .setAllowedOriginPatterns("*"); // Cho phép tất cả origin
    }
    @Bean
    public WebSocketHandler myHandler() {
        return new MyHandler(sessionManager);
    }
}