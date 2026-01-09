import 'package:flutter/material.dart';
// Import màn hình Home của bạn (nếu có)
// import 'package:smart_home/screens/home_screen.dart';
import 'package:esp32_ble_flutter/screens/auth/signin_screen.dart';

class WellDoneScreen extends StatelessWidget {
  const WellDoneScreen({super.key});

  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              // --- 1. Close Button (Top Left) ---
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, size: 26, color: textDark),
                  onPressed: () {
                    // Hành động khi nhấn đóng (thường là về Home)
                    _goToHome(context);
                  },
                ),
              ),

              const Spacer(flex: 2), // Đẩy nội dung vào giữa

              // --- 2. Success Graphic (Tự vẽ bằng Code) ---
              SizedBox(
                width: 140,
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Các chấm trang trí (Confetti)
                    const Positioned(
                        top: 20,
                        left: 20,
                        child: _Dot(size: 8, color: Color(0xFF88A4FF))),
                    const Positioned(
                        top: 10,
                        right: 30,
                        child: _Dot(size: 6, color: primaryBlue)),
                    const Positioned(
                        bottom: 30,
                        left: 10,
                        child: _Dot(size: 5, color: primaryBlue)),
                    const Positioned(
                        bottom: 20,
                        right: 20,
                        child: _Dot(size: 7, color: Color(0xFF88A4FF))),
                    const Positioned(
                        top: 60,
                        right: 0,
                        child: _Dot(size: 4, color: Color(0xFF88A4FF))),

                    // Vòng tròn chính
                    Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        color: primaryBlue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x333F63F3), // Shadow xanh nhạt
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.check,
                          color: Colors.white, size: 40),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. Title ---
              const Text(
                "Well Done!",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 12),

              // --- 4. Description ---
              const Text(
                "Congratulations! Your home is now a Smartify\nhaven. Start exploring and managing your\nsmart space with ease.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: textGray,
                  fontSize: 14.5,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const Spacer(flex: 3), // Đẩy nút xuống dưới

              // --- 5. Button "Get Started" ---
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SignInScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    shadowColor: primaryBlue.withOpacity(0.4),
                  ),
                  child: const Text(
                    "Get Started",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
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

  void _goToHome(BuildContext context) {
    // TODO: Điều hướng vào màn hình chính của App
    // Navigator.pushAndRemoveUntil(
    //   context,
    //   MaterialPageRoute(builder: (context) => const HomeScreen()),
    //   (route) => false, // Xóa hết lịch sử back để không quay lại màn setup
    // );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Welcome to Smartify Home!")),
    );
  }
}

// Widget nhỏ để vẽ các chấm tròn trang trí
class _Dot extends StatelessWidget {
  final double size;
  final Color color;

  const _Dot({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
