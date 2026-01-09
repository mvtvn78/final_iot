import 'dart:async';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import thư viện lưu trữ

// --- CÁC IMPORT MÀN HÌNH KHÁC ---
import 'package:esp32_ble_flutter/screens/devices/add_device_screen.dart';
import 'package:esp32_ble_flutter/screens/details/device_detail_screen.dart';
import 'package:esp32_ble_flutter/screens/notifications/notification_screen.dart';
import 'package:esp32_ble_flutter/screens/chat/chat_screen.dart';
import 'package:esp32_ble_flutter/screens/users/account_screen.dart';
import 'package:esp32_ble_flutter/screens/users/smart_screen.dart';
import 'package:esp32_ble_flutter/screens/users/report_screen.dart';

// --- CÁC IMPORT SERVICE ---
import 'package:esp32_ble_flutter/services/api.dart';
import 'package:esp32_ble_flutter/services/devices/device_api.dart';
import 'package:esp32_ble_flutter/services/token_storage.dart';
import 'package:esp32_ble_flutter/services/iot_ws_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- COLOR PALETTE ---
  static const Color primaryBlue = Color(0xFF4A6EF5);
  static const Color textDark = Color(0xFF1D2445);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color bgLight = Color(0xFFF6F8FB);

  // Category Colors
  static const Color yellowBg = Color(0xFFFFF7E3);
  static const Color yellowIcon = Color(0xFFF6A726);
  static const Color purpleBg = Color(0xFFF3E8FF);
  static const Color purpleIcon = Color(0xFFA855F7);
  static const Color redBg = Color(0xFFFFEBEB);
  static const Color redIcon = Color(0xFFE95E5E);

  // Bottom Nav Index
  int _navIndex = 0;

  // Tab Index (0: All, 1: Living, 2: Bedroom)
  int _selectedRoomIndex = 0;

  // --- API & Logic Variables ---
  late final Dio _dio;
  late final DeviceApi _deviceApi;

  bool _loadingDevices = true;
  String? _deviceErr;
  List<Map<String, dynamic>> _devices = [];

  final Map<int, bool> _switchState = {};
  final Set<int> _switchBusy = {};

  // ===== WS Realtime =====
  final Map<int, IotWsMessage> _live = {};
  final Map<int, IotWsService> _wsByDevice = {};
  final Map<int, StreamSubscription<IotWsMessage>> _wsSubs = {};
  String? _token;

  late final String _wsBase;

  // ===== WEATHER & ADDRESS =====
  String _homeAddress = "Ho Chi Minh City, Viet Nam";
  double _temp = 20.0;
  String _weatherDesc = "Cloudy";
  bool _isLoadingWeather = false;

  // ===== MOCK DATA STATE (Dữ liệu giả lập cho Living Room/Bedroom) =====
  // device4.jpg = Lamp (Bóng đèn)
  // device1.jpg = CCTV (Camera)
  // device2.jpg = Speaker / AC (Loa/Điều hoà)
  // device3.jpg = Router

  final List<Map<String, dynamic>> _livingRoomDevices = [
    {
      "name": "Smart Lamp",
      "img": "assets/images/device4.jpg",
      "isOn": true,
      "type": "lamp"
    },
    {
      "name": "Smart V1 CCTV",
      "img": "assets/images/device1.jpg",
      "isOn": true,
      "type": "cctv"
    },
    {
      "name": "Stereo Speaker",
      "img": "assets/images/device2.jpg",
      "isOn": true,
      "type": "speaker"
    },
    {
      "name": "Router",
      "img": "assets/images/device3.jpg",
      "isOn": true,
      "type": "router"
    },
    {
      "name": "Air Conditioner",
      "img": "assets/images/device2.jpg",
      "isOn": true,
      "type": "ac"
    },
    {
      "name": "Smart Webcam",
      "img": "assets/images/device1.jpg",
      "isOn": false,
      "type": "cctv"
    },
  ];

  final List<Map<String, dynamic>> _bedroomDevices = [
    {
      "name": "Bed Lamp",
      "img": "assets/images/device4.jpg",
      "isOn": false,
      "type": "lamp"
    },
    {
      "name": "Baby Monitor",
      "img": "assets/images/device1.jpg",
      "isOn": false,
      "type": "cctv"
    },
    {
      "name": "Air Conditioner",
      "img": "assets/images/device2.jpg",
      "isOn": false,
      "type": "ac"
    },
    {
      "name": "Smart V3 CCTV",
      "img": "assets/images/device1.jpg",
      "isOn": false,
      "type": "cctv"
    },
  ];

  @override
  void initState() {
    super.initState();

    _dio = Api.dio;
    _deviceApi = DeviceApi(_dio);

    _wsBase = Api.baseUrl
        .replaceFirst("https://", "wss://")
        .replaceFirst("http://", "ws://");

    _bootstrap();
  }

  Future<void> _bootstrap() async {
    _token = await TokenStorage.read();
    await _loadSavedAddress();
    _fetchWeather();
    await _loadDevices();
    _connectWsForDevices();
  }

  // --- Logic Địa chỉ & Thời tiết ---
  Future<void> _loadSavedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddr = prefs.getString('user_home_address');
      if (savedAddr != null && savedAddr.isNotEmpty) {
        if (!mounted) return;
        setState(() => _homeAddress = savedAddr);
      }
    } catch (e) {
      debugPrint("Lỗi đọc địa chỉ: $e");
    }
  }

  Future<void> _fetchWeather() async {
    if (!mounted) return;
    setState(() => _isLoadingWeather = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble('home_lat') ?? 10.7828;
      final long = prefs.getDouble('home_long') ?? 106.6959;

      final url =
          "https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current_weather=true";
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data['current_weather'];
        final temp = data['temperature'];
        final code = data['weathercode'];

        if (!mounted) return;
        setState(() {
          _temp = (temp as num).toDouble();
          _weatherDesc = _getWeatherString(code);
        });
      }
    } catch (e) {
      debugPrint("Lỗi lấy thời tiết: $e");
    } finally {
      if (mounted) setState(() => _isLoadingWeather = false);
    }
  }

  String _getWeatherString(int code) {
    if (code == 0) return "Clear Sky";
    if (code == 1 || code == 2 || code == 3) return "Cloudy";
    if (code >= 45 && code <= 48) return "Foggy";
    if (code >= 51 && code <= 67) return "Rainy";
    if (code >= 80 && code <= 82) return "Showers";
    if (code >= 95) return "Thunderstorm";
    return "Unknown";
  }

  // --- Logic Devices & WS (Thiết bị thật) ---
  Future<void> _loadDevices() async {
    setState(() {
      _loadingDevices = true;
      _deviceErr = null;
    });

    try {
      final list = await _deviceApi.getDevices();
      if (!mounted) return;

      setState(() {
        _devices = list;
        for (final d in _devices) {
          final id = (d['id'] as num?)?.toInt();
          if (id != null) _switchState.putIfAbsent(id, () => false);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _deviceErr = e.toString());
    } finally {
      if (!mounted) return;
      setState(() => _loadingDevices = false);
    }
  }

  void _connectWsForDevices() {
    final token = _token;
    if (token == null || token.isEmpty) return;
    if (_devices.isEmpty) return;

    final currentIds = _devices
        .map((d) => (d["id"] as num?)?.toInt())
        .whereType<int>()
        .toSet();
    final toRemove =
        _wsByDevice.keys.where((id) => !currentIds.contains(id)).toList();

    for (final id in toRemove) {
      _wsSubs[id]?.cancel();
      _wsSubs.remove(id);
      _wsByDevice[id]?.dispose();
      _wsByDevice.remove(id);
      _live.remove(id);
    }

    for (final id in currentIds) {
      if (_wsByDevice.containsKey(id)) continue;
      final svc = IotWsService(wsBase: _wsBase);
      _wsByDevice[id] = svc;
      _wsSubs[id] = svc.stream.listen((msg) {
        if (!mounted) return;
        setState(() {
          _live[id] = msg;
          if (msg.stateRelay != null) _switchState[id] = msg.stateRelay!;
        });
      });
      svc.connect(deviceId: id, token: token);
    }
  }

  Future<void> _toggleDevice(int deviceId, bool value) async {
    if (_switchBusy.contains(deviceId)) return;
    setState(() {
      _switchBusy.add(deviceId);
      _switchState[deviceId] = value;
    });

    try {
      await _deviceApi.controlDevice(
          deviceId: deviceId, payload: value ? "1" : "0");
    } catch (e) {
      if (!mounted) return;
      setState(() => _switchState[deviceId] = !value);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Control failed: $e")));
    } finally {
      if (!mounted) return;
      setState(() => _switchBusy.remove(deviceId));
    }
  }

  // --- Logic Toggle cho Mock Device (Living/Bedroom) ---
  void _toggleMockDevice(List<Map<String, dynamic>> list, int index, bool val) {
    setState(() {
      list[index]['isOn'] = val;
    });
  }

  @override
  void dispose() {
    for (final sub in _wsSubs.values) sub.cancel();
    for (final ws in _wsByDevice.values) ws.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHomeContent(),
      const SmartScreen(),
      const ReportsScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      backgroundColor: bgLight,
      body: pages[_navIndex],
      floatingActionButton: _navIndex == 0
          ? Padding(
              padding: const EdgeInsets.only(bottom: 20, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton(
                    onPressed: () {},
                    heroTag: "mic",
                    mini: true,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.mic, color: primaryBlue),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: FloatingActionButton(
                      onPressed: () async {
                        await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AddDeviceScreen()));
                        await _bootstrap();
                      },
                      heroTag: "add",
                      backgroundColor: primaryBlue,
                      elevation: 4,
                      child:
                          const Icon(Icons.add, size: 32, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ]),
        child: BottomNavigationBar(
          currentIndex: _navIndex,
          onTap: (i) => setState(() => _navIndex = i),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: primaryBlue,
          unselectedItemColor: textGray,
          showUnselectedLabels: true,
          selectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          unselectedLabelStyle:
              const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_filled), label: "My Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.auto_awesome_mosaic_outlined), label: "Smart"),
            BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart_outlined_rounded),
                label: "Reports"),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded), label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _bootstrap,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildWeatherCard(),
              const SizedBox(height: 24),
              _buildCategories(),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("All Devices",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textDark)),
                  Icon(Icons.more_vert, color: textGray.withOpacity(0.7)),
                ],
              ),
              const SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTabChip("All Rooms (37)", 0),
                    const SizedBox(width: 10),
                    _buildTabChip("Living Room (6)", 1),
                    const SizedBox(width: 10),
                    _buildTabChip("Bedroom (4)", 2),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // LOGIC CHUYỂN TAB
              if (_selectedRoomIndex == 0) _buildRealDeviceArea(),
              if (_selectedRoomIndex == 1)
                _buildMockRoomGrid(_livingRoomDevices),
              if (_selectedRoomIndex == 2) _buildMockRoomGrid(_bedroomDevices),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  // --- TAB 0: ALL ROOMS (REAL DATA) ---
  Widget _buildRealDeviceArea() {
    if (_loadingDevices) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }
    if (_deviceErr != null) return _buildError(_deviceErr!);
    if (_devices.isEmpty) return _buildNoDevices();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _devices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, i) {
        final d = _devices[i];
        final int id = (d['id'] as num).toInt();
        // Fix tên thành Smart Plug
        String name = "Smart Plug";

        final live = _live[id];
        final bool on = _switchState[id] ?? false;
        final bool busy = _switchBusy.contains(id);

        return _buildRealGridDeviceItem(id, name, on, busy, live);
      },
    );
  }

  // --- TAB 1 & 2: MOCK ROOMS ---
  Widget _buildMockRoomGrid(List<Map<String, dynamic>> devices) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: devices.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemBuilder: (context, i) {
        final item = devices[i];
        return _buildMockDeviceCard(item, i, devices);
      },
    );
  }

  // --- Widget Card cho Dữ liệu Thật ---
  Widget _buildRealGridDeviceItem(
      int id, String name, bool on, bool busy, IotWsMessage? live) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => DeviceDetailScreen(
                    deviceId: id,
                    deviceName: name,
                    initialRelayState: on,
                    initialPower: live?.power ?? "0")));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dùng ảnh device4.jpg (Bóng đèn)
                Container(
                  width: 46,
                  height: 46,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: bgLight, borderRadius: BorderRadius.circular(12)),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset("assets/images/device4.jpg",
                        fit: BoxFit.contain),
                  ),
                ),
                Transform.scale(
                  scale: 0.8,
                  child: busy
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Switch(
                          value: on,
                          activeColor: primaryBlue,
                          onChanged: (v) => _toggleDevice(id, v),
                        ),
                )
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textDark)),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                      color: bgLight, borderRadius: BorderRadius.circular(8)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.wifi, size: 10, color: textGray),
                      SizedBox(width: 4),
                      Text("Wi-Fi",
                          style: TextStyle(fontSize: 10, color: textGray)),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // --- Widget Card cho Dữ liệu Mock (Có ảnh và Switch bấm được) ---
  Widget _buildMockDeviceCard(
      Map<String, dynamic> item, int index, List<Map<String, dynamic>> list) {
    bool isOn = item['isOn'];
    String type = item['type'];
    String imgPath = item['img'];

    // Check CCTV
    bool isCCTV = type == 'cctv';

    if (isCCTV) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(20),
            image: DecorationImage(
                image: AssetImage(imgPath), // Dùng ảnh từ assets
                fit: BoxFit.cover,
                opacity: 0.8)),
        child: Stack(
          children: [
            if (isOn)
              Positioned(
                top: 12,
                left: 12,
                child: Row(children: const [
                  Icon(Icons.circle, color: Colors.red, size: 8),
                  SizedBox(width: 4),
                  Text("Live",
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold))
                ]),
              ),
            Positioned(
              top: 5,
              right: 5,
              child: Transform.scale(
                scale: 0.7,
                child: Switch(
                    value: isOn,
                    activeColor: primaryBlue,
                    onChanged: (v) =>
                        _toggleMockDevice(list, index, v) // Toggle được
                    ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Text(item['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Colors.white)),
            )
          ],
        ),
      );
    }

    // Giao diện thiết bị thường (Nền trắng, có ảnh nhỏ)
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ảnh thiết bị
              Container(
                width: 46,
                height: 46,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: bgLight, borderRadius: BorderRadius.circular(12)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(imgPath, fit: BoxFit.contain),
                ),
              ),
              // Switch
              Transform.scale(
                scale: 0.8,
                child: Switch(
                    value: isOn,
                    activeColor: primaryBlue,
                    onChanged: (v) => _toggleMockDevice(list, index, v)),
              )
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item['name'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: textDark)),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                    color: bgLight, borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                        item['type'] == 'speaker' || item['type'] == 'ac'
                            ? Icons.bluetooth
                            : Icons.wifi,
                        size: 10,
                        color: textGray),
                    const SizedBox(width: 4),
                    Text(
                        item['type'] == 'speaker' || item['type'] == 'ac'
                            ? "Bluetooth"
                            : "Wi-Fi",
                        style: const TextStyle(fontSize: 10, color: textGray)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  // --- Header, Weather, Categories, TabChip, Error UI (Giữ nguyên) ---
  Widget _buildHeader() {
    return Row(
      children: [
        const Text("My Home",
            style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(width: 6),
        const Icon(Icons.keyboard_arrow_down, color: textDark),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const ChatScreen())),
          child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const Icon(Icons.smart_toy_outlined,
                  color: primaryBlue, size: 24)),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const NotificationScreen())),
          child: Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: Stack(alignment: Alignment.center, children: [
                const Icon(Icons.notifications_none_rounded,
                    color: textDark, size: 24),
                Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: Colors.white, width: 1.5))))
              ])),
        ),
      ],
    );
  }

  Widget _buildWeatherCard() {
    final width = MediaQuery.of(context).size.width;
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
              colors: [Color(0xFF4A6EF5), Color(0xFF6B8BFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          boxShadow: [
            BoxShadow(
                color: const Color(0xFF4A6EF5).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 10))
          ]),
      child: Stack(
        children: [
          Positioned(
              right: -20,
              top: -20,
              child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle))),
          Padding(
            padding: const EdgeInsets.all(20),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _isLoadingWeather
                  ? const SizedBox(
                      height: 30,
                      width: 30,
                      child: CircularProgressIndicator(color: Colors.white))
                  : Text("${_temp.toStringAsFixed(0)}°C",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                  width: width * 0.55,
                  child: Text(_homeAddress,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 13,
                          height: 1.3))),
              const SizedBox(height: 4),
              Text("Today $_weatherDesc",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.8), fontSize: 12)),
              const Spacer(),
              Row(children: const [
                Icon(Icons.air, color: Colors.white70, size: 14),
                SizedBox(width: 4),
                Text("AQI 92",
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                SizedBox(width: 12),
                Icon(Icons.water_drop_outlined,
                    color: Colors.white70, size: 14),
                SizedBox(width: 4),
                Text("78.2%",
                    style: TextStyle(color: Colors.white70, fontSize: 11)),
                SizedBox(width: 12),
                Icon(Icons.wind_power, color: Colors.white70, size: 14),
                SizedBox(width: 4),
                Text("2.0 m/s",
                    style: TextStyle(color: Colors.white70, fontSize: 11))
              ])
            ]),
          ),
          Positioned(
              right: 10,
              top: 20,
              child: SizedBox(
                  width: 100,
                  height: 80,
                  child: Stack(alignment: Alignment.center, children: const [
                    Positioned(
                        right: 0,
                        top: 0,
                        child: Icon(Icons.wb_sunny_rounded,
                            color: Colors.orangeAccent, size: 50)),
                    Positioned(
                        left: 0,
                        bottom: 0,
                        child: Icon(Icons.cloud, color: Colors.white, size: 70))
                  ]))),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      _buildCategoryItem("Lightning", "12 lights", Icons.lightbulb_outline,
          yellowBg, yellowIcon),
      _buildCategoryItem("Cameras", "8 cameras", Icons.videocam_outlined,
          purpleBg, purpleIcon),
      _buildCategoryItem(
          "Electrical", "6 devices", Icons.electrical_services, redBg, redIcon),
    ]);
  }

  Widget _buildCategoryItem(
      String title, String subtitle, IconData icon, Color bg, Color iconColor) {
    final width = (MediaQuery.of(context).size.width - 40 - 24) / 3;
    return Container(
        width: width,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(height: 12),
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: textGray, fontSize: 11))
        ]));
  }

  Widget _buildTabChip(String label, int index) {
    bool isActive = _selectedRoomIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedRoomIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
            color: isActive ? primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(30),
            border: isActive ? null : Border.all(color: Colors.grey.shade300)),
        child: Text(label,
            style: TextStyle(
                color: isActive ? Colors.white : textGray,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
      ),
    );
  }

  Widget _buildNoDevices() {
    return Center(
        child: Column(children: [
      const SizedBox(height: 40),
      Container(
          padding: const EdgeInsets.all(20),
          decoration:
              const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
          child: Icon(Icons.add_box_outlined,
              size: 50, color: primaryBlue.withOpacity(0.5))),
      const SizedBox(height: 16),
      const Text("No Devices Found",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
      const SizedBox(height: 8),
      const Text("Add a new device to get started",
          style: TextStyle(color: textGray)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
          onPressed: () async {
            await Navigator.push(context,
                MaterialPageRoute(builder: (_) => const AddDeviceScreen()));
            await _bootstrap();
          },
          icon: const Icon(Icons.add),
          label: const Text("Add Device"),
          style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12)))
    ]));
  }

  Widget _buildError(String err) {
    return Center(
        child: Column(children: [
      const Icon(Icons.error_outline, size: 40, color: Colors.redAccent),
      const SizedBox(height: 8),
      Text("Failed to load: $err",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.red)),
      TextButton(onPressed: _bootstrap, child: const Text("Retry"))
    ]));
  }
}
