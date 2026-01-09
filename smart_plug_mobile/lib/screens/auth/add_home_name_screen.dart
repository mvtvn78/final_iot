import 'package:flutter/material.dart';
import 'package:esp32_ble_flutter/screens/auth/add_room_screen.dart';

class AddHomeNameScreen extends StatefulWidget {
  // Nếu cần truyền data từ màn trước thì thêm vào constructor
  // final String selectedCountry;

  const AddHomeNameScreen({super.key});

  @override
  State<AddHomeNameScreen> createState() => _AddHomeNameScreenState();
}

class _AddHomeNameScreenState extends State<AddHomeNameScreen> {
  // --- Màu sắc thống nhất ---
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color lightBlueBg = Color(0xFFEEF2FF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color inputBg = Color(0xFFF9FAFB);

  final TextEditingController _nameCtrl =
      TextEditingController(text: "My Home");
  bool _canContinue = true;

  @override
  void initState() {
    super.initState();
    // Lắng nghe thay đổi text để enable/disable nút Continue
    _nameCtrl.addListener(() {
      setState(() {
        _canContinue = _nameCtrl.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. TOP NAVIGATION ---
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back Button
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.arrow_back,
                          size: 24, color: textDark),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Progress Bar (50% - 2/4)
                  Expanded(
                    child: Container(
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: 0.5, // 2/4 = 50%
                          child: Container(
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Text Counter
                  const Text(
                    "2 / 4",
                    style: TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // --- 2. TITLE & SUBTITLE ---
              RichText(
                text: const TextSpan(
                  text: "Add ",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    height: 1.2,
                    fontFamily: 'Arial',
                  ),
                  children: [
                    TextSpan(
                      text: "Home",
                      style: TextStyle(color: primaryBlue),
                    ),
                    TextSpan(text: " Name"),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                "Every smart home needs a name. What would\nyou like to call yours?",
                style: TextStyle(
                  color: textGray,
                  fontSize: 14.5,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 32),

              // --- 3. INPUT FIELD ---
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(
                  color: textDark,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: inputBg,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(color: primaryBlue, width: 1.5),
                  ),
                ),
              ),

              const Spacer(), // Đẩy nút xuống dưới cùng

              // --- 4. BOTTOM BUTTONS ---
              Row(
                children: [
                  // Skip Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Logic Skip (có thể đặt tên mặc định là My Home)
                          _goNextStep("My Home");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightBlueBg,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            color: primaryBlue,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Continue Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _canContinue
                            ? () {
                                _goNextStep(_nameCtrl.text.trim());
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          disabledBackgroundColor: primaryBlue.withOpacity(0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Continue",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  void _goNextStep(String homeName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddRoomsScreen(),
      ),
    );
  }
}
