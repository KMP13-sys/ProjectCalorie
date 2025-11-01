// lib/services/profile_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/profile_models.dart';
import '../config/api_config.dart';
import 'storage_helper.dart';
import 'auth_service.dart';

class ProfileService {
  // ========== ดึงข้อมูลโปรไฟล์ผู้ใช้ ==========
  static Future<UserProfile> getUserProfile(String userId) async {
    try {
      final url = '${ApiConfig.profileUrl}/$userId';

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

      final url = Uri.parse('${ApiConfig.profileUrl}/$userId/image');
      print('[Profile Service] Upload URL: $url');
      print('[Profile Service] Image path: ${imageFile.path}');
      print('[Profile Service] File exists: ${await imageFile.exists()}');

      // สร้าง multipart request
      var request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.files.add(
        await http.MultipartFile.fromPath(
          'profile_image',
          imageFile.path,
        ),
      );

      print('[Profile Service] Sending request...');

      // ส่ง request
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print('[Profile Service] Response status: ${response.statusCode}');
      print('[Profile Service] Response body: ${response.body}');

      // ถ้า token หมดอายุ ให้ refresh แล้วลองใหม่
      if (response.statusCode == 401 || response.statusCode == 403) {
        print('[Profile Service] Token expired, refreshing...');
        try {
          accessToken = await AuthService.refreshAccessToken();
          print('[Profile Service] Token refreshed, retrying upload...');

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

          print('[Profile Service] Retry response status: ${response.statusCode}');
          print('[Profile Service] Retry response body: ${response.body}');
        } catch (e) {
          print('[Profile Service] Refresh token error: $e');
          throw Exception('Session expired. Please login again.');
        }
      }

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('[Profile Service] Upload successful!');
        return UpdateProfileImageResponse(
          message: data['message'] ?? 'Profile image updated successfully',
          imageUrl: data['image_url'],
        );
      } else {
        // พยายาม parse error message จาก response
        String errorMessage = 'Failed to update profile image';
        try {
          final error = jsonDecode(response.body);
          errorMessage = error['message'] ?? errorMessage;
        } catch (e) {
          errorMessage = 'Server error: ${response.statusCode} - ${response.body}';
        }
        print('[Profile Service] Upload failed: $errorMessage');
        throw Exception(errorMessage);
      }
    } on SocketException catch (e) {
      print('[Profile Service] Network error: $e');
      throw Exception('ไม่สามารถเชื่อมต่อกับเซิร์ฟเวอร์ได้ กรุณาตรวจสอบการเชื่อมต่ออินเทอร์เน็ต');
    } catch (e) {
      print('[Profile Service] Error: $e');
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
      final url = '${ApiConfig.baseUrl}/api/update/$userId';

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
      // ✅ ดึง userId จาก JWT token โดยตรงแทนที่จะใช้จาก storage
      final accessToken = await StorageHelper.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('No access token found. Please login.');
      }

      String? userId;

      try {
        // Decode JWT payload เพื่อดึง userId
        final parts = accessToken.split('.');
        if (parts.length == 3) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final resp = utf8.decode(base64Url.decode(normalized));
          final payloadMap = json.decode(resp);

          // Backend ใช้ field 'id' ใน JWT
          userId = payloadMap['id']?.toString();

          print('[Profile Service] Decoded userId from token: $userId');
        }
      } catch (e) {
        print('[Profile Service] Error decoding token: $e');
      }

      // ถ้า decode ไม่ได้ ให้ fallback ไปใช้จาก storage
      if (userId == null || userId.isEmpty) {
        final userIdStr = await StorageHelper.getUserId();

        if (userIdStr == null || userIdStr.isEmpty) {
          throw Exception('User ID not found. Please login again.');
        }

        userId = userIdStr;
        print('[Profile Service] Using userId from storage: $userId');
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