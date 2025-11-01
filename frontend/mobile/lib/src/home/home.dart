import 'package:flutter/material.dart';
import '../../service/storage_helper.dart';
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

/// HomeScreen Widget
/// หน้าหลักของแอปพลิเคชัน - แสดงข้อมูลแคลอรี่, รายการอาหาร, กิจกรรม, และคำแนะนำ
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  /// State Variables: Global Keys สำหรับ Refresh Components
  final GlobalKey _kcalbarKey = GlobalKey();
  final GlobalKey _listSportKey = GlobalKey();
  final GlobalKey _listMenuKey = GlobalKey();
  final GlobalKey _recMenuKey = GlobalKey();
  final GlobalKey _recSportKey = GlobalKey();

  /// State Variables: UI State
  bool _hasSelectedActivityLevel = false;
  int? _userId;

  /// Lifecycle: เริ่มต้น Observers และโหลดข้อมูลผู้ใช้
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkActivityLevelStatus();
    });
    _loadUserInfo();
  }

  /// Business Logic: โหลดข้อมูลผู้ใช้จาก Storage
  Future<void> _loadUserInfo() async {
    final userIdStr = await StorageHelper.getUserId();
    setState(() {
      _userId = userIdStr != null ? int.tryParse(userIdStr) : null;
    });
  }

  /// Lifecycle: ทำความสะอาด Observers
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Lifecycle: จัดการ App Lifecycle State (กลับมาที่แอป)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _checkActivityLevelStatus();
      _refreshKcalbar();
      _refreshListMenu();
      _refreshListSport();
      _refreshRecMenu();
      _refreshRecSport();
    }
  }

  /// Business Logic: ตรวจสอบว่าผู้ใช้เลือก Activity Level แล้วหรือยัง
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

  /// Helper: Refresh Kcalbar Component
  void _refreshKcalbar() {
    final state = _kcalbarKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
    _checkActivityLevelStatus();
  }

  /// Helper: Refresh ListSport Component
  void _refreshListSport() {
    final state = _listSportKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
  }

  /// Helper: Refresh ListMenu Component
  void _refreshListMenu() {
    final state = _listMenuKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
  }

  /// Helper: Refresh RecMenu Component
  void _refreshRecMenu() {
    final state = _recMenuKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
  }

  /// Helper: Refresh RecSport Component
  void _refreshRecSport() {
    final state = _recSportKey.currentState;
    if (state != null) {
      (state as dynamic).refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Responsive: คำนวณขนาดและ spacing ตามขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 600;
    final bool isMobileScreen = screenWidth < 400;

    final double containerPadding = isMobileScreen ? 8.0 : isSmallScreen ? 12.0 : 16.0;
    final double smallSpacing = isMobileScreen ? 2.0 : 5.0;
    final double graphHeight = screenHeight * (isMobileScreen ? 0.35 : isSmallScreen ? 0.40 : 0.45);

    return Scaffold(
      backgroundColor: const Color(0xFFDBFFC8),
      body: Column(
        children: [
          // Section: Navbar
          NavBarUser(),

          // Section: Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Section: Two Column Layout
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section: Left Column
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

                              // Section: Recommended Sport
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

                      // Section: Right Column
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

                              // Section: Recommended Menu
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

                  // Section: Weekly Graph (Responsive height)
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

      // Section: Bottom Navigation Bar (Camera - แสดงเมื่อเลือก Activity Level แล้ว)
      bottomNavigationBar: _hasSelectedActivityLevel
          ? const CameraBottomNavBar()
          : null,
    );
  }
}
