import 'package:dio/dio.dart';
import 'package:esp32_ble_flutter/services/devices/device_api.dart';
import 'package:esp32_ble_flutter/services/devices/user_device.dart';
import 'api_client.dart';
import 'auth_api.dart';

class Api {
  Api._();

  // ✅ sửa baseUrl 1 lần ở đây thôi
  // 10.198.26.62
  // 192.168.1.123
  // 10.25.100.61
  // 192.168.1.157
  // static const String baseUrl = "http://192.168.0.221:8080"; // Android emulator
  static const String baseUrl =
      "http://slothz.ddns.net:22021"; // Android emulator

  // static const String baseUrl = "http://192.168.1.5:3000"; // điện thoại thật

  static final Dio dio = ApiClient.create(baseUrl: baseUrl);

  static final AuthApi auth = AuthApi(dio);
  static final DeviceApi devices = DeviceApi(dio);
  static final UserDeviceApi userDevices = UserDeviceApi(dio);
}
