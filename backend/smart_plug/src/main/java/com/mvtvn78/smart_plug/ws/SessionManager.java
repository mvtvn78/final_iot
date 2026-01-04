package com.mvtvn78.smart_plug.ws;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;

import java.io.IOException;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;

@Component
public class SessionManager {

    /**
     * deviceId -> Set<WebSocketSession>
     */
    private final Map<String, Set<WebSocketSession>> deviceSessions =
            new ConcurrentHashMap<>();

    /* =========================
       CONNECT
       ========================= */

    public void addSession(WebSocketSession session) {
        String deviceId = (String) session.getAttributes().get("deviceId");
        if (deviceId == null ) {
            return; // hoặc throw exception
        }
        // tạo Set nếu chưa có (thread-safe)
        deviceSessions
                .computeIfAbsent(deviceId,
                        k -> ConcurrentHashMap.newKeySet())
                .add(session);

        log("➕ CONNECT", deviceId, session);
    }

    /* =========================
       DISCONNECT
       ========================= */

    public void removeSession(WebSocketSession session) {
        String deviceId = (String) session.getAttributes().get("deviceId");

        if (deviceId == null) return;

        Set<WebSocketSession> sessions =
                deviceSessions.get(deviceId);

        if (sessions != null) {
            sessions.remove(session);

            // nếu device không còn session nào → cleanup
            if (sessions.isEmpty()) {
                deviceSessions.remove(deviceId);
            }
        }

        log("➖ DISCONNECT", deviceId, session);
    }

    /* =========================
       SEND MESSAGE
       ========================= */

    public void sendToDevice(String deviceId, String message)
            throws IOException {

        Set<WebSocketSession> sessions =
                deviceSessions.get(deviceId);

        if (sessions == null) return;

        for (WebSocketSession session : sessions) {
            if (session.isOpen()) {
                session.sendMessage(new TextMessage(message));
            }
        }
    }

    /* =========================
       BROADCAST ALL DEVICES
       ========================= */

    public void broadcast(String message) throws IOException {
        for (Set<WebSocketSession> sessions : deviceSessions.values()) {
            for (WebSocketSession session : sessions) {
                if (session.isOpen()) {
                    session.sendMessage(new TextMessage(message));
                }
            }
        }
    }

    /* =========================
       CLEANUP
       ========================= */

    public void cleanup() {
        deviceSessions.forEach((deviceId, sessions) -> {
            sessions.removeIf(s -> !s.isOpen());
            if (sessions.isEmpty()) {
                deviceSessions.remove(deviceId);
            }
        });
    }

    /* =========================
       LOG
       ========================= */

    private void log(String action, String deviceId, WebSocketSession session) {
        System.out.printf(
                "%s | device=%s | session=%s%n",
                action,
                deviceId,
                session.getId()
        );
    }
}