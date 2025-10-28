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
  int _kcalbarStat = 2000;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

          // Content scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Row ฝั่งซ้าย/ขวา
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
                              Kcalbar(
                                key: _kcalbarKey,
                                onRefresh: _refreshKcalbar,
                              ),
                              const SizedBox(height: 50),
                              const NutritionPieChartComponent(),
                              const SizedBox(height: 50),
                              const ListSportPage(),
                              const SizedBox(height: 10),
                              const RacSport(
                                  remainingCalories: 500, refreshTrigger: 5),
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
                                  onCaloriesUpdated: _refreshKcalbar),
                              const SizedBox(height: 20),
                              const ListMenuPage(),
                              const SizedBox(height: 10),
                              const RacMenu(
                                  remainingCalories: 500, refreshTrigger: 3),
                              const SizedBox(height: 10),
                              Activity(onSave: (burned) {
                                setState(() {
                                  _kcalbarStat -= burned;
                                });
                                _refreshKcalbar();
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // WeeklyGraph อยู่กลางและ scroll ได้
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10.0), // เว้นขอบซ้าย-ขวา, บน-ล่าง
                    child: SizedBox(
                      width: double.infinity, // ให้เต็มความกว้างภายใน Padding
                      height: 200, // กำหนดความสูง
                      child: WeeklyGraph(),
                    ),
                  ),


                  const SizedBox(height: 10), // เว้นด้านล่าง
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
