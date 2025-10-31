import 'package:flutter/material.dart';
import 'dart:async';
import '../../service/recommend_service.dart';

class SportItem {
  final int id;
  final String name;
  final int calories;

  SportItem({required this.id, required this.name, required this.calories});

  factory SportItem.fromJson(Map<String, dynamic> json) {
    return SportItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'ไม่ทราบชื่อ',
      calories: (json['calories'] ?? 0).toInt(),
    );
  }
}

class RacSport extends StatefulWidget {
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
  bool loading = true;
  List<SportItem> sportList = [];

  Future<void> fetchRecommend() async {
    setState(() => loading = true);

    try {
      final recommendations =
          await RecommendationService.getSportRecommendations(
            userId: widget.userId,
            topN: 5,
          );

      final items = recommendations
          .map((rec) => SportItem.fromJson(rec))
          .toList();

      setState(() {
        // ✅ เอาแค่ 3 รายการแรก เพราะ API ไม่ส่ง calories มาให้ filter
        sportList = items.take(3).toList();
        loading = false;
      });
    } catch (e) {
      print("❌ Error: $e");
      setState(() {
        sportList = [];
        loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchRecommend();
  }

  @override
  void didUpdateWidget(covariant RacSport oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      fetchRecommend();
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

          // หัวคอลัมน์
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
