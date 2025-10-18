// lib/src/home/home.dart
import 'package:flutter/material.dart';
import '../componants/navbaruser.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBFFC8),
      body: Column(
        children: [
          // ใส่ Navbar ตรงนี้ - ไม่ต้องส่ง parameter แล้ว
          const NavBarUser(),
          
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'เนื้อหาหน้า Home',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '🎉 Navbar จะดึงข้อมูลจาก API อัตโนมัติ',
                    style: TextStyle(fontSize: 14),
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