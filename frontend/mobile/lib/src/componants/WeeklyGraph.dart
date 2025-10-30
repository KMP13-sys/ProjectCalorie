import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeeklyGraph extends StatelessWidget {
  final List<Map<String, dynamic>> weeklyData = [
    {'name': 'Mon', 'NetCal': 1850},
    {'name': 'Tue', 'NetCal': 2100},
    {'name': 'Wed', 'NetCal': 1500},
    {'name': 'Thu', 'NetCal': 2400},
    {'name': 'Fri', 'NetCal': 1950},
    {'name': 'Sat', 'NetCal': 2600},
    {'name': 'Sun', 'NetCal': 1700},
  ];

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final chartHeight = screenWidth * 0.55; // responsive height
    final fontSize = screenWidth * 0.035; // responsive font
    final dotRadius = screenWidth * 0.02;
    final reservedSize = screenWidth * 0.1;

    final spots = List.generate(weeklyData.length, (index) {
      return FlSpot(index.toDouble(), weeklyData[index]['NetCal'].toDouble());
    });

    final totalWeek =
        weeklyData.fold(0, (sum, item) => sum + (item['NetCal'] as int));

    final maxY = weeklyData
            .map((e) => e['NetCal'] as int)
            .reduce((a, b) => a > b ? a : b)
            .toDouble() +
        400;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: 10),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: chartHeight,
            padding: EdgeInsets.all(screenWidth * 0.03),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(chartHeight * 0.035, chartHeight * 0.035),
                  blurRadius: 0,
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
                      reservedSize: reservedSize,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index < 0 || index >= weeklyData.length)
                          return const SizedBox();
                        return Center(
                          child: Text(
                            weeklyData[index]['name'],
                            style: TextStyle(
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                              fontSize: fontSize,
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
                        return Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
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
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) =>
                          FlDotCirclePainter(
                        radius: dotRadius,
                        color: Colors.green,
                        strokeWidth: 0,
                      ),
                    ),
                    belowBarData: BarAreaData(show: false),
                  ),
                ],
                lineTouchData: LineTouchData(
                  handleBuiltInTouches: true,
                  touchTooltipData: LineTouchTooltipData(
                    tooltipRoundedRadius: 8,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      if (touchedSpots.isEmpty) return [];
                      return touchedSpots.map((spot) {
                        final int index = spot.x.toInt();
                        if (index < 0 || index >= weeklyData.length) return null;
                        final data = weeklyData[index];
                        return LineTooltipItem(
                          '${data['name']}\n${data['NetCal']} Kcal',
                          TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: fontSize,
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
            bottom: 0,
            child: Container(
              width: screenWidth - 32,
              alignment: Alignment.center,
              child: Text(
                'Total: $totalWeek',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
