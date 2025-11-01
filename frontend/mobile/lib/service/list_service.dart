import 'dart:convert';
import '../config/api_config.dart';
import '../models/list_models.dart';
import 'storage_helper.dart';
import 'auth_service.dart';

// Service สำหรับดึงข้อมูลรายการอาหารและกิจกรรม
class ListService {
  // ดึง userId จาก Storage
  Future<String?> _getUserId() async {
    try {
      return await StorageHelper.getUserId();
    } catch (e) {
      return null;
    }
  }

  // ดึงรายการอาหารวันนี้
  Future<List<MealItem>> getTodayMeals() async {
    try {
      final userId = await _getUserId();

      if (userId == null || userId.isEmpty) {
        return [];
      }

      final url = '${ApiConfig.dailyUrl}/meals/$userId';

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        final meals = (data['meals'] as List)
            .map((meal) => MealItem.fromJson(meal))
            .toList();

        return meals;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load meals: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching today meals: $e');
    }
  }

  // ดึงรายการกิจกรรมวันนี้
  Future<List<ActivityItem>> getTodayActivities() async {
    try {
      final userId = await _getUserId();

      if (userId == null || userId.isEmpty) {
        return [];
      }

      final url = '${ApiConfig.dailyUrl}/activities/$userId';

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final activities = (data['activities'] as List)
            .map((activity) => ActivityItem.fromJson(activity))
            .toList();

        return activities;
      } else if (response.statusCode == 404) {
        return [];
      } else {
        throw Exception('Failed to load activities: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching today activities: $e');
    }
  }

  // ดึงข้อมูลทั้งหมดของวันนี้ (อาหาร + กิจกรรม)
  Future<Map<String, dynamic>> getTodayData() async {
    try {
      final meals = await getTodayMeals();
      final activities = await getTodayActivities();

      return {'meals': meals, 'activities': activities};
    } catch (e) {
      throw Exception('Error fetching today data: $e');
    }
  }
}
