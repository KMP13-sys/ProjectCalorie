import 'package:flutter/material.dart';
import 'dart:async';
import '../../service/recommend_service.dart';

// SportItem Model
// โมเดลสำหรับเก็บข้อมูลกีฬา
class SportItem {
  final int id;
  final String name;
  final int calories;

  SportItem({required this.id, required this.name, required this.calories});

  // Factory: แปลง JSON เป็น SportItem object
  factory SportItem.fromJson(Map<String, dynamic> json) {
    return SportItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'ไม่ทราบชื่อ',
      calories: (json['calories'] ?? 0).toInt(),
    );
  }
}

// RacSport Widget
// แสดงรายการกีฬาที่แนะนำ
class RacSport extends StatefulWidget {
  // Parameters
  final int remainingCalories;
  final int refreshTrigger;
  final int userId;

  const RacSport({
    Key? key,
    required this.remainingCalories,
    required this.refreshTrigger,
    required this.userId,
  }) : super(key: key);

  @override
  State<RacSport> createState() => _RacSportState();
}

class _RacSportState extends State<RacSport> {
  // State Variables
  bool loading = true;
  List<SportItem> sportList = [];

  // Business Logic: ดึงรายการกีฬาแนะนำจาก API
  Future<void> fetchRecommend() async {
    setState(() => loading = true);

    try {
      // API Call: ดึงรายการกีฬาแนะนำ
      final recommendations =
          await RecommendationService.getSportRecommendations(
            userId: widget.userId,
            topN: 5,
          );

      // Data: แปลงข้อมูลและเลือก 3 รายการแรก
      final items = recommendations
          .map((rec) => SportItem.fromJson(rec))
          .toList();

      setState(() {
        sportList = items.take(3).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        sportList = [];
        loading = false;
      });
    }
  }

  // Lifecycle: โหลดรายการแนะนำเมื่อเริ่มต้น
  @override
  void initState() {
    super.initState();
    fetchRecommend();
  }

  // Lifecycle: รีเฟรชเมื่อ refreshTrigger เปลี่ยน
  @override
  void didUpdateWidget(covariant RacSport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      fetchRecommend();
    }
  }

  // Public Method: รีเฟรชรายการแนะนำ
  void refresh() {
    fetchRecommend();
  }

  // UI: สร้างหน้ารายการกีฬาแนะนำแบบ Pixel Art Style
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
              'RECOMMEND SPORT',
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
                  'SPORT',
                  style: TextStyle(
                    fontSize: fontSizeText,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2a2a2a),
                    fontFamily: 'TA8bit',
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Decoration: Divider
          Container(height: 3, color: const Color(0xFF2a2a2a)),
          const SizedBox(height: 10),

          // Section: Content - รายการกีฬาแนะนำ
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF2a2a2a),
                    ),
                  )
                : sportList.isEmpty
                    ? Center(
                        child: Text(
                          'ไม่มีกีฬาที่เหมาะสม',
                          style: TextStyle(
                            fontSize: fontSizeText,
                            color: const Color(0xFF2a2a2a),
                            fontFamily: 'TA8bit',
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: sportList.asMap().entries.map((entry) {
                            // Data: แต่ละรายการกีฬา
                            final sport = entry.value;
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
                                      sport.name,
                                      style: TextStyle(
                                        fontSize: fontSizeText,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF2a2a2a),
                                        fontFamily: 'TA8bit',
                                      ),
                                      overflow: TextOverflow.ellipsis,
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
