import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:esp32_ble_flutter/screens/auth/forgot-password/create_new_password_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color bgField = Color(0xFFF9FAFB);

  static const int _otpLen = 6;

  final List<TextEditingController> _controllers =
      List.generate(_otpLen, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_otpLen, (_) => FocusNode());

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _getOtp() => _controllers.map((e) => e.text).join();

  void _next() {
    final otp = _getOtp();
    if (otp.length < _otpLen) {
      _toast("Please enter full $_otpLen-digit code");
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNewPasswordScreen(
          email: widget.email,
          otp: otp,
        ),
      ),
    );
  }

  Widget _otpBox(int index) {
    return Expanded(
      child: SizedBox(
        height: 58,
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: bgField,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: primaryBlue, width: 2),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index < _otpLen - 1) {
                FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
              } else {
                FocusScope.of(context).unfocus();
                _next(); // auto next khi nhập ô cuối
              }
            } else {
              if (index > 0) {
                FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
              }
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter OTP Code 🔐",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Enter the 6-digit code for ${widget.email}.",
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: textGray,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- OTP Inputs: 6 ô cùng 1 hàng ---
              Row(
                children: [
                  _otpBox(0),
                  const SizedBox(width: 10),
                  _otpBox(1),
                  const SizedBox(width: 10),
                  _otpBox(2),
                  const SizedBox(width: 10),
                  _otpBox(3),
                  const SizedBox(width: 10),
                  _otpBox(4),
                  const SizedBox(width: 10),
                  _otpBox(5),
                ],
              ),

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Verify",
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
