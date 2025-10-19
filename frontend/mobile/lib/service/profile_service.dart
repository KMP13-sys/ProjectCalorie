// lib/services/profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'user_models.dart';
import 'storage_helper.dart';

class ProfileService {
  // Base URL ของ API
  static const String baseUrl = 'http://localhost:4000/api/profile';

  // สำหรับ Android Emulator ใช้ 10.0.2.2 แทน localhost
  // static const String baseUrl = 'http://10.0.2.2:4000/api/profile';

  // สำหรับ iOS Simulator ใช้ localhost ได้เลย
  // static const String baseUrl = 'http://localhost:4000/api/profile';

  // ดึงข้อมูลโปรไฟล์ผู้ใช้
  static Future<UserProfile?> getUserProfile(int userId) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        print('Error: No token found');
        return null;
      }

      final url = Uri.parse('$baseUrl/$userId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error fetching profile: ${e.toString()}');
      return null;
    }
  }

  // อัปเดทรูปโปรไฟล์
  static Future<Map<String, dynamic>> updateProfileImage({
    required int userId,
    required File imageFile,
  }) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final url = Uri.parse('$baseUrl/$userId/image');

      // สร้าง multipart request
      var request = http.MultipartRequest('PUT', url);

      // เพิ่ม headers
      request.headers['Authorization'] = 'Bearer $token';

      // เพิ่มไฟล์รูปภาพ
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image', // ต้องตรงกับชื่อที่ backend รับ
          imageFile.path,
        ),
      );

      // ส่ง request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'],
          'image_url': data['image_url'],
        };
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile image',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: ${e.toString()}'};
    }
  }

  // อัปเดทข้อมูลโปรไฟล์ (สำหรับใช้ในหน้า Profile)
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    double? weight,
    double? height,
    int? age,
    String? gender,
    String? goal,
  }) async {
    try {
      final token = await StorageHelper.getToken();

      if (token == null) {
        return {'success': false, 'message': 'No token found'};
      }

      final url = Uri.parse('http://localhost:4000/api/update/$userId');
      // หรือใช้ baseUrl ที่คุณตั้งไว้สำหรับ update profile

      final Map<String, dynamic> body = {};
      if (weight != null) body['weight'] = weight;
      if (height != null) body['height'] = height;
      if (age != null) body['age'] = age;
      if (gender != null) body['gender'] = gender.toLowerCase();
      if (goal != null) body['goal'] = goal.toLowerCase();

      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Profile updated successfully',
        };
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'เกิดข้อผิดพลาด: ${e.toString()}'};
    }
  }
}
