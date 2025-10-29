import 'package:flutter/material.dart';
import 'dart:async';

class MenuItem {
  final int id;
  final String name;
  final int calories;

  MenuItem({required this.id, required this.name, required this.calories});
}

class RacMenu extends StatefulWidget {
  final int remainingCalories;
  final int refreshTrigger; // ใช้เพื่อ refresh เมื่อแนบรูปใหม่

  const RacMenu({
    super.key,
    required this.remainingCalories,
    required this.refreshTrigger,
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

    // จำลองดีเลย์โหลด 0.8 วิ
    await Future.delayed(const Duration(milliseconds: 800));

    // เมนูจำลอง
    final mockMenu = [
      MenuItem(id: 1, name: 'ข้าวผัดกุ้ง', calories: 450),
      MenuItem(id: 2, name: 'สลัดไก่ย่าง', calories: 250),
      MenuItem(id: 3, name: 'เกาเหลาหมูตุ๋น', calories: 300),
    ];

    // เลือกเมนูที่แคลอรี่ไม่เกินแคลที่เหลือ
    final filtered = mockMenu
        .where((m) => m.calories <= widget.remainingCalories)
        .toList();

    setState(() {
      menuList = filtered.take(3).toList();
      loading = false;
    });
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
              child: Text(
                "กำลังโหลด...",
                style: TextStyle(color: Colors.grey),
              ),
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
