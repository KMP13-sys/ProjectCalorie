import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../service/kal_service.dart';

// WeeklyGraph Widget
// แสดงกราฟแคลอรี่รายสัปดาห์แบบ Line Chart พร้อม Responsive Design
class WeeklyGraph extends StatefulWidget {
  const WeeklyGraph({super.key});

  @override
  State<WeeklyGraph> createState() => _WeeklyGraphState();
}

class _WeeklyGraphState extends State<WeeklyGraph> {
  // State Variables
  List<Map<String, dynamic>> weeklyData = [];
  bool isLoading = true;
  String errorMessage = '';

  // Lifecycle: โหลดข้อมูลกราฟเมื่อเริ่มต้น
  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  // Business Logic: โหลดข้อมูลกราฟรายสัปดาห์จาก API
  Future<void> _loadWeeklyData() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      // API Call: ดึงข้อมูลแคลอรี่รายสัปดาห์
      final response = await KalService.getWeeklyCalories();

      // Data: แปลงข้อมูลจาก API ให้อยู่ในรูปแบบที่ใช้งานได้
      final formattedData = response.data.map((item) {
        // แปลงวันที่เป็นชื่อวัน (Mon, Tue, Wed, Thu, Fri, Sat, Sun)
        final date = DateTime.parse(item.date);
        final weekday = date.weekday;
        final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
        final dayName = dayNames[weekday - 1];

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
    } catch (e) {
      // Error: จัดการ error message
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

  // UI: สร้างกราฟ Line Chart รายสัปดาห์
  @override
  Widget build(BuildContext context) {
    // Responsive: คำนวณขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Responsive: ปรับขนาดทุกส่วนตามหน้าจอ
    final bool isSmallScreen = screenWidth < 400;
    final double chartHeight = isSmallScreen
        ? screenHeight * 0.4
        : screenHeight * 0.45;
    final double fontSize = isSmallScreen
        ? screenWidth * 0.035
        : screenWidth * 0.038;
    final double titleFontSize = isSmallScreen
        ? screenWidth * 0.04
        : screenWidth * 0.045;
    final double dotRadius = isSmallScreen
        ? screenWidth * 0.018
        : screenWidth * 0.02;
    final double reservedSize = screenWidth * 0.15;
    final double padding = screenWidth * 0.04;
    final double horizontalPadding = screenWidth * 0.04;
    final double borderRadius = screenWidth * 0.02;
    final double shadowBlurRadius = screenWidth * 0.02;
    final double iconSize = isSmallScreen
        ? screenWidth * 0.1
        : screenWidth * 0.12;

    // State: Loading
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
                color: Colors.black.withValues(alpha: 0.1),
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

    // State: Error
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
                color: Colors.black.withValues(alpha: 0.1),
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

    // State: Empty data
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
                color: Colors.black.withValues(alpha: 0.1),
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

    // Data: คำนวณข้อมูลสำหรับกราฟ
    final spots = List.generate(weeklyData.length, (index) {
      return FlSpot(index.toDouble(), weeklyData[index]['NetCal'].toDouble());
    });

    // Data: คำนวณผลรวมแคลอรี่ทั้งสัปดาห์
    final totalWeek =
        weeklyData.fold(0, (sum, item) => sum + (item['NetCal'] as int));

    // Data: หา maxValue สำหรับ Y-axis
    final values = weeklyData.map((e) => e['NetCal'] as int).toList();
    final maxValue = values.reduce((a, b) => a > b ? a : b).toDouble();

    // Chart: Y-axis เริ่มจาก 0 เสมอ
    final minY = 0.0;

    // Chart: คำนวณ interval (แบ่งเป็น 4-5 ช่วง)
    double interval;
    if (maxValue <= 100) {
      interval = 25;
    } else if (maxValue <= 200) {
      interval = 50;
    } else if (maxValue <= 500) {
      interval = 100;
    } else if (maxValue <= 1000) {
      interval = 200;
    } else if (maxValue <= 2000) {
      interval = 500;
    } else {
      interval = 1000;
    }

    // Chart: ปัด maxY ขึ้นให้เป็น multiple ของ interval
    final maxY = ((maxValue / interval).ceil() * interval).toDouble();

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
              color: Colors.black.withValues(alpha: 0.1),
              offset: Offset(screenWidth * 0.005, screenWidth * 0.005),
              blurRadius: shadowBlurRadius,
            ),
          ],
        ),
        child: Column(
          children: [
            // Section: Header - แสดงผลรวมแคลอรี่ทั้งสัปดาห์
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
            // Section: Line Chart
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
                                  fontSize: fontSize * 0.75,
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
                              Colors.green.withValues(alpha: 0.3),
                              Colors.green.withValues(alpha: 0.1),
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
                              color: Colors.green.withValues(alpha: 0.5),
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
