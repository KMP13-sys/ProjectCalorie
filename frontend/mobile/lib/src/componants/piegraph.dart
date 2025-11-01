import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../service/kal_service.dart';
import '../../models/kal_models.dart';

// NutritionPieChartComponent Widget
// แสดงกราฟวงกลมแสดงสัดส่วนสารอาหาร (โปรตีน, ไขมัน, คาร์โบไฮเดรต)
class NutritionPieChartComponent extends StatefulWidget {
  const NutritionPieChartComponent({super.key});

  @override
  State<NutritionPieChartComponent> createState() =>
      _NutritionPieChartComponentState();
}

class _NutritionPieChartComponentState
    extends State<NutritionPieChartComponent> {
  // State Variables
  DailyMacros? _macros;
  bool _isLoading = true;
  String? _errorMessage;

  // Lifecycle: โหลดข้อมูล Macros เมื่อเริ่มต้น
  @override
  void initState() {
    super.initState();
    _loadMacros();
  }

  // Business Logic: ดึงข้อมูล Macros (โปรตีน, ไขมัน, คาร์โบไฮเดรต) จาก API
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

  // UI: สร้างกราฟวงกลมสารอาหาร
  @override
  Widget build(BuildContext context) {
    // Responsive: คำนวณขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive: ปรับขนาดตามหน้าจอ
    final bool isSmallScreen = screenWidth < 400;
    final double containerHeight = isSmallScreen
        ? screenWidth * 0.35
        : screenWidth * 0.4;
    final double fontSize = isSmallScreen ? 12 : 14;

    // State: Loading
    if (_isLoading) {
      return SizedBox(
        height: containerHeight,
        child: const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF2a2a2a),
          ),
        ),
      );
    }

    // State: Error
    if (_errorMessage != null || _macros == null) {
      return SizedBox(
        height: containerHeight,
        child: Center(
          child: Text(
            _errorMessage ?? 'No data',
            style: TextStyle(
              fontSize: fontSize,
              color: Colors.red,
              fontFamily: 'TA8bit',
            ),
          ),
        ),
      );
    }

    // State: No data
    if (_macros!.protein == 0 &&
        _macros!.fat == 0 &&
        _macros!.carbohydrate == 0) {
      return SizedBox(
        height: containerHeight,
        child: Center(
          child: Text(
            'No nutrition data',
            style: TextStyle(
              fontSize: fontSize,
              color: const Color(0xFF2a2a2a),
              fontFamily: 'TA8bit',
            ),
          ),
        ),
      );
    }

    return _buildPieChart(screenWidth, isSmallScreen);
  }

  // Widget: สร้างกราฟวงกลม Pie Chart
  Widget _buildPieChart(double screenWidth, bool isSmallScreen) {
    // Responsive: ปรับขนาด Pie Chart ตามหน้าจอ
    final chartSize = isSmallScreen
        ? screenWidth * 0.7
        : screenWidth * 0.75;

    return Center(
      child: SizedBox(
        width: chartSize,
        height: chartSize,
        child: PieChart(
          PieChartData(
            sections: _buildSections(chartSize, isSmallScreen),
            sectionsSpace: 0,
            centerSpaceRadius: 0,
          ),
        ),
      ),
    );
  }

  // Helper: สร้าง sections สำหรับกราฟวงกลม (Carbs, Fat, Protein)
  List<PieChartSectionData> _buildSections(
      double chartSize, bool isSmallScreen) {
    return [
      _buildSection(
        _macros!.carbohydrate,
        const Color.fromARGB(255, 152, 206, 251),
        'Carbs',
        chartSize,
        isSmallScreen,
      ),
      _buildSection(
        _macros!.fat,
        const Color.fromARGB(255, 243, 122, 113),
        'Fat',
        chartSize,
        isSmallScreen,
      ),
      _buildSection(
        _macros!.protein,
        const Color.fromARGB(255, 243, 199, 103),
        'Protein',
        chartSize,
        isSmallScreen,
      ),
    ];
  }

  // Helper: สร้าง section เดี่ยวสำหรับแต่ละสารอาหาร
  PieChartSectionData _buildSection(
    double value,
    Color color,
    String title,
    double chartSize,
    bool isSmallScreen,
  ) {
    // Responsive: ปรับขนาด radius และฟอนต์ตามหน้าจอ
    final radius = isSmallScreen ? chartSize * 0.28 : chartSize * 0.3;
    final fontSize = isSmallScreen ? chartSize * 0.035 : chartSize * 0.04;

    // Data: คำนวณเปอร์เซ็นต์จากค่ารวมทั้งหมด
    final total = _macros!.protein + _macros!.fat + _macros!.carbohydrate;
    final percent = total > 0 ? ((value / total) * 100).toStringAsFixed(0) : '0';

    return PieChartSectionData(
      value: value,
      color: color,
      title: '$title $percent%',
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: const Color.fromARGB(255, 0, 0, 0),
      ),
    );
  }
}
