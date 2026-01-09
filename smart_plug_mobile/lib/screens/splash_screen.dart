import 'dart:async';
import 'package:flutter/material.dart';
// Import Onboarding
import 'package:esp32_ble_flutter/screens/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      // --- THAY ĐỔI Ở ĐÂY ---
      // Chuyển thẳng sang OnboardingScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Không truyền device/writeChar nữa vì chưa kết nối
          builder: (_) => const OnboardingScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // UI giữ nguyên
    return const Scaffold(
      backgroundColor: Color(0xFF3F5BFF),
      body: SafeArea(
        child: Stack(
          children: [
            Align(
              alignment: Alignment(0, -0.05),
              child: _LogoAndTitle(),
            ),
            Align(
              alignment: Alignment(0, 0.72),
              child: SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 4,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LogoAndTitle extends StatelessWidget {
  const _LogoAndTitle();

  static const String kLogoPath = "assets/images/logo.jpg";

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.asset(
            kLogoPath,
            width: 78,
            height: 78,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22)),
                child: const Icon(Icons.bluetooth,
                    size: 40, color: Color(0xFF3F5BFF)),
              );
            },
          ),
        ),
        const SizedBox(height: 14),
        const Text(
          "Smartify",
          style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2),
        ),
      ],
    );
  }
}
