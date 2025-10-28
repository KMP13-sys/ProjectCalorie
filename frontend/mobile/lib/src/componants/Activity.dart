import 'package:flutter/material.dart';

class Activity extends StatefulWidget {
  final Function(int caloriesBurned) onSave; // ส่งค่ากลับไปเพื่อลบแคลใน Kcalbar

  const Activity({Key? key, required this.onSave}) : super(key: key);

  @override
  State<Activity> createState() => _ActivityState();
}

class _ActivityState extends State<Activity> {
  String selectedActivity = 'วิ่ง';
  int duration = 0; // นาที

  // แคลที่เผาผลาญต่อนาที (สมมติ)
  final Map<String, int> caloriesPerMin = {
    'วิ่ง': 10,
    'ปั่นจักรยาน': 8,
    'โยคะ': 4,
    'เดิน': 5,
  };

  void increaseTime() {
    setState(() => duration += 1);
  }

  void decreaseTime() {
    setState(() {
      if (duration > 0) duration -= 5;
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
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 255, 255, 255),
        border: Border.all(width: 5, color: Colors.black),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 🔽 Dropdown เลือกกิจกรรม
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFCCBC),
              border: Border.all(width: 2, color: Colors.black),
            ),
            child: DropdownButton<String>(
              value: selectedActivity,
              underline: const SizedBox(),
              isExpanded: true,
              items: caloriesPerMin.keys
                  .map((activity) => DropdownMenuItem(
                        value: activity,
                        child: Text(
                          activity,
                          style: const TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => selectedActivity = value!);
              },
            ),
          ),

          const SizedBox(height: 20),

          // 🕒 ช่องเวลา + ปุ่มเพิ่ม/ลด
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeButton("-", decreaseTime, const Color(0xFFFFFFAA)),
              Container(
                width: 80,
                height: 50,
                alignment: Alignment.center,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFCCBC),
                  border: Border.all(width: 2, color: Colors.black),
                ),
                child: Text(
                  "$duration",
                  style: const TextStyle(
                    fontSize: 30,
                    fontFamily: 'TA8bit',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildTimeButton("+", increaseTime, const Color(0xFFB2DFDB)),
            ],
          ),

          const SizedBox(height: 16),

          // 💾 ปุ่ม SAVE
          ElevatedButton(
            onPressed: saveActivity,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB2DFDB),
              shape: RoundedRectangleBorder(
                side: const BorderSide(width: 2, color: Colors.black),
                borderRadius: BorderRadius.circular(0),
              ),
              elevation: 3,
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Text(
                "SAVE",
                style: TextStyle(
                  fontFamily: 'TA8bit',
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeButton(String symbol, VoidCallback onPressed, Color color) {
    return SizedBox(
      width: 45,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            side: const BorderSide(width: 2, color: Colors.black),
          ),
          elevation: 2,
        ),
        child: Text(
          symbol,
          style: const TextStyle(
            fontFamily: 'TA8bit',
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
