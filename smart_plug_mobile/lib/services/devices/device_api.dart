import 'package:dio/dio.dart';

class DeviceApi {
  final Dio _dio;
  DeviceApi(this._dio);

  Future<List<Map<String, dynamic>>> getDevices() async {
    final res = await _dio.get("/devices");
    final data = res.data;

    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return [];
  }

  Future<Map<String, dynamic>> createDevice({
    required String name,
    required String topicRelay,
    required String topicData,
  }) async {
    final res = await _dio.post("/devices", data: {
      "name": name,
      "topicRelay": topicRelay,
      "topicData": topicData,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> controlDevice({
    required int deviceId,
    required String payload, // "1" / "0"
  }) async {
    final res = await _dio.post(
      "/devices/$deviceId/control",
      data: payload,
      options: Options(headers: {"Content-Type": "text/plain"}),
    );
    return Map<String, dynamic>.from(res.data);
  }

  Future<List<dynamic>> getTelemetry(int deviceId) async {
    try {
      final response = await _dio.get('/telemetry/$deviceId');
      // API trả về List
      return response.data as List<dynamic>;
    } catch (e) {
      throw Exception("Lỗi lấy lịch sử: $e");
    }
  }
}
