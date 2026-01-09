import 'package:flutter/material.dart';
import 'package:esp32_ble_flutter/services/api.dart';
import 'package:esp32_ble_flutter/screens/auth/forgot-password/otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color inputBg = Color(0xFFF9FAFB);

  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _next() async {
    final email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      _toast("Please enter your registered email.");
      return;
    }
    if (!email.contains("@") || !email.contains(".")) {
      _toast("Email is invalid.");
      return;
    }

    if (_loading) return;
    setState(() => _loading = true);

    try {
      // ✅ POST /user/forgot-password (send OTP)
      final res = await Api.auth.forgotPasswordPost(email: email);

      final statusCode = res["statusCode"];
      final data = res["data"];
      final message = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : "Request failed";

      if (statusCode == 200) {
        _toast("OTP sent! Please check your email.");

        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpVerificationScreen(email: email),
          ),
        );
      } else if (statusCode == 404) {
        _toast("Email not found. Please register first.");
      } else if (statusCode == 209) {
        _toast("Please wait 5 minutes before trying again.");
      } else {
        _toast(message);
      }
    } catch (e) {
      _toast("Error: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Forgot Your Password? 🔑",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Enter your registered email, then enter OTP and set a new password.",
                style: TextStyle(
                  fontSize: 14.5,
                  color: textGray,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                "Your Registered Email",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(fontSize: 15, color: textDark),
                decoration: InputDecoration(
                  hintText: "andrew.ainsley@yourdomain.com",
                  hintStyle: const TextStyle(color: textGray, fontSize: 14),
                  prefixIcon: const Icon(Icons.mail_outline_rounded,
                      size: 20, color: textGray),
                  filled: true,
                  fillColor: inputBg,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: primaryBlue, width: 1.5),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    disabledBackgroundColor: primaryBlue.withOpacity(0.5),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Next",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
