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
      final recommendations = await RecommendationService.getSportRecommendations(
        userId: widget.userId,
        topN: 5,
      );

      final items = recommendations
          .map((rec) => SportItem.fromJson(rec))
          .where((item) => item.calories.abs() <= widget.remainingCalories)
          .toList();

      setState(() {
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth * 0.04;
    final headerFontSize = screenWidth * 0.05;
    final spacing = screenWidth * 0.02;
    final borderWidth = screenWidth * 0.012;
    final shadowOffset = screenWidth * 0.02;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFAA),
        border: Border.all(width: borderWidth, color: const Color(0xFF2a2a2a)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: Offset(shadowOffset, shadowOffset),
            blurRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(spacing * 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "RECOMMEND SPORT",
            style: TextStyle(
              fontSize: headerFontSize,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: const Color(0xFF2a2a2a),
              fontFamily: 'TA8bit',
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: spacing),
          Container(height: borderWidth, color: const Color(0xFF2a2a2a)),
          SizedBox(height: spacing * 2),
          if (loading)
            Center(
              child: Text(
                "กำลังโหลด...",
                style: TextStyle(color: Colors.black54, fontSize: fontSize),
              ),
            )
          else if (sportList.isEmpty)
            Center(
              child: Text(
                "ไม่มีกีฬาที่เหมาะสม",
                style: TextStyle(color: Colors.black54, fontSize: fontSize),
              ),
            )
          else
            ...sportList.map((item) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: spacing),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "🏃‍♂️ ${item.name}",
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF2a2a2a),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                    SizedBox(width: spacing),
                    Text(
                      "${item.calories} kcal",
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2a2a2a),
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
