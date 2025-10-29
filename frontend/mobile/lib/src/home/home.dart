// lib/src/home/home.dart
import 'package:flutter/material.dart';
import '../../service/storage_helper.dart'; // ✅ ใช้ StorageHelper แทน SharedPreferences

import '../componants/navbaruser.dart';
import '../componants/Kcalbar.dart';
import '../componants/camera.dart';
import '../componants/activityfactor.dart';
import '../componants/piegraph.dart';
import '../componants/ListMenu.dart';
import '../componants/ListSport.dart';
import '../componants/RacMenu.dart';
import '../componants/RacSport.dart';
import '../componants/Activity.dart';
import '../componants/WeeklyGraph.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey _kcalbarKey = GlobalKey();
  bool _hasSelectedActivityLevel = false;

  int? _userId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActivityLevelStatus();
    });
    _loadUserInfo(); // ✅ โหลด token / userId
  }

  Future<void> _loadUserInfo() async {
    // ✅ ใช้ StorageHelper ดึง userId จาก secure storage
    final userIdStr = await StorageHelper.getUserId();
    setState(() {
      _userId = userIdStr != null ? int.tryParse(userIdStr) : null;
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
    if (state == AppLifecycleState.resumed) {
      _checkActivityLevelStatus();
    }
  }

  Future<void> _checkActivityLevelStatus() async {
    final state = _kcalbarKey.currentState;
    if (state != null) {
      final hasData = await (state as dynamic).hasCalorieData();
      if (mounted) {
        setState(() {
          _hasSelectedActivityLevel = hasData;
        });
      }
    }
  }

  void _refreshKcalbar() {
    final state = _kcalbarKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
    _checkActivityLevelStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDBFFC8),
      body: Column(
        children: [
          // Navbar บน
          NavBarUser(),

          // เนื้อหา Scroll ได้
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // แบ่งฝั่งซ้าย/ขวา
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ฝั่งซ้าย
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Kcalbar(key: _kcalbarKey),
                              const SizedBox(height: 50),
                              const NutritionPieChartComponent(),
                              const SizedBox(height: 50),
                              const ListSportPage(),
                              const SizedBox(height: 10),
                              if (_userId != null)
                                RacSport(
                                  remainingCalories: 500,
                                  refreshTrigger: 5,
                                  userId: _userId!,
                                )
                              else
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "กำลังโหลดข้อมูลผู้ใช้...",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),

                      // ฝั่งขวา
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ActivityFactorButton(
                                onCaloriesUpdated: _refreshKcalbar,
                              ),
                              const SizedBox(height: 20),
                              const ListMenuPage(),
                              const SizedBox(height: 10),

                              // ✅ เชื่อม RacMenu เข้ากับ RecommendationService
                              if (_userId != null)
                                RacMenu(
                                  remainingCalories: 500,
                                  refreshTrigger: 3,
                                  userId: _userId!,
                                )
                              else
                                const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "กำลังโหลดข้อมูลผู้ใช้...",
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 10),
                              Activity(
                                onSave: (burned) {
                                  _refreshKcalbar();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Weekly Graph
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 10.0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 200,
                      child: WeeklyGraph(),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),

      // Navbar ล่าง (กล้อง)
      bottomNavigationBar: _hasSelectedActivityLevel
          ? const CameraBottomNavBar()
          : null,
    );
  }
}
