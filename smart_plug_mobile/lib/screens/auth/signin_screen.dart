import 'package:esp32_ble_flutter/services/token_storage.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:esp32_ble_flutter/services/api.dart';
import 'package:esp32_ble_flutter/screens/home/home_screen.dart';
import 'package:esp32_ble_flutter/screens/auth/forgot-password/forgot_password_screen.dart';

/// File: lib/screens/auth/sign_in_screen.dart
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);

  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _remember = false;
  bool _obscure = true;
  bool _loading = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  OverlayEntry? _toastEntry;

  void _toast(String msg) {
    if (!mounted) return;

    // remove toast cũ nếu đang hiện
    _toastEntry?.remove();
    _toastEntry = null;

    final overlay = Overlay.of(context);
    if (overlay == null) return;

    final topPadding = MediaQuery.of(context).padding.top;

    _toastEntry = OverlayEntry(
      builder: (_) => Positioned(
        left: 16,
        right: 16,
        top: topPadding + 12,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF111827), // gần giống dark
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 18,
                  offset: Offset(0, 8),
                  color: Colors.black26,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: Colors.white, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    msg,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14.5,
                      height: 1.2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_toastEntry!);

    Future.delayed(const Duration(seconds: 2), () {
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }

  bool _validate() {
    final u = _userCtrl.text.trim();
    final p = _passCtrl.text;

    if (u.isEmpty || p.isEmpty) {
      _toast("Please enter username and password.");
      return false;
    }

    // ✅ validate password length > 8
    if (p.length < 7) {
      _toast("Password must be longer than 8 characters.");
      return false;
    }

    return true;
  }

  void _showInvalidDialog(String msg) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline_rounded,
                  color: primaryBlue,
                  size: 34,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Login failed",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  color: textGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "OK",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
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

  Future<void> _submitLogin() async {
    if (!_validate()) return;
    if (_loading) return;

    setState(() => _loading = true);

    try {
      final res = await Api.auth.login(
        userName: _userCtrl.text.trim(),
        password: _passCtrl.text,
      );

      final data = (res["data"] is Map)
          ? Map<String, dynamic>.from(res["data"])
          : <String, dynamic>{};

      final token = data["token"]?.toString();
      final message = data["message"]?.toString();

      if (token != null && token.isNotEmpty) {
        await TokenStorage.save(token);
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
        return;
      }

      // ✅ case sai user/pass: backend trả 200 nhưng có message
      if (message != null && message.isNotEmpty) {
        if (!mounted) return;
        _showInvalidDialog(message);
      } else {
        _toast("Invalid username or password");
      }
    } on DioException catch (e) {
      final serverMsg =
          (e.response?.data is Map && e.response?.data["error"] != null)
              ? e.response?.data["error"].toString()
              : null;

      _toast(serverMsg ?? e.message ?? "Request failed");
    } catch (e) {
      _toast(e.toString());
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
              const Text(
                "Welcome Back! 👋",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Your Smart Home, Your Rules.",
                style: TextStyle(
                  fontSize: 15,
                  color: textGray,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 32),
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
                controller: _userCtrl,
                hint: "user123",
                prefix: const Icon(Icons.person_outline_rounded,
                    size: 20, color: textGray),
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 20),
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
                obscureText: _obscure,
                prefix: const Icon(Icons.lock_outline_rounded,
                    size: 20, color: textGray),
                suffix: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: textGray,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: _remember,
                      onChanged: (v) => setState(() => _remember = v ?? false),
                      activeColor: primaryBlue,
                      side: const BorderSide(color: primaryBlue, width: 1.5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "Remember me",
                    style: TextStyle(
                        fontSize: 13.5,
                        color: textGray,
                        fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const ForgotPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(
                        fontSize: 13.5,
                        color: primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitLogin,
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
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.6,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Sign in",
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
