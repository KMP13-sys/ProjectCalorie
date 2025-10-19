// lib/services/storage_helper.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  // Keys สำหรับเก็บข้อมูล
  static const String _keyToken = 'auth_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';

  // บันทึก Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, token);
  }

  // ดึง Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyToken);
  }

  // บันทึก User ID
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
  }

  // ดึง User ID
  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  // บันทึก Username (optional - สำหรับใช้งานเบื้องต้น)
  static Future<void> saveUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  // ดึง Username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }

  // บันทึกข้อมูล Login ทั้งหมดพร้อมกัน
  static Future<void> saveLoginData({
    required String token,
    required int userId,
    required String username,
  }) async {
    await saveToken(token);
    await saveUserId(userId);
    await saveUsername(username);
  }

  // ลบข้อมูลทั้งหมด (Logout)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUsername);
  }

  // เช็คว่ามี Token อยู่หรือไม่ (ตรวจสอบว่า Login อยู่หรือเปล่า)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
