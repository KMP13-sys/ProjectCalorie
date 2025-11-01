import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'storage_helper.dart';
import '../config/api_config.dart';

// Service สำหรับการทำนายอาหารด้วย ML Model
class PredictService {
  static String get baseUrl => ApiConfig.flaskUrl;

  // ตรวจสอบความคมชัดของภาพ
  static Future<bool> isImageClear(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return false;

      double variance = _calculateLaplacianVariance(image);

      return variance > 100;
    } catch (e) {
      return false;
    }
  }

  // คำนวณ Laplacian variance เพื่อวัดความคมชัด
  static double _calculateLaplacianVariance(img.Image image) {
    final gray = img.grayscale(image);
    final laplacian = <double>[];

    for (int y = 1; y < gray.height - 1; y++) {
      for (int x = 1; x < gray.width - 1; x++) {
        final center = gray.getPixel(x, y).r.toDouble();
        final top = gray.getPixel(x, y - 1).r.toDouble();
        final bottom = gray.getPixel(x, y + 1).r.toDouble();
        final left = gray.getPixel(x - 1, y).r.toDouble();
        final right = gray.getPixel(x + 1, y).r.toDouble();

        final laplacianValue = (4 * center - top - bottom - left - right).abs();
        laplacian.add(laplacianValue);
      }
    }

    if (laplacian.isEmpty) return 0;

    final mean = laplacian.reduce((a, b) => a + b) / laplacian.length;
    final variance = laplacian.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / laplacian.length;

    return variance;
  }

  // ส่งภาพไปทำนายอาหารที่ ML Model
  static Future<Map<String, dynamic>> predictFood(File imageFile) async {
    try {
      final token = await StorageHelper.getAccessToken();
      final userIdStr = await StorageHelper.getUserId();
      final userId = userIdStr != null ? int.tryParse(userIdStr) : null;

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'error': 'No authentication token found',
        };
      }

      if (userId == null) {
        return {
          'success': false,
          'error': 'User not logged in',
        };
      }

      final uri = Uri.parse('$baseUrl/api/predict-food/$userId');
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Bearer $token';

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final confidence = data['data']['confidence'] ?? 0.0;

          if (confidence < 0.5) {
            return {
              'success': false,
              'error': 'ภาพที่ส่งมาไม่ใช่อาหารหรือไม่ชัดเจน กรุณาถ่ายภาพใหม่',
              'low_confidence': true,
            };
          }

          return {
            'success': true,
            'data': data['data'],
          };
        } else {
          return {
            'success': false,
            'error': 'ไม่สามารถทำนายภาพได้',
          };
        }
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Authentication failed',
          'unauthorized': true,
        };
      } else {
        return {
          'success': false,
          'error': 'Server error: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์',
      };
    }
  }

  // บันทึกข้อมูลมื้ออาหาร
  static Future<Map<String, dynamic>> saveMeal({
    required int foodId,
    required double confidenceScore,
    String? mealDatetime,
  }) async {
    try {
      final token = await StorageHelper.getAccessToken();
      final userIdStr = await StorageHelper.getUserId();
      final userId = userIdStr != null ? int.tryParse(userIdStr) : null;

      if (token == null || token.isEmpty) {
        return {
          'success': false,
          'error': 'No authentication token found',
        };
      }

      if (userId == null) {
        return {
          'success': false,
          'error': 'User not logged in',
        };
      }

      final uri = Uri.parse('$baseUrl/api/save-meal/$userId');

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'food_id': foodId,
          'confidence_score': confidenceScore,
          if (mealDatetime != null) 'meal_datetime': mealDatetime,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else if (response.statusCode == 401) {
        return {
          'success': false,
          'error': 'Authentication failed',
          'unauthorized': true,
        };
      } else {
        final data = json.decode(response.body);
        return {
          'success': false,
          'error': data['message'] ?? 'Cannot save meal',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการบันทึกข้อมูล',
      };
    }
  }
}
