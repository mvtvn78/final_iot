import 'package:flutter/material.dart';

// 1. MODEL: Cấu trúc dữ liệu cho thông báo
class NotificationItem {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final bool isUnread;
  final String category; // 'General' hoặc 'SmartHome'
  final String section; // 'Today' hoặc 'Yesterday' (để phân nhóm)

  NotificationItem({
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.isUnread,
    required this.category,
    required this.section,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  // Màu sắc chủ đạo
  final Color primaryBlue = const Color(0xFF3F63F3);
  final Color bgGray = const Color(0xFFF3F4F6);
  final Color textDark = const Color(0xFF1F2937);
  final Color textGray = const Color(0xFF9CA3AF);

  int _selectedTabIndex = 0; // 0: General, 1: Smart Home

  // Dữ liệu giả lập (Mock Data) giống trong ảnh
  final List<NotificationItem> _allNotifications = [
    // --- GENERAL TAB ---
    NotificationItem(
      title: "Account Security Alert 🔒",
      description:
          "We've noticed some unusual activity on your account. Please review your recent logins.",
      time: "09:41 AM",
      icon: Icons.shield_outlined,
      isUnread: true,
      category: "General",
      section: "Today",
    ),
    NotificationItem(
      title: "System Update Available 🔄",
      description:
          "A new system update is ready for installation. It includes performance improvements.",
      time: "08:46 AM",
      icon: Icons.info_outline,
      isUnread: true,
      category: "General",
      section: "Today",
    ),
    NotificationItem(
      title: "Password Reset Successful ✅",
      description:
          "Your password has been successfully reset. If you didn't request this change, contact support.",
      time: "20:30 PM",
      icon: Icons.lock_outline,
      isUnread: false,
      category: "General",
      section: "Yesterday",
    ),
    NotificationItem(
      title: "Exciting New Feature 🆕",
      description:
          "We've just launched a new feature that will enhance your user experience.",
      time: "16:29 PM",
      icon: Icons.star_outline,
      isUnread: false,
      category: "General",
      section: "Yesterday",
    ),

    // --- SMART HOME TAB (Dữ liệu ví dụ cho tab 2) ---
    NotificationItem(
      title: "Living Room Light On 💡",
      description: "The living room light has been turned on manually.",
      time: "10:00 AM",
      icon: Icons.lightbulb_outline,
      isUnread: true,
      category: "SmartHome",
      section: "Today",
    ),
    NotificationItem(
      title: "Motion Detected (CCTV) 📹",
      description: "Motion was detected in the backyard camera.",
      time: "02:15 AM",
      icon: Icons.videocam_outlined,
      isUnread: false,
      category: "SmartHome",
      section: "Yesterday",
    ),
  ];

  // Hàm lấy danh sách theo tab đang chọn
  List<NotificationItem> get _currentList {
    String currentCategory = _selectedTabIndex == 0 ? "General" : "SmartHome";
    return _allNotifications
        .where((item) => item.category == currentCategory)
        .toList();
  }

  // Hàm hiển thị Popup chi tiết
  void _showDetailPopup(NotificationItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(item.icon, color: primaryBlue),
            const SizedBox(width: 10),
            Expanded(
                child: Text(item.title, style: const TextStyle(fontSize: 18))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.description,
              style: TextStyle(color: textDark, height: 1.5),
            ),
            const SizedBox(height: 15),
            Text(
              "Time: ${item.time}",
              style: TextStyle(color: textGray, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close",
                style:
                    TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Nhóm dữ liệu theo Section (Today, Yesterday) để hiển thị
    final groupedNotifications = <String, List<NotificationItem>>{};
    for (var item in _currentList) {
      if (!groupedNotifications.containsKey(item.section)) {
        groupedNotifications[item.section] = [];
      }
      groupedNotifications[item.section]!.add(item);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: Text(
          "Notification",
          style: TextStyle(color: textDark, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: textDark),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // 1. CUSTOM TAB BAR
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              height: 50,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTabButton("General", 0),
                  _buildTabButton("Smart Home", 1),
                ],
              ),
            ),
          ),

          // 2. LIST VIEW
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: groupedNotifications.keys.length,
              itemBuilder: (context, index) {
                String section = groupedNotifications.keys.elementAt(index);
                List<NotificationItem> items = groupedNotifications[section]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Section (Today/Yesterday)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        section,
                        style: TextStyle(
                          color: textGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    // List Items trong section
                    ...items
                        .map((item) => _buildNotificationCard(item))
                        .toList(),
                    const SizedBox(height: 10),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Widget Button cho Tab
  Widget _buildTabButton(String title, int index) {
    bool isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: const Offset(0, 2))
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : textDark,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget Item Thông báo
  Widget _buildNotificationCard(NotificationItem item) {
    return InkWell(
      onTap: () => _showDetailPopup(item), // Sự kiện click hiện Popup
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon tròn bên trái
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
                color: Colors.white,
              ),
              child: Icon(item.icon, color: textDark, size: 24),
            ),
            const SizedBox(width: 16),

            // Nội dung ở giữa
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(
                      color: textDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style:
                        TextStyle(color: textGray, fontSize: 13, height: 1.4),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.time,
                    style: TextStyle(color: textGray, fontSize: 12),
                  ),
                ],
              ),
            ),

            // Dấu chấm xanh và mũi tên bên phải
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10), // Căn chỉnh cho đẹp
                if (item.isUnread)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                const SizedBox(height: 8),
                if (item
                    .isUnread) // Chỉ hiện mũi tên hoặc căn chỉnh theo ý muốn
                  const SizedBox(), // Spacer
                Icon(Icons.chevron_right, color: textGray, size: 20),
              ],
            )
          ],
        ),
      ),
    );
  }
}
