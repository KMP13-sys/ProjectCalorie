import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../FoodDetailScreen/FoodDetailScreen.dart';
import '../../service/predict_service.dart';

class CameraBottomNavBar extends StatelessWidget {
  const CameraBottomNavBar({super.key});

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showDialog<ImageSource>(
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
                color: const Color(0xFFF2F2F2),
                border: Border.all(color: Colors.black, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
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
                    color: const Color(0xFFBDBDBD),
                    child: const Text(
                      'SELECT IMAGE SOURCE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  InkWell(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: _optionBox(
                      icon: Icons.camera_alt,
                      text: 'ถ่ายรูปใหม่ (Camera)',
                      color: const Color(0xFFD4F2C1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: _optionBox(
                      icon: Icons.photo_library,
                      text: 'เลือกรูปจากอัลบั้ม (Gallery)',
                      color: const Color(0xFFFFF3A3),
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 100,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCCCCC),
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: const Text(
                        'CANCEL',
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

    if (source != null) {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null && context.mounted) {
        final File imageFile = File(pickedFile.path);
        await _processImage(context, imageFile);
      }
    }
  }

  Future<void> _processImage(BuildContext context, File imageFile) async {
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
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(6, 6),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  strokeWidth: 3,
                ),
                SizedBox(height: 16),
                Text(
                  'กำลังวิเคราะห์ภาพอาหาร...',
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
      // ตรวจสอบความคมชัดของภาพ
      final isClear = await PredictService.isImageClear(imageFile);

      if (!isClear) {
        Navigator.pop(context); // ปิด loading dialog

        if (context.mounted) {
          _showErrorDialog(
            context,
            'ภาพไม่ชัดเจน',
            'กรุณาถ่ายภาพใหม่ให้ชัดเจนกว่านี้',
          );
        }
        return;
      }

      // ส่งภาพไปทำนาย (ดึง userId จาก SharedPreferences อัตโนมัติ)
      final result = await PredictService.predictFood(imageFile);

      Navigator.pop(context); // ปิด loading dialog

      if (!context.mounted) return;

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];

        // นำทางไปหน้าแสดงผล
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              imageFile: imageFile,
              foodName: data['predicted_food'] ?? 'ไม่ทราบชื่อ',
              foodId: data['food_id'] ?? 0,
              carbs: (data['nutrition']?['carbohydrate_gram'] ?? 0).toInt(),
              fat: (data['nutrition']?['fat_gram'] ?? 0).toInt(),
              protein: (data['nutrition']?['protein_gram'] ?? 0).toInt(),
              calories: (data['nutrition']?['calories'] ?? 0).toInt(),
              confidence: data['confidence'] ?? 0.0,
            ),
          ),
        );
      } else {
        // แสดง error dialog
        _showErrorDialog(
          context,
          result['low_confidence'] == true
            ? 'ไม่ใช่ภาพอาหาร'
            : 'เกิดข้อผิดพลาด',
          result['error'] ?? 'ไม่สามารถทำนายภาพได้',
        );
      }
    } catch (e) {
      Navigator.pop(context); // ปิด loading dialog

      if (context.mounted) {
        _showErrorDialog(
          context,
          'เกิดข้อผิดพลาด',
          'ไม่สามารถประมวลผลภาพได้ กรุณาลองใหม่อีกครั้ง',
        );
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
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
                    color: Colors.black.withOpacity(0.4),
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

  static Widget _optionBox({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 3),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: const Border(
          top: BorderSide(color: Colors.black, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFA3EBA1),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt,
              size: 32,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
