// lib/src/home/home.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../componants/navbaruser.dart';
import '../componants/Kcalbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ตัวแปรเก็บข้อมูล
  double _currentCalories = 2000;
  double _targetCalories = 2200;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ดึงข้อมูล
  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    // TODO: ดึงข้อมูลจาก API
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBFFC8),
      body: Column(
        children: [
          // Navbar
          NavBarUser(),
          
          // Content (แบ่งครึ่งซ้าย-ขวา)
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF6fa85e),
                    ),
                  )
                : Row(
                    children: [
                      // ฝั่งซ้าย - Kcalbar
                      Expanded(
                        flex: 1, // ครึ่งหนึ่ง
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Kcalbar(
                                current: _currentCalories,
                                target: _targetCalories,
                              ),
                              // เพิ่มเนื้อหาอื่นqๆ ด้านซ้ายได้ที่นี่
                            ],
                          ),
                        ),
                      ),
                      
                      // เส้นแบ่ง (optional)
                      Container(
                        width: 3,
                        color: Colors.black.withOpacity(0.1),
                      ),
                      
                      // ฝั่งขวา - ว่างไว้สำหรับเนื้อหาอื่น
                      Expanded(
                        flex: 1, // อีกครึ่งหนึ่ง
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Right Side Content',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontFamily: 'TA8bit',
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
    );
  }
}