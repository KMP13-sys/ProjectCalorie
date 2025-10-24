// lib/services/profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../service/user_models.dart';
import 'storage_helper.dart';
import 'auth_service.dart';

class ProfileService {
  // Base URL ของ API
  static const String baseUrl = 'http://localhost:4000/api';

  // สำหรับ Android Emulator ใช้ 10.0.2.2 แทน localhost
  // static const String baseUrl = 'http://10.0.2.2:4000/api';

  // ========== ดึงข้อมูลโปรไฟล์ผู้ใช้ ==========
  static Future<UserProfile> getUserProfile(String userId) async {
    try {
      final url = '$baseUrl/profile/$userId';

      final response = await AuthService.authenticatedRequest(
        method: 'GET',
        endpoint: url,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== ดึงข้อมูลโปรไฟล์ของ User ที่ login อยู่ ==========
  static Future<UserProfile> getMyProfile() async {
    try {
      final userId = await StorageHelper.getUserId();

      if (userId == null || userId.isEmpty) {
        throw Exception('No user ID found. Please login again.');
      }

      return await getUserProfile(userId);
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== อัปเดทรูปโปรไฟล์ ==========
  static Future<UpdateProfileImageResponse> updateProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      String? accessToken = await StorageHelper.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please login.');
      }

      final url = Uri.parse('$baseUrl/profile/$userId/image');

      // สร้าง multipart request
      var request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          imageFile.path,
        ),
      );

      // ส่ง request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // ถ้า token หมดอายุ ให้ refresh แล้วลองใหม่
      if (response.statusCode == 401 || response.statusCode == 403) {
        try {
          accessToken = await AuthService.refreshAccessToken();

          // ลองอัพโหลดอีกครั้งด้วย token ใหม่
          request = http.MultipartRequest('PUT', url);
          request.headers['Authorization'] = 'Bearer $accessToken';
          request.files.add(
            await http.MultipartFile.fromPath(
              'profile_image',
              imageFile.path,
            ),
          );

          streamedResponse = await request.send();
          response = await http.Response.fromStream(streamedResponse);
        } catch (e) {
          throw Exception('Session expired. Please login again.');
        }
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UpdateProfileImageResponse(
          message: data['message'] ?? 'Profile image updated successfully',
          imageUrl: data['image_url'],
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile image');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== อัปเดทข้อมูลโปรไฟล์ ==========
  static Future<UpdateProfileResponse> updateProfile({
    required String userId,
    double? weight,
    double? height,
    int? age,
    String? gender,
    String? goal,
  }) async {
    try {
      final url = '$baseUrl/update/$userId';

      final Map<String, dynamic> body = {};
      if (weight != null) body['weight'] = weight;
      if (height != null) body['height'] = height;
      if (age != null) body['age'] = age;
      if (gender != null) body['gender'] = gender.toLowerCase();
      if (goal != null) body['goal'] = goal.toLowerCase();

      final response = await AuthService.authenticatedRequest(
        method: 'PUT',
        endpoint: url,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return UpdateProfileResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== อัปเดทโปรไฟล์ของ User ที่ login อยู่ ==========
  static Future<UpdateProfileResponse> updateMyProfile({
    double? weight,
    double? height,
    int? age,
    String? gender,
    String? goal,
  }) async {
    try {
      final userId = await StorageHelper.getUserId();

      if (userId == null || userId.isEmpty) {
        throw Exception('No user ID found. Please login again.');
      }

      return await updateProfile(
        userId: userId,
        weight: weight,
        height: height,
        age: age,
        gender: gender,
        goal: goal,
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== อัปเดทรูปโปรไฟล์ของ User ที่ login อยู่ ==========
  static Future<UpdateProfileImageResponse> updateMyProfileImage({
    required File imageFile,
  }) async {
    try {
      final userId = await StorageHelper.getUserId();

      if (userId == null || userId.isEmpty) {
        throw Exception('No user ID found. Please login again.');
      }

      return await updateProfileImage(
        userId: userId,
        imageFile: imageFile,
      );
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }
}