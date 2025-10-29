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
      print('📊 Loading calorie status...');
      final status = await KalService.getCalorieStatus();
      print('✅ Loaded calorie status: ${status.toJson()}');
      setState(() {
        _calorieStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading calorie status: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // ฟังก์ชันสำหรับ refresh จากภายนอก
  void refresh() {
    _loadCalorieStatus();
  }

  // เช็คว่ามีข้อมูลแคลอรี่วันนี้หรือไม่
  Future<bool> hasCalorieData() async {
    try {
      final status = await KalService.getCalorieStatus();
      // ถ้า targetCalories > 0 แสดงว่ามีการเลือกระดับกิจกรรมแล้ว
      return status.targetCalories > 0;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    // แสดง loading
    if (_isLoading) {
      return Container(
        height: 100,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8bc273)),
          ),
        ),
      );
    }

    // แสดง error
    if (_errorMessage != null) {
      return Container(
        height: 150,
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 32),
              const SizedBox(height: 8),
              Text(
                'ไม่สามารถโหลดข้อมูลได้',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontFamily: 'TA8bit',
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => _loadCalorieStatus(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8bc273),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('ลองใหม่', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    // ไม่มีข้อมูล หรือ targetCalories = 0
    if (_calorieStatus == null || _calorieStatus!.targetCalories == 0) {
      return Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9BD),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 28,
              color: Colors.black,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'กรุณาเลือกระดับกิจกรรมประจำวัน',
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'TA8bit',
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'เพื่อคำนวณแคลอรี่ที่เหมาะสมกับคุณ',
                    style: TextStyle(
                      fontSize: 9,
                      fontFamily: 'TA8bit',
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // คำนวณค่าต่างๆ
    final current = _calorieStatus!.netCalories; // ใช้ net_calories (consumed - burned)
    final target = _calorieStatus!.targetCalories;
    final remaining = _calorieStatus!.remainingCalories;

    double progress = target > 0 ? current / target : 0;

    // จำกัด progress ไม่ให้เกิน 1.0 (100%)
    double displayProgress = progress > 1.0 ? 1.0 : progress;

    // เปลี่ยนสีถ้ากินเกิน
    Color barColor = progress > 1.0 ? Colors.red : widget.progressColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // หัวข้อด้านบน
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kcal',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontFamily: 'TA8bit',
                ),
              ),
              Text(
                '${current.toStringAsFixed(0)} Kcal from ${target.toStringAsFixed(0)} Kcal',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'TA8bit',
                ),
              ),
            ],
          ),
        ),
        
        // Progress Bar
        Container(
          height: 32,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 4),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                offset: const Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(26),
            child: Stack(
              children: [
                // Background (สีเทา)
                Container(
                  decoration: BoxDecoration(
                    color: widget.backgroundColor,
                  ),
                ),
                
                // Progress Bar (สีเขียวหรือแดง)
                FractionallySizedBox(
                  widthFactor: displayProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: barColor,
                    ),
                  ),
                ),
                
                // ข้อความคงเหลือด้านขวา
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          // decoration: BoxDecoration(
                          //   color: Colors.white.withOpacity(0.9),
                          //   borderRadius: BorderRadius.circular(15),
                          //   border: Border.all(color: Colors.black, width: 2),
                          // ),
                          child: Text(
                            remaining > 0
                                ? '${remaining.toStringAsFixed(0)} Kcal'
                                : 'Over ${(-remaining).toStringAsFixed(0)} Kcal!',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: remaining > 0 ? Colors.black87 : Colors.red,
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
  }
}