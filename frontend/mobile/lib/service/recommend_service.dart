import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'storage_helper.dart';
import 'auth_service.dart';

class RecommendationService {
  // ✅ Recommendation APIs อยู่ใน Flask server (port 5000) ไม่ใช่ Node.js (port 4000)
  static String get baseUrl {
    if (kIsWeb) {
      // Web: ใช้ localhost
      return "http://localhost:5000";
    } else {
      // Mobile/Desktop: ใช้ localhost (iOS/Desktop) หรือ 10.0.2.2 (Android Emulator)
      // สำหรับ Android Emulator ให้เปลี่ยนเป็น 10.0.2.2 ด้วยตัวเอง
      return "http://localhost:5000";
    }
  }

  /// 🍱 ฟังก์ชันดึงข้อมูลแนะนำอาหาร
  static Future<List<Map<String, dynamic>>> getFoodRecommendations({
    required int userId,
    String? date,
    int topN = 3,
  }) async {
    try {
      // ดึง access token จาก storage
      String? accessToken = await StorageHelper.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found. Please login.');
      }

      final uri = Uri.parse('$baseUrl/api/food-recommend/$userId').replace(
        queryParameters: {
          if (date != null) 'date': date,
          'top_n': topN.toString(),
        },
      );

      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      // ถ้า token หมดอายุ ให้ refresh แล้วลองใหม่
      if (response.statusCode == 401 || response.statusCode == 403) {
        accessToken = await AuthService.refreshAccessToken();
        response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ✅ สมมติว่า API ส่งกลับมาเป็น {"recommendations": [{...}, {...}]}
        if (data is Map && data.containsKey('recommendations')) {
          final recs = data['recommendations'];
          if (recs is List) {
            return List<Map<String, dynamic>>.from(recs);
          }
        }

        // ✅ ถ้า API ส่งกลับมาเป็น list โดยตรง
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }

        return [];
      } else {
        throw Exception(_parseError(response));
      }
    } catch (e) {
      // ignore: avoid_print
      print("❌ Error fetching food recommendations: $e");
      rethrow;
    }
  }

  /// 🏃‍♂️ ฟังก์ชันดึงข้อมูลแนะนำกีฬา
  static Future<List<Map<String, dynamic>>> getSportRecommendations({
    required int userId,
    int topN = 3,
    int kNeighbors = 5,
  }) async {
    try {
      // ดึง access token จาก storage
      String? accessToken = await StorageHelper.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found. Please login.');
      }

      final uri = Uri.parse('$baseUrl/api/sport-recommend/$userId').replace(
        queryParameters: {
          'top_n': topN.toString(),
          'k_neighbors': kNeighbors.toString(),
        },
      );

      var response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      // ถ้า token หมดอายุ ให้ refresh แล้วลองใหม่
      if (response.statusCode == 401 || response.statusCode == 403) {
        accessToken = await AuthService.refreshAccessToken();
        response = await http.get(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $accessToken',
          },
        );
      }

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('recommendations')) {
          final recs = data['recommendations'];
          if (recs is List) {
            return List<Map<String, dynamic>>.from(recs);
          }
        }

        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }

        return [];
      } else {
        throw Exception(_parseError(response));
      }
    } catch (e) {
      // ignore: avoid_print
      print("❌ Error fetching sport recommendations: $e");
      rethrow;
    }
  }

  /// 🧰 Helper แปลงข้อความ error
  static String _parseError(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['message'] ?? body['error'] ?? 'Unknown error';
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }
}
