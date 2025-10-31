import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../FoodDetailScreen/FoodDetailScreen.dart';
import '../../service/predict_service.dart';

class CameraBottomNavBar extends StatelessWidget {
  const CameraBottomNavBar({super.key});

  // ✅ Responsive helper - ปรับขนาดตามหน้าจอ
  double _responsiveSize(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return base * 0.75; // มือถือเล็กมาก
    if (width < 400) return base * 0.85; // มือถือเล็ก
    if (width > 600) return base * 1.2; // แท็บเล็ต
    return base; // ปกติ
  }

  // ✅ Responsive font size
  double _responsiveFontSize(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return base * 0.85;
    if (width < 400) return base * 0.9;
    if (width > 600) return base * 1.1;
    return base;
  }

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        // ✅ Responsive dialog sizing
        final width = MediaQuery.of(context).size.width;
        final bool isSmallScreen = width < 400;
        final double dialogWidth = isSmallScreen ? width * 0.9 : width * 0.85;
        final double dialogPadding = isSmallScreen ? 12 : 16;
        final double titleFontSize = _responsiveFontSize(context, 16);
        final double textFontSize = _responsiveFontSize(context, 14);
        final double spacing = isSmallScreen ? 10 : 12;

        return Center(
          child: Dialog(
            insetPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            backgroundColor: const Color(0xFFf8f8f8),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.black,
                width: isSmallScreen ? 3 : 4,
              ),
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                border: Border.all(
                  color: Colors.black,
                  width: isSmallScreen ? 3 : 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: Offset(
                      isSmallScreen ? 4 : 6,
                      isSmallScreen ? 4 : 6,
                    ),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: EdgeInsets.all(dialogPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 6 : 8,
                    ),
                    color: const Color(0xFFBDBDBD),
                    child: Text(
                      'SELECT IMAGE SOURCE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  InkWell(
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                    child: _optionBox(
                      context: context,
                      icon: Icons.camera_alt,
                      text: 'ถ่ายรูปใหม่ (Camera)',
                      color: const Color(0xFFD4F2C1),
                    ),
                  ),
                  SizedBox(height: spacing),
                  InkWell(
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                    child: _optionBox(
                      context: context,
                      icon: Icons.photo_library,
                      text: 'เลือกรูปจากอัลบั้ม (Gallery)',
                      color: const Color(0xFFFFF3A3),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: isSmallScreen ? 80 : 100,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFCCCCCC),
                        border: Border.all(
                          color: Colors.black,
                          width: isSmallScreen ? 2 : 3,
                        ),
                      ),
                      child: Text(
                        'CANCEL',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: textFontSize,
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
        // ✅ Responsive loading dialog
        final width = MediaQuery.of(context).size.width;
        final bool isSmallScreen = width < 400;
        final double dialogWidth = isSmallScreen ? width * 0.85 : width * 0.8;
        final double dialogPadding = isSmallScreen ? 16 : 24;
        final double fontSize = _responsiveFontSize(context, 14);

        return Center(
          child: Container(
            width: dialogWidth,
            padding: EdgeInsets.all(dialogPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.black,
                width: isSmallScreen ? 3 : 4,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: Offset(
                    isSmallScreen ? 4 : 6,
                    isSmallScreen ? 4 : 6,
                  ),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.black),
                  strokeWidth: isSmallScreen ? 2.5 : 3,
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Text(
                  'กำลังวิเคราะห์ภาพอาหาร...',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.bold,
                    fontSize: fontSize,
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
    // ✅ Responsive error dialog
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 400;
    final double dialogWidth = isSmallScreen ? width * 0.9 : width * 0.85;
    final double dialogPadding = isSmallScreen ? 12 : 16;
    final double titleFontSize = _responsiveFontSize(context, 16);
    final double messageFontSize = _responsiveFontSize(context, 14);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Dialog(
            insetPadding: EdgeInsets.all(isSmallScreen ? 16 : 24),
            backgroundColor: const Color(0xFFf8f8f8),
            shape: RoundedRectangleBorder(
              side: BorderSide(
                color: Colors.black,
                width: isSmallScreen ? 3 : 4,
              ),
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                color: const Color(0xFFFFC1C1),
                border: Border.all(
                  color: Colors.black,
                  width: isSmallScreen ? 3 : 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    offset: Offset(
                      isSmallScreen ? 4 : 6,
                      isSmallScreen ? 4 : 6,
                    ),
                    blurRadius: 0,
                  ),
                ],
              ),
              padding: EdgeInsets.all(dialogPadding),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 6 : 8,
                    ),
                    color: const Color(0xFFFF6B6B),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: titleFontSize,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: messageFontSize,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 16 : 20),
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: isSmallScreen ? 80 : 100,
                      padding: EdgeInsets.symmetric(
                        vertical: isSmallScreen ? 6 : 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: Colors.black,
                          width: isSmallScreen ? 2 : 3,
                        ),
                      ),
                      child: Text(
                        'ตกลง',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          fontSize: messageFontSize,
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
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (_, constraints) {
        // ✅ Responsive option box
        final width = MediaQuery.of(context).size.width;
        final bool isSmallScreen = width < 400;
        final double fontSize = constraints.maxWidth < 320
            ? 11.0
            : isSmallScreen
                ? 12.0
                : 14.0;
        final double iconSize = fontSize + 4;
        final double verticalPadding = isSmallScreen ? 10 : 12;
        final double borderWidth = isSmallScreen ? 2 : 3;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: borderWidth),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black, size: iconSize),
              SizedBox(width: isSmallScreen ? 8 : 10),
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
    // ✅ Responsive camera button
    final width = MediaQuery.of(context).size.width;
    final bool isSmallScreen = width < 400;
    final double buttonSize = _responsiveSize(context, 64);
    final double containerHeight = _responsiveSize(context, 80);
    final double borderWidth = isSmallScreen ? 2 : 3;
    final double buttonBorderWidth = isSmallScreen ? 3 : 4;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        border: Border(
          top: BorderSide(color: Colors.black, width: borderWidth),
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
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              color: const Color(0xFFA3EBA1),
              border: Border.all(
                color: Colors.black,
                width: buttonBorderWidth,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  offset: Offset(
                    isSmallScreen ? 3 : 4,
                    isSmallScreen ? 3 : 4,
                  ),
                  blurRadius: 0,
                ),
              ],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.camera_alt,
              size: buttonSize * 0.5,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
