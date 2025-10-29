import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'storage_helper.dart';

class PredictService {
  // ใช้ environment variable หรือค่า default
  static String get baseUrl {
    // ใช้ค่า default ตาม environment
    const String defaultUrl = String.fromEnvironment(
      'API_BASE_URL',
      defaultValue: 'http://127.0.0.1:5000',
    );
    return defaultUrl;
  }

  /// ตรวจสอบความคมชัดของภาพ
  static Future<bool> isImageClear(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) return false;

      // คำนวณ Laplacian variance เพื่อวัดความคมชัด
      // ค่ายิ่งสูง = ภาพยิ่งคมชัด
      double variance = _calculateLaplacianVariance(image);

      // กำหนด threshold ที่ 100 (ปรับได้ตามความเหมาะสม)
      return variance > 100;
    } catch (e) {
      print('Error checking image clarity: $e');
      return false;
    }
  }

  /// คำนวณ Laplacian variance (วัดความคมชัด)
  static double _calculateLaplacianVariance(img.Image image) {
    // แปลงเป็น grayscale
    final gray = img.grayscale(image);

    // Laplacian kernel
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

    // คำนวณ variance
    if (laplacian.isEmpty) return 0;

    final mean = laplacian.reduce((a, b) => a + b) / laplacian.length;
    final variance = laplacian.map((x) => (x - mean) * (x - mean)).reduce((a, b) => a + b) / laplacian.length;

    return variance;
  }

  /// ส่งภาพไปทำนายที่ ML model
  static Future<Map<String, dynamic>> predictFood(File imageFile) async {
    try {
      // ดึง token และ userId จาก StorageHelper
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

      // สร้าง multipart request
      final uri = Uri.parse('$baseUrl/api/predict-food/$userId');
      final request = http.MultipartRequest('POST', uri);

      // เพิ่ม headers
      request.headers['Authorization'] = 'Bearer $token';

      // เพิ่มไฟล์ภาพ
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      // ส่ง request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        // ตรวจสอบว่าเป็นอาหารหรือไม่ (confidence ต้องมากกว่า 0.5)
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
      print('Error predicting food: $e');
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการเชื่อมต่อกับเซิร์ฟเวอร์',
      };
    }
  }

  /// บันทึกข้อมูลมื้ออาหาร
  static Future<Map<String, dynamic>> saveMeal({
    required int foodId,
    required double confidenceScore,
    String? mealDatetime,
  }) async {
    try {
      // ดึง token และ userId จาก StorageHelper
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
      print('Error saving meal: $e');
      return {
        'success': false,
        'error': 'เกิดข้อผิดพลาดในการบันทึกข้อมูล',
      };
    }
  }
}
