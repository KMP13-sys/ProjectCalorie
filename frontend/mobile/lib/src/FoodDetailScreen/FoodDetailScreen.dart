import 'dart:io';
import 'package:flutter/material.dart';
import '../../service/predict_service.dart';
import '../componants/navbaruser.dart';

/// FoodDetailScreen Widget
/// หน้าแสดงรายละเอียดอาหารที่ AI ทำนาย พร้อมปุ่มบันทึกข้อมูล
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
  /// State Variables
  bool _isSaving = false;

  /// Business Logic: บันทึกข้อมูลอาหารลง Database
  /// เรียก PredictService.saveMeal และจัดการ UI ตาม response
  Future<void> _saveMeal() async {
    if (_isSaving) return;

    setState(() {
      _isSaving = true;
    });

    // UI: แสดง loading dialog
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
      // API Call: บันทึกข้อมูล (ดึง userId จาก SharedPreferences อัตโนมัติ)
      final result = await PredictService.saveMeal(
        foodId: widget.foodId,
        confidenceScore: widget.confidence,
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (result['success'] == true) {
        await _showSuccessDialog();

        // Navigation: กลับไปหน้าหลักอัตโนมัติ
        if (mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      } else {
        _showErrorDialog(
          'เกิดข้อผิดพลาด',
          result['error'] ?? 'ไม่สามารถบันทึกข้อมูลได้',
        );
      }
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

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

  /// UI: แสดง Success Dialog พร้อมปิดอัตโนมัติหลัง 2 วินาที
  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // Auto-close: ปิด dialog อัตโนมัติหลัง 2 วินาที
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });

        return Center(
          child: Dialog(
            insetPadding: const EdgeInsets.all(16),
            backgroundColor: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFa8d48f), Color(0xFF8bc273)],
                ),
                border: Border.all(color: Colors.black, width: 8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(8, 8),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Section: Main content
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Section: Header
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6fa85e),
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: const Text(
                            '★ MEAL SAVED! ★',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(3, 3),
                                  color: Colors.black26,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Section: Pixel Star Icon (5x5 grid)
                        SizedBox(
                          width: 64,
                          height: 64,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFC107)),
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFC107)),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFD54F)),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFC107)),
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 12, height: 12, color: const Color(0xFFFFC107)),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFD54F)),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFE082)),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFD54F)),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFC107)),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFC107)),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFD54F)),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFC107)),
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                  Container(width: 12, height: 12, color: const Color(0xFFFFC107)),
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                  Container(width: 12, height: 12, color: Colors.transparent),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Section: Message Box
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 4),
                          ),
                          child: const Column(
                            children: [
                              Text(
                                'MEAL SAVED!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1f2937),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Your meal has been recorded successfully!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: Color(0xFF4b5563),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Section: Returning message
                        const Text(
                          'Returning to main page...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 11,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                offset: Offset(2, 2),
                                color: Colors.black38,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Decoration: Corner Pixels
                  Positioned(
                    top: -4,
                    left: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      color: const Color(0xFF6fa85e),
                    ),
                  ),
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      color: const Color(0xFF6fa85e),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    left: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      color: const Color(0xFF6fa85e),
                    ),
                  ),
                  Positioned(
                    bottom: -4,
                    right: -4,
                    child: Container(
                      width: 16,
                      height: 16,
                      color: const Color(0xFF6fa85e),
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

  /// UI: แสดง Error Dialog
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
    // Responsive: คำนวณขนาดและ spacing ตามขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final bool isSmallScreen = screenWidth < 400;
    final bool isUltraSmall = screenWidth < 360;
    final double scale = isUltraSmall ? 0.85 : isSmallScreen ? 0.95 : 1.0;

    final double horizontalPadding = isSmallScreen ? 12 : 24;
    final double verticalPadding = isSmallScreen ? 12 : 20;
    final double borderWidth = isSmallScreen ? 4 : 8;
    final double innerBorderWidth = isSmallScreen ? 3 : 6;
    final double shadowOffset = isSmallScreen ? 6 : 12;
    final double backButtonPadding = isSmallScreen ? 6 : 8;
    final double backButtonBorder = isSmallScreen ? 3 : 4;
    final double backIconSize = (isSmallScreen ? 20 : 24) * scale;
    final double imageHeight = screenHeight * (isSmallScreen ? 0.22 : 0.28);
    final double headerFontSize = (isSmallScreen ? 14 : 18) * scale;
    final double infoFontSize = (isSmallScreen ? 12 : 14) * scale;
    final double buttonHeight = (isSmallScreen ? 45 : 55) * scale;
    final double buttonFontSize = (isSmallScreen ? 16 : 20) * scale;

    return Scaffold(
      backgroundColor: const Color(0xFFf0f4f0),
      body: Column(
        children: [
          // Section: NavBar
          const NavBarUser(),

          // Section: Content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFf0f4f0), Color(0xFFe8ede8)],
                ),
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: verticalPadding, horizontal: horizontalPadding),
                    child: Column(
                      children: [
                        // Section: Back Button with pixel art style
                        Align(
                          alignment: Alignment.topLeft,
                          child: InkWell(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              padding: EdgeInsets.all(backButtonPadding),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.black, width: backButtonBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    offset: Offset(backButtonBorder * 1.0, backButtonBorder * 1.0),
                                    blurRadius: 0,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                size: backIconSize,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 20),

                        // Section: Main Content Container with pixel art border
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: borderWidth),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                offset: Offset(shadowOffset, shadowOffset),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Column(
                                    children: [
                                      // Section: Food Image with pixel frame
                                      Container(
                                        width: double.infinity,
                                        height: imageHeight,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: Colors.black, width: innerBorderWidth),
                                          color: Colors.grey[100],
                                        ),
                                        child: Stack(
                                          children: [
                                            // Decoration: Pixel frame corners
                                            Positioned(
                                              top: -1,
                                              left: -1,
                                              child: Container(width: 12, height: 12, color: Colors.grey[800]),
                                            ),
                                            Positioned(
                                              top: -1,
                                              right: -1,
                                              child: Container(width: 12, height: 12, color: Colors.grey[800]),
                                            ),
                                            Positioned(
                                              bottom: -1,
                                              left: -1,
                                              child: Container(width: 12, height: 12, color: Colors.grey[800]),
                                            ),
                                            Positioned(
                                              bottom: -1,
                                              right: -1,
                                              child: Container(width: 12, height: 12, color: Colors.grey[800]),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Image.file(
                                                widget.imageFile,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: double.infinity,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 12 : 16),

                                      // Section: Header Box
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 8 : 12),
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [Color(0xFFA3EBA1), Color(0xFF8bc273)],
                                          ),
                                          border: Border.all(color: Colors.black, width: isSmallScreen ? 3 : 4),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              offset: Offset(isSmallScreen ? 4 : 6, isSmallScreen ? 4 : 6),
                                              blurRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Text(
                                          '★ What food is this ★',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontFamily: 'monospace',
                                            fontWeight: FontWeight.bold,
                                            fontSize: headerFontSize,
                                            color: const Color(0xFF1f2937),
                                            shadows: const [
                                              Shadow(
                                                offset: Offset(2, 2),
                                                color: Colors.white38,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 8 : 12),

                                      // Section: Info Container
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [Color(0xFFFFFFCC), Color(0xFFFFFFAA)],
                                          ),
                                          border: Border.all(color: Colors.black, width: innerBorderWidth),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withValues(alpha: 0.2),
                                              offset: Offset(isSmallScreen ? 4 : 6, isSmallScreen ? 4 : 6),
                                              blurRadius: 0,
                                            ),
                                          ],
                                        ),
                                        padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                        child: Column(
                                          children: [
                                            _infoBox('Menu: ${widget.foodName}', fontSize: infoFontSize),
                                            _infoBox('Carbs: ${widget.carbs} g', fontSize: infoFontSize),
                                            _infoBox('Fat: ${widget.fat} g', fontSize: infoFontSize),
                                            _infoBox('Protein: ${widget.protein} g', fontSize: infoFontSize),
                                            _infoBox('Calories: ${widget.calories} kcal', fontSize: infoFontSize),
                                            _infoBox('Confidence: ${(widget.confidence * 100).toStringAsFixed(1)}%', fontSize: infoFontSize),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: isSmallScreen ? 12 : 20),

                                      // Section: Save Button
                                      InkWell(
                                        onTap: _isSaving ? null : _saveMeal,
                                        child: Container(
                                          width: double.infinity,
                                          height: buttonHeight,
                                          decoration: BoxDecoration(
                                            gradient: _isSaving
                                                ? null
                                                : const LinearGradient(
                                                    begin: Alignment.topCenter,
                                                    end: Alignment.bottomCenter,
                                                    colors: [Color(0xFFA3EBA1), Color(0xFF8bc273)],
                                                  ),
                                            color: _isSaving ? const Color(0xFFCCCCCC) : null,
                                            border: Border.all(color: Colors.black, width: innerBorderWidth),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withValues(alpha: 0.3),
                                                offset: _isSaving
                                                  ? Offset(shadowOffset / 2, shadowOffset / 2)
                                                  : Offset(shadowOffset, shadowOffset),
                                                blurRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Stack(
                                            children: [
                                              // Corner pixels for button
                                              if (!_isSaving) ...[
                                                Positioned(
                                                  top: -1,
                                                  left: -1,
                                                  child: Container(
                                                    width: isSmallScreen ? 6 : 8,
                                                    height: isSmallScreen ? 6 : 8,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                Positioned(
                                                  top: -1,
                                                  right: -1,
                                                  child: Container(
                                                    width: isSmallScreen ? 6 : 8,
                                                    height: isSmallScreen ? 6 : 8,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                              Center(
                                                child: Text(
                                                  _isSaving ? 'SAVING...' : 'SAVE',
                                                  style: TextStyle(
                                                    fontFamily: 'monospace',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: buttonFontSize,
                                                    color: Colors.black,
                                                    shadows: const [
                                                      Shadow(
                                                        offset: Offset(2, 2),
                                                        color: Colors.black26,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // Decoration: Pixel decoration at bottom
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          _buildPixelSquare(const Color(0xFFA3EBA1)),
                                          const SizedBox(width: 4),
                                          _buildPixelSquare(const Color(0xFF8bc273)),
                                          const SizedBox(width: 4),
                                          _buildPixelSquare(const Color(0xFFA3EBA1)),
                                          const SizedBox(width: 4),
                                          _buildPixelSquare(const Color(0xFF8bc273)),
                                          const SizedBox(width: 4),
                                          _buildPixelSquare(const Color(0xFFA3EBA1)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  // Decoration: Corner pixels for main container
                                  Positioned(
                                    top: -8,
                                    left: -8,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA3EBA1),
                                        border: Border.all(color: Colors.black, width: 2),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFA3EBA1),
                                        border: Border.all(color: Colors.black, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget: สร้างกล่องสี่เหลี่ยมเล็กสำหรับตกแต่ง (Pixel Art)
  Widget _buildPixelSquare(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Colors.black, width: 1),
      ),
    );
  }

  /// Widget: กล่องแสดงข้อมูลโภชนาการแต่ละรายการ
  Widget _infoBox(String text, {required double fontSize}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 400;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 3 : 4),
      padding: EdgeInsets.symmetric(
        vertical: isSmallScreen ? 6 : 8,
        horizontal: isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFFFDD), Color(0xFFFFFFB3)],
        ),
        border: Border.all(color: const Color(0xFFFFD700), width: isSmallScreen ? 1.5 : 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF333333),
        ),
      ),
    );
  }
}
