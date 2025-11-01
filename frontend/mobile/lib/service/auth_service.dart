import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/auth_models.dart';
import '../config/api_config.dart';
import 'storage_helper.dart';

// Service สำหรับการจัดการ Authentication
class AuthService {
  static String get baseUrl => ApiConfig.authUrl;

  // สมัครสมาชิกใหม่
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

  // เข้าสู่ระบบ
  static Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'platform': 'mobile',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(data);

        // บันทึก tokens และข้อมูล user
        if (loginResponse.refreshToken != null) {
          await StorageHelper.saveLoginData(
            accessToken: loginResponse.accessToken,
            refreshToken: loginResponse.refreshToken!,
            userId: loginResponse.userId ?? '',
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

  // รีเฟรช Access Token เมื่อหมดอายุ
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

        await StorageHelper.saveAccessToken(refreshResponse.accessToken);

        return refreshResponse.accessToken;
      } else if (response.statusCode == 403) {
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

  // ออกจากระบบ
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
        }
      }

      await StorageHelper.clearAll();
    } catch (e) {
      await StorageHelper.clearAll();
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ลบบัญชีผู้ใช้
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
        await StorageHelper.clearAll();
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to delete account');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('เกิดข้อผิดพลาด: ${e.toString()}');
    }
  }

  // ดึงข้อมูลผู้ใช้ปัจจุบัน
  static Future<User?> getCurrentUser() async {
    try {
      final accessToken = await StorageHelper.getAccessToken();

      if (accessToken == null) {
        return null;
      }

      // แยก JWT payload เพื่อดึง userId
      final parts = accessToken.split('.');
      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      final userId = payloadMap['id']?.toString() ?? payloadMap['userId']?.toString();

      if (userId == null) {
        return null;
      }

      final profileUrl = '${ApiConfig.profileUrl}/$userId';
      final url = Uri.parse(profileUrl);

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

        await StorageHelper.saveUserId(user.userId);
        await StorageHelper.saveUsername(user.username);
        if (user.email != null) {
          await StorageHelper.saveEmail(user.email!);
        }

        return user;
      } else {
        throw Exception('Failed to fetch user profile: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Error getting current user: $e');
    }
  }

  // ตรวจสอบว่ามี session ที่ใช้งานได้หรือไม่
  static Future<bool> hasValidSession() async {
    try {
      final refreshToken = await StorageHelper.getRefreshToken();

      if (refreshToken == null || refreshToken.isEmpty) {
        return false;
      }

      final parts = refreshToken.split('.');
      if (parts.length != 3) {
        return false;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final resp = utf8.decode(base64Url.decode(normalized));
      final payloadMap = json.decode(resp);

      final exp = payloadMap['exp'] as int?;
      if (exp == null) {
        return false;
      }

      final expiryDate = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      final now = DateTime.now();

      if (now.isAfter(expiryDate)) {
        await StorageHelper.clearAll();
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  // Helper สำหรับเรียก API พร้อม auto refresh token
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