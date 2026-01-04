package com.mvtvn78.smart_plug.interceptor;

import com.mvtvn78.smart_plug.config.JwtService;
import com.mvtvn78.smart_plug.model.User;
import com.mvtvn78.smart_plug.repository.UserDeviceRepository;
import com.mvtvn78.smart_plug.repository.UserRepository;
import com.mvtvn78.smart_plug.service.UserService;
import com.mvtvn78.smart_plug.util.CommonUtil;
import jakarta.servlet.http.HttpServletResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.server.ServerHttpRequest;
import org.springframework.http.server.ServerHttpResponse;
import org.springframework.stereotype.Component;
import org.springframework.util.MultiValueMap;
import org.springframework.web.socket.WebSocketHandler;
import org.springframework.web.socket.server.HandshakeInterceptor;
import org.springframework.web.util.UriComponentsBuilder;

import java.net.URI;
import java.util.Map;
@Component
public class DeviceInterceptor implements HandshakeInterceptor {
    @Autowired
    private JwtService jwtTokenUtil;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private UserDeviceRepository userDeviceRepository;
    @Override
    public boolean beforeHandshake(
            ServerHttpRequest request,
            ServerHttpResponse response,
            WebSocketHandler wsHandler,
            Map<String, Object> attributes) {
        URI uri = request.getURI();
        MultiValueMap<String, String> queryParams =
                UriComponentsBuilder.fromUri(uri)
                        .build()
                        .getQueryParams();

        String deviceId = queryParams.getFirst("deviceId");
        String token = queryParams.getFirst("token");
        if (deviceId == null || token == null) {
            return false;
        }
        Long deviceLong =  CommonUtil.parseLongSafe(deviceId);
        if(deviceLong == null){
            return false;
        }
        if (jwtTokenUtil.isTokenExpired(token)) {
            return false;
        }
        String userName = jwtTokenUtil.extractUsername(token);
        User user = userRepository.findByUserName(userName);
        if (user == null) {
            return false;
        }
        if(!userDeviceRepository.existsByUser_IdAndDevice_Id(user.getId(),deviceLong)){
            return false;
        }
        attributes.put("deviceId", deviceId);
        return true;
    }
    @Override
    public void afterHandshake(
            ServerHttpRequest request,
            ServerHttpResponse response,
            WebSocketHandler wsHandler,
            Exception exception) {

    }
}
