// lib/services/storage_helper.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageHelper {
  static const _storage = FlutterSecureStorage();

  // Keys สำหรับเก็บข้อมูล
  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';

  // ========== ACCESS TOKEN ==========
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  // ========== REFRESH TOKEN ==========
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // ========== USER ID ==========
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // ========== USERNAME ==========
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: _keyUsername, value: username);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  // ========== EMAIL ==========
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _keyEmail, value: email);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _keyEmail);
  }

  // ========== บันทึกข้อมูล Login ทั้งหมดพร้อมกัน ==========
  static Future<void> saveLoginData({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String username,
    String? email,
  }) async {
    await saveAccessToken(accessToken);
    await saveRefreshToken(refreshToken);
    await saveUserId(userId);
    await saveUsername(username);
    if (email != null) await saveEmail(email);
  }

  // ========== ลบข้อมูลทั้งหมด (Logout) ==========
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ========== เช็คว่ามี Refresh Token อยู่หรือไม่ ==========
  static Future<bool> isLoggedIn() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  // ========== เช็คว่า Access Token ยังใช้งานได้หรือไม่ ==========
  static Future<bool> hasValidAccessToken() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}