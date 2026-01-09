import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  // --- Màu sắc theo thiết kế ---
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color darkBlue =
      Color(0xFF2E4ECC); // Màu đậm hơn cho cột selected
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color bgLight = Color(0xFFF3F4F6);
  static const Color white = Colors.white;
  static const Color orangeColor = Color(0xFFFF9800);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- 1. Header ---
              _buildHeader(),
              const SizedBox(height: 24),

              // --- 2. Energy Summary Cards ---
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.bolt_rounded,
                      iconColor: Colors.white,
                      iconBgColor: orangeColor,
                      label: "This month",
                      kwh: "825.40",
                      cost: "\$123.81",
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      icon: Icons.power_rounded,
                      iconColor: Colors.white,
                      iconBgColor: primaryBlue,
                      label: "Previous month",
                      kwh: "958.75",
                      cost: "\$143.81",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // --- 3. Statistics (Chart) ---
              _buildStatisticsSection(),
              const SizedBox(height: 24),

              // --- 4. Devices Grid ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Devices",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  const Icon(Icons.more_vert, color: textGray),
                ],
              ),
              const SizedBox(height: 16),
              _buildDevicesGrid(),
            ],
          ),
        ),
      ),
    );
  }

  // --- Widget: Header ---
  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          "My Home",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.keyboard_arrow_down, color: textDark),
        const Spacer(),
        // Icon Calendar
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.calendar_today_outlined,
              size: 20, color: textDark),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.more_vert, color: textDark),
      ],
    );
  }

  // --- Widget: Energy Summary Card ---
  Widget _buildSummaryCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String label,
    required String kwh,
    required String cost,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: textGray)),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: kwh,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textDark,
                  ),
                ),
                const TextSpan(
                  text: " kWh",
                  style: TextStyle(fontSize: 12, color: textGray),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            cost,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: textGray,
            ),
          ),
        ],
      ),
    );
  }

  // --- Widget: Statistics Chart (Custom Bar Chart) ---
  Widget _buildStatisticsSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Header Chart
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Statistics",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: const [
                    Text(
                      "Last 6 Months",
                      style: TextStyle(fontSize: 12, color: textDark),
                    ),
                    SizedBox(width: 4),
                    Icon(Icons.keyboard_arrow_down, size: 16, color: textGray),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30), // Khoảng trống cho tooltip

          // Bar Chart Row
          SizedBox(
            height: 180,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBar("Jul", 0.6, false),
                _buildBar("Aug", 0.5, false),
                _buildBar("Sept", 0.8, false),
                _buildBar("Oct", 0.55, true, value: "785.40 kWh"), // Selected
                _buildBar("Nov", 0.9, false),
                _buildBar("Dec", 0.45, false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(String month, double heightPct, bool isSelected,
      {String? value}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Tooltip (Chỉ hiện khi selected)
        if (isSelected && value != null) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value.split(' ')[0], // Lấy số
              style: const TextStyle(
                  color: white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
          CustomPaint(
            size: const Size(10, 6),
            painter: TrianglePainter(color: primaryBlue),
          ),
          const SizedBox(height: 4),
        ],

        // Thanh Bar
        Container(
          width: 30, // Độ rộng cột
          height: 120 * heightPct, // Chiều cao
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : const Color(0xFF819BFF),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          month,
          style: const TextStyle(fontSize: 12, color: textGray),
        ),
      ],
    );
  }

  // --- Widget: Devices Grid ---
  Widget _buildDevicesGrid() {
    // Fake Data
    final devices = [
      {
        "name": "Smart Lamp",
        "kwh": "184.69",
        "cost": "\$27.70",
        "count": "12 devices",
        // Bạn có thể đổi icon/màu sắc ở đây nếu muốn
      },
      {
        "name": "Smart VI CCTV",
        "kwh": "125.73",
        "cost": "\$18.86",
        "count": "3 devices",
      },
      {
        "name": "Smart Router",
        "kwh": "106.45",
        "cost": "\$15.97",
        "count": "1 device",
      },
      {
        "name": "Air Purifier",
        "kwh": "98.24",
        "cost": "\$14.74",
        "count": "2 devices",
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(), // Scroll theo trang chính
      shrinkWrap: true,
      itemCount: devices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85, // Tỷ lệ khung hình thẻ
      ),
      itemBuilder: (context, index) {
        final device = devices[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Image & Kwh
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- IMAGE TỪ ASSETS ---
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      "assets/icons/iot_devices.jpg",
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        device["kwh"]! + " kWh",
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: textDark),
                      ),
                      Text(
                        device["cost"]!,
                        style: const TextStyle(fontSize: 11, color: textGray),
                      ),
                    ],
                  )
                ],
              ),
              const Spacer(),

              // Device Name
              Text(
                device["name"]!,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 4),

              // Count & Arrow
              Row(
                children: [
                  Text(
                    device["count"]!,
                    style: const TextStyle(fontSize: 11, color: textGray),
                  ),
                  const Spacer(),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: textGray),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// --- Helper: Vẽ tam giác nhỏ cho tooltip ---
class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()..color = color;
    var path = Path();
    path.lineTo(-5, -5);
    path.lineTo(size.width / 2, size.height);
    path.lineTo(size.width, 0);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
