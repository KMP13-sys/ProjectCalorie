import 'package:flutter/material.dart';
import 'src/open.dart'; // import ไฟล์ open.dart

void main() {
  runApp(const CalDeficitsApp());
}

class CalDeficitsApp extends StatelessWidget {
  const CalDeficitsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Cal-Deficits',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'TA8bit', // ถ้าเพิ่มฟอนต์ 8-bit
      ),
      home: const SplashScreen(), // เรียกใช้ SplashScreen จาก open.dart
    );
  }
}