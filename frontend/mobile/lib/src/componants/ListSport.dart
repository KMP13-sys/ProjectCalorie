// componants/ListSport.dart
import 'package:flutter/material.dart';
import '../../service/list_service.dart';
import '../../service/list_models.dart';

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

  /// ดึงข้อมูลกิจกรรมจาก API
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
    return Container(
      height: 264,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 252, 251, 192),
        border: Border.all(color: const Color(0xFF2a2a2a), width: 5),
        borderRadius: BorderRadius.zero, // ✅ ขอบเหลี่ยม
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.3),
            offset: const Offset(8, 8),
            blurRadius: 0,
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          const Text(
            'LIST SPORT',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: Color(0xFF2a2a2a),
              fontFamily: 'TA8bit',
            ),
          ),
          const SizedBox(height: 10),

          // ✅ หัวข้อคอลัมน์
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'SPORT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2a2a2a),
                    fontFamily: 'TA8bit',
                  ),
                ),
              ),
              SizedBox(width: 40),
              Text(
                'TIME',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2a2a2a),
                  fontFamily: 'TA8bit',
                ),
              ),
              SizedBox(width: 30),
              Text(
                'BURN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2a2a2a),
                  fontFamily: 'TA8bit',
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ✅ เส้นคั่นใต้หัวข้อ
          Container(height: 3, color: const Color(0xFF2a2a2a)),
          const SizedBox(height: 10),

          // Content
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
                          style: const TextStyle(
                            fontSize: 14,
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
                ? const Center(
                    child: Text(
                      'No activities today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF2a2a2a),
                        fontFamily: 'TA8bit',
                      ),
                    ),
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: _activities.asMap().entries.map((entry) {
                        final activity = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // ชื่อกีฬา
                              Expanded(
                                child: Text(
                                  activity.sportName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2a2a2a),
                                    fontFamily: 'TA8bit',
                                  ),
                                ),
                              ),

                              // เวลาที่ออกกำลังกาย
                              Text(
                                '${activity.time}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2a2a2a),
                                  fontFamily: 'TA8bit',
                                ),
                              ),

                              const SizedBox(width: 30),

                              // แคลอรี่ที่เผาผลาญ
                              Text(
                                '-${activity.caloriesBurned}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2a2a2a),
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
