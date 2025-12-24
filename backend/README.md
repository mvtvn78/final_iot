 # smart_plug

Spring Boot backend để quản lý smart plug devices (Java 17).

## Tổng quan

Project này cung cấp REST API và WebSocket để quản lý thiết bị smart plug, thu nhận telemetry và điều khiển relay thông qua MQTT.

## Yêu cầu

- Java 17
- Maven

## Chạy ứng dụng

Sử dụng Maven:

```bash
mvn spring-boot:run
```

Ứng dụng mặc định chạy trên `http://localhost:8080`.

## Xác thực

- Một số endpoint công khai (không cần đăng nhập):

    - `/user/login`
    - `/user/register`
    - `/user/forgot`
    - `/user/forgot-password`
    - `/iot/**`

- Các endpoint còn lại yêu cầu header:

    `Authorization: Bearer <token>`

Token lấy được khi đăng nhập thành công.

## API

Lưu ý: các ví dụ trả về là JSON mẫu.

### Device

- GET /devices

    - Mô tả: Liệt kê tất cả devices của user hiện tại.
    - Request body: None
    - Response (khi có devices):

```json
[
    {
        "id": 1,
        "name": "Tên thiết bị",
        "topicRelay": "/test/relay/mvt",
        "topicData": "/test/data/mvt"
    }
]
```

    - Response (khi không có devices): `[]`

- POST /devices

    - Mô tả: Tạo thiết bị mới.
    - Request body (JSON):

```json
{
    "name": "Tên thiết bị",
    "topicRelay": "/test/relay/mvt",
    "topicData": "/test/data/mvt"
}
```

    - Response (thành công):

```json
{
    "statusCode": 200,
    "data": {
        "id": 2,
        "name": "Tên thiết bị",
        "topicRelay": "/test/relay/mvt",
        "topicData": "/test/data/mvt"
    }
}
```

- POST /devices/{device_id}/control

    - Mô tả: Gửi payload (string) lên topic Relay của thiết bị.
    - Request body: raw string (payload)
    - Response (nếu user không sở hữu device): HTTP 404

```json
{
    "statusCode": 404,
    "data": { "message": "Device not assigned to user" }
}
```

    - Response (nếu thành công):

```json
{
    "statusCode": 200,
    "data": { "message": "Published to /test/relay/mvt" }
}
```

### Telemetry

- GET /telemetry/{device_id}

    - Mô tả: Lấy tất cả thông số telemetry của thiết bị.
    - Request body: None
    - Response (nếu sở hữu device):

```json
[
    {
        "id": 20,
        "deviceId": 4,
        "payload": "1",
        "timestamp": "2025-12-24T10:00:24.888392"
    }
]
```

    - Nếu không sở hữu device: trả về HTTP 403 (Forbidden).

### UserDevice

- POST /user-devices

    - Mô tả: Thêm thiết bị cho user hiện tại.
    - Request body:

```json
{ "deviceId": 4 }
```

    - Response (thêm thành công):

```json
{ "statusCode": 200, "data": { "message": "Device added" } }
```

    - Nếu thiết bị đã thuộc sở hữu của user:

```json
{ "statusCode": 409, "data": { "message": "Device already assigned to user" } }
```

    - Nếu thiết bị không tồn tại:

```json
{ "statusCode": 404, "data": { "message": "Device not found" } }
```

- DELETE /user-devices

    - Mô tả: Xóa quyền sở hữu thiết bị của user hiện tại.
    - Request body:

```json
{ "deviceId": 4 }
```

    - Response (thành công):

```json
{ "statusCode": 200, "data": { "message": "Device removed successfully" } }
```

    - Response (không thành công / không tìm thấy):

```json
{ "statusCode": 404, "data": { "message": "Device removed unsuccessfully" } }
```

### User

- POST /user/register

    - Mô tả: Đăng ký user mới.
    - Request body:

```json
{
    "userName": "user123",
    "email": "user@example.com",
    "fullName": "Họ Tên",
    "password": "pwd",
    "confirmPassword": "pwd"
}
```

    - Nếu email hoặc userName trùng:

```json
{ "statusCode": 209, "data": { "message": "User exist" } }
```

    - Nếu thành công:

```json
{
    "statusCode": 200,
    "data": {
        "userId": 9,
        "userName": "12g2tbtmvt",
        "email": "12gt2btmvt@gmail.com",
        "fullName": "Mai Văn Tiền",
        "role": "user"
    }
}
```

- POST /user/login

    - Request body:

```json
{ "userName": "user123", "password": "pwd" }
```

    - Success:

```json
{ "statusCode": 200, "data": { "token": "<jwt-token>" } }
```

    - Sai thông tin:

```json
{ "statusCode": 200, "data": { "message": "Invalid username or password" } }
```

- POST /user/forgot

    - Request body: `{ "email": "user@example.com" }`
    - Response (gửi OTP thành công):

```json
{ "statusCode": 200, "data": { "message": "Send OTP Successfully" } }
```

    - Nếu email không tồn tại:

```json
{ "statusCode": 209, "data": { "message": "Send OTP Unsuccessful" } }
```

- PUT /user/password

    - Thay đổi mật khẩu cho user hiện tại.
    - Request body:

```json
{ "oldPwd": "old", "newPwd": "new", "confirmPwd": "new" }
```

    - Sai mật khẩu cũ:

```json
{ "statusCode": 401, "data": { "message": "Old Password Do not Match" } }
```

    - Xác nhận mật khẩu không đúng:

```json
{ "statusCode": 209, "data": { "message": "Password confirm do not match" } }
```

    - Thành công:

```json
{ "statusCode": 200, "data": { "message": "Change Password Successfully" } }
```

- PUT /user/full-name

    - Thay đổi `fullName` của user hiện tại.
    - Request body: `{ "fullName": "Tên mới" }`

    - Thành công:

```json
{ "statusCode": 200, "data": { "message": "Change FullName Successfully" } }
```

- PUT /user/forgot-password

    - Thay đổi mật khẩu theo OTP.
    - Request body:

```json
{
    "email": "user@example.com",
    "otp": 123456,
    "newPwd": "new",
    "confirmPwd": "new"
}
```

    - Thành công:

```json
{ "statusCode": 200, "data": { "message": "Change Password Successfully" } }
```

    - OTP không hợp lệ:

```json
{ "statusCode": 209, "data": { "message": "Invalid OTP" } }
```

## WebSocket

Kết nối WebSocket cho IoT:

```
ws://localhost:8080/iot?deviceId=<device_id>&token=<token>
```
Dữ liệu trả về khi có dữ liệu:
```
{"stateRelay": true,"power": "130","ts": 133055}
```
Lưu ý: `token` lấy từ khi đăng nhập.

## Ghi chú

- Các ví dụ JSON ở trên là mẫu — thực tế có thể khác tuỳ cấu trúc trả về của API.
- Nếu bạn muốn, mình có thể thêm ví dụ `curl` cho từng endpoint hoặc dịch sang English.
# Luồng hoạt động các logic phức tạp
## Quên mật khẩu
- Yêu cầu gửi mã OTP từ POST /user/forgot
- Nhận mã OTP từ email
- Vào UI Reset Password truyền request PUT /user/forgot-password
- Và phản hồi lại cho người dùng