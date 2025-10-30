import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../FoodDetailScreen/FoodDetailScreen.dart';
import '../../service/predict_service.dart';

class CameraBottomNavBar extends StatelessWidget {
  const CameraBottomNavBar({super.key});

  // ✅ Responsive helper
  double _responsiveSize(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    if (width < 400) return base * 0.8; // มือถือเล็ก
    if (width > 600) return base * 1.2; // แท็บเล็ต
    return base; // ปกติ
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        final width = MediaQuery.of(context).size.width;
        final dialogWidth = width * 0.85; // ✅ ปรับขนาด dialog ตามจอ
        return Center(
          child: Dialog(
            insetPadding: const EdgeInsets.all(24),
            backgroundColor: const Color(0xFFf8f8f8),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.black, width: 4),
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final dialogWidth = MediaQuery.of(context).size.width * 0.8;
        return Center(
          child: Container(
            width: dialogWidth,
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
      final isClear = await PredictService.isImageClear(imageFile);

      if (!isClear) {
        Navigator.pop(context);
        if (context.mounted) {
          _showErrorDialog(
            context,
            'ภาพไม่ชัดเจน',
            'กรุณาถ่ายภาพใหม่ให้ชัดเจนกว่านี้',
          );
        }
        return;
      }

      final result = await PredictService.predictFood(imageFile);
      Navigator.pop(context);

      if (!context.mounted) return;

      if (result['success'] == true && result['data'] != null) {
        final data = result['data'];
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
        _showErrorDialog(
          context,
          result['low_confidence'] == true ? 'ไม่ใช่อาหาร' : 'เกิดข้อผิดพลาด',
          result['error'] ?? 'ไม่สามารถทำนายภาพได้',
        );
      }
    } catch (e) {
      Navigator.pop(context);
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
    final dialogWidth = MediaQuery.of(context).size.width * 0.85;
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
              width: dialogWidth,
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

  static Widget _optionBox({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fontSize = constraints.maxWidth < 320 ? 12.0 : 14.0;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: 3),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: fontSize + 4),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double size = _responsiveSize(context, 64); // ✅ responsive button size
    return Container(
      height: _responsiveSize(context, 80),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: const Border(
          top: BorderSide(color: Colors.black, width: 3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: GestureDetector(
          onTap: () => _pickImage(context),
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: const Color(0xFFA3EBA1),
              border: Border.all(color: Colors.black, width: 4),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt,
              size: size * 0.5,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
