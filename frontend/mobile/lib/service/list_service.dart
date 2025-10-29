// service/list_service.dart
import 'dart:convert';
import '../config/api_config.dart';
import 'list_models.dart';
import 'storage_helper.dart';
import 'auth_service.dart';

/// Service
class ListService {
  /// ดึง userId จาก FlutterSecureStorage
  Future<String?> _getUserId() async {
    try {
      return await StorageHelper.getUserId();
    } catch (e) {
      print('Error getting user_id: $e');
      return null;
    }
  }

  /// GET /api/daily/meals/:userId
  Future<List<MealItem>> getTodayMeals() async {
    try {
      final userId = await _getUserId();

      print('🔍 DEBUG - User ID: $userId');

      if (userId == null || userId.isEmpty) {
        print('❌ User ID not found');
        return [];
      }

      final url = '${ApiConfig.dailyUrl}/meals/$userId';
      print('🔄 Fetching today meals from: $url');

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url,
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('🔍 DEBUG - Parsed data: $data');

        final meals = (data['meals'] as List)
            .map((meal) => MealItem.fromJson(meal))
            .toList();

        print('✅ Fetched ${meals.length} meals for today');
        return meals;
      } else if (response.statusCode == 404) {
        print('ℹ️ No meals found for today');
        return [];
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load meals: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception in getTodayMeals: $e');
      throw Exception('Error fetching today meals: $e');
    }
  }

  /// GET /api/daily/activities/:userId
  Future<List<ActivityItem>> getTodayActivities() async {
    try {
      final userId = await _getUserId();

      if (userId == null || userId.isEmpty) {
        print('❌ User ID not found');
        return [];
      }

      final url = '${ApiConfig.dailyUrl}/activities/$userId';
      print('🔄 Fetching today activities from: $url');

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url,
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final activities = (data['activities'] as List)
            .map((activity) => ActivityItem.fromJson(activity))
            .toList();

        print('✅ Fetched ${activities.length} activities for today');
        return activities;
      } else if (response.statusCode == 404) {
        print('ℹ️ No activities found for today');
        return [];
      } else {
        print('❌ Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to load activities: ${response.body}');
      }
    } catch (e) {
      print('❌ Exception in getTodayActivities: $e');
      throw Exception('Error fetching today activities: $e');
    }
  }

  Future<Map<String, dynamic>> getTodayData() async {
    try {
      final meals = await getTodayMeals();
      final activities = await getTodayActivities();

      return {'meals': meals, 'activities': activities};
    } catch (e) {
      print('❌ Exception in getTodayData: $e');
      throw Exception('Error fetching today data: $e');
    }
  }
}
