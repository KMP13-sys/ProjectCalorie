// componants/ListSport.dart
import 'package:flutter/material.dart';

class ListSportPage extends StatelessWidget {
  final String sportName;
  final int time; // เวลาที่ออกกำลังกาย (นาที)
  final int caloriesBurned; // แคลอรี่ที่เผาผลาญ

  const ListSportPage({
    super.key,
    required this.sportName,
    required this.time,
    required this.caloriesBurned,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 264,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 252, 251, 192),
        border: Border.all(color: const Color(0xFF2a2a2a), width: 5),
        borderRadius: BorderRadius.zero, // ✅ ขอบเหลี่ยม
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'LIST SPORT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: Color(0xFF2a2a2a),
              fontFamily: 'TA8bit',
            ),
          ),
          const SizedBox(height: 10),

          // ✅ หัวข้อคอลัมน์
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'SPORT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2a2a2a),
                    fontFamily: 'TA8bit',
                  ),
                ),
              ),
              SizedBox(width: 40),
              Text(
                'TIME',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2a2a2a),
                  fontFamily: 'TA8bit',
                ),
              ),
              SizedBox(width: 30),
              Text(
                'BURN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2a2a2a),
                  fontFamily: 'TA8bit',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ✅ เส้นคั่นใต้หัวข้อ
          Container(
            height: 3,
            color: const Color(0xFF2a2a2a),
          ),
          const SizedBox(height: 10),

          // รายการกีฬา
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(10, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ชื่อกีฬา
                        Expanded(
                          child: Text(
                            '$sportName ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2a2a2a),
                              fontFamily: 'TA8bit',
                            ),
                          ),
                        ),

                        // เวลาที่ออกกำลังกาย
                        Text(
                          '$time',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2a2a2a),
                            fontFamily: 'TA8bit',
                          ),
                        ),

                        const SizedBox(width: 30),

                        // แคลอรี่ที่เผาผลาญ
                        Text(
                          '-$caloriesBurned',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2a2a2a),
                            fontFamily: 'TA8bit',
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
