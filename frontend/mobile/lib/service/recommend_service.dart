import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// 🌐 ตั้งค่า base URL อัตโนมัติ
/// - Android Emulator ใช้ 10.0.2.2
/// - อื่น ๆ ใช้ localhost
String getBaseUrl() {
  if (Platform.isAndroid) {
    return "http://10.0.2.2:5000"; // สำหรับ Android Emulator
  } else {
    return "http://127.0.0.1:5000"; // สำหรับ iOS / Web / Desktop
  }
}

class RecommendationService {
  final String token; // JWT Token จากการล็อกอิน
  final String baseUrl = getBaseUrl();

  RecommendationService({required this.token});

  /// 🍱 ฟังก์ชันดึงข้อมูลแนะนำอาหาร
  Future<List<Map<String, dynamic>>> getFoodRecommendations({
    required int userId,
    String? date,
    int topN = 3,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/food-recommend/$userId').replace(
        queryParameters: {
          if (date != null) 'date': date,
          'top_n': topN.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

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
      print("❌ Error fetching food recommendations: $e");
      rethrow;
    }
  }

  /// 🏃‍♂️ ฟังก์ชันดึงข้อมูลแนะนำกีฬา
  Future<List<Map<String, dynamic>>> getSportRecommendations({
    required int userId,
    int topN = 3,
    int kNeighbors = 5,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/sport-recommend/$userId').replace(
        queryParameters: {
          'top_n': topN.toString(),
          'k_neighbors': kNeighbors.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

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
      print("❌ Error fetching sport recommendations: $e");
      rethrow;
    }
  }

  /// 🧰 Helper แปลงข้อความ error
  String _parseError(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['message'] ?? body['error'] ?? 'Unknown error';
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }
}
