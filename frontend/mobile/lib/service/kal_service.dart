import 'dart:convert';
import '../config/api_config.dart';
import 'storage_helper.dart';
import 'auth_service.dart';
import '../models/kal_models.dart';

// Service สำหรับจัดการข้อมูลแคลอรี่
class KalService {
  static String get baseUrl => ApiConfig.dailyUrl;

  // คำนวณและบันทึกแคลอรี่ (BMR + TDEE + Target)
  static Future<CalculateCaloriesResponse> calculateAndSaveCalories({
    required double activityLevel,
  }) async {
    try {
      final userId = await StorageHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final url = Uri.parse('$baseUrl/calculate-calories/$userId');

      final response = await AuthService.authenticatedRequest(
        method: 'POST',
        endpoint: url.toString(),
        body: jsonEncode({'activityLevel': activityLevel}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CalculateCaloriesResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to calculate calories');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error calculating calories: $e');
    }
  }

  // ดึงสถานะแคลอรี่ (Target, Consumed, Burned, Net, Remaining)
  static Future<CalorieStatus> getCalorieStatus() async {
    try {
      final userId = await StorageHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final url = Uri.parse('$baseUrl/status/$userId');

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url.toString(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return CalorieStatus.fromJson(data);
      } else if (response.statusCode == 404) {
        return CalorieStatus(
          activityLevel: 0,
          targetCalories: 0,
          consumedCalories: 0,
          burnedCalories: 0,
          netCalories: 0,
          remainingCalories: 0,
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch calorie status');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error fetching calorie status: $e');
    }
  }

  // ดึงข้อมูลสารอาหาร (Protein, Fat, Carbohydrate)
  static Future<DailyMacros> getDailyMacros() async {
    try {
      final userId = await StorageHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final url = Uri.parse('$baseUrl/macros/$userId');

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url.toString(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DailyMacros.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch daily macros');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error fetching daily macros: $e');
    }
  }

  // ดึงข้อมูลแคลอรี่รายสัปดาห์
  static Future<WeeklyCaloriesResponse> getWeeklyCalories() async {
    try {
      final userId = await StorageHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      final url = Uri.parse('$baseUrl/weekly/$userId');

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url.toString(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WeeklyCaloriesResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch weekly calories');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error fetching weekly calories: $e');
    }
  }
}
