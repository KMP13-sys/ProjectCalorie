import 'package:flutter/material.dart';
import 'dart:async';

class RacSport extends StatefulWidget {
  final int remainingCalories;
  final int refreshTrigger; // จะเปลี่ยนเมื่อแนบรูปใหม่

  const RacSport({
    Key? key,
    required this.remainingCalories,
    required this.refreshTrigger,
  }) : super(key: key);

  @override
  State<RacSport> createState() => _RacSportState();
}

class _RacSportState extends State<RacSport> {
  bool loading = true;
  List<Map<String, dynamic>> sportList = [];

  Future<void> fetchRecommend() async {
    setState(() => loading = true);

    // จำลองดีเลย์โหลด 0.8 วิ
    await Future.delayed(const Duration(milliseconds: 800));

    final mockMenu = [
      {'id': 1, 'name': 'วิ่ง', 'calories': -450},
      {'id': 2, 'name': 'เต้น', 'calories': -250},
      {'id': 3, 'name': 'นอน', 'calories': -300},
    ];

    // กรองข้อมูลตาม remainingCalories
        // ...existing code...
        final filtered = mockMenu
            .where((m) => (m['calories'] as int).abs() <= widget.remainingCalories)
            .take(3)
            .toList();
        // ...existing code...


    setState(() {
      sportList = filtered;
      loading = false;
    });
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
            Expanded(
              child: ListView.builder(
                itemCount: sportList.length,
                itemBuilder: (context, index) {
                  final item = sportList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2a2a2a),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
