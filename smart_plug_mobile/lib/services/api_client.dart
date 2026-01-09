import 'package:dio/dio.dart';
import 'package:esp32_ble_flutter/services/token_storage.dart';

class ApiClient {
  ApiClient._();

  static Dio create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {"Content-Type": "application/json"},
      ),
    );

    // ✅ Add token to every request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Nếu muốn bỏ qua token cho 1 số endpoint
          final path = options.path; // ví dụ: "/user/login"
          final skipAuth = path.contains("/user/login") ||
              path.contains("/user/register") ||
              path.contains("/user/forgot-password") ||
              path.contains("/forgot");

          if (!skipAuth) {
            final token = await TokenStorage.read();
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          }

          handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }
}
