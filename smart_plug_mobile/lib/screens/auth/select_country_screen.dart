import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:esp32_ble_flutter/screens/auth/add_home_name_screen.dart';

class SelectCountryScreen extends StatefulWidget {
  @override
  State<SelectCountryScreen> createState() => _SelectCountryScreenState();
}

class _SelectCountryScreenState extends State<SelectCountryScreen> {
  // Màu sắc lấy từ thiết kế
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color lightBlueBg = Color(0xFFEEF2FF); // Màu nền cho nút Skip
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color borderLight = Color(0xFFF3F4F6);

  final TextEditingController _searchCtrl = TextEditingController();

  final List<_Country> _all = const [
    _Country("🇻🇳", "Vietnam"),
    _Country("🇺🇸", "United States"),
    _Country("🇬🇧", "United Kingdom"),
    _Country("🇨🇦", "Canada"),
    _Country("🇦🇺", "Australia"),
    _Country("🇯🇵", "Japan"),
    _Country("🇰🇷", "South Korea"),
    _Country("🇨🇳", "China"),
    _Country("🇩🇪", "Germany"),
    _Country("🇫🇷", "France"),
    _Country("🇮🇳", "India"),
    _Country("🇷🇺", "Russia"),
    _Country("🇧🇷", "Brazil"),
    _Country("🇮🇹", "Italy"),
    // ... bạn có thể thêm các nước khác
  ];

  String? _selectedName;
  List<_Country> _filtered = const [];

  @override
  void initState() {
    super.initState();
    _filtered = _all;
    _searchCtrl.addListener(_applySearch);
  }

  void _applySearch() {
    final q = _searchCtrl.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((c) => c.name.toLowerCase().contains(q)).toList();
    });
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applySearch);
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Nếu chưa chọn thì nút Continue sẽ bị disable
    final canContinue = _selectedName != null;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Top Navigation Row ---
              Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon:
                        const Icon(Icons.arrow_back, size: 24, color: textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 16),
                  // Progress Bar
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: 0.25, // 1/4
                        minHeight: 8,
                        backgroundColor: const Color(0xFFF3F4F6),
                        valueColor: const AlwaysStoppedAnimation(primaryBlue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "1 / 4",
                    style: TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- Title (RichText để tô màu xanh chữ Country) ---
              RichText(
                text: const TextSpan(
                  text: "Select ",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                    height: 1.2,
                    fontFamily: 'Arial', // Hoặc font mặc định của App
                  ),
                  children: [
                    TextSpan(
                      text: "Country",
                      style: TextStyle(color: primaryBlue),
                    ),
                    TextSpan(text: " of Origin"),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Let's start by selecting the country where your\nsmart haven resides.",
                style: TextStyle(
                  color: textGray,
                  fontSize: 14,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 24),

              // --- Search Bar ---
              TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: textDark),
                decoration: InputDecoration(
                  hintText: "Search Country...",
                  hintStyle:
                      const TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                  prefixIcon: const Icon(Icons.search,
                      size: 22, color: Color(0xFF9CA3AF)),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB), // Màu nền rất nhạt
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
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
                    borderSide: const BorderSide(color: primaryBlue, width: 1),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // --- Country List ---
              Expanded(
                child: ListView.separated(
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) {
                    final c = _filtered[i];
                    final selected = c.name == _selectedName;

                    return InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () => setState(() => _selectedName = c.name),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected ? primaryBlue : borderLight,
                            width: selected ? 1.5 : 1,
                          ),
                          // Hiệu ứng đổ bóng nhẹ giống card
                          boxShadow: [
                            if (!selected)
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Cờ (Emoji hoặc Image)
                            Container(
                              width: 40,
                              height: 28,
                              alignment: Alignment.center,
                              // Nếu bạn muốn dùng ảnh chữ nhật như design thì thay Text bằng Image.asset
                              // Ở đây mình dùng Text emoji phóng to để giả lập
                              child: Text(
                                c.flag,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                c.name,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: textDark,
                                ),
                              ),
                            ),
                            // Nếu muốn icon check thì bỏ comment dòng dưới
                            // if (selected) const Icon(Icons.check_circle, color: primaryBlue, size: 20),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // --- Bottom Buttons ---
              Row(
                children: [
                  // Skip Button
                  Expanded(
                    child: SizedBox(
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: lightBlueBg, // Màu xanh rất nhạt
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          "Skip",
                          style: TextStyle(
                            color: primaryBlue, // Chữ màu xanh đậm
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
                        onPressed: canContinue
                            ? () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Selected: $_selectedName")),
                                );
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const AddHomeNameScreen(),
                                  ),
                                );
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
}

class _Country {
  final String flag;
  final String name;
  const _Country(this.flag, this.name);
}
