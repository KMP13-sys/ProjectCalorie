// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../service/auth_models.dart';
import '../config/api_config.dart';
import 'storage_helper.dart';

class AuthService {
  // ใช้ ApiConfig แทนการ hardcode URL
  static String get baseUrl => ApiConfig.authUrl;

  // ========== REGISTER ==========
  static Future<RegisterResponse> register({
    required String username,
    required String email,
    required String phoneNumber,
    required String password,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required String goal,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/register');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'phone_number': phoneNumber,
          'password': password,
          'age': age,
          'gender': gender,
          'height': height,
          'weight': weight,
          'goal': goal,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return RegisterResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== LOGIN ==========
  static Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');

      // ✅ Debug: แสดง URL ที่กำลังเรียก
      print('🌐 Calling login API: $url');
      print('📦 Request body: ${jsonEncode({
          'username': username,
          'password': password,
          'platform': 'mobile',
        })}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'platform': 'mobile', // ✅ บอกว่ามาจาก mobile
        }),
      );

      // ✅ Debug: แสดง response
      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        // ✅ บันทึก tokens และข้อมูล user
        if (loginResponse.refreshToken != null) {
          await StorageHelper.saveLoginData(
            accessToken: loginResponse.accessToken,
            refreshToken: loginResponse.refreshToken!,
            userId: '', // จะได้จาก getCurrentUser() ภายหลัง
            username: username,
          );
        }

        return loginResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาดในการเชื่อมต่อ: ${e.toString()}');
    }
  }

  // ========== REFRESH ACCESS TOKEN ==========
  static Future<String> refreshAccessToken() async {
    try {
      final refreshToken = await StorageHelper.getRefreshToken();

      if (refreshToken == null) {
        throw Exception('No refresh token found');
      }

      final url = Uri.parse('$baseUrl/refresh');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final refreshResponse = RefreshTokenResponse.fromJson(data);

        // ✅ บันทึก access token ใหม่
        await StorageHelper.saveAccessToken(refreshResponse.accessToken);

        return refreshResponse.accessToken;
      } else if (response.statusCode == 403) {
        // Refresh token หมดอายุ - ต้อง logout
        await logout();
        throw Exception('Session expired. Please login again.');
      } else {
        throw Exception('Failed to refresh token');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== LOGOUT ==========
  static Future<void> logout() async {
    try {
      final accessToken = await StorageHelper.getAccessToken();

      if (accessToken != null) {
        final url = Uri.parse('$baseUrl/logout');

        try {
          await http.post(
            url,
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Content-Type': 'application/json',
            },
          );
        } catch (e) {
          // ถ้า API ล้มเหลวก็ไม่เป็นไร ยังคงลบ local tokens
          print('Logout API error: $e');
        }
      }

      // ลบ tokens ใน device
      await StorageHelper.clearAll();
    } catch (e) {
      // แม้จะ error ก็ยังต้องลบ local tokens
      await StorageHelper.clearAll();
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== DELETE ACCOUNT ==========
  static Future<void> deleteAccount() async {
    try {
      final accessToken = await StorageHelper.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found. Please login again.');
      }

      final url = Uri.parse('$baseUrl/delete-account');

      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // ลบสำเร็จ - ลบ local tokens
        await StorageHelper.clearAll();
        print('✅ Account deleted successfully');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ========== GET CURRENT USER ==========
  static Future<User?> getCurrentUser() async {
    try {
      final accessToken = await StorageHelper.getAccessToken();

      if (accessToken == null) {
        return null;
      }

      // แยก JWT payload เพื่อดึง userId
      final parts = accessToken.split('.');
      if (parts.length != 3) {
        print('❌ Invalid JWT token format');
        return null;
      }

      // Decode payload (Base64)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      // Debug: แสดง payload
      print('🔐 JWT Payload: $payloadMap');

      // Backend ใช้ 'id' ไม่ใช่ 'userId'
      final userId = payloadMap['id']?.toString() ?? payloadMap['userId']?.toString();

      if (userId == null) {
        print('❌ No id found in token payload');
        return null;
      }

      print('✅ Found userId in token: $userId');

      // เรียก API GET /api/profile/:id (ใช้ ApiConfig)
      final profileUrl = '${ApiConfig.profileUrl}/$userId';
      final url = Uri.parse(profileUrl);

      print('🌐 Fetching profile from: $profileUrl');

      var response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      // ถ้า token หมดอายุ ให้ refresh แล้วลองใหม่
      if (response.statusCode == 401 || response.statusCode == 403) {
        final newAccessToken = await refreshAccessToken();
        response = await http.get(
          url,
          headers: {'Authorization': 'Bearer $newAccessToken'},
        );
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data);

        // บันทึกข้อมูล user
        await StorageHelper.saveUserId(user.userId);
        await StorageHelper.saveUsername(user.username);
        if (user.email != null) {
          await StorageHelper.saveEmail(user.email!);
        }

        print('✅ User data saved to storage. userId: ${user.userId}');

        // Verify ว่าบันทึกสำเร็จ
        final savedUserId = await StorageHelper.getUserId();
        print('✅ Verified saved userId: $savedUserId');

        return user;
      } else {
        print('❌ Failed to fetch user profile. Status: ${response.statusCode}');
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Get current user error: $e');
      if (e is Exception) rethrow;
      throw Exception('Error getting current user: $e');
    }
  }

  // ========== CHECK SESSION ==========
  static Future<bool> hasValidSession() async {
    try {
      final refreshToken = await StorageHelper.getRefreshToken();

      // ถ้าไม่มี refresh token = ไม่มี session
      if (refreshToken == null || refreshToken.isEmpty) {
        // ignore: avoid_print
        print('❌ No refresh token found');
        return false;
      }

      // Decode JWT payload เพื่อเช็คอายุ
      final parts = refreshToken.split('.');
      if (parts.length != 3) {
        // ignore: avoid_print
        print('❌ Invalid refresh token format');
        return false;
      }

      // Decode payload (Base64)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      // เช็คว่า token หมดอายุหรือยัง
      final exp = payloadMap['exp'] as int?;
      if (exp == null) {
        // ignore: avoid_print
        print('❌ No expiration time in token');
        return false;
      }

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      if (now.isAfter(expiryDate)) {
        // ignore: avoid_print
        print('❌ Refresh token expired at $expiryDate');
        // Token หมดอายุ - ลบ tokens ที่เก่า
        await StorageHelper.clearAll();
        return false;
      }

      // ignore: avoid_print
      print('✅ Valid session found. Token expires at $expiryDate');
      return true;
    } catch (e) {
      // ignore: avoid_print
      print('❌ Error checking session: $e');
      return false;
    }
  }

  // ========== HELPER: API CALL WITH AUTO REFRESH ==========
  // ใช้สำหรับเรียก API อื่นๆ ที่ต้องการ authentication
  static Future<http.Response> authenticatedRequest({
    required String method,
    required String endpoint,
    Map<String, String>? headers,
    Object? body,
  }) async {
    String? accessToken = await StorageHelper.getAccessToken();

    if (accessToken == null) {
      throw Exception('No access token found. Please login.');
    }

    final url = Uri.parse(endpoint);
    final defaultHeaders = {
      'Authorization': 'Bearer $accessToken',
      'Content-Type': 'application/json',
      ...?headers,
    };

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(url, headers: defaultHeaders);
        break;
      case 'POST':
        response = await http.post(url, headers: defaultHeaders, body: body);
        break;
      case 'PUT':
        response = await http.put(url, headers: defaultHeaders, body: body);
        break;
      case 'DELETE':
        response = await http.delete(url, headers: defaultHeaders, body: body);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    // ถ้า token หมดอายุ (401/403) ให้ refresh แล้วลองใหม่
    if (response.statusCode == 401 || response.statusCode == 403) {
      try {
        accessToken = await refreshAccessToken();
        defaultHeaders['Authorization'] = 'Bearer $accessToken';

        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(url, headers: defaultHeaders);
            break;
          case 'POST':
            response = await http.post(url, headers: defaultHeaders, body: body);
            break;
          case 'PUT':
            response = await http.put(url, headers: defaultHeaders, body: body);
            break;
          case 'DELETE':
            response = await http.delete(url, headers: defaultHeaders, body: body);
            break;
        }
      } catch (e) {
        throw Exception('Session expired. Please login again.');
      }
    }

    return response;
  }
}