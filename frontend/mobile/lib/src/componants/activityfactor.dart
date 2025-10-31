// ============================================
// activity_factor.dart - Responsive Activity Factor Component
// ============================================

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../service/kal_service.dart';

class ActivityFactorButton extends StatefulWidget {
  final Function(int, String)? onSaved;
  final Function()? onCaloriesUpdated;

  const ActivityFactorButton({Key? key, this.onSaved, this.onCaloriesUpdated})
      : super(key: key);

  @override
  State<ActivityFactorButton> createState() => _ActivityFactorButtonState();
}

class _ActivityFactorButtonState extends State<ActivityFactorButton> {
  int? _savedLevel;
  String? _savedLabel;
  bool _isLocked = false;

  @override
  void initState() {
    super.initState();
    _loadSavedData();
  }

  Map<String, dynamic> _getLevelFromActivityFactor(double factor) {
    if (factor == 1.2) return {'level': 1, 'label': 'น้อยมาก'};
    if (factor == 1.4) return {'level': 2, 'label': 'น้อย'};
    if (factor == 1.6) return {'level': 3, 'label': 'ปานกลาง'};
    if (factor == 1.7) return {'level': 4, 'label': 'มาก'};
    if (factor == 1.9) return {'level': 5, 'label': 'มากที่สุด'};
    return {'level': 0, 'label': 'ไม่ทราบ'};
  }

  Future<void> _loadSavedData() async {
    try {
      final status = await KalService.getCalorieStatus();
      if (status.targetCalories > 0 && status.activityLevel > 0) {
        final levelData = _getLevelFromActivityFactor(status.activityLevel);
        final level = levelData['level'] as int;
        final label = levelData['label'] as String;

        setState(() {
          _savedLevel = level;
          _savedLabel = label;
          _isLocked = true;
        });

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('activity_level', level);
        await prefs.setString('activity_label', label);
        await prefs.setString(
            'activity_timestamp', DateTime.now().toIso8601String());
      } else {
        setState(() {
          _isLocked = false;
          _savedLevel = null;
          _savedLabel = null;
        });
      }
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      final savedLevel = prefs.getInt('activity_level');
      final savedLabel = prefs.getString('activity_label');
      final savedTimestamp = prefs.getString('activity_timestamp');
      if (savedLevel != null && savedLabel != null && savedTimestamp != null) {
        final savedDate = DateTime.parse(savedTimestamp);
        final now = DateTime.now();
        final isSameDay = savedDate.year == now.year &&
            savedDate.month == now.month &&
            savedDate.day == now.day;
        setState(() {
          _savedLevel = savedLevel;
          _savedLabel = savedLabel;
          _isLocked = isSameDay;
        });
      }
    }
  }

  Future<void> _openActivitySelector(BuildContext context) async {
    if (_isLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '⭐ เลือกได้อีกครั้งพรุ่งนี้นะ!',
            style:
                TextStyle(fontFamily: 'TA8bit', fontWeight: FontWeight.bold, color: Color( 0xFF2a2a2a)),
          ),
          backgroundColor: const Color(0xFFFFF9BD),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.black, width: 3)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) => const ActivityFactorDialog(),
    );

    if (result != null) {
      final level = result['level'] as int;
      final label = result['label'] as String;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('activity_level', level);
      await prefs.setString('activity_label', label);
      await prefs.setString(
          'activity_timestamp', DateTime.now().toIso8601String());

      setState(() {
        _savedLevel = level;
        _savedLabel = label;
        _isLocked = true;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✨ บันทึก LV.$level: $label แล้ว!',
              style: const TextStyle(fontFamily: 'TA8bit', fontWeight: FontWeight.bold, color: Color( 0xFF2a2a2a)),
            ),
            backgroundColor: const Color(0xFFFFF9BD),
            behavior: SnackBarBehavior.floating,
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: Colors.black, width: 3)),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      widget.onSaved?.call(level, label);
      widget.onCaloriesUpdated?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ใช้ MediaQuery เพื่อคำนวณขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;

    // ✅ ปรับขนาด responsive ตามหน้าจอ
    final bool isSmallScreen = screenWidth < 400;
    final double containerHeight = isSmallScreen ? 50 : 60;
    final double padding = isSmallScreen ? 10 : 14;
    final double iconBoxSize = isSmallScreen ? 36 : 42;
    final double fontSizeLabel = isSmallScreen ? 9 : 11;
    final double fontSizeValue = isSmallScreen ? 12 : 14;
    final double fontSizeLV = isSmallScreen ? 8 : 9;
    final double fontSizeLVNumber = isSmallScreen ? 14 : 17;
    final double iconSize = isSmallScreen ? 18 : 22;
    final double arrowSize = isSmallScreen ? 12 : 15;
    final double borderWidth = isSmallScreen ? 3 : 4;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openActivitySelector(context),
        child: Container(
          height: containerHeight,
          padding: EdgeInsets.symmetric(horizontal: padding),
          decoration: BoxDecoration(
            color: _savedLevel != null
                ? const Color(0xFFFFF9BD)
                : const Color(0xFFF5F5F5),
            border: Border.all(color: Colors.black, width: borderWidth),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                offset: Offset(
                  isSmallScreen ? 2 : 3,
                  isSmallScreen ? 2 : 3,
                ),
                blurRadius: 0,
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                padding: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  color: _savedLevel != null
                      ? const Color(0xFFFFF9BD)
                      : Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: isSmallScreen ? 2 : 3,
                  ),
                ),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: _savedLevel != null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'LV',
                              style: TextStyle(
                                fontSize: fontSizeLV,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'TA8bit',
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              '$_savedLevel',
                              style: TextStyle(
                                fontSize: fontSizeLVNumber,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'TA8bit',
                                color: Colors.black,
                              ),
                            ),
                          ],
                        )
                      : Icon(
                          Icons.directions_run,
                          size: iconSize,
                          color: Colors.black,
                        ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 6 : 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVITY',
                      style: TextStyle(
                        fontSize: fontSizeLabel,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'TA8bit',
                        letterSpacing: 1,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      _savedLevel != null
                          ? (_savedLabel ?? 'ไม่ระบุ')
                          : 'กดเพื่อเลือก',
                      style: TextStyle(
                        fontSize: fontSizeValue,
                        fontFamily: 'TA8bit',
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.black,
                size: arrowSize,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================
// ActivityFactorDialog - Responsive
// ============================================

class ActivityFactorDialog extends StatefulWidget {
  const ActivityFactorDialog({Key? key}) : super(key: key);

  @override
  State<ActivityFactorDialog> createState() => _ActivityFactorDialogState();
}

class _ActivityFactorDialogState extends State<ActivityFactorDialog> {
  int? _selectedLevel;

  final List<Map<String, dynamic>> _activityLevels = [
    {'level': 1, 'label': 'น้อยมาก', 'description': 'นอนเฉยๆ', 'factor': 1.2},
    {'level': 2, 'label': 'น้อย', 'description': 'ทำงานเบาๆ เดินเล่น', 'factor': 1.4},
    {'level': 3, 'label': 'ปานกลาง', 'description': 'ยืน เดิน ยกของเล็กน้อย', 'factor': 1.6},
    {'level': 4, 'label': 'มาก', 'description': 'ออกกำลังกายหนัก', 'factor': 1.7},
    {'level': 5, 'label': 'มากที่สุด', 'description': 'นักกีฬา', 'factor': 1.9},
  ];

  Future<void> _saveSelection() async {
    if (_selectedLevel == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            '⚠️ เลือกระดับก่อนนะ!',
            style:
                TextStyle(fontFamily: 'TA8bit', fontWeight: FontWeight.bold, color: Color( 0xFF2a2a2a)),
          ),
          backgroundColor: const Color(0xFFFFF9BD),
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.black, width: 3)),
        ),
      );
      return;
    }

    final selectedData =
        _activityLevels.firstWhere((item) => item['level'] == _selectedLevel);
    final activityFactor = selectedData['factor'] as double;

    if (!context.mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFF9BD)),
        ),
      ),
    );

    try {
      await KalService.calculateAndSaveCalories(activityLevel: activityFactor);
      await Future.delayed(const Duration(milliseconds: 300));

      if (!context.mounted) return;
      Navigator.pop(context); // ปิด loading
      Navigator.pop(context, {
        'level': _selectedLevel,
        'label': selectedData['label'],
        'factor': activityFactor,
      });
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '❌ เกิดข้อผิดพลาด: ${e.toString()}',
            style: const TextStyle(
                fontFamily: 'TA8bit', fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero,
              side: BorderSide(color: Colors.black, width: 3)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ใช้ MediaQuery เพื่อคำนวณขนาดหน้าจอ
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // ✅ ปรับขนาด responsive ตามหน้าจอ
    final bool isSmallScreen = screenWidth < 400;
    final double dialogMaxWidth = isSmallScreen ? screenWidth * 0.9 : 420;
    final double dialogMaxHeight = isSmallScreen ? screenHeight * 0.7 : 480;
    final double headerPadding = isSmallScreen ? 12 : 18;
    final double contentPadding = isSmallScreen ? 10 : 14;
    final double itemMargin = isSmallScreen ? 6 : 8;
    final double itemPadding = isSmallScreen ? 6 : 8;
    final double levelBoxSize = isSmallScreen ? 30 : 36;
    final double fontSizeTitle = isSmallScreen ? 14 : 16;
    final double fontSizeLabel = isSmallScreen ? 12 : 14;
    final double fontSizeDesc = isSmallScreen ? 9 : 10;
    final double checkSize = isSmallScreen ? 14 : 16;
    final double buttonHeight = isSmallScreen ? 32 : 36;
    final double borderWidth = isSmallScreen ? 3 : 4;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: dialogMaxWidth,
          maxHeight: dialogMaxHeight,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: borderWidth),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(headerPadding),
              color: const Color(0xFFFFF9BD),
              child: Center(
                child: Text(
                  'ACTIVITY LEVEL',
                  style: TextStyle(
                    color: Colors.black,
                    fontFamily: 'TA8bit',
                    fontWeight: FontWeight.bold,
                    fontSize: fontSizeTitle,
                  ),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(contentPadding),
                child: Column(
                  children: [
                    ..._activityLevels.map((item) {
                      final isSelected = _selectedLevel == item['level'];
                      return GestureDetector(
                        onTap: () =>
                            setState(() => _selectedLevel = item['level']),
                        child: Container(
                          margin: EdgeInsets.only(bottom: itemMargin),
                          padding: EdgeInsets.all(itemPadding),
                          color: isSelected
                              ? const Color(0xFFFFF9BD)
                              : const Color(0xFFE0E0E0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: levelBoxSize,
                                height: levelBoxSize,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      '${item['level']}',
                                      style: TextStyle(
                                        fontFamily: 'TA8bit',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: fontSizeLabel,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: isSmallScreen ? 6 : 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['label'],
                                      style: TextStyle(
                                        fontFamily: 'TA8bit',
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                        fontSize: fontSizeLabel,
                                      ),
                                    ),
                                    Text(
                                      item['description'],
                                      style: TextStyle(
                                        fontFamily: 'TA8bit',
                                        fontSize: fontSizeDesc,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Container(
                                  width: checkSize,
                                  height: checkSize,
                                  margin: EdgeInsets.only(
                                    left: isSmallScreen ? 4 : 6,
                                  ),
                                  color: Colors.black,
                                  child: Center(
                                    child: Text(
                                      '✔',
                                      style: TextStyle(
                                        color: Colors.yellow,
                                        fontSize: fontSizeDesc,
                                        fontFamily: 'TA8bit',
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: isSmallScreen ? 10 : 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              height: buttonHeight,
                              color: const Color(0xFFC0C0C0),
                              child: Center(
                                child: Text(
                                  'ยกเลิก',
                                  style: TextStyle(
                                    fontFamily: 'TA8bit',
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSizeLabel,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: isSmallScreen ? 6 : 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: _saveSelection,
                            child: Container(
                              height: buttonHeight,
                              color: const Color(0xFFFFF9BD),
                              child: Center(
                                child: Text(
                                  'บันทึก',
                                  style: TextStyle(
                                    fontFamily: 'TA8bit',
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSizeLabel,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
