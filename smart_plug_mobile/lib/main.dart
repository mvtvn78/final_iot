import 'package:esp32_ble_flutter/screens/devices/scan_connect_screen.dart';
import 'package:flutter/material.dart';
import 'package:esp32_ble_flutter/screens/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BLE ESP32 Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SplashScreen(), // màn đầu tiên
    );
  }
}
