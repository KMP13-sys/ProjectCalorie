// lib/src/home/home.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mobile/src/componants/activityfactor.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  // Key สำหรับ refresh Kcalbar (ใช้ dynamic เพื่อเข้าถึง private state)
  final GlobalKey _kcalbarKey = GlobalKey();
  bool _isLoading = false;
  bool _hasSelectedActivityLevel = false; // เก็บสถานะว่าเลือกระดับกิจกรรมแล้วหรือยัง

  @override
  void initState() {
    super.initState();
    _checkActivityLevelStatus();
  }

  // เช็คว่าเลือกระดับกิจกรรมวันนี้แล้วหรือยัง
  Future<void> _checkActivityLevelStatus() async {
    final state = _kcalbarKey.currentState;
    if (state != null) {
      final hasData = await (state as dynamic).hasCalorieData();
      setState(() {
        _hasSelectedActivityLevel = hasData;
      });
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
          // Navbar
          NavBarUser(),
          
          // Content (แบ่งครึ่งซ้าย-ขวา)
          Expanded(
            child: Row(
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
                          key: _kcalbarKey,
                          onRefresh: () {
                            print('✅ Kcalbar refreshed!');
                          },
                        ),

                        const SizedBox(height: 50),

                        NutritionPieChartComponent(
                          carbs: 250,
                          fats: 70,
                          protein: 150,
                        ),

                        const SizedBox(height: 50),

                        ListSportPage(
                          sportName: 'sportName',
                          time: 5,
                          caloriesBurned: 41,
                        ),
                      ],
                    ),
                  ),
                ),

                // ฝั่งขวา - Activity Factor & Menu
                Expanded(
                  flex: 1, // อีกครึ่งหนึ่ง
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

                        ListMenuPage(
                          name: 'pizza',
                          calories: 254,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // แสดง Camera button เฉพาะเมื่อเลือกระดับกิจกรรมแล้ว
          if (_hasSelectedActivityLevel) CameraIconButton(),
        ],
      ),
    );
  }
}