import 'dart:convert';
import 'package:http/http.dart' as http;
import 'storage_helper.dart';
import 'auth_service.dart';
import '../config/api_config.dart';

// Service สำหรับดึงคำแนะนำอาหารและกีฬา
class RecommendationService {
  static String get baseUrl => ApiConfig.flaskUrl;

  // ดึงคำแนะนำอาหาร
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

        if (data is Map && data.containsKey('recommendations')) {
          final recs = data['recommendations'];
          if (recs is List) {
            return _convertToMapList(recs);
          }
        }

        if (data is List) {
          return _convertToMapList(data);
        }

        return [];
      } else {
        throw Exception(_parseError(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  // ดึงคำแนะนำกีฬา
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
            return _convertToMapList(recs);
          }
        }

        if (data is List) {
          return _convertToMapList(data);
        }

        return [];
      } else {
        throw Exception(_parseError(response));
      }
    } catch (e) {
      rethrow;
    }
  }

  // แปลง List ให้เป็น List<Map<String, dynamic>>
  static List<Map<String, dynamic>> _convertToMapList(List data) {
    return data.map((item) {
      if (item is Map<String, dynamic>) {
        return item;
      } else if (item is String) {
        return {
          'id': 0,
          'name': item,
          'calories': 0,
        };
      } else {
        return {
          'id': 0,
          'name': item.toString(),
          'calories': 0,
        };
      }
    }).toList();
  }

  // แปลง error message จาก response
  static String _parseError(http.Response response) {
    try {
      final body = json.decode(response.body);
      return body['message'] ?? body['error'] ?? 'Unknown error';
    } catch (_) {
      return 'Request failed (${response.statusCode})';
    }
  }
}
