// lib/src/home/home.dart
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../componants/navbaruser.dart';
import '../componants/Kcalbar.dart';
import '../componants/camera.dart';
import '../componants/activityfactor.dart';
import '../componants/piegraph.dart';
import '../componants/ListMenu.dart';
import '../componants/ListSport.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  // Key สำหรับ refresh Kcalbar (ใช้ dynamic เพื่อเข้าถึง private state)
  final GlobalKey _kcalbarKey = GlobalKey();
  bool _hasSelectedActivityLevel =
      false; // เก็บสถานะว่าเลือกระดับกิจกรรมแล้วหรือยัง

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(
      this,
    ); // เพิ่ม observer สำหรับเช็คเมื่อ app resume
    // เช็คครั้งแรกหลังจาก build เสร็จ
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActivityLevelStatus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // เช็คใหม่เมื่อ app กลับมา active (เช่น หลัง login ใหม่)
    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed, checking activity level status...');
      _checkActivityLevelStatus();
    }
  }

  // เช็คว่าเลือกระดับกิจกรรมวันนี้แล้วหรือยัง (เช็คจาก API)
  Future<void> _checkActivityLevelStatus() async {
    print('🔍 Checking activity level status...');
    final state = _kcalbarKey.currentState;
    if (state != null) {
      final hasData = await (state as dynamic).hasCalorieData();
      print('📊 Activity level selected: $hasData');
      if (mounted) {
        setState(() {
          _hasSelectedActivityLevel = hasData;
        });
      }
    }
  }

  // ฟังก์ชันสำหรับ refresh Kcalbar เมื่อมีการเปลี่ยนแปลง
  void _refreshKcalbar() {
    final state = _kcalbarKey.currentState;
    if (state != null) {
      // เรียก refresh method ผ่าน dynamic
      (state as dynamic).refresh();
    }
    // เช็คสถานะใหม่หลัง refresh
    _checkActivityLevelStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBFFC8),
      body: Column(
        children: [
          // Navbar บน (ติดด้านบนตลอด)
          NavBarUser(),

          // Content กลาง (scroll ได้)
          Expanded(
            child: SingleChildScrollView(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ฝั่งซ้าย - Kcalbar, PieChart, ListSport
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Kcalbar(
                            key: _kcalbarKey,
                            onRefresh: () {
                              print('✅ Kcalbar refreshed!');
                            },
                          ),

                          const SizedBox(height: 50),

                          const NutritionPieChartComponent(),

                          const SizedBox(height: 50),

                          const ListSportPage(),
                        ],
                      ),
                    ),
                  ),

                  // ฝั่งขวา - Activity Factor & Menu
                  Expanded(
                    flex: 1,
                    child: Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ActivityFactorButton(
                            onCaloriesUpdated: () {
                              // Refresh Kcalbar เมื่อเลือกระดับกิจกรรมเสร็จ
                              _refreshKcalbar();
                            },
                          ),

                          const SizedBox(height: 20),

                          const ListMenuPage(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      // Navbar ล่าง (ปุ่มกล้อง - ติดด้านล่างตลอด)
      // แสดง Camera button เฉพาะเมื่อเลือกระดับกิจกรรมแล้ว
      bottomNavigationBar: _hasSelectedActivityLevel
        ? const CameraBottomNavBar()
        : null,
    );
  }
}
