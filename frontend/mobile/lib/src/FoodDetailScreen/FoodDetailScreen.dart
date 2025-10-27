import 'dart:io';
import 'package:flutter/material.dart';
import '../../service/predict_service.dart';

class FoodDetailScreen extends StatefulWidget {
  final File imageFile;
  final String foodName;
  final int foodId;
  final int carbs;
  final int fat;
  final int protein;
  final int calories;
  final double confidence;

  const FoodDetailScreen({
    super.key,
    required this.imageFile,
    required this.foodName,
    required this.foodId,
    required this.carbs,
    required this.fat,
    required this.protein,
    required this.calories,
    required this.confidence,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  bool _isSaving = false;

  Future<void> _saveMeal() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    // แสดง loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'กำลังบันทึกข้อมูล...',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // บันทึกข้อมูล (ดึง userId จาก SharedPreferences อัตโนมัติ)
      final result = await PredictService.saveMeal(
        foodId: widget.foodId,
        confidenceScore: widget.confidence,
      );

      if (!mounted) return;

      Navigator.pop(context); // ปิด loading dialog

      if (result['success'] == true) {
        // แสดง success dialog
        await _showSuccessDialog();

        // กลับไปหน้าหลักอัตโนมัติ
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        // แสดง error dialog
        _showErrorDialog(
          'เกิดข้อผิดพลาด',
          result['error'] ?? 'ไม่สามารถบันทึกข้อมูลได้',
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context); // ปิด loading dialog

      _showErrorDialog(
        'เกิดข้อผิดพลาด',
        'ไม่สามารถบันทึกข้อมูลได้ กรุณาลองใหม่อีกครั้ง',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // ปิด dialog อัตโนมัติหลัง 2 วินาที
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });

        return Center(
          child: Dialog(
            insetPadding: const EdgeInsets.all(24),
            backgroundColor: const Color(0xFFf8f8f8),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 4),
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFD4F2C1),
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(6, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFA3EBA1),
                    child: const Text(
                      'สำเร็จ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.check_circle_outline,
                    size: 48,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'บันทึกข้อมูลสำเร็จ',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'กำลังกลับสู่หน้าหลัก...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Dialog(
            insetPadding: const EdgeInsets.all(24),
            backgroundColor: const Color(0xFFf8f8f8),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 4),
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFC1C1),
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: const Offset(6, 6),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: const Color(0xFFFF6B6B),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: const Text(
                        'ตกลง',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
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
                child: Image.file(widget.imageFile, fit: BoxFit.cover),
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
                    _infoBox('เมนู : ${widget.foodName}'),
                    _infoBox('คาร์บ : ${widget.carbs} g'),
                    _infoBox('ไขมัน : ${widget.fat} g'),
                    _infoBox('โปรตีน : ${widget.protein} g'),
                    _infoBox('แคลอรี่ : ${widget.calories} kcal'),
                    _infoBox('ความแม่นยำ : ${(widget.confidence * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ปุ่ม SAVE
              InkWell(
                onTap: _isSaving ? null : _saveMeal,
                child: Container(
                  width: 120,
                  height: 45,
                  decoration: BoxDecoration(
                    color: _isSaving ? const Color(0xFFCCCCCC) : const Color(0xFFA3EBA1),
                    border: Border.all(color: Colors.black, width: 4),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _isSaving ? 'SAVING...' : 'SAVE',
                    style: const TextStyle(
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
