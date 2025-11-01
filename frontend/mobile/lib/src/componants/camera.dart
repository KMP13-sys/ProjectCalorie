import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../FoodDetailScreen/FoodDetailScreen.dart';
import '../../service/predict_service.dart';

// Camera Bottom Navigation Bar
// ปุ่มกล้องสำหรับถ่ายรูปหรือเลือกรูปอาหาร
class CameraBottomNavBar extends StatelessWidget {
  const CameraBottomNavBar({super.key});

  // Helper: ปรับขนาด element ตามหน้าจอ
  double _responsiveSize(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return base * 0.75;
    if (width < 400) return base * 0.85;
    if (width > 600) return base * 1.2;
    return base;
  }

  // Helper: ปรับขนาดฟอนต์ตามหน้าจอ
  double _responsiveFontSize(BuildContext context, double base) {
    final width = MediaQuery.of(context).size.width;
    if (width < 360) return base * 0.85;
    if (width < 400) return base * 0.9;
    if (width > 600) return base * 1.1;
    return base;
  }

  // Business Logic: เลือกรูปจากกล้องหรืออัลบั้ม
  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    // Show source selection dialog
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        // Responsive: คำนวณขนาด dialog
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
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                // Pixel art gradient background
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFA8D48F), // Light green
                    Color(0xFF8BC273), // Medium green
                  ],
                ),
                border: Border.all(
                  color: Colors.black,
                  width: isSmallScreen ? 6 : 8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: Offset(
                      isSmallScreen ? 6 : 8,
                      isSmallScreen ? 6 : 8,
                    ),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decorative corner pixels
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: isSmallScreen ? 12 : 16,
                      height: isSmallScreen ? 12 : 16,
                      color: const Color(0xFF6FA85E),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: isSmallScreen ? 12 : 16,
                      height: isSmallScreen ? 12 : 16,
                      color: const Color(0xFF6FA85E),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: isSmallScreen ? 12 : 16,
                      height: isSmallScreen ? 12 : 16,
                      color: const Color(0xFF6FA85E),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: isSmallScreen ? 12 : 16,
                      height: isSmallScreen ? 12 : 16,
                      color: const Color(0xFF6FA85E),
                    ),
                  ),
                  // Main content
                  Padding(
                    padding: EdgeInsets.all(dialogPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Pixel art header
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 8 : 10,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6FA85E),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            '★ SELECT IMAGE SOURCE ★',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: titleFontSize,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: const Offset(2, 2),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        // Camera option
                        InkWell(
                          onTap: () => Navigator.pop(context, ImageSource.camera),
                          child: _optionBox(
                            context: context,
                            icon: Icons.camera_alt,
                            text: '📷 ถ่ายรูปใหม่',
                            color: const Color(0xFFC8E6C9),
                          ),
                        ),
                        SizedBox(height: spacing),
                        // Gallery option
                        InkWell(
                          onTap: () => Navigator.pop(context, ImageSource.gallery),
                          child: _optionBox(
                            context: context,
                            icon: Icons.photo_library,
                            text: '🖼️ เลือกจากอัลบั้ม',
                            color: const Color(0xFFFFF9C4),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        // Cancel button
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: isSmallScreen ? 100 : 120,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 8 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0E0),
                              border: Border.all(
                                color: Colors.black,
                                width: isSmallScreen ? 3 : 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: Offset(
                                    isSmallScreen ? 3 : 4,
                                    isSmallScreen ? 3 : 4,
                                  ),
                                  blurRadius: 0,
                                ),
                              ],
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
                ],
              ),
            ),
          ),
        );
      },
    );

    // Pick image from selected source
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

  // Business Logic: ประมวลผลรูปและเรียก AI Prediction
  Future<void> _processImage(BuildContext context, File imageFile) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Responsive: คำนวณขนาด loading dialog
        final width = MediaQuery.of(context).size.width;
        final bool isSmallScreen = width < 400;
        final double dialogWidth = isSmallScreen ? width * 0.9 : width * 0.85;
        final double dialogPadding = isSmallScreen ? 16 : 20;
        final double titleFontSize = _responsiveFontSize(context, 18);
        final double textFontSize = _responsiveFontSize(context, 14);
        final double smallTextSize = _responsiveFontSize(context, 12);

        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: dialogWidth,
            decoration: BoxDecoration(
              // Pixel art gradient background
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFA8D48F), // Light green
                  Color(0xFF8BC273), // Medium green
                ],
              ),
              border: Border.all(
                color: Colors.black,
                width: isSmallScreen ? 6 : 8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  offset: Offset(
                    isSmallScreen ? 6 : 8,
                    isSmallScreen ? 6 : 8,
                  ),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Stack(
              children: [
                // Decorative corner pixels
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    width: isSmallScreen ? 12 : 16,
                    height: isSmallScreen ? 12 : 16,
                    color: const Color(0xFF6FA85E),
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: isSmallScreen ? 12 : 16,
                    height: isSmallScreen ? 12 : 16,
                    color: const Color(0xFF6FA85E),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: isSmallScreen ? 12 : 16,
                    height: isSmallScreen ? 12 : 16,
                    color: const Color(0xFF6FA85E),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: isSmallScreen ? 12 : 16,
                    height: isSmallScreen ? 12 : 16,
                    color: const Color(0xFF6FA85E),
                  ),
                ),
                // Main content
                Padding(
                  padding: EdgeInsets.all(dialogPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Pixel art header bar
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: isSmallScreen ? 8 : 10,
                        ),
                        decoration: const BoxDecoration(
                          color: Color(0xFF6FA85E),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.black,
                              width: 4,
                            ),
                          ),
                        ),
                        child: Text(
                          '★ PROCESSING ★',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.bold,
                            fontSize: titleFontSize,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: const Offset(2, 2),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      // Pixel food icon (animated)
                      TweenAnimationBuilder(
                        tween: Tween<double>(begin: 0, end: 1),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, double value, child) {
                          return Transform.translate(
                            offset: Offset(0, -10 * value),
                            child: Text(
                              '🍔',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 48 : 64,
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      // Message box
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.black,
                            width: 4,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'ANALYZING FOOD...',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: textFontSize,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: isSmallScreen ? 6 : 8),
                            Text(
                              'กำลังวิเคราะห์อาหาร',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'monospace',
                                fontSize: smallTextSize,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 16 : 20),
                      // Pixel loading bar
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          border: Border.all(
                            color: const Color(0xFF6FA85E),
                            width: 4,
                          ),
                        ),
                        child: Container(
                          height: isSmallScreen ? 20 : 24,
                          color: const Color(0xFF2D2D2D),
                          child: _LoadingBar(isSmall: isSmallScreen),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 8 : 12),
                      Text(
                        'Predicting...',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: smallTextSize,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Colors.black.withValues(alpha: 0.5),
                              offset: const Offset(1, 1),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    try {
      // API Call: ตรวจสอบความชัดของรูป
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

      // API Call: ทำนายอาหารจาก AI
      final result = await PredictService.predictFood(imageFile);
      Navigator.pop(context);

      if (!context.mounted) return;

      // Success: นำทางไปหน้ารายละเอียดอาหาร
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
        // Error: แสดง error dialog
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

  // Helper: แสดง Error Dialog แบบ Pixel Art Style
  // รองรับ Responsive Design
  void _showErrorDialog(BuildContext context, String title, String message) {
    // Responsive: คำนวณขนาดสำหรับ error dialog
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
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
            ),
            child: Container(
              width: dialogWidth,
              decoration: BoxDecoration(
                // Background: Pixel art gradient - red theme for errors
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFB3BA), // Light red/pink
                    Color(0xFFFF8A95), // Medium red/pink
                  ],
                ),
                border: Border.all(
                  color: Colors.black,
                  width: isSmallScreen ? 6 : 8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: Offset(
                      isSmallScreen ? 6 : 8,
                      isSmallScreen ? 6 : 8,
                    ),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Decoration: Corner pixels - red theme
                  Positioned(
                    top: 0,
                    left: 0,
                    child: Container(
                      width: isSmallScreen ? 12 : 16,
                      height: isSmallScreen ? 12 : 16,
                      color: const Color(0xFFE57373),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: isSmallScreen ? 12 : 16,
                      height: isSmallScreen ? 12 : 16,
                      color: const Color(0xFFE57373),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: isSmallScreen ? 12 : 16,
                      height: isSmallScreen ? 12 : 16,
                      color: const Color(0xFFE57373),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: isSmallScreen ? 12 : 16,
                      height: isSmallScreen ? 12 : 16,
                      color: const Color(0xFFE57373),
                    ),
                  ),
                  // Section: Main content
                  Padding(
                    padding: EdgeInsets.all(dialogPadding),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Section: Pixel art header - error theme
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(
                            vertical: isSmallScreen ? 8 : 10,
                          ),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE57373),
                            border: Border(
                              bottom: BorderSide(
                                color: Colors.black,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '⚠ ',
                                style: TextStyle(
                                  fontSize: titleFontSize + 2,
                                ),
                              ),
                              Text(
                                title,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  fontSize: titleFontSize,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      offset: const Offset(2, 2),
                                      blurRadius: 0,
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                ' ⚠',
                                style: TextStyle(
                                  fontSize: titleFontSize + 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        // Section: Message box
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 4,
                            ),
                          ),
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: messageFontSize,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        // Section: OK button
                        InkWell(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            width: isSmallScreen ? 100 : 120,
                            padding: EdgeInsets.symmetric(
                              vertical: isSmallScreen ? 8 : 10,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE0E0E0),
                              border: Border.all(
                                color: Colors.black,
                                width: isSmallScreen ? 3 : 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: Offset(
                                    isSmallScreen ? 3 : 4,
                                    isSmallScreen ? 3 : 4,
                                  ),
                                  blurRadius: 0,
                                ),
                              ],
                            ),
                            child: Text(
                              'OK',
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Widget: สร้างกล่องตัวเลือก (Camera/Gallery) แบบ Pixel Art Style
  // พารามิเตอร์: icon, text, color
  static Widget _optionBox({
    required BuildContext context,
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return LayoutBuilder(
      builder: (_, constraints) {
        // Responsive: คำนวณขนาดสำหรับ option box
        final width = MediaQuery.of(context).size.width;
        final bool isSmallScreen = width < 400;
        final double fontSize = constraints.maxWidth < 320
            ? 11.0
            : isSmallScreen
                ? 12.0
                : 14.0;
        final double iconSize = fontSize + 6;
        final double verticalPadding = isSmallScreen ? 12 : 14;
        final double borderWidth = isSmallScreen ? 3 : 4;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: verticalPadding,
            horizontal: 12,
          ),
          decoration: BoxDecoration(
            color: color,
            border: Border.all(color: Colors.black, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                offset: Offset(
                  isSmallScreen ? 3 : 4,
                  isSmallScreen ? 3 : 4,
                ),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.black87, size: iconSize),
              SizedBox(width: isSmallScreen ? 10 : 12),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // UI: สร้างปุ่มกล้องแบบ Pixel Art Style
  // แสดงที่ Bottom Navigation Bar
  @override
  Widget build(BuildContext context) {
    // Responsive: คำนวณขนาดสำหรับปุ่มกล้อง
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

// Widget: Pixel Art Loading Bar Animation
// แสดง animation loading bar แบบ pixel art style
class _LoadingBar extends StatefulWidget {
  final bool isSmall;

  const _LoadingBar({required this.isSmall});

  @override
  State<_LoadingBar> createState() => _LoadingBarState();
}

class _LoadingBarState extends State<_LoadingBar>
    with SingleTickerProviderStateMixin {
  // Animation State
  late AnimationController _controller;
  late Animation<double> _animation;

  // Lifecycle: เริ่มต้น Animation Controller
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  // Lifecycle: ทำลาย Animation Controller
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // UI: สร้าง Loading Bar Animation
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Stack(
          children: [
            // Animation: Moving gradient bar
            Positioned.fill(
              child: FractionallySizedBox(
                widthFactor: _animation.value,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(0xFF4ECDC4),
                        Color(0xFF44A3C4),
                      ],
                    ),
                  ),
                  // Effect: Pixel shine effect
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: widget.isSmall ? 4 : 6,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
