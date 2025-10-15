// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_models.dart';

class ApiService {
  // Base URL ของ API
  static const String baseUrl = 'http://localhost:4000/auth';

  // สำหรับ Android Emulator ใช้ 10.0.2.2 แทน localhost
  // static const String baseUrl = 'http://10.0.2.2:5000/auth';

  // สำหรับ iOS Simulator ใช้ localhost ได้เลย
  // static const String baseUrl = 'http://localhost:5000/auth';

  // ฟังก์ชันสมัครสมาชิก
  static Future<AuthResponse> register({
    required String username,
    required String email,
    required String phone_number,
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
          'phone_number': phone_number,
          'password': password,
          'age': age,
          'gender': gender,
          'height': height,
          'weight': weight,
          'goal': goal,
        }),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // สมัครสำเร็จ
        return AuthResponse(
          success: true,
          message: data['message'],
          token: data['token'],
        );
      } else {
        // มี error
        return AuthResponse(
          success: false,
          message: data['message'] ?? 'Registration failed',
        );
      }
    } catch (e) {
      return AuthResponse(
        success: false,
        message: 'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${e.toString()}',
      );
    }
  }

  // ฟังก์ชันเข้าสู่ระบบ
  static Future<LoginResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Login สำเร็จ
        return LoginResponse(
          success: true,
          message: data['message'],
          token: data['token'],
          user: data['user'] != null ? UserData.fromJson(data['user']) : null,
        );
      } else {
        // มี error
        return LoginResponse(
          success: false,
          message: data['message'] ?? 'Login failed',
        );
      }
    } catch (e) {
      return LoginResponse(
        success: false,
        message: 'เกิดข้อผิดพลาดในการเชื่อมต่อ: ${e.toString()}',
      );
    }
  }
}
