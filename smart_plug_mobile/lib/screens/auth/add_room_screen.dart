import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import để lưu dữ liệu
import 'package:esp32_ble_flutter/screens/auth/set_home_location_screen.dart';

class AddRoomsScreen extends StatefulWidget {
  const AddRoomsScreen({super.key});

  @override
  State<AddRoomsScreen> createState() => _AddRoomsScreenState();
}

class _AddRoomsScreenState extends State<AddRoomsScreen> {
  // --- Màu sắc thống nhất ---
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color lightBlueBg = Color(0xFFEEF2FF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color cardBg = Color(0xFFF9FAFB);

  // Danh sách các phòng mẫu (Mặc định chưa chọn cái nào)
  final List<_RoomItem> _rooms = [
    _RoomItem("Living Room", Icons.weekend_outlined, isSelected: false),
    _RoomItem("Bedroom", Icons.bed_outlined, isSelected: false),
    _RoomItem("Bathroom", Icons.bathtub_outlined, isSelected: false),
    _RoomItem("Kitchen", Icons.room_service_outlined, isSelected: false),
    _RoomItem("Study Room", Icons.school_outlined, isSelected: false),
    _RoomItem("Dining Room", Icons.restaurant_outlined, isSelected: false),
    _RoomItem("Backyard", Icons.park_outlined, isSelected: false),
    _RoomItem("Garage", Icons.garage_outlined, isSelected: false),
  ];

  bool _isSaving = false;

  // --- HÀM LƯU DỮ LIỆU VÀ CHUYỂN TRANG ---
  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);

    try {
      // 1. Lọc ra danh sách tên các phòng đã chọn
      List<String> selectedRoomNames = _rooms
          .where((room) => room.isSelected)
          .map((room) => room.name)
          .toList();

      // 2. Lưu vào SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('user_rooms', selectedRoomNames);

      debugPrint("Đã lưu các phòng: $selectedRoomNames");

      if (!mounted) return;

      // 3. Chuyển sang màn hình tiếp theo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const SetHomeLocationScreen(),
        ),
      );
    } catch (e) {
      debugPrint("Lỗi lưu phòng: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // Hàm xử lý nút Skip (Lưu danh sách rỗng hoặc mặc định)
  Future<void> _handleSkip() async {
    // Tùy logic, ở đây mình không lưu gì cả, hoặc lưu mặc định Living Room
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SetHomeLocationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Kiểm tra xem có ít nhất 1 phòng được chọn không
    final bool canContinue = _rooms.any((r) => r.isSelected);

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
                children: [
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

                  // Progress Bar (75% - 3/4)
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
                          widthFactor: 0.75, // 3/4 = 75%
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
                  const Text(
                    "3 / 4",
                    style: TextStyle(
                      color: textDark,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // --- 2. TITLE ---
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
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
                        text: "Rooms",
                        style: TextStyle(color: primaryBlue),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  "Select the rooms in your house. Don't worry,\nyou can always add more later.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textGray,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- 3. GRID ROOMS ---
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: _rooms.length + 1, // +1 cho nút "Add Room"
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cột
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.4, // Tỷ lệ chiều rộng/cao
                  ),
                  itemBuilder: (context, index) {
                    // Item cuối cùng là nút "Add Room"
                    if (index == _rooms.length) {
                      return _buildAddRoomCard();
                    }

                    // Các item phòng
                    final room = _rooms[index];
                    return _buildRoomCard(room);
                  },
                ),
              ),

              // --- 4. BOTTOM BUTTONS ---
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _handleSkip,
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
                    Expanded(
                      child: SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: canContinue && !_isSaving
                              ? _saveAndContinue
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            disabledBackgroundColor:
                                primaryBlue.withOpacity(0.5),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
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
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị thẻ Phòng
  Widget _buildRoomCard(_RoomItem room) {
    return InkWell(
      onTap: () {
        setState(() {
          room.isSelected = !room.isSelected;
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: room.isSelected
              ? primaryBlue.withOpacity(0.05)
              : cardBg, // Đổi màu nền nhẹ khi chọn
          borderRadius: BorderRadius.circular(16),
          border: room.isSelected
              ? Border.all(color: primaryBlue, width: 1.5)
              : Border.all(color: Colors.transparent),
        ),
        child: Stack(
          children: [
            // Nội dung chính giữa
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    room.icon,
                    size: 32,
                    color: room.isSelected ? primaryBlue : textGray,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    room.name,
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w600,
                      color: room.isSelected ? primaryBlue : textDark,
                    ),
                  ),
                ],
              ),
            ),

            // Checkmark ở góc phải trên
            if (room.isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: primaryBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Widget hiển thị nút Add Room (Item cuối cùng)
  Widget _buildAddRoomCard() {
    return InkWell(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Tính năng thêm phòng tùy chỉnh")),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.transparent),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.add_circle_outline_rounded,
              size: 32,
              color: primaryBlue,
            ),
            SizedBox(height: 10),
            Text(
              "Add Room",
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Model đơn giản cho Room
class _RoomItem {
  final String name;
  final IconData icon;
  bool isSelected;

  _RoomItem(this.name, this.icon, {this.isSelected = false});
}
