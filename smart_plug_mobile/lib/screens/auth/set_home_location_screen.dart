import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // <--- IMPORT QUAN TRỌNG
import 'package:esp32_ble_flutter/screens/auth/well_done_screen.dart';

class SetHomeLocationScreen extends StatefulWidget {
  const SetHomeLocationScreen({super.key});

  @override
  State<SetHomeLocationScreen> createState() => _SetHomeLocationScreenState();
}

class _SetHomeLocationScreenState extends State<SetHomeLocationScreen> {
  static const Color primaryBlue = Color(0xFF3F63F3);
  static const Color lightBlueBg = Color(0xFFEEF2FF);
  static const Color textDark = Color(0xFF1F2937);
  static const Color textGray = Color(0xFF9CA3AF);
  static const Color inputBg = Color(0xFFF9FAFB);

  final TextEditingController _addressCtrl = TextEditingController();
  final MapController _mapController = MapController();
  LatLng _center = const LatLng(10.7828, 106.6959);
  bool _isLoadingAddress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showEnableLocationDialog();
    });
  }

  @override
  void dispose() {
    _addressCtrl.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // --- Logic lưu Storage và chuyển trang ---
  Future<void> _saveAddressAndContinue() async {
    final address = _addressCtrl.text;
    if (address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng chọn địa chỉ trước!")),
      );
      return;
    }

    try {
      // 1. Khởi tạo Shared Preferences
      final prefs = await SharedPreferences.getInstance();

      // 2. Lưu địa chỉ với Key là 'user_home_address'
      await prefs.setString('user_home_address', address);

      // 3. (Tuỳ chọn) Lưu luôn tọa độ nếu cần sau này dùng
      await prefs.setDouble('home_lat', _center.latitude);
      await prefs.setDouble('home_lng', _center.longitude);

      debugPrint(">>> Đã lưu địa chỉ vào LocalStorage: $address");

      if (!mounted) return;

      // 4. Chuyển màn hình
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WellDoneScreen()),
      );
    } catch (e) {
      debugPrint("Lỗi lưu data: $e");
    }
  }

  // ... (Giữ nguyên các hàm _getCurrentLocation, _getAddressFromNominatim, _showEnableLocationDialog như cũ)
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    if (permission == LocationPermission.deniedForever) return;

    Position position = await Geolocator.getCurrentPosition();
    LatLng newPos = LatLng(position.latitude, position.longitude);
    _mapController.move(newPos, 16.0);
    _getAddressFromNominatim(newPos);
  }

  Future<void> _getAddressFromNominatim(LatLng pos) async {
    if (!mounted) return;
    setState(() {
      _isLoadingAddress = true;
      _center = pos;
    });
    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${pos.latitude}&lon=${pos.longitude}&zoom=18&addressdetails=1');
      final response = await http.get(url, headers: {
        'User-Agent': 'com.esp32_ble.app/1.0.0',
        'Accept-Language': 'vi-VN'
      });
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) _addressCtrl.text = data['display_name'] ?? "Unknown";
      }
    } catch (e) {
      debugPrint("$e");
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  void _showEnableLocationDialog() {
    // ... (Giữ nguyên code popup của bạn)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on, size: 50, color: primaryBlue),
                const SizedBox(height: 20),
                const Text("Enable Location",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _getCurrentLocation();
                  },
                  child: const Text("Enable"),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ... (Phần Header giữ nguyên)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(children: [
                IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context))
              ]),
            ),

            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: _center,
                      initialZoom: 15.0,
                      onMapEvent: (evt) {
                        if (evt is MapEventMoveEnd)
                          _getAddressFromNominatim(evt.camera.center);
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.esp32_ble.app',
                      ),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.location_on,
                        size: 50, color: Colors.redAccent),
                  ),
                  if (_isLoadingAddress)
                    const Positioned(
                        top: 10,
                        child: Card(
                            child: Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text("Finding address...")))),
                ],
              ),
            ),

            // --- BOTTOM PANEL ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 15,
                      offset: Offset(0, -5))
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Address Details",
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: textDark)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _addressCtrl,
                    readOnly: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: inputBg,
                      prefixIcon:
                          const Icon(Icons.home_filled, color: primaryBlue),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none),
                      hintText: "Locating...",
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor: lightBlueBg, elevation: 0),
                            child: const Text("Skip",
                                style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            // --- GỌI HÀM LƯU TẠI ĐÂY ---
                            onPressed: _saveAddressAndContinue,
                            // ----------------------------
                            style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue, elevation: 0),
                            child: const Text("Continue",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
