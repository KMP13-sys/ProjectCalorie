// lib/src/componants/WeeklyGraph.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../service/kal_service.dart';

/// Widget สำหรับแสดงกราฟแคลอรี่รายสัปดาห์
/// - ดึงข้อมูลจาก KalService.getWeeklyCalories()
/// - แสดงผลเหมือนเว็บ: หัวข้อด้านบน + กราฟด้านล่าง
/// - Responsive ทุกส่วน
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

      debugPrint('🌐 Fetching weekly calories data...');

      final response = await KalService.getWeeklyCalories();

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
      debugPrint('❌ Error loading weekly data: $e');

      String errorMsg = 'Failed to load weekly data';

      if (e.toString().contains('Session expired') ||
          e.toString().contains('No access token')) {
        errorMsg = 'Please login again';
      } else if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        errorMsg = 'Network connection error';
      }

      setState(() {
        errorMessage = errorMsg;
        isLoading = false;
        weeklyData = [];
      });

      if (e is Exception) rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ Responsive dimensions - เพิ่มความสูงกราฟ
    final chartHeight = screenHeight * 0.45; // เพิ่มจาก 0.38 เป็น 0.45
    final fontSize = screenWidth * 0.038; // เพิ่มขนาดตัวอักษร
    final titleFontSize = screenWidth * 0.045; // เพิ่มขนาดหัวข้อ
    final dotRadius = screenWidth * 0.02; // เพิ่มขนาด dot
    final reservedSize = screenWidth * 0.15;
    final padding = screenWidth * 0.04;
    final horizontalPadding = screenWidth * 0.04;
    final borderRadius = screenWidth * 0.02;
    final shadowBlurRadius = screenWidth * 0.02;
    final iconSize = screenWidth * 0.12;

    // ========== Loading State ==========
    if (isLoading) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenHeight * 0.012,
        ),
        child: Container(
          height: chartHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(screenWidth * 0.005, screenWidth * 0.005),
                blurRadius: shadowBlurRadius,
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: iconSize * 0.6,
              height: iconSize * 0.6,
              child: const CircularProgressIndicator(
                color: Colors.green,
                strokeWidth: 3,
              ),
            ),
          ),
        ),
      );
    }

    // ========== Error State ==========
    if (errorMessage.isNotEmpty && weeklyData.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenHeight * 0.012,
        ),
        child: Container(
          height: chartHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(screenWidth * 0.005, screenWidth * 0.005),
                blurRadius: shadowBlurRadius,
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
                    size: iconSize,
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
                  ElevatedButton.icon(
                    onPressed: _loadWeeklyData,
                    icon: Icon(Icons.refresh, size: fontSize * 1.3),
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
                        borderRadius: BorderRadius.circular(borderRadius),
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

    // ========== Empty State ==========
    if (weeklyData.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalPadding,
          vertical: screenHeight * 0.012,
        ),
        child: Container(
          height: chartHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: Offset(screenWidth * 0.005, screenWidth * 0.005),
                blurRadius: shadowBlurRadius,
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
                  size: iconSize,
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

    // ========== คำนวณข้อมูลสำหรับกราฟ ==========

    final spots = List.generate(weeklyData.length, (index) {
      return FlSpot(index.toDouble(), weeklyData[index]['NetCal'].toDouble());
    });

    // คำนวณผลรวมแคลอรี่ทั้งสัปดาห์
    final totalWeek =
        weeklyData.fold(0, (sum, item) => sum + (item['NetCal'] as int));

    // หา maxValue สำหรับ Y-axis
    final values = weeklyData.map((e) => e['NetCal'] as int).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();

    // ✅ เหมือนเว็บ: Y-axis เริ่มจาก 0 เสมอ
    final minY = 0.0;
    // เพิ่ม padding 20% ด้านบน
    final maxY = maxValue * 1.2;

    // ✅ คำนวณ interval สำหรับ Y-axis (แบ่งเป็น 4-5 ช่วง)
    final yRange = maxY - minY;
    double interval;
    if (yRange <= 100) {
      interval = 25;
    } else if (yRange <= 200) {
      interval = 50;
    } else if (yRange <= 500) {
      interval = 100;
    } else if (yRange <= 1000) {
      interval = 200;
    } else if (yRange <= 2000) {
      interval = 500;
    } else {
      interval = 1000;
    }

    debugPrint('📊 Weekly Data: $weeklyData');
    debugPrint('📊 Values: $values');
    debugPrint('📊 Max: $maxValue, Total: $totalWeek, MaxY: $maxY, Interval: $interval');

    // ========== แสดงกราฟ ==========

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: screenHeight * 0.012,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: Offset(screenWidth * 0.005, screenWidth * 0.005),
              blurRadius: shadowBlurRadius,
            ),
          ],
        ),
        child: Column(
          children: [
            // ✅ หัวข้อด้านบน: แสดงผลรวมแคลอรี่ทั้งสัปดาห์
            Padding(
              padding: EdgeInsets.all(padding * 1.5),
              child: Text(
                'รวมแคลที่ทานไปทั้งสัปดาห์: $totalWeek kcal',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: titleFontSize,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // ✅ กราฟ
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (weeklyData.length - 1).toDouble(),
                    minY: minY,
                    maxY: maxY,
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: interval,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: screenWidth * 0.0025,
                        dashArray: [
                          (screenWidth * 0.0075).toInt(),
                          (screenWidth * 0.0075).toInt(),
                        ],
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey[300]!,
                        strokeWidth: screenWidth * 0.0025,
                        dashArray: [
                          (screenWidth * 0.0075).toInt(),
                          (screenWidth * 0.0075).toInt(),
                        ],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: reservedSize * 0.85,
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index < 0 || index >= weeklyData.length) {
                              return const SizedBox();
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: screenHeight * 0.005),
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
                          interval: interval,
                          reservedSize: reservedSize,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: EdgeInsets.only(right: screenWidth * 0.015),
                              child: Text(
                                '${value.toInt()}',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                  fontSize: fontSize * 0.75, // ลดจาก 0.85 เป็น 0.75
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
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.green,
                        barWidth: screenWidth * 0.008,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) =>
                              FlDotCirclePainter(
                            radius: dotRadius,
                            color: Colors.green,
                            strokeWidth: screenWidth * 0.005,
                            strokeColor: Colors.white,
                          ),
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.green.withOpacity(0.3),
                              Colors.green.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      enabled: true,
                      handleBuiltInTouches: true,
                      touchSpotThreshold: screenWidth * 0.05,
                      getTouchedSpotIndicator: (barData, spotIndexes) {
                        return spotIndexes.map((index) {
                          return TouchedSpotIndicatorData(
                            FlLine(
                              color: Colors.green.withOpacity(0.5),
                              strokeWidth: screenWidth * 0.005,
                              dashArray: [
                                (screenWidth * 0.01).toInt(),
                                (screenWidth * 0.01).toInt(),
                              ],
                            ),
                            FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) =>
                                  FlDotCirclePainter(
                                radius: dotRadius * 2,
                                color: Colors.green,
                                strokeWidth: screenWidth * 0.006,
                                strokeColor: Colors.white,
                              ),
                            ),
                          );
                        }).toList();
                      },
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchedSpot) => Colors.green,
                        tooltipRoundedRadius: borderRadius * 0.8,
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
                            if (index < 0 || index >= weeklyData.length) {
                              return null;
                            }
                            final data = weeklyData[index];
                            return LineTooltipItem(
                              '${data['name']}\n${data['NetCal']} Kcal',
                              TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: fontSize * 0.95,
                              ),
                            );
                          }).whereType<LineTooltipItem>().toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
