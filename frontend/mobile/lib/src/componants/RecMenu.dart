import 'package:flutter/material.dart';
import 'dart:async';
import '../../service/recommend_service.dart';

// MenuItem Model
// โมเดลสำหรับเก็บข้อมูลอาหาร
class MenuItem {
  final int id;
  final String name;
  final int calories;

  MenuItem({required this.id, required this.name, required this.calories});

  // Factory: แปลง JSON เป็น MenuItem object
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'ไม่ทราบชื่อ',
      calories: (json['calories'] ?? 0).toInt(),
    );
  }
}

// RacMenu Widget
// แสดงรายการอาหารที่แนะนำตามแคลอรี่ที่เหลือ
class RacMenu extends StatefulWidget {
  // Parameters
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
  // State Variables
  bool loading = true;
  List<MenuItem> menuList = [];

  // Lifecycle: โหลดรายการแนะนำเมื่อเริ่มต้น
  @override
  void initState() {
    super.initState();
    fetchRecommend();
  }

  // Lifecycle: รีเฟรชเมื่อ parameters เปลี่ยน
  @override
  void didUpdateWidget(RacMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.remainingCalories != widget.remainingCalories ||
        oldWidget.refreshTrigger != widget.refreshTrigger) {
      fetchRecommend();
    }
  }

  // Business Logic: ดึงรายการอาหารแนะนำจาก API
  Future<void> fetchRecommend() async {
    setState(() => loading = true);

    try {
      // API Call: ดึงรายการอาหารแนะนำ
      final recommendations = await RecommendationService.getFoodRecommendations(
        userId: widget.userId,
        topN: 5,
      );

      // Data: กรองเฉพาะอาหารที่แคลอรี่ไม่เกินค่าที่เหลือ และเลือก 3 รายการแรก
      final items = recommendations
          .map((rec) => MenuItem.fromJson(rec))
          .where((item) => item.calories <= widget.remainingCalories)
          .toList();

      setState(() {
        menuList = items.take(3).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        menuList = [];
        loading = false;
      });
    }
  }

  // Public Method: รีเฟรชรายการแนะนำ
  void refresh() {
    fetchRecommend();
  }

  // UI: สร้างหน้ารายการอาหารแนะนำแบบ Pixel Art Style
  @override
  Widget build(BuildContext context) {
    // Responsive: คำนวณขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive: ปรับขนาด font/padding/layout ตามหน้าจอ
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
            color: Colors.black.withValues(alpha: 0.3),
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section: Header
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

          // Section: Column Headers
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

          // Decoration: Divider
          Container(height: 3, color: const Color(0xFF2a2a2a)),
          const SizedBox(height: 10),

          // Section: Content - รายการอาหารแนะนำ
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
                            // Data: แต่ละรายการอาหาร
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
