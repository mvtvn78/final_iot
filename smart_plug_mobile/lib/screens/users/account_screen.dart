import 'package:flutter/material.dart';
import 'package:esp32_ble_flutter/screens/auth/signin_screen.dart';
import 'package:esp32_ble_flutter/services/token_storage.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  // --- Màu sắc theo thiết kế ---
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF6B7280);
  static const Color redColor = Color(0xFFFA4D56); // Màu đỏ cho Logout
  static const Color bgLight = Color(0xFFF9FAFB);

  // --- Logic Đăng xuất (Giữ nguyên) ---
  Future<void> _signOut(BuildContext context) async {
    await TokenStorage.clear();

    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (route) => false,
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
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
                  Icons.logout_rounded,
                  color: primaryBlue,
                  size: 30,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                "Sign out?",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "You will be returned to the login screen.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  color: textGray,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textDark,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);
                          await _signOut(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Sign out",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UI Chính ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Avatar + Tên + Email
              Row(
                children: [
                  // Avatar hình tròn (Có thể thay bằng NetworkImage)
                  const CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?img=11'), // Ảnh demo
                    backgroundColor: bgLight,
                  ),
                  const SizedBox(width: 16),
                  // Tên và Email
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Thai Quang Minh",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "thaiminh0612@gmail.com",
                          style: TextStyle(
                            fontSize: 13,
                            color: textGray,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Nút mũi tên edit (nếu cần)
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.arrow_forward_ios_rounded,
                        size: 18, color: textDark),
                  )
                ],
              ),

              const SizedBox(height: 30),

              // --- Section: General ---
              _buildSectionTitle("General"),
              _buildListTile(
                icon: Icons.home_outlined,
                title: "Home Management",
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.mic_none_outlined,
                title: "Voice Assistants",
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.notifications_none_outlined,
                title: "Notifications",
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.verified_user_outlined,
                title: "Account & Security",
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.swap_vert_rounded,
                title: "Linked Accounts",
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.visibility_outlined, // Mắt
                title: "App Appearance",
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.settings_outlined,
                title: "Additional Settings",
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // --- Section: Support ---
              _buildSectionTitle("Support"),
              _buildListTile(
                icon: Icons.insights_outlined, // Hoặc Icons.show_chart
                title: "Data & Analytics",
                onTap: () {},
              ),
              _buildListTile(
                icon: Icons.description_outlined,
                title: "Help & Support",
                onTap: () {},
              ),

              const SizedBox(height: 20),

              // --- Logout Button (Màu đỏ) ---
              InkWell(
                onTap: () => _confirmSignOut(context),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: const [
                      Icon(Icons.logout_rounded, color: redColor, size: 26),
                      SizedBox(width: 16),
                      Text(
                        "Logout",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: redColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper Widget: Tiêu đề Section (General, Support...) ---
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16, // Nhỏ hơn tiêu đề chính một chút
          fontWeight: FontWeight.w600,
          color: textGray,
        ),
      ),
    );
  }

  // --- Helper Widget: Một dòng cài đặt (Icon - Title - Arrow) ---
  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(
          children: [
            // Icon bên trái
            Icon(icon, color: textDark, size: 26),
            const SizedBox(width: 16),
            // Text Title
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),
            // Mũi tên bên phải
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: textDark,
            ),
          ],
        ),
      ),
    );
  }
}
