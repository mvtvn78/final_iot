import 'dart:async';
import 'dart:convert'; // Để parse JSON
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
// import 'package:intl/intl.dart'; // Bật nếu bạn có cài intl, ở dưới tôi dùng hàm tay cho tiện

import 'package:esp32_ble_flutter/services/api.dart';
import 'package:esp32_ble_flutter/services/devices/device_api.dart';
import 'package:esp32_ble_flutter/services/token_storage.dart';
import 'package:esp32_ble_flutter/services/iot_ws_service.dart';

class DeviceDetailScreen extends StatefulWidget {
  final int deviceId;
  final String deviceName;
  final bool initialRelayState;
  final String initialPower;

  const DeviceDetailScreen({
    super.key,
    required this.deviceId,
    required this.deviceName,
    this.initialRelayState = false,
    this.initialPower = "0",
  });

  @override
  State<DeviceDetailScreen> createState() => _DeviceDetailScreenState();
}

class _DeviceDetailScreenState extends State<DeviceDetailScreen>
    with SingleTickerProviderStateMixin {
  // --- Màu sắc UI ---
  static const Color primaryBlue = Color(0xFF4A6EF5);
  static const Color bgLight = Color(0xFFF6F8FB);
  static const Color textDark = Color(0xFF1D2445);
  static const Color textGray = Color(0xFF9CA3AF);

  // --- Logic ---
  late final DeviceApi _deviceApi;
  late final IotWsService _wsService;
  StreamSubscription<IotWsMessage>? _wsSub;

  // Realtime State
  late bool _isRelayOn;
  late String _powerValue;
  int _ts = 0;
  bool _isBusy = false;

  // Schedule State (Lưu cục bộ để hiển thị)
  String? _scheduledAction; // Ví dụ: "Turn ON at 18:30"

  // Tabs Control
  late TabController _tabController;

  // Telemetry Data
  List<dynamic> _historyList = [];
  bool _isLoadingHistory = false;

  // Tên hiển thị (Đã xử lý)
  late String _displayName;

  @override
  void initState() {
    super.initState();
    _deviceApi = DeviceApi(Api.dio);
    _tabController = TabController(length: 2, vsync: this);

    // Xử lý tên: Nếu tên là ID kỹ thuật (chứa "89_") thì đổi thành "Smart Plug"
    if (widget.deviceName.startsWith("89_") || widget.deviceName.length > 15) {
      _displayName = "Smart Plug";
    } else {
      _displayName = widget.deviceName;
    }

    // Init state
    _isRelayOn = widget.initialRelayState;
    _powerValue = widget.initialPower;

    _setupWebSocket();

    // Load lịch sử khi chuyển sang tab Telemetry
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _fetchTelemetry();
      }
    });
  }

  Future<void> _setupWebSocket() async {
    final token = await TokenStorage.read();
    if (token == null) return;

    String wsBase = Api.baseUrl
        .replaceFirst("https://", "wss://")
        .replaceFirst("http://", "ws://");

    _wsService = IotWsService(wsBase: wsBase);

    _wsSub = _wsService.stream.listen((msg) {
      if (!mounted) return;
      setState(() {
        if (msg.stateRelay != null) _isRelayOn = msg.stateRelay!;
        if (msg.power != null) _powerValue = msg.power!;
        if (msg.ts != null) _ts = msg.ts!;
      });
    });

    _wsService.connect(deviceId: widget.deviceId, token: token);
  }

  Future<void> _fetchTelemetry() async {
    if (_isLoadingHistory) return;
    setState(() => _isLoadingHistory = true);
    try {
      final data = await _deviceApi.getTelemetry(widget.deviceId);
      if (!mounted) return;
      setState(() {
        _historyList = data.reversed.toList();
      });
    } catch (e) {
      debugPrint("Lỗi telemetry: $e");
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  Future<void> _toggleDevice(bool value) async {
    if (_isBusy) return;
    setState(() {
      _isBusy = true;
      _isRelayOn = value;
    });

    try {
      await _deviceApi.controlDevice(
        deviceId: widget.deviceId,
        payload: value ? "1" : "0",
      );
      // Refresh telemetry sau 1s
      Future.delayed(const Duration(seconds: 1), () {
        if (_tabController.index == 1) _fetchTelemetry();
      });
    } catch (e) {
      if (mounted) setState(() => _isRelayOn = !value);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Lỗi: $e")));
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  // --- Logic Schedule ---
  Future<void> _showScheduleDialog() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: primaryBlue),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && mounted) {
      // Chọn hành động
      bool? isTurnOn = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Select Action"),
          content: Text("At ${picked.format(context)}, turn the device:"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false), // OFF
              child: const Text("OFF",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true), // ON
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue),
              child: const Text("ON", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );

      if (isTurnOn != null) {
        // Cập nhật UI để người dùng thấy đã đặt lịch
        setState(() {
          _scheduledAction =
              "${isTurnOn ? 'Turn ON' : 'Turn OFF'} at ${picked.format(context)}";
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Scheduled: $_scheduledAction"),
            backgroundColor: primaryBlue,
          ),
        );

        // TODO: Gọi API gửi lịch xuống server tại đây
      }
    }
  }

  @override
  void dispose() {
    _wsSub?.cancel();
    _wsService.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: textDark),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        // Hiển thị tên đã xử lý (Smart Plug)
        title: Text(_displayName,
            style:
                const TextStyle(color: textDark, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryBlue,
          unselectedLabelColor: textGray,
          indicatorColor: primaryBlue,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Monitor"),
            Tab(text: "Telemetry"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMonitorTab(),
          _buildTelemetryTab(),
        ],
      ),
    );
  }

  // ================= TAB 1: MONITOR =================
  Widget _buildMonitorTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          // 1. Header Card (Toggle + Info)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color:
                          _isRelayOn ? primaryBlue.withOpacity(0.1) : bgLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.power_settings_new,
                        color: _isRelayOn ? primaryBlue : textGray, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_isRelayOn ? "Status: ON" : "Status: OFF",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textDark)),
                      Text("Living Room",
                          style: TextStyle(
                              color: textGray.withOpacity(0.8), fontSize: 13)),
                    ],
                  ),
                ],
              ),
              Transform.scale(
                scale: 1.2,
                child: Switch(
                  value: _isRelayOn,
                  activeColor: primaryBlue,
                  onChanged: _toggleDevice,
                ),
              ),
            ],
          ),

          const SizedBox(height: 40),

          // 2. Power Circle (Vòng tròn công suất)
          _buildPowerCircle(),

          const SizedBox(height: 30),

          // 3. SCHEDULE SECTION (Đã đẩy lên đây)
          _buildScheduleCard(),

          const SizedBox(height: 30),

          // 4. Stats Row (Hiển thị 3 thông số chi tiết)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 5))
              ],
              border: Border.all(color: bgLight),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                    Icons.flash_on, "Power", "$_powerValue W", Colors.orange),
                Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade200), // Divider
                _buildStatItem(
                    Icons.toggle_on,
                    "State",
                    _isRelayOn ? "ON" : "OFF",
                    _isRelayOn ? primaryBlue : textGray),
                Container(
                    width: 1,
                    height: 40,
                    color: Colors.grey.shade200), // Divider
                _buildStatItem(
                    Icons.access_time, "Uptime", _formatTs(_ts), Colors.teal),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // Widget hiển thị Schedule (nhìn "ăn" hơn)
  Widget _buildScheduleCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _scheduledAction != null
            ? const Color(0xFFF0FDF4)
            : bgLight, // Xanh lá nhạt nếu có lịch
        borderRadius: BorderRadius.circular(16),
        border: _scheduledAction != null
            ? Border.all(color: Colors.green.shade200)
            : null,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.alarm,
                  color: _scheduledAction != null ? Colors.green : primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Schedule Timer",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _scheduledAction ?? "No schedule set",
                      style: TextStyle(
                          color: _scheduledAction != null
                              ? Colors.green.shade700
                              : textGray,
                          fontWeight: _scheduledAction != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _showScheduleDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryBlue,
                  elevation: 0,
                  side: const BorderSide(color: primaryBlue),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(_scheduledAction == null ? "Set" : "Edit"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTs(int ms) {
    if (ms <= 0) return "0s";
    final duration = Duration(milliseconds: ms);
    if (duration.inHours > 0)
      return "${duration.inHours}h ${duration.inMinutes % 60}m";
    if (duration.inMinutes > 0)
      return "${duration.inMinutes}m ${duration.inSeconds % 60}s";
    return "${duration.inSeconds}s";
  }

  Widget _buildStatItem(
      IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 16, color: textDark)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: textGray, fontSize: 12)),
      ],
    );
  }

  // ================= TAB 2: TELEMETRY =================
  Widget _buildTelemetryTab() {
    if (_isLoadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_historyList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off,
                size: 60, color: textGray.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text("No activity history yet",
                style: TextStyle(color: textGray)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchTelemetry,
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: _historyList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _historyList[index];

          final rawPayload = item['payload']?.toString() ?? "";
          bool isOn = false;

          // Parse Payload
          if (rawPayload == "1" || rawPayload.toLowerCase() == "true") {
            isOn = true;
          } else if (rawPayload.startsWith("{")) {
            try {
              final Map<String, dynamic> data = json.decode(rawPayload);
              if (data.containsKey('stateRelay')) {
                isOn = data['stateRelay'] == true;
              }
            } catch (e) {
              // ignore
            }
          }

          // Parse Time
          final rawTime = item['timestamp']?.toString() ?? "";
          String displayTime = rawTime;
          try {
            final dt = DateTime.parse(rawTime).toLocal();
            // Format thủ công: HH:mm DD/MM
            displayTime =
                "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}  ${dt.day}/${dt.month}";
          } catch (_) {}

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: bgLight),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isOn
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOn ? Icons.power : Icons.power_off,
                    color: isOn ? Colors.green : Colors.red,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOn ? "Device turned ON" : "Device turned OFF",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: textDark),
                      ),
                      const SizedBox(height: 4),
                      Text("Event ID: ${item['id']}",
                          style: TextStyle(
                              fontSize: 11, color: textGray.withOpacity(0.6))),
                    ],
                  ),
                ),
                Text(
                  displayTime,
                  style: const TextStyle(
                      color: textGray,
                      fontSize: 13,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // --- Widget vẽ vòng tròn công suất ---
  Widget _buildPowerCircle() {
    double power = double.tryParse(_powerValue) ?? 0.0;
    double progress = (power / 3000).clamp(0.0, 1.0);

    return Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(260, 260),
          painter: PowerCirclePainter(
            progress: _isRelayOn ? (progress < 0.02 ? 0.02 : progress) : 0.0,
            color: primaryBlue,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                        color: _isRelayOn
                            ? Colors.orange.withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 20)
                  ]),
              child: Icon(Icons.lightbulb,
                  size: 50,
                  color:
                      _isRelayOn ? Colors.orangeAccent : Colors.grey.shade300),
            ),
            const SizedBox(height: 15),
            Text("$_powerValue W",
                style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: textDark)),
            const Text("Current Usage",
                style: TextStyle(color: textGray, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}

// Custom Painter
class PowerCirclePainter extends CustomPainter {
  final double progress;
  final Color color;
  PowerCirclePainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 22.0;

    final trackPaint = Paint()
      ..color = const Color(0xFFF3F6FF)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        math.pi * 0.75, math.pi * 1.5, false, trackPaint);

    if (progress > 0) {
      final gradient = SweepGradient(
        startAngle: math.pi * 0.75,
        endAngle: math.pi * 0.75 + (math.pi * 1.5),
        colors: [const Color(0xFFFFD573), color],
        stops: const [0.0, 1.0],
        transform: GradientRotation(math.pi * 0.05),
      );
      final valuePaint = Paint()
        ..shader = gradient
            .createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth;

      canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
          math.pi * 0.75, math.pi * 1.5 * progress, false, valuePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
