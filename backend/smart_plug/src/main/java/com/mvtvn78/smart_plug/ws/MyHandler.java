package com.mvtvn78.smart_plug.ws;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;
@Slf4j
@RequiredArgsConstructor
public class MyHandler extends TextWebSocketHandler {
    private final SessionManager sessionManager;
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        sessionManager.addSession(session);
//        session.sendMessage( new TextMessage("Hello world"));
    }
    @Override
    public void afterConnectionClosed(
            WebSocketSession session,
            CloseStatus status) {
        sessionManager.removeSession(session);
    }
    @Override
    public void handleTransportError(
            WebSocketSession session,
            Throwable exception) {
        sessionManager.removeSession(session);
    }
//    @Override
//    public void handleTextMessage(WebSocketSession session, TextMessage message) throws IOException {
//        log.info("Test message {}", message.toString());
//    }
}