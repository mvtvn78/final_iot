package com.mvtvn78.smart_plug.config;

import com.mvtvn78.smart_plug.model.Device;
import com.mvtvn78.smart_plug.model.Telemetry;
import com.mvtvn78.smart_plug.repository.DeviceRepository;
import com.mvtvn78.smart_plug.repository.TelemetryRepository;
import com.mvtvn78.smart_plug.ws.SessionManager;
import org.eclipse.paho.client.mqttv3.MqttConnectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.integration.annotation.ServiceActivator;
import org.springframework.integration.channel.DirectChannel;
import org.springframework.integration.mqtt.core.DefaultMqttPahoClientFactory;
import org.springframework.integration.mqtt.core.MqttPahoClientFactory;
import org.springframework.integration.mqtt.inbound.MqttPahoMessageDrivenChannelAdapter;
import org.springframework.integration.mqtt.outbound.MqttPahoMessageHandler;
import org.springframework.integration.mqtt.support.DefaultPahoMessageConverter;
import org.springframework.messaging.MessageChannel;
import org.springframework.messaging.MessageHandler;

@Configuration
public class MqttConfig {
    @Value("${mqtt.broker.url:tcp://localhost:1883}")
    private String brokerUrl;
    @Value("${mqtt.client.id:spring-boot-client}")
    private String clientId;
    @Value("${mqtt.client.username:spring-boot-client}")
    private String userName;
    @Value("${mqtt.client.password:spring-boot-client}")
    private String password;
    @Autowired
    private TelemetryRepository telemetryRepository;
    @Autowired
    private SessionManager sessionManager;
    @Bean
    public MqttPahoClientFactory mqttClientFactory() {
        DefaultMqttPahoClientFactory factory = new DefaultMqttPahoClientFactory();
        MqttConnectOptions options = new MqttConnectOptions();
        options.setServerURIs(new String[] { brokerUrl });
//        options.setUserName(userName);
//        options.setPassword(password.toCharArray());
        factory.setConnectionOptions(options);
        return factory;
    }
    @Bean
    public MessageChannel mqttInputChannel() {
        return new DirectChannel();
    }
    @Bean
    public MqttPahoMessageDrivenChannelAdapter inbound(DeviceRepository deviceRepository) {
        // Không thêm topic tại đây
        MqttPahoMessageDrivenChannelAdapter adapter = new MqttPahoMessageDrivenChannelAdapter(clientId + "_in",
                mqttClientFactory());

        adapter.setCompletionTimeout(5000);
        adapter.setConverter(new DefaultPahoMessageConverter());
        adapter.setQos(1);
        adapter.setOutputChannel(mqttInputChannel());
        // LOAD TẤT CẢ TOPIC TỪ DB
        deviceRepository.findAll().forEach(d -> {
            adapter.addTopic(d.getTopicData(), 1);
            System.out.println("Subscribed to: " + d.getTopicData());
        });
        return adapter;
    }
    @Bean
    @ServiceActivator(inputChannel = "mqttInputChannel")
    public MessageHandler handler(@Autowired DeviceRepository deviceRepository) {
        return message -> {
            String topic = message.getHeaders().get("mqtt_receivedTopic").toString();
            String payload = message.getPayload().toString();
            System.out.println("Received MQTT message on topic " + topic + ": " + payload);
            // Lấy device theo topic thực tế
            Device device = deviceRepository.findByTopicData(topic);
            if (device != null) {
                try{
                    sessionManager.sendToDevice(device.getId().toString(),payload);
                }
                catch (Exception e){
                    e.printStackTrace();
                }
                Telemetry telemetry = new Telemetry();
                telemetry.setPayload(payload);
                telemetry.setDeviceId(device.getId());
                telemetryRepository.save(telemetry);
                System.out.println("Saved telemetry for deviceId = " + device.getId());
            } else {
                System.out.println("⚠ Không tìm thấy device với topic: " + topic);
            }
        };
    }
    @Bean
    @ServiceActivator(inputChannel = "mqttOutboundChannel")
    public MessageHandler mqttOutbound() {
        MqttPahoMessageHandler messageHandler = new MqttPahoMessageHandler(clientId + "_out", mqttClientFactory());
        messageHandler.setAsync(true);
        messageHandler.setDefaultTopic("/test/topic");
        return messageHandler;
    }
    @Bean
    public MessageChannel mqttOutboundChannel() {
        return new DirectChannel();
    }
}