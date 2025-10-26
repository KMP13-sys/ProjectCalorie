/// API Configuration
///
/// วิธีใช้งาน:
/// 1. Development (Local): ใช้ localhost
/// 2. Development (Ngrok): เปลี่ยนเป็น Ngrok URL
/// 3. Production (Railway): เปลี่ยนเป็น Railway URL
class ApiConfig {
  // ⚙️ เปลี่ยน URL ตรงนี้เท่านั้น
  static const String _baseUrl = 'http://localhost:4000';

  // 🔹 สำหรับ Android Emulator ใช้: 'http://10.0.2.2:4000'
  // 🔹 สำหรับ iOS Simulator ใช้: 'http://localhost:4000'
  // 🔹 สำหรับ Ngrok ใช้: 'https://your-ngrok-url.ngrok-free.app'
  // 🔹 สำหรับ Railway ใช้: 'https://your-app.up.railway.app'

  // API Endpoints
  static String get baseUrl => _baseUrl;
  static String get authUrl => '$_baseUrl/api/auth';
  static String get profileUrl => '$_baseUrl/api/profile';
  static String get dailyUrl => '$_baseUrl/api/daily';
  static String get uploadsUrl => '$_baseUrl/uploads';

  // Helper method สำหรับสร้าง full image URL
  static String getImageUrl(String imagePath) {
    // ถ้า imagePath เป็น full URL อยู่แล้ว ให้ return เลย
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    }

    // ถ้าเป็น path แบบ /uploads/xxx.jpg หรือ uploads/xxx.jpg
    String cleanPath = imagePath.replaceFirst(RegExp(r'^/+'), '');
    return '$_baseUrl/$cleanPath';
  }
}
