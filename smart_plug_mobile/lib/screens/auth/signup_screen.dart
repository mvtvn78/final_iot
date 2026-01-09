import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:esp32_ble_flutter/services/api.dart';
import 'package:esp32_ble_flutter/screens/auth/select_country_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);

  final _userNameCtrl = TextEditingController();
  final _fullNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();

  bool _agree = false;
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _userNameCtrl.dispose();
    _fullNameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool _validate() {
    final userName = _userNameCtrl.text.trim();
    final fullName = _fullNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmPassCtrl.text;

    if (fullName.isEmpty || email.isEmpty || pass.isEmpty || confirm.isEmpty) {
      _toast("Please fill in all fields.");
      return false;
    }
    if (userName.length < 6) {
      _toast("Username must be at least 6 characters.");
    }
    if (!email.contains("@") || !email.contains(".")) {
      _toast("Email is invalid.");
      return false;
    }

    if (pass.length < 8) {
      _toast("Password must be at least 8 characters.");
      return false;
    }

    if (pass != confirm) {
      _toast("Confirm password does not match.");
      return false;
    }

    if (!_agree) {
      _toast("Please accept Terms & Conditions.");
      return false;
    }

    return true;
  }

  Future<void> _signUp() async {
    if (!_validate()) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SigningUpDialog(),
    );

    try {
      final res = await Api.auth.signUp(
        userName: _userNameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        fullName: _fullNameCtrl.text.trim(),
        password: _passCtrl.text,
        confirmPassword: _confirmPassCtrl.text,
      );

      if (!mounted) return;
      Navigator.pop(context);

      // Backend: { "statusCode": 209, "data": { "message": "User exist" } }
      final statusCode = res["statusCode"];
      final data = res["data"];

      final message = (data is Map && data["message"] != null)
          ? data["message"].toString()
          : null;

      if (statusCode == 209) {
        _toast("Email or username already exists.");
        return;
      }

      // nếu backend có trả statusCode kiểu khác cho success thì check thêm ở đây
      // giả sử success là 200/201 hoặc res có field khác, bạn chỉnh theo backend
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => SelectCountryScreen()),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      final data = e.response?.data;

      // ưu tiên message từ backend nếu có
      final msg = (data is Map &&
              data["data"] is Map &&
              data["data"]["message"] != null)
          ? data["data"]["message"].toString()
          : (data is Map && data["message"] != null)
              ? data["message"].toString()
              : (data is Map && data["error"] != null)
                  ? data["error"].toString()
                  : (e.message ?? "Request failed");

      _toast(msg);
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      _toast(e.toString());
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
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Join Smartify Today",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(width: 12),
                  ClipOval(
                    child: Image.asset(
                      'assets/icons/person.jpg',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.account_circle,
                        size: 32,
                        color: textGray,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "Join Smartify, Your Gateway to Smart Living.",
                style: TextStyle(
                  fontSize: 14,
                  color: textGray,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                "Username",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              _Field(
                controller: _userNameCtrl,
                hint: "user123",
                prefix: const Icon(Icons.alternate_email,
                    size: 20, color: textGray),
              ),
              const SizedBox(height: 18),
              const Text(
                "Full name",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              _Field(
                controller: _fullNameCtrl,
                hint: "Họ Tên",
                prefix:
                    const Icon(Icons.person_outline, size: 20, color: textGray),
              ),
              const SizedBox(height: 18),
              const Text(
                "Email",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              _Field(
                controller: _emailCtrl,
                hint: "user@example.com",
                prefix:
                    const Icon(Icons.email_outlined, size: 20, color: textGray),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 18),
              const Text(
                "Password",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              _Field(
                controller: _passCtrl,
                hint: "Password",
                obscureText: _obscurePass,
                prefix:
                    const Icon(Icons.lock_outline, size: 20, color: textGray),
                suffix: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: textGray,
                  ),
                  onPressed: () => setState(() => _obscurePass = !_obscurePass),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                "Confirm password",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              _Field(
                controller: _confirmPassCtrl,
                hint: "Confirm Password",
                obscureText: _obscureConfirm,
                prefix:
                    const Icon(Icons.lock_outline, size: 20, color: textGray),
                suffix: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    _obscureConfirm
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: textGray,
                  ),
                  onPressed: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _agree,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                      activeColor: primaryBlue,
                      side: const BorderSide(color: primaryBlue, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        text: "I agree to Smartify ",
                        style: const TextStyle(fontSize: 13, color: textGray),
                        children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.baseline,
                            baseline: TextBaseline.alphabetic,
                            child: GestureDetector(
                              onTap: () {},
                              child: const Text(
                                "Terms & Conditions.",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: primaryBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Sign up",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(
                      fontSize: 13,
                      color: textGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "Sign in",
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Widget? prefix;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.hint,
    this.prefix,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1F2937)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
        prefixIcon: prefix != null
            ? Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: prefix,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        suffixIcon: suffix,
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF3F4F6), width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF3F63F3), width: 1.5),
        ),
      ),
    );
  }
}

class _SigningUpDialog extends StatelessWidget {
  const _SigningUpDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(strokeWidth: 5),
            ),
            SizedBox(height: 14),
            Text(
              "Sign up...",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
