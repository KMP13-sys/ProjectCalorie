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
import '../componants/RecMenu.dart';
import '../componants/RecSport.dart';
import '../componants/Activity.dart';
import '../componants/WeeklyGraph.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final GlobalKey _kcalbarKey = GlobalKey();
  final GlobalKey _listSportKey = GlobalKey();
  final GlobalKey _listMenuKey = GlobalKey();
  final GlobalKey _recMenuKey = GlobalKey();
  final GlobalKey _recSportKey = GlobalKey();
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
      // Refresh ทุก component เมื่อกลับมาที่หน้าจอนี้ (เช่น หลังจากถ่ายรูปอาหาร)
      _refreshKcalbar();
      _refreshListMenu();
      _refreshListSport();
      _refreshRecMenu();
      _refreshRecSport();
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

  void _refreshListSport() {
    final state = _listSportKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
  }

  void _refreshListMenu() {
    final state = _listMenuKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
  }

  void _refreshRecMenu() {
    final state = _recMenuKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
  }

  void _refreshRecSport() {
    final state = _recSportKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ Responsive calculations
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMobileScreen = screenWidth < 400;

    final double containerPadding = isMobileScreen ? 8.0 : isSmallScreen ? 12.0 : 16.0;
    final double spacing = isMobileScreen ? 30.0 : isSmallScreen ? 40.0 : 50.0;
    final double smallSpacing = isMobileScreen ? 2.0 : 5.0;
    final double graphHeight = screenHeight * (isMobileScreen ? 0.35 : isSmallScreen ? 0.40 : 0.45);

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
                          padding: EdgeInsets.all(containerPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Kcalbar(key: _kcalbarKey),
                              SizedBox(height: smallSpacing),
                              const NutritionPieChartComponent(),
                              SizedBox(height: smallSpacing),
                              ListSportPage(key: _listSportKey),
                              SizedBox(height: smallSpacing),
                              // ✅ RecSport ในฝั่งซ้าย
                              if (_userId != null)
                                RacSport(
                                  key: _recSportKey,
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
                          padding: EdgeInsets.all(containerPadding),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ActivityFactorButton(
                                onCaloriesUpdated: _refreshKcalbar,
                              ),
                              SizedBox(height: isMobileScreen ? 15 : 20),
                              ListMenuPage(key: _listMenuKey),
                              SizedBox(height: smallSpacing),

                              // ✅ เชื่อม RacMenu เข้ากับ RecommendationService
                              if (_userId != null)
                                RacMenu(
                                  key: _recMenuKey,
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

                              SizedBox(height: smallSpacing),
                              Activity(
                                onSave: (burned) {
                                  _refreshKcalbar();
                                  _refreshListSport();
                                  _refreshRecSport();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: isMobileScreen ? 3 : 5),

                  // Weekly Graph - ✅ Responsive height
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobileScreen ? 2 : 4,
                      vertical: isMobileScreen ? 6 : 10.0,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: graphHeight,
                      child: const WeeklyGraph(),
                    ),
                  ),

                  SizedBox(height: smallSpacing),
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
