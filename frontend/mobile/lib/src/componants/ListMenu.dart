// componants/ListMenu.dart
import 'package:flutter/material.dart';

class ListMenuPage extends StatelessWidget {
  final String name;
  final int calories;

  const ListMenuPage({
    super.key,
    required this.name,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 264,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 252, 251, 192),
        border: Border.all(color: const Color(0xFF2a2a2a), width: 5),
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
        children: [
          // Header
          const Text(
            'LIST MENU',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: Color(0xFF2a2a2a),
              fontFamily: 'TA8bit',
            ),
          ),
          const SizedBox(height: 20),

          // รายการอาหาร
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(10, (index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // ชื่ออาหาร
                        Expanded(
                          child: Text(
                            '$name ${index + 1}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2a2a2a),
                              fontFamily: 'TA8bit',
                            ),
                          ),
                        ),

                        // แคลอรี่
                        Text(
                          '$calories Kcal',
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