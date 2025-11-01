import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'storage_helper.dart';
import 'auth_service.dart';

// Service สำหรับบันทึกกิจกรรมออกกำลังกาย
class AddActivityService {
  static String get baseUrl => ApiConfig.baseUrl;

  // บันทึกกิจกรรมออกกำลังกาย
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

      final url = Uri.parse('$baseUrl/api/activity/$userId');

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

      // ถ้า token หมดอายุ ให้ refresh แล้วลองใหม่
      if (response.statusCode == 401 || response.statusCode == 403) {
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
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ดึงรายการกีฬาทั้งหมด
  static Future<List<Map<String, dynamic>>> getSportsList() async {
    try {
      String? accessToken = await StorageHelper.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please login again.');
      }

      final url = Uri.parse('$baseUrl/api/sports');

      var response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      // ถ้า token หมดอายุ ให้ refresh แล้วลองใหม่
      if (response.statusCode == 401 || response.statusCode == 403) {
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
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }
}
