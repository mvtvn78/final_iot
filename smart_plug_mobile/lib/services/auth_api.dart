import 'package:dio/dio.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  // ================= SIGN UP =================
  Future<Map<String, dynamic>> signUp({
    required String userName,
    required String email,
    required String fullName,
    required String password,
    required String confirmPassword,
  }) async {
    final res = await _dio.post(
      "/user/register",
      data: {
        "userName": userName,
        "email": email,
        "fullName": fullName,
        "password": password,
        "confirmPassword": confirmPassword,
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  // ================= LOGIN =================
  Future<Map<String, dynamic>> login({
    required String userName,
    required String password,
  }) async {
    final res = await _dio.post(
      "/user/login",
      data: {
        "userName": userName,
        "password": password,
      },
    );
    return Map<String, dynamic>.from(res.data);
  }

  // ================= FORGOT PASSWORD (SEND OTP) =================
  // POST /user/forgot
  // body: { email }

  Future<Map<String, dynamic>> forgotPasswordPut({
    required String email,
    required String otp,
    required String newPwd,
    required String confirmPwd,
  }) async {
    final res = await _dio.put("/user/forgot-password", data: {
      "email": email,
      "otp": int.tryParse(otp) ?? otp,
      "newPwd": newPwd,
      "confirmPwd": confirmPwd,
    });
    return Map<String, dynamic>.from(res.data);
  }

  Future<Map<String, dynamic>> forgotPasswordPost({
    required String email,
  }) async {
    final res = await _dio.post("/user/forgot", data: {
      "email": email,
    });
    return Map<String, dynamic>.from(res.data);
  }
}
