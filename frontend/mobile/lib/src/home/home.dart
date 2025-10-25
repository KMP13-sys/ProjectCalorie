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

                      
                      // ฝั่งขวา - ว่างไว้สำหรับเนื้อหาอื่น
                      Expanded(
                        flex: 1, // อีกครึ่งหนึ่ง
                        child: Container(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ActivityFactorButton(
                              ),

                              const SizedBox(height: 20),

                              ListMenuPage(
                                  name:'pizza' ,
                                  calories: 254,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),

            CameraIconButton()
        ],
      ),
    );
  }
}