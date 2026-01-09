import 'package:esp32_ble_flutter/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Để lưu token
import 'package:esp32_ble_flutter/services/api.dart';
import 'package:esp32_ble_flutter/screens/home/home_screen.dart';

class PasswordChangedSuccessScreen extends StatefulWidget {
  final String email;
  final String password;

  const PasswordChangedSuccessScreen({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  State<PasswordChangedSuccessScreen> createState() =>
      _PasswordChangedSuccessScreenState();
}

class _PasswordChangedSuccessScreenState
    extends State<PasswordChangedSuccessScreen> {
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);

  bool _isLoading = false; // Biến để hiện loading khi đang login ngầm

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // Hàm Đăng nhập ngầm (Silent Login)
  Future<void> _handleGoHome() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      // Gọi API Login bằng email và pass mới
      final res = await Api.auth.login(
        userName: widget.email,
        password: widget.password,
      );

      final data = (res["data"] is Map) ? res["data"] : {};
      final token = data["token"]?.toString();

      if (token != null && token.isNotEmpty) {
        // 1. Lưu token vào máy
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);
        await TokenStorage.save(token);
        await prefs.setString('user_email', widget.email);

        // 2. Chuyển hướng vào Home
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
            (route) => false,
          );
        }
      } else {
        // Trường hợp API không trả token (hiếm khi xảy ra nếu login đúng)
        _toast("Auto-login failed. Please sign in manually.");
        Navigator.pop(context); // Quay về Login
      }
    } catch (e) {
      _toast("Error: $e");
      // Nếu lỗi mạng, có thể cho user về trang Login để thử lại
      // Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Illustration Circle
              Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(
                  color: primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(Icons.smartphone,
                          size: 60, color: Colors.white),
                      Positioned(
                        top: 22,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                              color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.account_circle,
                              size: 20, color: primaryBlue),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "You're All Set!",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your password has been successfully changed.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: textGray,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(),

              // Nút Go to Homepage có hiệu ứng Loading
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleGoHome,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text(
                          "Go to Homepage",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
