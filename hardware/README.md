# Smart Plug (Firmware)

Phiên bản tóm tắt của README cho firmware ổ cắm thông minh (ESP-IDF).

## Mục đích
- Chứa mã firmware cho smart plug: điều khiển relay, gửi dữ liệu và cấu hình qua BLE/Wi‑Fi/MQTT.

## Yêu cầu
- ESP-IDF (phiên bản tương thích với project). 
- Toolchain cho ESP32/ESP32-C3 theo hướng dẫn của ESP-IDF.

## Build & Flash
1. Thiết lập môi trường ESP-IDF theo tài liệu chính thức.
2. Build và flash bằng `idf.py`:

```bash
cd hardware/smart_plug
idf.py set-target esp32c3   # nếu cần
idf.py build
idf.py -p <PORT> flash
```

## Cấu hình quan trọng
- Compiler options:
    - Optimization Level: Optimize for size (`-Os`)
- Partition Table:
    - Single factory app, large app

## Giao thức BLE (Ví dụ lệnh)

Command: BLE Wifi
- Request: gởi SSID và mật khẩu (dạng chuỗi `ssid=<your>,pass=<your>`)
- Ví dụ Request: `ssid=MyWiFi,pass=MyPassword`
- Response mẫu (JSON):

```json
{"code": 0, "message": "Connected to WiFi"}
{"code": 1, "message": "WiFi started"}
{"code": 2, "message": "WiFi connected to AP"}
{"code": -1, "message": "WiFi disconnected or error"}
```

Command: BLE Info Devices
- Request: `info`
- Response mẫu (JSON):

```json
{"name": "SMART_123e4567-e89b-12d3-a456-426614174000", "tpRelay": "/relay/<name>", "tpData": "/data/<name>"}
```

## Quy ước đặt tên thiết bị
- Tên thiết bị cấu thành từ: 16 (TQM) + 40 (MVT) + 33 (NVS) = `89_<MAC_DEVICE>`

## Bạn cần chỉnh đường dẫn MQTT trước khi chạy
- #define ESP_BROKER_IP "mqtt://10.119.64.78:1883" 