// componants/ListMenu.dart
import 'package:flutter/material.dart';
import '../../service/list_service.dart';
import '../../models/list_models.dart';

class ListMenuPage extends StatefulWidget {
  const ListMenuPage({super.key});

  @override
  State<ListMenuPage> createState() => _ListMenuPageState();
}

class _ListMenuPageState extends State<ListMenuPage> {
  final ListService _listService = ListService();
  List<MealItem> _meals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meals = await _listService.getTodayMeals();
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading meals';
        _isLoading = false;
      });
    }
  }

  // Public refresh method ที่จะถูกเรียกจาก parent widget
  void refresh() {
    _loadMeals();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ใช้ MediaQuery เพื่อคำนวณขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ ปรับขนาด font/padding ตามหน้าจอ
    final bool isSmallScreen = screenWidth < 400;
    final double fontSizeTitle = isSmallScreen ? 18 : 24;
    final double fontSizeText = isSmallScreen ? 12 : 16;
    final double padding = isSmallScreen ? 10 : 20;
    final double containerHeight = isSmallScreen ? screenHeight * 0.4 : 264;

    return Container(
      height: containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 219, 249, 255),
        border: Border.all(color: const Color(0xFF2a2a2a), width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Center(
            child: Text(
              'LIST MENU',
              style: TextStyle(
                fontSize: fontSizeTitle,
                fontWeight: FontWeight.bold,
                letterSpacing: 4,
                color: const Color(0xFF2a2a2a),
                fontFamily: 'TA8bit',
              ),
            ),
          ),
          const SizedBox(height: 10),

          // หัวคอลัมน์
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'FOOD',
                  style: TextStyle(
                    fontSize: fontSizeText,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2a2a2a),
                    fontFamily: 'TA8bit',
                  ),
                ),
              ),
              Text(
                'KCAL',
                style: TextStyle(
                  fontSize: fontSizeText,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2a2a2a),
                  fontFamily: 'TA8bit',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // เส้นคั่น
          Container(height: 3, color: const Color(0xFF2a2a2a)),
          const SizedBox(height: 10),

          // เนื้อหา
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2a2a2a),
                    ),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: fontSizeText,
                                color: Colors.red,
                                fontFamily: 'TA8bit',
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadMeals,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2a2a2a),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(fontFamily: 'TA8bit'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _meals.isEmpty
                        ? Center(
                            child: Text(
                              'No meals today',
                              style: TextStyle(
                                fontSize: fontSizeText,
                                color: const Color(0xFF2a2a2a),
                                fontFamily: 'TA8bit',
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: _meals.asMap().entries.map((entry) {
                                final meal = entry.value;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          meal.foodName,
                                          style: TextStyle(
                                            fontSize: fontSizeText,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2a2a2a),
                                            fontFamily: 'TA8bit',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${meal.calories}',
                                        style: TextStyle(
                                          fontSize: fontSizeText,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2a2a2a),
                                          fontFamily: 'TA8bit',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
