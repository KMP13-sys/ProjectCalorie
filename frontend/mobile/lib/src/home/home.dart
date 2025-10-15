import 'package:flutter/material.dart';
import '../authen/api_service.dart';
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
          // ใส่ Navbar ตรงนี้
          NavBarUser(), // ← เรียกใช้ navbar
          
          Expanded(
            child: Center(
              child: Text('เนื้อหาหน้า Home'),
            ),
          ),
        ],
      ),
    );
  }
}