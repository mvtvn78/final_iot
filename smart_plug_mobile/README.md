# Smartify - Smart Home Mobile App

Ứng dụng Flutter quản lý và điều khiển thiết bị IoT Smart Plug (ESP32) thông qua Bluetooth Low Energy (BLE) và Wi-Fi.

## 📱 Giới thiệu

Smartify là ứng dụng di động giúp bạn quản lý và điều khiển các thiết bị smart plug trong ngôi nhà thông minh của bạn. Ứng dụng hỗ trợ kết nối thiết bị ESP32 qua BLE, cấu hình Wi-Fi, và điều khiển realtime qua WebSocket.

## ✨ Tính năng chính

### 🔐 Xác thực người dùng

- Đăng ký tài khoản mới
- Đăng nhập với username/password
- Quên mật khẩu với xác thực OTP
- Lưu trữ token an toàn với Secure Storage

### 🔌 Quản lý thiết bị

- **Quét QR Code**: Quét mã QR trên thiết bị để lấy thông tin
- **Kết nối BLE**: Tự động tìm và kết nối với ESP32 qua Bluetooth
- **Cấu hình Wi-Fi**: Chọn mạng Wi-Fi và gửi thông tin đăng nhập cho thiết bị
- **Đăng ký thiết bị**: Tự động đăng ký thiết bị vào hệ thống backend
- **Điều khiển realtime**: Bật/tắt thiết bị với cập nhật trạng thái tức thời
- **Theo dõi công suất**: Hiển thị công suất tiêu thụ realtime qua WebSocket
- **Lịch sử telemetry**: Xem lịch sử dữ liệu và biểu đồ tiêu thụ

### 🏠 Home Dashboard

- Hiển thị danh sách tất cả thiết bị
- Phân loại theo phòng (Living Room, Bedroom)
- Thông tin thời tiết theo vị trí
- Thống kê nhanh (Lighting, Cameras, Electrical)

### 🤖 AI Assistant

- Chat với AI để điều khiển thiết bị bằng giọng nói
- Tích hợp Google Generative AI

### 📊 Báo cáo & Thống kê

- Xem báo cáo tiêu thụ điện năng
- Biểu đồ theo thời gian
- Phân tích hiệu quả sử dụng

### 🔔 Thông báo

- Nhận thông báo về trạng thái thiết bị
- Cảnh báo bất thường

## 🛠 Công nghệ sử dụng

### Core

- **Flutter** 3.0+ (Dart SDK >=3.0.0 <4.0.0)
- **Material Design** UI

### Bluetooth & Connectivity

- `flutter_blue_plus: ^1.31.0` - Kết nối BLE với ESP32
- `wifi_scan: ^0.4.1` - Quét mạng Wi-Fi
- `mobile_scanner: ^5.2.3` - Quét QR Code
- `permission_handler: ^11.0.1` - Quản lý quyền truy cập

### Networking

- `dio: ^5.7.0` - HTTP client cho REST API
- `web_socket_channel: ^2.4.0` - WebSocket cho realtime updates
- `http: ^1.2.2` - HTTP requests bổ sung

### Storage & Security

- `flutter_secure_storage: ^9.2.2` - Lưu trữ token an toàn
- `shared_preferences: ^2.2.2` - Lưu trữ cài đặt người dùng

### AI & Maps

- `google_generative_ai: ^0.4.6` - AI Chat Assistant
- `flutter_map: ^6.1.0` - Hiển thị bản đồ OSM
- `latlong2: ^0.9.0` - Xử lý tọa độ địa lý
- `geolocator: ^11.0.0` - Lấy vị trí GPS

### Utilities

- `intl: ^0.19.0` - Format ngày tháng và địa phương hóa

## 📁 Cấu trúc Project

```
lib/
├── main.dart                    # Entry point của ứng dụng
├── screens/                     # Tất cả các màn hình UI
│   ├── splash_screen.dart       # Màn hình khởi động
│   ├── onboarding_screen.dart   # Màn hình giới thiệu
│   ├── auth_screen.dart         # Màn hình xác thực
│   ├── auth/                    # Các màn hình auth flow
│   │   ├── signin_screen.dart
│   │   ├── signup_screen.dart
│   │   ├── forgot-password/
│   │   └── ...
│   ├── home/
│   │   └── home_screen.dart     # Màn hình chính
│   ├── devices/                 # Quản lý thiết bị
│   │   ├── add_device_screen.dart
│   │   └── scan_connect_screen.dart
│   ├── details/
│   │   └── device_detail_screen.dart
│   ├── chat/
│   │   └── chat_screen.dart     # AI Chat
│   ├── notifications/
│   │   └── notification_screen.dart
│   └── users/                   # Profile & Reports
│       ├── account_screen.dart
│       ├── smart_screen.dart
│       └── report_screen.dart
├── services/                    # Business logic & API
│   ├── api.dart                 # API singleton
│   ├── api_client.dart          # Dio client setup
│   ├── auth_api.dart            # Auth endpoints
│   ├── token_storage.dart       # Secure token storage
│   ├── iot_ws_service.dart      # WebSocket service
│   └── devices/
│       ├── device_api.dart      # Device CRUD
│       └── user_device.dart     # User-Device mapping
└── common/                      # Shared widgets
    └── Loading.dart
```

## 🚀 Cài đặt và Chạy

### Yêu cầu

- Flutter SDK >=3.0.0
- Dart SDK >=3.0.0 <4.0.0
- Android Studio / VS Code với Flutter extension
- Android device/emulator hoặc iOS device/simulator

### Các bước cài đặt

1. **Clone repository**

```bash
git clone <repository-url>
cd smart_plug_mobile
```

2. **Cài đặt dependencies**

```bash
flutter pub get
```

3. **Cấu hình API Base URL**
   Mở file `lib/services/api.dart` và cập nhật `baseUrl`:

```dart
static const String baseUrl = "http://your-backend-url:port";
```

4. **Chạy ứng dụng**

```bash
# Android
flutter run

# iOS
flutter run -d ios

# Chạy trên thiết bị cụ thể
flutter run -d <device-id>
```

### Build APK/IPA

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## ⚙️ Cấu hình

### API Backend

Cập nhật base URL trong `lib/services/api.dart`:

```dart
static const String baseUrl = "http://slothz.ddns.net:22021";
```

### WebSocket

WebSocket URL được tự động chuyển đổi từ HTTP base URL:

- `http://` → `ws://`
- `https://` → `wss://`

### Permissions (Android)

Đảm bảo các quyền sau được cấu hình trong `android/app/src/main/AndroidManifest.xml`:

- `BLUETOOTH`
- `BLUETOOTH_SCAN`
- `BLUETOOTH_CONNECT`
- `ACCESS_FINE_LOCATION`
- `ACCESS_COARSE_LOCATION`
- `CAMERA`

### Permissions (iOS)

Cấu hình trong `ios/Runner/Info.plist`:

- `NSBluetoothAlwaysUsageDescription`
- `NSLocationWhenInUseUsageDescription`
- `NSCameraUsageDescription`

## 🔄 Quy trình sử dụng

### 1. Đăng ký/Đăng nhập

- Mở ứng dụng → Onboarding → Chọn Sign up hoặc Sign in
- Nhập thông tin và xác thực

### 2. Thêm thiết bị mới

1. Nhấn nút **+** trên Home Screen
2. Quét QR Code trên thiết bị ESP32
3. Ứng dụng tự động tìm và kết nối BLE
4. Chọn mạng Wi-Fi và nhập mật khẩu
5. Thiết bị kết nối Wi-Fi và gửi thông tin về
6. Thiết bị được tự động đăng ký vào tài khoản

### 3. Điều khiển thiết bị

- Trên Home Screen: Bật/tắt bằng switch
- Xem chi tiết: Nhấn vào card thiết bị
- Trên Detail Screen: Xem công suất realtime, lịch sử, lên lịch

### 4. AI Assistant

- Nhấn icon robot trên Home Screen
- Chat với AI để điều khiển thiết bị bằng ngôn ngữ tự nhiên

## 📡 API Endpoints

### Authentication

- `POST /user/register` - Đăng ký tài khoản
- `POST /user/login` - Đăng nhập
- `POST /user/forgot` - Gửi OTP quên mật khẩu
- `PUT /user/forgot-password` - Đặt lại mật khẩu

### Devices

- `GET /devices` - Lấy danh sách thiết bị
- `POST /devices` - Tạo thiết bị mới
- `POST /devices/{id}/control` - Điều khiển thiết bị (payload: "1" hoặc "0")
- `GET /telemetry/{id}` - Lấy lịch sử telemetry

### User Devices

- `POST /user-devices` - Gán thiết bị cho user
- `DELETE /user-devices` - Xóa thiết bị khỏi user

### WebSocket

- `WS /iot?deviceId={id}&token={token}` - Kết nối realtime
  - Nhận: `{stateRelay: bool, power: string, ts: int}`

## 🔧 ESP32 BLE Protocol

### Service & Characteristics

- **Service UUID**: `0000ff00-0000-1000-8000-00805f9b34fb`
- **RX Characteristic (Write)**: `0000ff01-0000-1000-8000-00805f9b34fb`
- **TX Characteristic (Notify)**: `0000ff02-0000-1000-8000-00805f9b34fb`

### Commands

- **Cấu hình Wi-Fi**: `ssid=<SSID>,pass=<PASSWORD>`
- **Lấy thông tin**: `info`
- **Phản hồi Wi-Fi**: JSON với `code` (1=connecting, 2=success, 3/4=fail)
- **Thông tin thiết bị**: JSON với `name`, `tpRelay`, `tpData`

## 🎨 UI/UX Features

- Material Design 3
- Responsive layout
- Dark/Light theme support (có thể mở rộng)
- Smooth animations
- Pull-to-refresh
- Error handling với user-friendly messages

## 📝 Notes

- Token được lưu an toàn trong Secure Storage
- WebSocket tự động reconnect khi mất kết nối
- BLE connection timeout: 12 giây
- Wi-Fi setup timeout: 20 giây
- Exponential backoff cho WebSocket reconnection
