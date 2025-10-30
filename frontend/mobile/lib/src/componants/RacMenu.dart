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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.04; // responsive font
    final headerFontSize = screenWidth * 0.05;
    final spacing = screenWidth * 0.02;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFAA),
        border: Border.all(width: screenWidth * 0.012, color: const Color(0xFF2A2A2A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(screenWidth * 0.02, screenWidth * 0.02),
            blurRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(screenWidth * 0.04),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "RECOMMEND MENU",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'TA8bit',
              fontWeight: FontWeight.bold,
              fontSize: headerFontSize,
              letterSpacing: 4,
              color: const Color(0xFF2A2A2A),
            ),
          ),
          SizedBox(height: spacing),
          Container(height: screenWidth * 0.008, color: const Color(0xFF2A2A2A)),
          SizedBox(height: spacing * 1.5),

          if (loading)
            Center(
              child: Text("กำลังโหลด...",
                  style: TextStyle(color: Colors.grey, fontSize: fontSize)),
            )
          else if (menuList.isEmpty)
            Center(
              child: Text(
                "ไม่มีเมนูที่เหมาะสม",
                style: TextStyle(color: Colors.grey, fontSize: fontSize),
              ),
            )
          else
            ...menuList.map((item) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: spacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2A2A2A),
                          fontSize: fontSize,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Text(
                      "${item.calories} kcal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2A2A2A),
                        fontSize: fontSize,
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
