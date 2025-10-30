// nutrition_pie_chart_component.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../service/kal_service.dart';
import '../../models/kal_models.dart';

class NutritionPieChartComponent extends StatefulWidget {
  const NutritionPieChartComponent({super.key});

  @override
  State<NutritionPieChartComponent> createState() =>
      _NutritionPieChartComponentState();
}

class _NutritionPieChartComponentState
    extends State<NutritionPieChartComponent> {
  DailyMacros? _macros;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMacros();
  }

  /// ดึงข้อมูล Macros จาก API
  Future<void> _loadMacros() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final macros = await KalService.getDailyMacros();
      setState(() {
        _macros = macros;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading macros';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ดึงขนาดหน้าจอสำหรับ responsive
    final screenWidth = MediaQuery.of(context).size.width;

    if (_isLoading) {
      return SizedBox(
        height: screenWidth * 0.4,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2a2a2a),
          ),
        ),
      );
    }

    if (_errorMessage != null || _macros == null) {
      return SizedBox(
        height: screenWidth * 0.4,
        child: Center(
          child: Text(
            _errorMessage ?? 'No data',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.red,
              fontFamily: 'TA8bit',
            ),
          ),
        ),
      );
    }

    if (_macros!.protein == 0 &&
        _macros!.fat == 0 &&
        _macros!.carbohydrate == 0) {
      return SizedBox(
        height: screenWidth * 0.4,
        child: const Center(
          child: Text(
            'No nutrition data',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF2a2a2a),
              fontFamily: 'TA8bit',
            ),
          ),
        ),
      );
    }

    return _buildPieChart(screenWidth);
  }

  Widget _buildPieChart(double screenWidth) {
    // ปรับขนาด Pie Chart ให้เหมาะกับจอ
    final chartSize = screenWidth * 0.6; // 60% ของความกว้างหน้าจอ

    return Center(
      child: SizedBox(
        width: chartSize,
        height: chartSize,
        child: PieChart(
          PieChartData(
            sections: _buildSections(chartSize),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
          ),
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildSections(double chartSize) {
    return [
      _buildSection(
          _macros!.carbohydrate,
          const Color.fromARGB(255, 152, 206, 251),
          'Carbs',
          chartSize),
      _buildSection(
          _macros!.fat, const Color.fromARGB(255, 243, 122, 113), 'Fat', chartSize),
      _buildSection(
          _macros!.protein,
          const Color.fromARGB(255, 243, 199, 103),
          'Protein',
          chartSize),
    ];
  }

  PieChartSectionData _buildSection(
      double value, Color color, String title, double chartSize) {
    // ปรับขนาดตัวหนังสือและ radius ตามขนาดจอ
    final radius = chartSize * 0.3;
    final fontSize = chartSize * 0.08;

    return PieChartSectionData(
      value: value,
      color: color,
      title: '$title\n${value.toStringAsFixed(1)}g',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 3, 0, 0),
      ),
    );
  }
}
