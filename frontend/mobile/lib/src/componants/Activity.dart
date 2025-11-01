import 'package:flutter/material.dart';
import '../../service/add_activity_service.dart';

class Activity extends StatefulWidget {
  final Function(int caloriesBurned) onSave;

  const Activity({Key? key, required this.onSave}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  String selectedActivity = 'วิ่ง';
  int duration = 0;
  bool isLoading = false;

  // รายการกีฬา 20 ชนิด (ต้องตรงกับชื่อใน database ตาราง Sports)
  final List<String> sports = [
    'เต้น',
    'บาสเก็ตบอล',
    'มวย',
    'กระโดดเชือก',
    'ปั่นจักรยาน',
    'ปิงปอง',
    'เทควันโด',
    'ว่ายน้ำ',
    'วิ่ง',
    'แบดมินตัน',
    'สเกตบอร์ด',
    'วอลเลย์บอล',
    'ฟุตบอล',
    'เซิร์ฟ',
    'ยกน้ำหนัก',
    'โยคะ',
    'แอโรบิค',
    'เครื่องเล่น Elliptical',
    'เทนนิส',
    'สควอช',
  ];

  void increaseTime() => setState(() => duration += 5);

  void decreaseTime() {
    setState(() {
      if (duration > 0) duration -= 5;
      if (duration < 0) duration = 0;
    });
  }

  /// Helper method เพื่อแปลงค่าจาก response เป็น int
  /// รองรับทั้ง num และ String (เช่น "150.00")
  int _parseToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      final parsed = double.tryParse(value);
      return parsed?.toInt() ?? 0;
    }
    return 0;
  }

  Future<void> saveActivity() async {
    // ตรวจสอบว่าเลือกเวลามากกว่า 0 หรือไม่
    if (duration <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('กรุณาเลือกระยะเวลาที่มากกว่า 0 นาที'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // เรียก API ผ่าน AddActivityService
      final result = await AddActivityService.logActivity(
        sportName: selectedActivity,
        time: duration,
      );

      if (!mounted) return;

      // ดึงค่าแคลอรี่จาก response (รองรับทั้ง num และ String)
      final caloriesBurned = _parseToInt(result['calories_burned']);
      final totalBurned = _parseToInt(result['total_burned']);

      // เรียก callback เพื่ออัพเดท UI ของหน้า parent
      widget.onSave(caloriesBurned);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'บันทึกแล้ว! เผาผลาญไป $caloriesBurned kcal\nรวมวันนี้: $totalBurned kcal',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // รีเซ็ตค่าเวลากลับเป็น 0
      setState(() {
        duration = 0;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ใช้ MediaQuery เพื่อคำนวณขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ ปรับขนาด responsive ตามหน้าจอ
    final bool isSmallScreen = screenWidth < 400;
    final bool isUltraSmall = screenWidth < 360;
    final double scale = isUltraSmall ? 0.85 : isSmallScreen ? 0.95 : 1.0;
    final double padding = isSmallScreen ? 10 : 16;
    final double margin = isSmallScreen ? 8 : 16;
    final double borderWidth = isSmallScreen ? 2 : 3;
    final double dropdownHeight = isSmallScreen ? 40 : 55;
    final double timeBoxHeight = isSmallScreen ? 40 : 55;
    final double fontSize = isSmallScreen ? 14 : 16;
    final double timeDisplayFontSize = 32 * scale;
    final double buttonFontSize = 22 * scale;
    final double spacing = isSmallScreen ? 12 : 20;

    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: screenWidth * 0.95,
          ),
          padding: EdgeInsets.all(padding),
          margin: EdgeInsets.all(margin),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(width: borderWidth, color: Colors.black),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                offset: Offset(isSmallScreen ? 4 : 6, isSmallScreen ? 4 : 6),
                blurRadius: 0,
              ),
            ],
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown
            Container(
              height: dropdownHeight,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFCCBC),
                border: Border.all(width: 2, color: Colors.black),
              ),
              child: DropdownButton<String>(
                value: selectedActivity,
                underline: const SizedBox(),
                isExpanded: true,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                  color: Colors.black,
                ),
                items: sports
                    .map((activity) => DropdownMenuItem(
                          value: activity,
                          child: Text(activity),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedActivity = value!),
              ),
            ),

            SizedBox(height: spacing),

            // Time row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeButton(
                  "-",
                  decreaseTime,
                  const Color(0xFFFFFFAA),
                  isSmallScreen,
                  scale,
                ),
                Expanded(
                  child: Container(
                    height: timeBoxHeight,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "$duration",
                        style: TextStyle(
                          fontSize: timeDisplayFontSize,
                          fontFamily: 'TA8bit',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildTimeButton(
                  "+",
                  increaseTime,
                  const Color(0xFFB2DFDB),
                  isSmallScreen,
                  scale,
                ),
              ],
            ),

            SizedBox(height: spacing),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveActivity,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB2DFDB),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(width: 2, color: Colors.black),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 3,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * scale,
                    vertical: 10 * scale,
                  ),
                ),
                child: isLoading
                    ? SizedBox(
                        height: 22 * scale,
                        width: 22 * scale,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.black),
                        ),
                      )
                    : Text(
                        "SAVE",
                        style: TextStyle(
                          fontFamily: 'TA8bit',
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: buttonFontSize,
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

  Widget _buildTimeButton(
    String symbol,
    VoidCallback onPressed,
    Color color,
    bool isSmall,
    double scale,
  ) {
    final double buttonSize = (isSmall ? 40 : 50) * scale;
    final double buttonFontSize = (isSmall ? 22 : 28) * scale;

    return SizedBox(
      width: buttonSize,
      height: buttonSize,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: Colors.black),
            borderRadius: BorderRadius.circular(4),
          ),
          elevation: 2,
        ),
        child: Text(
          symbol,
          style: TextStyle(
            fontFamily: 'TA8bit',
            fontWeight: FontWeight.bold,
            fontSize: buttonFontSize,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
