// lib/src/componants/WeeklyGraph.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../service/kal_service.dart';

/// Widget สำหรับแสดงกราฟแคลอรี่รายสัปดาห์
/// - ดึงข้อมูลจาก KalService.getWeeklyCalories()
/// - แสดง loading state ระหว่างดึงข้อมูล
/// - จัดการ error และแสดงปุ่ม retry
/// - รองรับ responsive design
class WeeklyGraph extends StatefulWidget {
  const WeeklyGraph({super.key});

  @override
  State<WeeklyGraph> createState() => _WeeklyGraphState();
}

class _WeeklyGraphState extends State<WeeklyGraph> {
  // ข้อมูลกราฟที่แปลงแล้ว
  List<Map<String, dynamic>> weeklyData = [];
  // สถานะการโหลด
  bool isLoading = true;
  // ข้อความ error (ถ้ามี)
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  // ========== โหลดข้อมูลกราฟรายสัปดาห์ ==========

  Future<void> _loadWeeklyData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // ✅ Debug: แสดง request
      debugPrint('🌐 Fetching weekly calories data...');

      final response = await KalService.getWeeklyCalories();

      // ✅ Debug: แสดงข้อมูลที่ได้
      debugPrint('✅ Weekly data received: ${response.data.length} items');

      // แปลงข้อมูลจาก API ให้อยู่ในรูปแบบที่ใช้งานได้
      final formattedData = response.data.map((item) {
        // แปลงวันที่เป็นชื่อวัน (Mon, Tue, Wed, ...)
        final date = DateTime.parse(item.date);
        final weekday = date.weekday;
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final dayName = dayNames[weekday - 1]; // weekday starts from 1 (Monday)

        return {
          'name': dayName,
          'NetCal': item.netCalories.toInt(),
          'date': item.date,
        };
      }).toList();

      setState(() {
        weeklyData = formattedData;
        isLoading = false;
      });

      debugPrint('✅ Weekly data loaded successfully');
    } catch (e) {
      // ✅ แยกประเภท error เหมือน auth_service
      debugPrint('❌ Error loading weekly data: $e');

      String errorMsg = 'Failed to load weekly data';

      // ตรวจสอบประเภทของ error
      if (e.toString().contains('Session expired') ||
          e.toString().contains('No access token')) {
        errorMsg = 'Please login again';
        debugPrint('⚠️ Authentication error detected');
      } else if (e.toString().contains('SocketException') ||
                 e.toString().contains('Failed host lookup')) {
        errorMsg = 'Network connection error';
        debugPrint('⚠️ Network error detected');
      }

      setState(() {
        errorMessage = errorMsg;
        isLoading = false;
        // แสดงข้อมูลว่างเปล่าแทนข้อมูลตัวอย่าง
        weeklyData = [];
      });

      // ✅ Rethrow exception ถ้าเป็น Exception เพื่อให้ parent widget จัดการได้
      if (e is Exception) rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ Responsive dimensions สำหรับมือถือ
    final chartHeight = screenHeight * 0.35; // ใช้ความสูงหน้าจอแทน
    final fontSize = screenWidth * 0.032; // ลด font size ลงเล็กน้อย
    final dotRadius = screenWidth * 0.015; // ลดขนาด dot
    final reservedSize = screenWidth * 0.12; // เพิ่มพื้นที่สำหรับตัวเลข
    final padding = screenWidth * 0.03; // padding ภายใน
    final horizontalPadding = screenWidth * 0.03; // padding ซ้าย-ขวา
    final tooltipFontSize = fontSize * 0.9; // ขนาด font ใน tooltip

    // แสดง loading indicator
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
        child: Container(
          height: chartHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(2, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: const Center(
            child: CircularProgressIndicator(color: Colors.green),
          ),
        ),
      );
    }

    // แสดง error message (ถ้ามี) พร้อมปุ่ม retry
    if (errorMessage.isNotEmpty && weeklyData.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
        child: Container(
          height: chartHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(2, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: padding * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: fontSize * 3,
                  ),
                  SizedBox(height: screenHeight * 0.02),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: fontSize * 1.1,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: screenHeight * 0.025),
                  // ✅ ปุ่ม Retry
                  ElevatedButton.icon(
                    onPressed: _loadWeeklyData,
                    icon: Icon(Icons.refresh, size: fontSize * 1.2),
                    label: Text(
                      'Retry',
                      style: TextStyle(fontSize: fontSize * 1.1),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.08,
                        vertical: screenHeight * 0.015,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // ตรวจสอบว่ามีข้อมูลหรือไม่
    if (weeklyData.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
        child: Container(
          height: chartHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(2, 2),
                blurRadius: 8,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.pie_chart_outline,
                  color: Colors.grey,
                  size: fontSize * 3,
                ),
                SizedBox(height: screenHeight * 0.02),
                Text(
                  'No data available',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: fontSize * 1.1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final spots = List.generate(weeklyData.length, (index) {
      return FlSpot(index.toDouble(), weeklyData[index]['NetCal'].toDouble());
    });

    final totalWeek =
        weeklyData.fold(0, (sum, item) => sum + (item['NetCal'] as int));

    // หา maxY โดยตรวจสอบว่ามีข้อมูลหรือไม่
    final maxValue = weeklyData
        .map((e) => e['NetCal'] as int)
        .reduce((a, b) => a > b ? a : b);
    final maxY = (maxValue > 0 ? maxValue.toDouble() : 1000.0) + 400;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: chartHeight,
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(2, 2),
                  blurRadius: 8,
                ),
              ],
            ),
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (weeklyData.length - 1).toDouble(),
                minY: 0,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 500,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                    dashArray: [3, 3],
                  ),
                  getDrawingVerticalLine: (value) => FlLine(
                    color: Colors.grey[300]!,
                    strokeWidth: 1,
                    dashArray: [3, 3],
                  ),
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      reservedSize: reservedSize * 0.8,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= weeklyData.length) {
                          return const SizedBox();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            weeklyData[index]['name'],
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                              fontSize: fontSize * 0.95,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 500,
                      reservedSize: reservedSize,
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            '${value.toInt()}',
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                              fontSize: fontSize * 0.85,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    bottom: BorderSide(color: Colors.black),
                    left: BorderSide(color: Colors.black),
                    right: BorderSide(color: Colors.transparent),
                    top: BorderSide(color: Colors.transparent),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.green,
                    barWidth: screenWidth * 0.008, // responsive line width
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: dotRadius * 1.5, // เพิ่มขนาด dot ให้กดง่ายขึ้น
                        color: Colors.green,
                        strokeWidth: screenWidth * 0.004,
                        strokeColor: Colors.white,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.green.withOpacity(0.1), // เพิ่ม gradient
                    ),
                  ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  handleBuiltInTouches: true,
                  touchSpotThreshold: screenWidth * 0.05, // เพิ่ม touch area
                  getTouchedSpotIndicator: (barData, spotIndexes) {
                    return spotIndexes.map((index) {
                      return TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.green.withAlpha(128),
                          strokeWidth: 2,
                          dashArray: [4, 4],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: dotRadius * 2, // ขนาดใหญ่ขึ้นเมื่อ touch
                            color: Colors.green,
                            strokeWidth: screenWidth * 0.006,
                            strokeColor: Colors.white,
                          ),
                        ),
                      );
                    }).toList();
                  },
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    tooltipPadding: EdgeInsets.symmetric(
                      horizontal: padding * 1.5,
                      vertical: padding,
                    ),
                    fitInsideHorizontally: true,
                    fitInsideVertically: true,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      if (touchedSpots.isEmpty) return [];
                      return touchedSpots.map((spot) {
                        final int index = spot.x.toInt();
                        if (index < 0 || index >= weeklyData.length) return null;
                        final data = weeklyData[index];
                        return LineTooltipItem(
                          '${data['name']}\n${data['NetCal']} Kcal',
                          TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: tooltipFontSize,
                          ),
                        );
                      }).whereType<LineTooltipItem>().toList();
                    },
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: padding * 0.5,
            child: Container(
              width: screenWidth - (horizontalPadding * 2),
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                vertical: padding * 0.8,
                horizontal: padding * 2,
              ),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(230),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(25),
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Text(
                'Total: $totalWeek Kcal',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize * 1.1,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
