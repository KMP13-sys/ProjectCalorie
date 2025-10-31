// lib/service/add_activity_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_helper.dart';
import 'auth_service.dart';

class AddActivityService {
  static String get baseUrl => ApiConfig.baseUrl;

  // ========== LOG ACTIVITY ==========
  static Future<Map<String, dynamic>> logActivity({
    required String sportName,
    required int time,
  }) async {
    try {
      String? accessToken = await StorageHelper.getAccessToken();
      String? userId = await StorageHelper.getUserId();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please login again.');
      }

      if (userId == null || userId.isEmpty) {
        throw Exception('User ID not found. Please login again.');
      }

      // Backend route: POST /api/activity/:userId
      final url = Uri.parse('$baseUrl/api/activity/$userId');

      print('🏃 Calling activity API: $url');
      print('📦 Request body: ${jsonEncode({
            'sport_name': sportName,
            'time': time,
          })}');

      var response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sport_name': sportName,
          'time': time,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      // ถ้า token หมดอายุ ให้ refresh แล้วลองใหม่
      if (response.statusCode == 401 || response.statusCode == 403) {
        print('🔄 Token expired, refreshing...');

        try {
          accessToken = await AuthService.refreshAccessToken();

          response = await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'sport_name': sportName,
              'time': time,
            }),
          );

          print('📡 Retry response status: ${response.statusCode}');
          print('📡 Retry response body: ${response.body}');
        } catch (e) {
          throw Exception('Session expired. Please login again.');
        }
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        return {
          'success': true,
          'message': data['message'] ?? 'Activity logged successfully',
          'sport_name': data['data']?['sport_name'] ?? sportName,
          'time': data['data']?['time'] ?? time,
          'calories_burned': data['data']?['calories_burned'] ?? 0,
          'total_burned': data['data']?['total_burned'] ?? 0,
        };
      } else if (response.statusCode == 404) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Sport not found');
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Invalid input');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to log activity');
      }
    } catch (e) {
      print('❌ Error logging activity: $e');
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== GET SPORTS LIST ==========
  static Future<List<Map<String, dynamic>>> getSportsList() async {
    try {
      String? accessToken = await StorageHelper.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please login again.');
      }

      // สมมติว่า backend มี endpoint GET /api/sports
      final url = Uri.parse('$baseUrl/api/sports');

      print('🏃 Fetching sports list from: $url');

      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      // ถ้า token หมดอายุ ให้ refresh แล้วลองใหม่
      if (response.statusCode == 401 || response.statusCode == 403) {
        print('🔄 Token expired, refreshing...');
        accessToken = await AuthService.refreshAccessToken();

        response = await http.get(
          url,
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // แปลง List<dynamic> เป็น List<Map<String, dynamic>>
        if (data is List) {
          return data.map((sport) => sport as Map<String, dynamic>).toList();
        } else if (data['sports'] != null) {
          return (data['sports'] as List)
              .map((sport) => sport as Map<String, dynamic>)
              .toList();
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch sports list');
      }
    } catch (e) {
      print('❌ Error fetching sports list: $e');
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }
}
