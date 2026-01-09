// pubspec.yaml dependencies:
// flutter_blue_plus: ^1.31.0
// mobile_scanner: ^5.2.3
// permission_handler: ^11.0.1
// wifi_scan: ^0.4.1

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wifi_scan/wifi_scan.dart';

// --- IMPORT CÁC FILE CỦA BẠN ---
import 'package:esp32_ble_flutter/services/api.dart';
// QUAN TRỌNG: Import Home Screen để chuyển trang khi thành công
import 'package:esp32_ble_flutter/screens/home/home_screen.dart';

class DeviceInfo {
  final String name;
  final String tpRelay;
  final String tpData;

  DeviceInfo({required this.name, required this.tpRelay, required this.tpData});

  factory DeviceInfo.fromJson(Map<String, dynamic> j) => DeviceInfo(
        name: (j['name'] ?? '').toString(),
        tpRelay: (j['tpRelay'] ?? '').toString(),
        tpData: (j['tpData'] ?? '').toString(),
      );

  bool get isValid =>
      name.isNotEmpty && tpRelay.isNotEmpty && tpData.isNotEmpty;
}

/// ===============================
/// 1) Screen: Scan QR + Connect BLE
/// ===============================
class ScanQrConnectScreen extends StatefulWidget {
  const ScanQrConnectScreen({super.key});

  @override
  State<ScanQrConnectScreen> createState() => _ScanQrConnectScreenState();
}

class _ScanQrConnectScreenState extends State<ScanQrConnectScreen> {
  final MobileScannerController _cameraController = MobileScannerController();

  bool _isScanningQr = true;
  bool _isConnecting = false;

  StreamSubscription<List<ScanResult>>? _scanSub;
  BluetoothDevice? _device;

  // UUID chuẩn 16-bit (ESP32: 0x00FF service, 0xFF01 RX write, 0xFF02 TX notify)
  static final Guid _rxUuid = Guid("0000ff01-0000-1000-8000-00805f9b34fb");
  static final Guid _txUuid = Guid("0000ff02-0000-1000-8000-00805f9b34fb");

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.locationWhenInUse,
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
    ].request();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanningQr) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.trim().isEmpty) return;

    setState(() => _isScanningQr = false);
    _connectToBleByName(code.trim());
  }

  Future<void> _connectToBleByName(String deviceName) async {
    setState(() => _isConnecting = true);

    try {
      await FlutterBluePlus.stopScan();
      await _scanSub?.cancel();
      _scanSub = null;

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 10));
      bool found = false;

      _scanSub = FlutterBluePlus.scanResults.listen((results) async {
        if (found) return;

        for (final r in results) {
          final name1 = r.device.platformName;
          final name2 = r.advertisementData.advName;

          final matched = name1 == deviceName || name2 == deviceName;
          if (!matched) continue;

          found = true;
          await FlutterBluePlus.stopScan();
          await _scanSub?.cancel();
          _scanSub = null;

          _device = r.device;

          await _device!.connect(
            timeout: const Duration(seconds: 12),
            autoConnect: false,
          );

          // Android trick: request MTU priority
          try {
            await _device!.requestMtu(247);
          } catch (_) {}

          final services = await _device!.discoverServices();

          BluetoothCharacteristic? rxWrite;
          BluetoothCharacteristic? txNotify;

          for (final s in services) {
            for (final c in s.characteristics) {
              if (c.uuid == _rxUuid &&
                  (c.properties.write || c.properties.writeWithoutResponse)) {
                rxWrite = c;
              }
              if (c.uuid == _txUuid && c.properties.notify) {
                txNotify = c;
              }
            }
          }

          if (!mounted) return;

          if (rxWrite == null || txNotify == null) {
            await _device?.disconnect();
            setState(() {
              _isConnecting = false;
              _isScanningQr = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Không tìm thấy FF01/FF02 trên thiết bị!"),
                backgroundColor: Colors.red,
              ),
            );
            return;
          }

          setState(() => _isConnecting = false);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WifiSetupScreen(
                device: _device!,
                writeChar: rxWrite!,
                notifyChar: txNotify!,
              ),
            ),
          );
          return;
        }
      });

      await Future.delayed(const Duration(seconds: 11));

      if (!mounted) return;
      if (!found) {
        await FlutterBluePlus.stopScan();
        await _scanSub?.cancel();
        _scanSub = null;

        setState(() {
          _isConnecting = false;
          _isScanningQr = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("⚠ Không tìm thấy thiết bị BLE này!"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      await FlutterBluePlus.stopScan();
      await _scanSub?.cancel();
      _scanSub = null;

      if (!mounted) return;
      setState(() {
        _isConnecting = false;
        _isScanningQr = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Lỗi kết nối: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _scanSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR → Connect BLE")),
      body: Stack(
        children: [
          MobileScanner(
            controller: _cameraController,
            onDetect: _handleBarcode,
          ),
          if (_isConnecting)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      "Đang kết nối BLE...",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _isScanningQr ? "Quét mã QR trên thiết bị" : "Đang xử lý...",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===============================
/// 2) Screen: List Wi-Fi (Android) + Send SSID/PASS via BLE
/// ===============================
class WifiSetupScreen extends StatefulWidget {
  final BluetoothDevice device;
  final BluetoothCharacteristic writeChar; // FF01
  final BluetoothCharacteristic notifyChar; // FF02

  const WifiSetupScreen({
    super.key,
    required this.device,
    required this.writeChar,
    required this.notifyChar,
  });

  @override
  State<WifiSetupScreen> createState() => _WifiSetupScreenState();
}

class _WifiSetupScreenState extends State<WifiSetupScreen> {
  StreamSubscription<List<int>>? _notifySub;
  List<WiFiAccessPoint> _aps = [];
  bool _loadingWifi = false;

  // Trạng thái hiển thị text
  String _status = "Đã kết nối BLE. Hãy chọn Wi-Fi.";

  // Trạng thái Loading toàn màn hình (khi đang kết nối Wi-Fi hoặc đăng ký API)
  bool _isBusy = false;
  String _busyMessage = "";

  // Logic flag
  bool _askedAddAfterWifiOk = false; // Để tránh hỏi nhiều lần
  bool _infoRequested = false;

  @override
  void initState() {
    super.initState();
    _setupNotify();
    _scanWifiFromPhone();
  }

  // --- 1. LẮNG NGHE PHẢN HỒI TỪ ESP32 ---
  Future<void> _setupNotify() async {
    try {
      await widget.notifyChar.setNotifyValue(true);

      _notifySub = widget.notifyChar.lastValueStream.listen((value) async {
        if (value.isEmpty) return;

        final msg = utf8.decode(value, allowMalformed: true).trim();
        if (msg.isEmpty) return;

        debugPrint("ESP32 Notify: $msg");

        // Cập nhật log nhỏ nếu không đang busy
        if (!_isBusy && mounted) {
          setState(() => _status = msg);
        }

        // --- A. XỬ LÝ TRẠNG THÁI WI-FI (JSON) ---
        final j = _tryParseJson(msg);
        if (j != null && j.containsKey("code")) {
          final code = _asInt(j["code"]);
          final message = (j["message"] ?? "").toString();

          if (code == 1) {
            // Code 1: Đang kết nối... (Vẫn giữ loading)
            if (mounted)
              setState(() => _busyMessage = "ESP32 đang kết nối Wi-Fi...");
          } else if (code == 2) {
            // Code 2: KẾT NỐI THÀNH CÔNG!
            _handleWifiSuccess(message);
          } else if (code == 4 || code == 3) {
            // Code 3/4: Thất bại
            _handleWifiFail(message);
          }
          return;
        }

        // --- B. XỬ LÝ INFO THIẾT BỊ (Để Register API) ---
        final info = _parseDeviceInfoLoose(msg);
        if (info != null) {
          // Nhận được info -> Gọi API đăng ký
          await _registerDeviceToBackend(info);
        }
      });
    } catch (e) {
      if (mounted) setState(() => _status = "Notify error: $e");
    }
  }

  // --- Xử lý khi Wi-Fi Connect OK ---
  void _handleWifiSuccess(String message) async {
    if (!mounted) return;

    // Tắt loading
    setState(() {
      _isBusy = false;
      _status = "✅ Wi-Fi Connected!";
    });

    if (_askedAddAfterWifiOk) return;
    _askedAddAfterWifiOk = true;

    // Hiện dialog hỏi Add Device
    final ok = await _confirmDialog(
      title: "Kết nối Wi-Fi thành công!",
      body:
          "Thiết bị đã vào mạng.\nBạn có muốn thêm thiết bị này vào tài khoản không?",
      okText: "Thêm ngay",
      cancelText: "Để sau",
    );

    if (ok == true && !_infoRequested) {
      _infoRequested = true;
      // Gửi lệnh lấy info -> chờ phản hồi để gọi API
      _sendInfoCommand();
    }
  }

  // --- Xử lý khi Wi-Fi Fail ---
  void _handleWifiFail(String message) {
    if (!mounted) return;
    // Tắt loading
    setState(() {
      _isBusy = false;
      _status = "❌ Lỗi Wi-Fi: $message";
    });

    _showDialog(
      title: "Kết nối thất bại",
      body:
          "ESP32 không thể kết nối Wi-Fi.\nLỗi: $message\nVui lòng kiểm tra mật khẩu.",
    );
  }

  // --- 2. GỌI API ĐĂNG KÝ THIẾT BỊ ---
  Future<void> _registerDeviceToBackend(DeviceInfo info) async {
    if (!mounted) return;

    // Bật Loading khi gọi API
    setState(() {
      _isBusy = true;
      _busyMessage = "Đang đăng ký thiết bị...";
    });

    try {
      // B1: Tạo thiết bị (Admin/Backend)
      final created = await Api.devices.createDevice(
        name: info.name,
        topicRelay: info.tpRelay,
        topicData: info.tpData,
      );

      final statusCode = created["statusCode"];
      final data = created["data"];

      if (statusCode != 200 || data == null || data["id"] == null) {
        throw Exception("Server error: ${created['message'] ?? 'Unknown'}");
      }

      final deviceId = (data["id"] as num).toInt();

      // B2: Gán thiết bị cho User hiện tại
      setState(() => _busyMessage = "Đang gán vào tài khoản...");
      final assigned = await Api.userDevices.addDevice(deviceId: deviceId);
      final assignCode = assigned["statusCode"];

      if (assignCode == 200 || assignCode == 409) {
        // 409 nghĩa là đã tồn tại, vẫn coi là thành công để về Home
        if (mounted) {
          setState(() => _isBusy = false);

          // Ngắt kết nối BLE cho sạch
          await widget.device.disconnect();

          // Chuyển về Home Screen (Xóa hết stack cũ)
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("🎉 Đã thêm thiết bị: ${info.name}")),
          );
        }
      } else {
        throw Exception("Assign failed: $assigned");
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isBusy = false;
        _status = "Lỗi API: $e";
      });
      _showDialog(title: "Lỗi đăng ký", body: e.toString());
    }
  }

  // --- CÁC HÀM HỖ TRỢ KHÁC ---

  Future<void> _sendInfoCommand() async {
    try {
      setState(() {
        _isBusy = true;
        _busyMessage = "Đang lấy thông tin thiết bị...";
      });
      await widget.writeChar.write(utf8.encode("info"), withoutResponse: false);
    } catch (e) {
      setState(() => _isBusy = false);
      _showDialog(title: "Lỗi BLE", body: "Không gửi được lệnh info: $e");
    }
  }

  Future<void> _connectWifi(String ssid) async {
    final pass = await _askPassword(ssid);
    if (pass == null) return; // User cancel

    // Bật Loading chờ kết nối
    setState(() {
      _isBusy = true;
      _busyMessage = "Đang gửi cấu hình Wi-Fi...";
    });

    final cmd = "ssid=$ssid,pass=$pass";
    try {
      await widget.writeChar.write(utf8.encode(cmd), withoutResponse: false);

      // Timer timeout phòng trường hợp ESP đơ không trả lời
      Timer(const Duration(seconds: 20), () {
        if (mounted && _isBusy && _busyMessage.contains("Wi-Fi")) {
          setState(() => _isBusy = false);
          _showDialog(
              title: "Timeout",
              body: "Không nhận được phản hồi từ thiết bị sau 20s.");
        }
      });
    } catch (e) {
      setState(() => _isBusy = false);
      _showDialog(title: "Lỗi BLE", body: "Gửi thất bại: $e");
    }
  }

  // ... (Giữ nguyên các hàm parse logic, scan wifi như cũ) ...
  Future<bool?> _confirmDialog(
      {required String title,
      required String body,
      required String okText,
      required String cancelText}) async {
    if (!mounted) return false;
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText)),
          ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(okText)),
        ],
      ),
    );
  }

  Future<void> _showDialog(
      {required String title, required String body}) async {
    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }

  DeviceInfo? _parseDeviceInfoLoose(String msg) {
    final j = _tryParseJson(msg);
    if (j != null &&
        j.containsKey("name") &&
        j.containsKey("tpRelay") &&
        j.containsKey("tpData")) {
      return DeviceInfo.fromJson(j);
    }
    String? name = _extractFieldLoose(msg, "name");
    String? tpRelay = _extractFieldLoose(msg, "tpRelay");
    String? tpData = _extractFieldLoose(msg, "tpData");
    if (name == null || tpRelay == null || tpData == null) return null;

    name = name.replaceAll('"', '').trim();
    tpRelay = tpRelay.replaceAll('"', '').trim();
    tpData = tpData.replaceAll('"', '').trim();
    if (tpRelay.startsWith("/data/") && tpData.startsWith("/relay/")) {
      final tmp = tpRelay;
      tpRelay = tpData;
      tpData = tmp;
    }
    return DeviceInfo(name: name, tpRelay: tpRelay, tpData: tpData);
  }

  String? _extractFieldLoose(String msg, String key) {
    final re = RegExp('"?$key"?\\s*:\\s*([^,}]+)');
    final m = re.firstMatch(msg);
    if (m == null) return null;
    var v = (m.group(1) ?? "").trim();
    if (v.startsWith('"') && v.endsWith('"') && v.length >= 2)
      v = v.substring(1, v.length - 1);
    return v.trim();
  }

  Map<String, dynamic>? _tryParseJson(String s) {
    try {
      final obj = json.decode(s);
      if (obj is Map<String, dynamic>) return obj;
      return null;
    } catch (_) {
      return null;
    }
  }

  int _asInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? -9999;
  }

  Future<void> _scanWifiFromPhone() async {
    setState(() => _loadingWifi = true);
    try {
      await Permission.locationWhenInUse.request();
      if (await WiFiScan.instance.canStartScan() == CanStartScan.yes) {
        await WiFiScan.instance.startScan();
      }
      await Future.delayed(const Duration(seconds: 1)); // delay nhẹ
      if (await WiFiScan.instance.canGetScannedResults() ==
          CanGetScannedResults.yes) {
        final results = await WiFiScan.instance.getScannedResults();
        final aps = results.where((e) => e.ssid.isNotEmpty).toList()
          ..sort((a, b) => b.level.compareTo(a.level));
        if (mounted) setState(() => _aps = aps);
      }
    } catch (e) {
      if (mounted) setState(() => _status = "Scan error: $e");
    } finally {
      if (mounted) setState(() => _loadingWifi = false);
    }
  }

  Future<String?> _askPassword(String ssid) async {
    final ctrl = TextEditingController();
    bool obscure = true;
    return showDialog<String>(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text("Kết nối $ssid"),
              content: TextField(
                controller: ctrl,
                obscureText: obscure,
                decoration: InputDecoration(
                  labelText: "Mật khẩu Wi-Fi",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon:
                        Icon(obscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setLocal(() => obscure = !obscure),
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Hủy")),
                ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, ctrl.text),
                    child: const Text("Kết nối")),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _notifySub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.device.platformName.isNotEmpty
        ? widget.device.platformName
        : "ESP32";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Cấu hình Wi-Fi"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadingWifi || _isBusy ? null : _scanWifiFromPhone,
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              ListTile(
                tileColor: Colors.blue.shade50,
                leading:
                    const Icon(Icons.bluetooth_connected, color: Colors.blue),
                title: Text("Đã kết nối: $name"),
                subtitle: Text(_status, style: const TextStyle(fontSize: 12)),
              ),
              const Divider(height: 1),
              if (_loadingWifi)
                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(child: CircularProgressIndicator()),
                ),
              Expanded(
                child: _aps.isEmpty && !_loadingWifi
                    ? const Center(
                        child: Text(
                            "Không tìm thấy mạng Wi-Fi nào.\nHãy bật Vị trí và thử lại."))
                    : ListView.separated(
                        itemCount: _aps.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, indent: 16, endIndent: 16),
                        itemBuilder: (_, i) {
                          final ap = _aps[i];
                          return ListTile(
                            leading: const Icon(Icons.wifi),
                            title: Text(ap.ssid,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            subtitle: Text("Tín hiệu: ${ap.level} dBm"),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: _isBusy ? null : () => _connectWifi(ap.ssid),
                          );
                        },
                      ),
              ),
            ],
          ),

          // --- MÀN HÌNH LOADING ĐEN CHE PHỦ ---
          if (_isBusy)
            Container(
              color: Colors.black.withOpacity(0.7),
              width: double.infinity,
              height: double.infinity,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 3),
                    const SizedBox(height: 24),
                    Text(
                      _busyMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "(Vui lòng không tắt ứng dụng)",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          decoration: TextDecoration.none),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
