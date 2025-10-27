import 'dart:io';
import 'package:flutter/material.dart';

class FoodDetailScreen extends StatelessWidget {
  final File imageFile;
  final String foodName;
  final int carbs;
  final int fat;
  final int protein;
  final int calories;

  const FoodDetailScreen({
    super.key,
    required this.imageFile,
    required this.foodName,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        child: Column(
          children: [
            // ปุ่มย้อนกลับ
            Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, size: 32, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const SizedBox(height: 10),

            // รูปอาหาร
            Container(
              width: 260,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(4),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.file(imageFile, fit: BoxFit.cover),
            ),
            const SizedBox(height: 20),

            // กล่องข้อมูลอาหาร
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: 3),
                color: const Color(0xFFE0E0E0),
              ),
              padding: const EdgeInsets.all(8),
              width: 240,
              child: Column(
                children: [
                  const Text(
                    'What food is this',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _infoBox('เมนู : $foodName'),
                  _infoBox('คาร์บ : $carbs'),
                  _infoBox('ไขมัน : $fat'),
                  _infoBox('โปรตีน : $protein'),
                  _infoBox('แคลอรี่ : $calories'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ปุ่ม SAVE
            InkWell(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('บันทึกข้อมูลสำเร็จ ✓')),
                );
              },
              child: Container(
                width: 120,
                height: 45,
                decoration: BoxDecoration(
                  color: const Color(0xFFA3EBA1),
                  border: Border.all(color: Colors.black, width: 4),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'SAVE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBox(String text) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFFFFB3),
      padding: const EdgeInsets.symmetric(vertical: 4),
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
