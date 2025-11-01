import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Helper สำหรับจัดการข้อมูลใน Secure Storage
class StorageHelper {
  static const _storage = FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyUsername = 'username';
  static const String _keyEmail = 'email';

  // บันทึก Access Token
  static Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _keyAccessToken, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _keyAccessToken);
  }

  // บันทึก Refresh Token
  static Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _keyRefreshToken, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _keyRefreshToken);
  }

  // บันทึก User ID
  static Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  static Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  // บันทึก Username
  static Future<void> saveUsername(String username) async {
    await _storage.write(key: _keyUsername, value: username);
  }

  static Future<String?> getUsername() async {
    return await _storage.read(key: _keyUsername);
  }

  // บันทึก Email
  static Future<void> saveEmail(String email) async {
    await _storage.write(key: _keyEmail, value: email);
  }

  static Future<String?> getEmail() async {
    return await _storage.read(key: _keyEmail);
  }

  // บันทึกข้อมูล Login ทั้งหมดพร้อมกัน
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

  // ลบข้อมูลทั้งหมด (ใช้เมื่อ Logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // ตรวจสอบว่ามี Refresh Token หรือไม่
  static Future<bool> isLoggedIn() async {
    final refreshToken = await getRefreshToken();
    return refreshToken != null && refreshToken.isNotEmpty;
  }

  // ตรวจสอบว่า Access Token ยังใช้งานได้หรือไม่
  static Future<bool> hasValidAccessToken() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}