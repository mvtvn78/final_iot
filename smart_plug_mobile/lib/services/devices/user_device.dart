import 'package:dio/dio.dart';

class UserDeviceApi {
  final Dio _dio;
  UserDeviceApi(this._dio);

  Future<Map<String, dynamic>> addDevice({required int deviceId}) async {
    final res = await _dio.post("/user-devices", data: {"deviceId": deviceId});
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> removeDevice({required int deviceId}) async {
    final res =
        await _dio.delete("/user-devices", data: {"deviceId": deviceId});
    return Map<String, dynamic>.from(res.data);
  }
}
