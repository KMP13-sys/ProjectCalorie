import 'package:flutter/material.dart';
import 'dart:async';
import '../../service/recommend_service.dart';

class MenuItem {
  final int id;
  final String name;
  final int calories;

  MenuItem({required this.id, required this.name, required this.calories});

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'ไม่ทราบชื่อ',
      calories: (json['calories'] ?? 0).toInt(),
    );
  }
}

class RacMenu extends StatefulWidget {
  final int remainingCalories;
  final int refreshTrigger;
  final int userId;

  const RacMenu({
    super.key,
    required this.remainingCalories,
    required this.refreshTrigger,
    required this.userId,
  });

  @override
  State<RacMenu> createState() => _RacMenuState();
}

class _RacMenuState extends State<RacMenu> {
  bool loading = true;
  List<MenuItem> menuList = [];

  @override
  void initState() {
    super.initState();
    fetchRecommend();
  }

  @override
  void didUpdateWidget(RacMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingCalories != widget.remainingCalories ||
        oldWidget.refreshTrigger != widget.refreshTrigger) {
      fetchRecommend();
    }
  }

  Future<void> fetchRecommend() async {
    setState(() => loading = true);

    try {
      final recommendations = await RecommendationService.getFoodRecommendations(
        userId: widget.userId,
        topN: 5,
      );

      final items = recommendations
          .map((rec) => MenuItem.fromJson(rec))
          .where((item) => item.calories <= widget.remainingCalories)
          .toList();

      setState(() {
        menuList = items.take(3).toList();
        loading = false;
      });
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        menuList = [];
        loading = false;
      });
    }
  }

  // Public refresh method ที่จะถูกเรียกจาก parent widget
  void refresh() {
    fetchRecommend();
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
        color: const Color(0xFFFFFFAA),
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
              'RECOMMEND MENU',
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
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2a2a2a),
                    ),
                  )
                : menuList.isEmpty
                    ? Center(
                        child: Text(
                          'ไม่มีเมนูที่เหมาะสม',
                          style: TextStyle(
                            fontSize: fontSizeText,
                            color: const Color(0xFF2a2a2a),
                            fontFamily: 'TA8bit',
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: menuList.asMap().entries.map((entry) {
                            final item = entry.value;
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
                                      item.name,
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
                                    '${item.calories}',
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
