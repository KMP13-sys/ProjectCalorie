// componants/ListMenu.dart
import 'package:flutter/material.dart';
import '../../service/list_service.dart';
import '../../models/list_models.dart';

class ListMenuPage extends StatefulWidget {
  const ListMenuPage({super.key});

  @override
  State<ListMenuPage> createState() => _ListMenuPageState();
}

class _ListMenuPageState extends State<ListMenuPage> {
  final ListService _listService = ListService();
  List<MealItem> _meals = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  /// ดึงข้อมูลอาหารจาก API
  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final meals = await _listService.getTodayMeals();
      setState(() {
        _meals = meals;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error loading meals';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 264,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 219, 249, 255),
        border: Border.all(color: const Color(0xFF2a2a2a), width: 5),
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
        children: [
          // Header
          const Text(
            'LIST MENU',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
              color: Color(0xFF2a2a2a),
              fontFamily: 'TA8bit',
            ),
          ),
          const SizedBox(height: 10),

                    const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'FOOD',
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
                'KCAL',
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
                    child: CircularProgressIndicator(
                      color: Color(0xFF2a2a2a),
                    ),
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
                              onPressed: _loadMeals,
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
                    : _meals.isEmpty
                        ? const Center(
                            child: Text(
                              'No meals today',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF2a2a2a),
                                fontFamily: 'TA8bit',
                              ),
                            ),
                          )
                        : SingleChildScrollView(
                            child: Column(
                              children: _meals.asMap().entries.map((entry) {
                                final meal = entry.value;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // ชื่ออาหาร
                                      Expanded(
                                        child: Text(
                                          meal.foodName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF2a2a2a),
                                            fontFamily: 'TA8bit',
                                          ),
                                        ),
                                      ),

                                      // แคลอรี่
                                      Text(
                                        '${meal.calories} Kcal',
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
