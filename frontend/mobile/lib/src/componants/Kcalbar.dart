// components/calorie_progress_bar.dart
import 'package:flutter/material.dart';
import '../../service/kal_service.dart';
import '../../models/kal_models.dart';

class Kcalbar extends StatefulWidget {
  final Color progressColor;   // สีของแถบความคืบหน้า
  final Color backgroundColor; // สีพื้นหลัง

  const Kcalbar({
    super.key,
    this.progressColor = const Color(0xFF8bc273),
    this.backgroundColor = const Color(0xFFE5E7EB),
  });

  @override
  State<Kcalbar> createState() => _KcalbarState();
}

class _KcalbarState extends State<Kcalbar> {
  CalorieStatus? _calorieStatus;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCalorieStatus();
  }

  Future<void> _loadCalorieStatus() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await KalService.getCalorieStatus();
      setState(() {
        _calorieStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void refresh() => _loadCalorieStatus();

  Future<bool> hasCalorieData() async {
    try {
      final status = await KalService.getCalorieStatus();
      return status.targetCalories > 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ใช้ MediaQuery เพื่อคำนวณขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ ปรับขนาด responsive ตามหน้าจอ
    final bool isSmallScreen = screenWidth < 400;
    final double fontSizeTitle = isSmallScreen ? 10 : 12;
    final double fontSizeText = isSmallScreen ? 9 : 11;
    final double padding = isSmallScreen ? 12 : 16;
    final double iconSize = isSmallScreen ? 24 : 32;
    final double barHeight = isSmallScreen ? 28 : 36;
    final double borderWidth = isSmallScreen ? 2 : 3;

    if (_isLoading) {
      return Container(
        height: isSmallScreen ? 80 : 100,
        padding: EdgeInsets.all(padding),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8bc273)),
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: isSmallScreen ? 120 : 150,
        padding: EdgeInsets.all(padding),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: iconSize),
              SizedBox(height: isSmallScreen ? 6 : 8),
              Text(
                'ไม่สามารถโหลดข้อมูลได้',
                style: TextStyle(
                  fontSize: fontSizeTitle,
                  color: Colors.red,
                  fontFamily: 'TA8bit',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isSmallScreen ? 3 : 4),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSizeText,
                  color: Colors.red,
                ),
              ),
              SizedBox(height: isSmallScreen ? 6 : 8),
              ElevatedButton(
                onPressed: _loadCalorieStatus,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8bc273),
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: isSmallScreen ? 6 : 8,
                  ),
                ),
                child: Text(
                  'ลองใหม่',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: fontSizeTitle,
                    fontFamily: 'TA8bit',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_calorieStatus == null || _calorieStatus!.targetCalories == 0) {
      return Container(
        height: isSmallScreen ? 70 : 80,
        padding: EdgeInsets.symmetric(
          horizontal: padding,
          vertical: isSmallScreen ? 10 : 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9BD),
          border: Border.all(color: Colors.black, width: borderWidth),
        ),
        child: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              size: isSmallScreen ? 24 : 28,
              color: Colors.black,
            ),
            SizedBox(width: isSmallScreen ? 10 : 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'กรุณาเลือกระดับกิจกรรมประจำวัน',
                    style: TextStyle(
                      fontSize: fontSizeTitle,
                      fontFamily: 'TA8bit',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final current = _calorieStatus!.netCalories;
    final target = _calorieStatus!.targetCalories;
    final remaining = _calorieStatus!.remainingCalories;
    final progress = target > 0 ? (current / target).clamp(0.0, 1.5) : 0.0;

    final displayProgress = progress > 1.0 ? 1.0 : progress;
    final barColor = progress > 1.0 ? Colors.red : widget.progressColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: isSmallScreen ? 6 : 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kcal',
                    style: TextStyle(
                      fontSize: fontSizeTitle,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontFamily: 'TA8bit',
                    ),
                  ),
                  Flexible(
                    child: Text(
                      '${current.toStringAsFixed(0)} / ${target.toStringAsFixed(0)} Kcal',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fontSizeTitle,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'TA8bit',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Progress Bar responsive
            Container(
              height: barHeight,
              margin: EdgeInsets.symmetric(horizontal: padding),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black, width: borderWidth),
                borderRadius: BorderRadius.circular(isSmallScreen ? 25 : 30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    offset: Offset(
                      isSmallScreen ? 3 : 4,
                      isSmallScreen ? 3 : 4,
                    ),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(isSmallScreen ? 22 : 26),
                child: Stack(
                  children: [
                    Container(color: widget.backgroundColor),
                    FractionallySizedBox(
                      widthFactor: displayProgress,
                      child: Container(color: barColor),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 10 : 12,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              child: Text(
                                remaining > 0
                                    ? '${remaining.toStringAsFixed(0)} Kcal'
                                    : 'Over ${(-remaining).toStringAsFixed(0)}!',
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: fontSizeTitle,
                                  fontWeight: FontWeight.bold,
                                  color: remaining > 0
                                      ? Colors.black87
                                      : Colors.red,
                                  fontFamily: 'TA8bit',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
