import 'package:flutter/material.dart';
import 'dart:async';
import '../../service/recommend_service.dart'; // ✅ import service

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
  final int userId; // ✅ เพิ่ม userId เพื่อดึงข้อมูลแนะนำ
  final String token; // ✅ เพิ่ม token เพื่อส่ง header Authorization

  const RacMenu({
    super.key,
    required this.remainingCalories,
    required this.refreshTrigger,
    required this.userId,
    required this.token,
  });

  @override
  State<RacMenu> createState() => _RacMenuState();
}

class _RacMenuState extends State<RacMenu> {
  bool loading = true;
  List<MenuItem> menuList = [];

  late RecommendationService recService;

  @override
  void initState() {
    super.initState();
    recService = RecommendationService(token: widget.token);
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
      final recommendations = await recService.getFoodRecommendations(
        userId: widget.userId,
        topN: 5,
      );

      // ✅ แปลงข้อมูลจาก API เป็น MenuItem
      final items = recommendations
          .map((rec) {
            return MenuItem.fromJson(rec);
          })
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
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFAA),
        border: Border.all(width: 5, color: const Color(0xFF2A2A2A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "RECOMMEND MENU",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'TA8bit',
              fontWeight: FontWeight.bold,
              fontSize: 15,
              letterSpacing: 4,
              color: Color(0xFF2A2A2A),
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 3, color: const Color(0xFF2A2A2A)),
          const SizedBox(height: 12),

          if (loading)
            const Center(
              child: Text("กำลังโหลด...", style: TextStyle(color: Colors.grey)),
            )
          else if (menuList.isEmpty)
            const Center(
              child: Text(
                "ไม่มีเมนูที่เหมาะสม",
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...menuList.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "🍽️ ${item.name}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2A2A),
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "${item.calories} kcal",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2A2A),
                        fontSize: 16,
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
