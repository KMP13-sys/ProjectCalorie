import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  final Function(int caloriesBurned) onSave;

  const Activity({Key? key, required this.onSave}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  String selectedActivity = 'วิ่ง';
  int duration = 0;

  final Map<String, int> caloriesPerMin = {
    'วิ่ง': 10,
    'ปั่นจักรยาน': 8,
    'โยคะ': 4,
    'เดิน': 5,
  };

  void increaseTime() => setState(() => duration += 1);

  void decreaseTime() {
    setState(() {
      if (duration > 0) duration -= 5;
      if (duration < 0) duration = 0;
    });
  }

  void saveActivity() {
    final burned = (caloriesPerMin[selectedActivity]! * duration);
    widget.onSave(burned);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('บันทึกแล้ว! เผาผลาญไป $burned kcal')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;
    final isUltraSmall = screenWidth < 360;

    // scale สำหรับปุ่มและตัวอักษร
    final scale = isUltraSmall ? 0.85 : isSmallScreen ? 0.95 : 1.0;

    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: screenWidth * 0.95, // ไม่เกินขอบหน้าจอ
        ),
        padding: EdgeInsets.all(isSmallScreen ? 10 : 16),
        margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 3, color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              offset: const Offset(6, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Dropdown
            Container(
              height: isSmallScreen ? 40 : 55,
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
                  fontSize: isSmallScreen ? 14 : 16,
                  color: Colors.black,
                ),
                items: caloriesPerMin.keys
                    .map((activity) => DropdownMenuItem(
                          value: activity,
                          child: Text(activity),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => selectedActivity = value!),
              ),
            ),

            SizedBox(height: isSmallScreen ? 12 : 20),

            // Time row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTimeButton("-", decreaseTime, const Color(0xFFFFFFAA), isSmallScreen, scale),
                Expanded(
                  child: Container(
                    height: isSmallScreen ? 40 : 55,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 255, 255),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "$duration",
                        style: TextStyle(
                          fontSize: 32 * scale,
                          fontFamily: 'TA8bit',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                _buildTimeButton("+", increaseTime, const Color(0xFFB2DFDB), isSmallScreen, scale),
              ],
            ),

            SizedBox(height: isSmallScreen ? 12 : 20),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveActivity,
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
                child: Text(
                  "SAVE",
                  style: TextStyle(
                    fontFamily: 'TA8bit',
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontSize: 22 * scale,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeButton(String symbol, VoidCallback onPressed, Color color, bool isSmall, double scale) {
    return SizedBox(
      width: (isSmall ? 40 : 50) * scale,
      height: (isSmall ? 40 : 50) * scale,
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
            fontSize: (isSmall ? 22 : 28) * scale,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
