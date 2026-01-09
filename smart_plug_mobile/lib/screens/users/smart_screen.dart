import 'package:flutter/material.dart';

class SmartScreen extends StatefulWidget {
  const SmartScreen({super.key});

  @override
  State<SmartScreen> createState() => _SmartScreenState();
}

class _SmartScreenState extends State<SmartScreen> {
  // --- Màu sắc theo thiết kế ---
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color bgLight = Color(0xFFF3F4F6); // Màu nền xám nhạt
  static const Color white = Colors.white;

  // 0: Automation, 1: Tap-to-Run
  int _selectedTabIndex = 0;

  // --- Fake Data Model ---
  // Class nội bộ để chứa dữ liệu demo
  List<SmartTask> automationData = [];
  List<SmartTask> tapToRunData = [];

  @override
  void initState() {
    super.initState();
    _initFakeData();
  }

  void _initFakeData() {
    // 1. Data cho tab Automation (Giống hình ảnh)
    automationData = [
      SmartTask(
        title: "Turn ON All the Lights",
        taskCount: "1 task",
        isOn: true,
        iconsBuilder: () => [
          _coloredIcon(Icons.access_time_filled, Colors.green),
          _arrowIcon(),
          _coloredIcon(Icons.wb_sunny_rounded, Colors.orange),
        ],
      ),
      SmartTask(
        title: "Go to Office",
        taskCount: "2 tasks",
        isOn: true,
        iconsBuilder: () => [
          _coloredIcon(Icons.location_on, Colors.redAccent),
          _coloredIcon(Icons.access_time_filled, Colors.green),
          _arrowIcon(),
          _coloredIcon(Icons.access_time_filled, Colors.grey),
          const SizedBox(width: 4),
          _coloredIcon(Icons.local_offer, Colors.blue),
        ],
      ),
      SmartTask(
        title: "Energy Saver Mode",
        taskCount: "2 tasks",
        isOn: false,
        iconsBuilder: () => [
          _coloredIcon(Icons.work, Colors.blueAccent),
          _arrowIcon(),
          _coloredIcon(Icons.verified_user, Colors.purple),
          const SizedBox(width: 4),
          _coloredIcon(Icons.notifications_active, Colors.redAccent),
        ],
      ),
      SmartTask(
        title: "Work Mode Activate",
        taskCount: "1 tasks",
        isOn: true,
        iconsBuilder: () => [
          _coloredIcon(Icons.touch_app, primaryBlue),
          _arrowIcon(),
          _coloredIcon(Icons.local_offer, Colors.grey),
        ],
      ),
    ];

    // 2. Data cho tab Tap-to-Run (Demo khác đi 1 chút)
    tapToRunData = [
      SmartTask(
        title: "Movie Night Mode",
        taskCount: "3 tasks",
        isOn:
            false, // Tap-to-run thường là nút Play, nhưng dùng switch để demo UI
        iconsBuilder: () => [
          _coloredIcon(Icons.movie, Colors.purple),
          _arrowIcon(),
          _coloredIcon(Icons.lightbulb, Colors.orange),
        ],
      ),
      SmartTask(
        title: "I'm Leaving Home",
        taskCount: "4 tasks",
        isOn: true,
        iconsBuilder: () => [
          _coloredIcon(Icons.directions_run, Colors.green),
          _arrowIcon(),
          _coloredIcon(Icons.lock, primaryBlue),
          const SizedBox(width: 4),
          _coloredIcon(Icons.power_settings_new, Colors.red),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight, // Nền xám nhạt toàn màn hình
      body: SafeArea(
        child: Column(
          children: [
            // --- 1. Header (My Home + Icons) ---
            _buildHeader(),

            // --- 2. Tab Switcher (Automation / Tap-to-Run) ---
            _buildTabSwitcher(),

            // --- 3. List Content ---
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _selectedTabIndex == 0
                    ? automationData.length
                    : tapToRunData.length,
                separatorBuilder: (ctx, index) => const SizedBox(height: 16),
                itemBuilder: (ctx, index) {
                  final item = _selectedTabIndex == 0
                      ? automationData[index]
                      : tapToRunData[index];
                  return _buildTaskCard(item, index);
                },
              ),
            ),
          ],
        ),
      ),

      // --- 4. Floating Action Button (Nút +) ---
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          onPressed: () {
            // Xử lý thêm Automation mới
          },
          backgroundColor: primaryBlue,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 32),
        ),
      ),
    );
  }

  // --- Widget: Header ---
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
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
          // Icon Document
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.description_outlined, color: textDark),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          // Icon Grid
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.grid_view_outlined, color: textDark),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  // --- Widget: Tab Switcher (Custom Segment Control) ---
  Widget _buildTabSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 48,
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem("Automation", 0),
          _buildTabItem("Tap-to-Run", 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? white : textDark,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget: Task Card (Item trong list) ---
  Widget _buildTaskCard(SmartTask item, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Title + Arrow icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: textDark,
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 14, color: textGray),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: Task count
          Text(
            item.taskCount,
            style: const TextStyle(fontSize: 12, color: textGray),
          ),
          const SizedBox(height: 12),

          // Row 3: Icons + Switch
          Row(
            children: [
              // Render list icon dynamic từ model
              ...item.iconsBuilder(),

              const Spacer(),

              // Switch Button
              Transform.scale(
                scale: 0.8, // Thu nhỏ switch một chút cho đẹp
                child: Switch(
                  value: item.isOn,
                  activeColor: white,
                  activeTrackColor: primaryBlue,
                  inactiveThumbColor: white,
                  inactiveTrackColor: Colors.grey.shade300,
                  trackOutlineColor:
                      MaterialStateProperty.all(Colors.transparent),
                  onChanged: (val) {
                    setState(() {
                      item.isOn = val;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Helpers cho Icons ---
  Widget _coloredIcon(IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      child: Icon(icon, size: 18, color: color),
    );
  }

  Widget _arrowIcon() {
    return const Padding(
      padding: EdgeInsets.only(right: 6),
      child: Icon(Icons.arrow_forward, size: 16, color: Color(0xFF9CA3AF)),
    );
  }
}

// --- Class Model cho Data ---
class SmartTask {
  String title;
  String taskCount;
  bool isOn;
  List<Widget> Function() iconsBuilder; // Hàm trả về list icon để render UI

  SmartTask({
    required this.title,
    required this.taskCount,
    required this.isOn,
    required this.iconsBuilder,
  });
}
