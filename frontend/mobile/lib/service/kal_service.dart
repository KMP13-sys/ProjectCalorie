// lib/service/kal_service.dart
import 'dart:convert';
//import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_helper.dart';
import 'auth_service.dart';
import 'kal_models.dart';

class KalService {
  // ใช้ ApiConfig แทนการ hardcode URL
  static String get baseUrl => ApiConfig.dailyUrl;

  // ========== CALCULATE AND SAVE CALORIES (BMR + TDEE + Target) ==========
  static Future<CalculateCaloriesResponse> calculateAndSaveCalories({
    required double activityLevel,
  }) async {
    try {
      final userId = await StorageHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      print('🔢 Calculating calories with activity level: $activityLevel');
      final url = Uri.parse('$baseUrl/calculate-calories/$userId');
      print('🌐 API URL: $url');

      final response = await AuthService.authenticatedRequest(
        method: 'POST',
        endpoint: url.toString(),
        body: jsonEncode({'activityLevel': activityLevel}),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully calculated calories');
        return CalculateCaloriesResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print('❌ API Error: ${error['message']}');
        throw Exception(error['message'] ?? 'Failed to calculate calories');
      }
    } catch (e) {
      print('❌ Exception in calculateAndSaveCalories: $e');
      if (e is Exception) rethrow;
      throw Exception('Error calculating calories: $e');
    }
  }

  // ========== GET CALORIE STATUS (Target, Consumed, Burned, Net, Remaining) ==========
  static Future<CalorieStatus> getCalorieStatus() async {
    try {
      final userId = await StorageHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      print('📊 Fetching calorie status for user: $userId');
      final url = Uri.parse('$baseUrl/status/$userId');

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url.toString(),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched calorie status');
        return CalorieStatus.fromJson(data);
      } else if (response.statusCode == 404) {
        // ยังไม่มีข้อมูลในวันนี้
        print('⚠️ No calorie data found for today');
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
        print('❌ API Error: ${error['message']}');
        throw Exception(error['message'] ?? 'Failed to fetch calorie status');
      }
    } catch (e) {
      print('❌ Exception in getCalorieStatus: $e');
      if (e is Exception) rethrow;
      throw Exception('Error fetching calorie status: $e');
    }
  }

  // ========== GET DAILY MACROS (Protein, Fat, Carbohydrate) ==========
  static Future<DailyMacros> getDailyMacros() async {
    try {
      final userId = await StorageHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      print('📊 Fetching daily macros for user: $userId');
      final url = Uri.parse('$baseUrl/macros/$userId');

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url.toString(),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched daily macros');
        return DailyMacros.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print('❌ API Error: ${error['message']}');
        throw Exception(error['message'] ?? 'Failed to fetch daily macros');
      }
    } catch (e) {
      print('❌ Exception in getDailyMacros: $e');
      if (e is Exception) rethrow;
      throw Exception('Error fetching daily macros: $e');
    }
  }

  // ========== GET WEEKLY CALORIES ==========
  static Future<WeeklyCaloriesResponse> getWeeklyCalories() async {
    try {
      final userId = await StorageHelper.getUserId();
      if (userId == null) {
        throw Exception('User ID not found. Please login again.');
      }

      print('📊 Fetching weekly calories for user: $userId');
      final url = Uri.parse('$baseUrl/weekly/$userId');

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url.toString(),
      );

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched weekly calories');
        return WeeklyCaloriesResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        print('❌ API Error: ${error['message']}');
        throw Exception(error['message'] ?? 'Failed to fetch weekly calories');
      }
    } catch (e) {
      print('❌ Exception in getWeeklyCalories: $e');
      if (e is Exception) rethrow;
      throw Exception('Error fetching weekly calories: $e');
    }
  }
}
