import 'dart:convert';
import 'package:flutter/material.dart';

// ❌ bỏ flutter_blue_plus khỏi AuthScreen
import 'package:esp32_ble_flutter/screens/auth/signup_screen.dart';
import 'package:esp32_ble_flutter/screens/auth/signin_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  // (Giữ lại nếu bạn muốn dùng sau này; hiện tại không còn BLE ở đây)
  // Future<void> _sendToEsp(String msg) async {}

  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color softBlue = Color(0xFFEEF2FF);
  static const Color textDark = Color(0xFF111827);
  static const Color textGray = Color(0xFF6B7280);
  static const Color borderGray = Color(0xFFE5E7EB);

  static const String kWifiIcon = "assets/icons/wifi.jpg";
  static const String kGoogleIcon = "assets/icons/google.jpg";
  static const String kTwitterIcon = "assets/icons/twitter.jpg";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ===== TOP ICON (wifi) =====
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.asset(
                    kWifiIcon,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                "Let's Get Started!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Let's dive in into your account",
                style: TextStyle(
                  fontSize: 13.5,
                  color: textGray,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 26),

              // ===== SOCIAL BUTTONS =====
              SocialButton(
                label: "Continue with Google",
                leading: Image.asset(kGoogleIcon, width: 20, height: 20),
                onTap: () async {
                  // TODO: google auth
                },
              ),
              const SizedBox(height: 12),

              SocialButton(
                label: "Continue with Apple",
                leading: const Icon(Icons.apple, size: 20, color: Colors.black),
                onTap: () async {},
              ),
              const SizedBox(height: 12),

              SocialButton(
                label: "Continue with Facebook",
                leading: const Icon(Icons.facebook,
                    size: 20, color: Color(0xFF1877F2)),
                onTap: () async {},
              ),
              const SizedBox(height: 12),

              SocialButton(
                label: "Continue with Twitter",
                leading: Image.asset(kTwitterIcon, width: 20, height: 20),
                onTap: () async {},
              ),

              const SizedBox(height: 18),

              // ===== SIGN UP =====
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignUpScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ===== SIGN IN =====
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SignInScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: softBlue, // bật lại nền cho giống thiết kế
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Sign in",
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _FooterLink(text: "Privacy Policy"),
                  SizedBox(width: 10),
                  Text("·", style: TextStyle(color: textGray)),
                  SizedBox(width: 10),
                  _FooterLink(text: "Terms of Service"),
                ],
              ),
              const SizedBox(height: 6),
            ],
          ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final Widget leading;
  final VoidCallback onTap;

  const SocialButton({
    super.key,
    required this.label,
    required this.leading,
    required this.onTap,
  });

  static const Color borderGray = Color(0xFFE5E7EB);
  static const Color textDark = Color(0xFF111827);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderGray, width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              SizedBox(
                width: 28,
                height: 28,
                child: Center(child: leading),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    color: textDark,
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  const _FooterLink({required this.text});

  static const Color textGray = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12.2,
          color: textGray,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
