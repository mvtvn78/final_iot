import 'dart:async';
import 'package:flutter/material.dart';

// --- IMPORT CÁC MÀN HÌNH KHÁC ---
import "package:esp32_ble_flutter/screens/devices/scan_connect_screen.dart";
import "package:esp32_ble_flutter/screens/home/home_screen.dart";

// 1. MODEL
class DeviceModel {
  final String id;
  final String name;
  final IconData icon; // Dùng cho radar (nếu ko có ảnh)
  final Offset position; // Dùng cho radar
  final String imageUrl; // URL mạng hoặc Asset local

  DeviceModel(this.id, this.name, this.icon, this.position,
      {this.imageUrl = ""});
}

// 2. MÀN HÌNH BÁO THÀNH CÔNG (Success Screen)
class DeviceSuccessScreen extends StatelessWidget {
  final DeviceModel device;

  const DeviceSuccessScreen({super.key, required this.device});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Icon Checkmark xanh
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF3F63F3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 24),
              const Text(
                "Connected!",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937)),
              ),
              const SizedBox(height: 12),
              Text(
                "You have connected to ${device.name}.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 40),

              // Ảnh thiết bị (Xử lý Assets vs Network)
              SizedBox(
                height: 200,
                child: device.imageUrl.isNotEmpty
                    ? (device.imageUrl.startsWith('http')
                        ? Image.network(device.imageUrl, fit: BoxFit.contain)
                        : Image.asset(device.imageUrl, fit: BoxFit.contain))
                    : Icon(device.icon, size: 150, color: Colors.grey.shade300),
              ),

              const Spacer(),

              // Cụm 2 nút bấm dưới cùng
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFEFF4FF), // Nền xanh nhạt
                        foregroundColor:
                            const Color(0xFF3F63F3), // Chữ xanh đậm
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text("Go to Homepage",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Logic chuyển sang màn hình điều khiển (nếu cần)
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF3F63F3), // Nền xanh đậm
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                      ),
                      child: const Text("Control Device",
                          style: TextStyle(fontWeight: FontWeight.bold)),
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

// 3. MÀN HÌNH ĐANG KẾT NỐI (Loading Screen)
class DeviceConnectScreen extends StatefulWidget {
  final DeviceModel device;

  const DeviceConnectScreen({super.key, required this.device});

  @override
  State<DeviceConnectScreen> createState() => _DeviceConnectScreenState();
}

class _DeviceConnectScreenState extends State<DeviceConnectScreen> {
  int _progress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startSimulation();
  }

  void _startSimulation() {
    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        _progress += 1;
      });

      if (_progress >= 100) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      DeviceSuccessScreen(device: widget.device)),
            );
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Add Device",
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.crop_free), onPressed: () {}),
        ],
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Connect to device",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937)),
            ),
            const SizedBox(height: 16),

            // Pill trạng thái Wifi/Bluetooth
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.wifi, size: 16, color: Color(0xFF3F63F3)),
                  SizedBox(width: 8),
                  Icon(Icons.bluetooth, size: 16, color: Color(0xFF3F63F3)),
                  SizedBox(width: 8),
                  Text(
                    "Turn on your Wifi & Bluetooth to connect",
                    style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Tên thiết bị
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    color: Color(0xFF3F63F3), size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.device.name,
                  style:
                      const TextStyle(fontSize: 16, color: Color(0xFF4B5563)),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Vòng tròn Loading + Ảnh
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 280,
                  height: 280,
                  child: CircularProgressIndicator(
                    value: _progress / 100,
                    strokeWidth: 8,
                    backgroundColor: const Color(0xFFF3F4F6),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF3F63F3)),
                  ),
                ),
                SizedBox(
                  width: 180,
                  height: 180,
                  child: widget.device.imageUrl.isNotEmpty
                      ? (widget.device.imageUrl.startsWith('http')
                          ? Image.network(widget.device.imageUrl,
                              fit: BoxFit.contain)
                          : Image.asset(widget.device.imageUrl,
                              fit: BoxFit.contain))
                      : Icon(widget.device.icon, size: 100, color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(height: 30),
            const Text("Connecting...",
                style: TextStyle(color: Color(0xFF6B7280))),
            const SizedBox(height: 8),
            Text(
              "$_progress%",
              style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3F63F3)),
            ),

            const Spacer(),

            const Text("Can't connect with your devices?",
                style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 13)),
            TextButton(
              onPressed: () {},
              child: const Text("Learn more",
                  style: TextStyle(
                      color: Color(0xFF3F63F3), fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// 4. MÀN HÌNH CHÍNH (ADD DEVICE - TAB SCAN & MANUAL)
class AddDeviceScreen extends StatefulWidget {
  const AddDeviceScreen({super.key});

  @override
  State<AddDeviceScreen> createState() => _AddDeviceScreenState();
}

class _AddDeviceScreenState extends State<AddDeviceScreen>
    with SingleTickerProviderStateMixin {
  // Màu sắc chuẩn
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color textDark = Color(0xFF1D2445);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color bgContainer = Color(0xFFF3F4F6);

  late TabController _tabController;

  // Tabs Filter cho Manual Add
  int _selectedManualFilter = 0; // 0: Popular, 1: Lighting, 2: Camera...

  // Danh sách thiết bị cho Radar (Nearby)
  final List<DeviceModel> nearbyDevices = [
    DeviceModel(
        "1", "Smart Bulb", Icons.lightbulb_outline, const Offset(-0.6, -0.6),
        imageUrl: "assets/images/device4.jpg"),
    DeviceModel(
        "2", "Smart V1 CCTV", Icons.videocam_outlined, const Offset(0.7, -0.3),
        imageUrl: "assets/images/device1.jpg"),
    DeviceModel("3", "Router", Icons.router, const Offset(0.5, 0.6),
        imageUrl: "assets/images/device3.jpg"),
    DeviceModel("4", "Speaker", Icons.speaker, const Offset(-0.5, 0.4),
        imageUrl: "assets/images/device2.jpg"),
  ];

  // Danh sách thiết bị cho Manual Add (Grid)
  final List<DeviceModel> manualDevices = [
    DeviceModel("m1", "Smart V1 CCTV", Icons.videocam, const Offset(0, 0),
        imageUrl: "assets/images/device1.jpg"),
    DeviceModel("m2", "Smart Webcam", Icons.camera_indoor, const Offset(0, 0),
        imageUrl: "assets/images/device2.jpg"),
    DeviceModel("m3", "Smart V2 CCTV", Icons.videocam_off, const Offset(0, 0),
        imageUrl: "assets/images/device3.jpg"),
    DeviceModel("m4", "Smart Lamp", Icons.lightbulb, const Offset(0, 0),
        imageUrl: "assets/images/device4.jpg"),
    DeviceModel("m5", "Stereo Speaker", Icons.speaker, const Offset(0, 0),
        imageUrl: "assets/images/device2.jpg"),
    DeviceModel("m6", "Router", Icons.router, const Offset(0, 0),
        imageUrl: "assets/images/device3.jpg"),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi bấm vào thiết bị (chung cho cả 2 tab)
  void _onDeviceTap(DeviceModel device) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeviceConnectScreen(device: device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: textDark,
        centerTitle: true,
        title: const Text(
          "Add Device",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ScanQrConnectScreen()));
            },
          ),
        ],
        // --- PHẦN TABBAR (SIDEBAR) ---
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.all(4),
            height: 50,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white)), // Không viền xám
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    )
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: textDark,
                labelStyle:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                tabs: const [
                  Tab(text: "Nearby Devices"),
                  Tab(text: "Add Manual"),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRadarTab(),
          _buildManualTab(), // <-- Tab Manual đã chỉnh nền trắng
        ],
      ),
    );
  }

  // --- TAB 1: RADAR SCAN (Giữ nguyên logic cũ) ---
  Widget _buildRadarTab() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          "Looking for nearby devices...",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: textDark),
        ),
        const SizedBox(height: 12),

        // Trạng thái Wifi/Bluetooth
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: bgContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.wifi, size: 14, color: primaryBlue),
              SizedBox(width: 4),
              Icon(Icons.bluetooth, size: 14, color: primaryBlue),
              SizedBox(width: 8),
              Text(
                "Turn on your Wifi & Bluetooth to connect",
                style: TextStyle(fontSize: 12, color: textGray),
              ),
            ],
          ),
        ),

        // --- RADAR ---
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double size = constraints.maxWidth < constraints.maxHeight
                  ? constraints.maxWidth * 0.9
                  : constraints.maxHeight * 0.9;

              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildRing(size * 0.9),
                  _buildRing(size * 0.6),
                  _buildRing(size * 0.3),

                  // Avatar
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.network(
                        "https://i.pravatar.cc/300?img=12",
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stack) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 40)),
                      ),
                    ),
                  ),

                  // Các thiết bị bay xung quanh
                  ...nearbyDevices.map((device) {
                    return Align(
                      alignment:
                          Alignment(device.position.dx, device.position.dy),
                      child: GestureDetector(
                        onTap: () => _onDeviceTap(device),
                        child: _buildDeviceIcon(device),
                      ),
                    );
                  }).toList(),
                ],
              );
            },
          ),
        ),

        // --- BOTTOM SECTION ---
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 65),
          child: Column(
            children: [
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)),
                    elevation: 2,
                    shadowColor: primaryBlue.withOpacity(0.3),
                  ),
                  child: const Text(
                    "Connect to All Devices",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Can't find your devices?",
                  style: TextStyle(color: textGray, fontSize: 13)),
              const SizedBox(height: 4),
              InkWell(
                onTap: () {},
                child: const Text(
                  "Learn more",
                  style: TextStyle(
                      color: primaryBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 13),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  // --- TAB 2: MANUAL ADD (GRID UI GIỐNG ẢNH) ---
  Widget _buildManualTab() {
    return Column(
      children: [
        // Filter Buttons (Popular, Lightning, Camera...)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              _buildFilterChip("Popular", 0),
              const SizedBox(width: 10),
              _buildFilterChip("Lightning", 1),
              const SizedBox(width: 10),
              _buildFilterChip("Camera", 2),
              const SizedBox(width: 10),
              _buildFilterChip("Electrical", 3),
            ],
          ),
        ),

        // Device Grid (Chỉnh nền trắng cho Card)
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 Cột
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85, // Tỉ lệ khung hình
            ),
            itemCount: manualDevices.length,
            itemBuilder: (context, index) {
              final device = manualDevices[index];
              return _buildManualDeviceCard(device);
            },
          ),
        ),
      ],
    );
  }

  // Widget: Filter Chip (Nút lọc trên cùng)
  Widget _buildFilterChip(String label, int index) {
    bool isSelected = _selectedManualFilter == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedManualFilter = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? primaryBlue : Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textDark,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // Widget: Card thiết bị trong tab Manual (NỀN TRẮNG)
  Widget _buildManualDeviceCard(DeviceModel device) {
    return GestureDetector(
      onTap: () => _onDeviceTap(device),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Nền trắng chuẩn
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04), // Đổ bóng nhẹ
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ảnh thiết bị
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Image.asset(
                  device.imageUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) =>
                      Icon(device.icon, size: 60, color: Colors.grey),
                ),
              ),
            ),
            // Tên thiết bị
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0, left: 8, right: 8),
              child: Text(
                device.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widgets (Radar Ring, Device Icon...)
  Widget _buildRing(double diameter) {
    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: primaryBlue.withOpacity(0.3),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildDeviceIcon(DeviceModel device) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          padding: const EdgeInsets.all(8), // Padding để ảnh không sát viền
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          // Hiển thị ảnh thay vì Icon nếu có
          child: ClipOval(
            child: Image.asset(device.imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (c, e, s) =>
                    Icon(device.icon, color: textDark, size: 24)),
          ),
        ),
      ],
    );
  }
}
