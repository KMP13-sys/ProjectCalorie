// componants/ListSport.dart
import 'package:flutter/material.dart';
import '../../service/list_service.dart';
import '../../models/list_models.dart';

class ListSportPage extends StatefulWidget {
  const ListSportPage({super.key});

  @override
  State<ListSportPage> createState() => _ListSportPageState();
}

class _ListSportPageState extends State<ListSportPage> {
  final ListService _listService = ListService();
  List<ActivityItem> _activities = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final activities = await _listService.getTodayActivities();
      setState(() {
        _activities = activities;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading activities';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ใช้ MediaQuery สำหรับ responsive
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final bool isSmallScreen = screenWidth < 400;
    final double fontSizeTitle = isSmallScreen ? 18 : 24;
    final double fontSizeText = isSmallScreen ? 12 : 16;
    final double padding = isSmallScreen ? 10 : 20;
    final double containerHeight = isSmallScreen ? screenHeight * 0.4 : 264;

    return Container(
      height: containerHeight,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 219, 249, 255),
        border: Border.all(color: const Color(0xFF2a2a2a), width: 5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      padding: EdgeInsets.all(padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'LIST SPORT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: fontSizeTitle,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: const Color(0xFF2a2a2a),
              fontFamily: 'TA8bit',
            ),
          ),
          const SizedBox(height: 10),

          // หัวคอลัมน์
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'SPORT',
                  style: TextStyle(
                    fontSize: fontSizeText,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2a2a2a),
                    fontFamily: 'TA8bit',
                  ),
                ),
              ),
              Text(
                'TIME',
                style: TextStyle(
                  fontSize: fontSizeText,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2a2a2a),
                  fontFamily: 'TA8bit',
                ),
              ),
              SizedBox(width: isSmallScreen ? 10 : 30),
              Text(
                'BURN',
                style: TextStyle(
                  fontSize: fontSizeText,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2a2a2a),
                  fontFamily: 'TA8bit',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // เส้นคั่น
          Container(height: 3, color: const Color(0xFF2a2a2a)),
          const SizedBox(height: 10),

          // เนื้อหา
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF2a2a2a)),
                  )
                : _errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: fontSizeText,
                                color: Colors.red,
                                fontFamily: 'TA8bit',
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _loadActivities,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2a2a2a),
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(fontFamily: 'TA8bit'),
                              ),
                            ),
                          ],
                        ),
                      )
                    : _activities.isEmpty
                        ? Center(
                            child: Text(
                              'No activities today',
                              style: TextStyle(
                                fontSize: fontSizeText,
                                color: const Color(0xFF2a2a2a),
                                fontFamily: 'TA8bit',
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: _activities.asMap().entries.map((entry) {
                                final activity = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // ชื่อกีฬา
                                      Expanded(
                                        child: Text(
                                          activity.sportName,
                                          style: TextStyle(
                                            fontSize: fontSizeText,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF2a2a2a),
                                            fontFamily: 'TA8bit',
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),

                                      // เวลา
                                      Text(
                                        '${activity.time}',
                                        style: TextStyle(
                                          fontSize: fontSizeText,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2a2a2a),
                                          fontFamily: 'TA8bit',
                                        ),
                                      ),

                                      SizedBox(width: isSmallScreen ? 10 : 30),

                                      // แคลอรี่ที่เผาผลาญ
                                      Text(
                                        '-${activity.caloriesBurned}',
                                        style: TextStyle(
                                          fontSize: fontSizeText,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF2a2a2a),
                                          fontFamily: 'TA8bit',
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
          ),
        ],
      ),
    );
  }
}
