import 'package:flutter/material.dart';
import 'dart:async';
import '../../service/recommend_service.dart'; // ✅ import service

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
  final int refreshTrigger; // จะเปลี่ยนเมื่อแนบรูปใหม่
  final int userId; // ✅ เพิ่ม userId

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
      // ✅ เรียกใช้ static method โดยตรง
      final recommendations = await RecommendationService.getSportRecommendations(
        userId: widget.userId,
        topN: 5,
      );

      // ✅ แปลงข้อมูลจาก API เป็น SportItem และกรองตาม remainingCalories
      final items = recommendations
          .map((rec) => SportItem.fromJson(rec))
          .where((item) => item.calories.abs() <= widget.remainingCalories)
          .toList();

      setState(() {
        sportList = items.take(3).toList();
        loading = false;
      });
    } catch (e) {
      // ignore: avoid_print
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
    // ถ้า refreshTrigger เปลี่ยน → โหลดข้อมูลใหม่
    if (oldWidget.refreshTrigger != widget.refreshTrigger) {
      fetchRecommend();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFAA),
        border: Border.all(width: 5, color: const Color(0xFF2a2a2a)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(8, 8),
            blurRadius: 0,
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "RECOMMEND SPORT",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: Color(0xFF2a2a2a),
              fontFamily: 'TA8bit',
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(height: 3, color: const Color(0xFF2a2a2a)),
          const SizedBox(height: 16),
          if (loading)
            const Center(
              child: Text(
                "กำลังโหลด...",
                style: TextStyle(color: Colors.black54),
              ),
            )
          else if (sportList.isEmpty)
            const Center(
              child: Text(
                "ไม่มีกีฬาที่เหมาะสม",
                style: TextStyle(color: Colors.black54),
              ),
            )
          else
            ...sportList.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "🏃‍♂️ ${item.name}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2a2a2a),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "${item.calories} kcal",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2a2a2a),
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
