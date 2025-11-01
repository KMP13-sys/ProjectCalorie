/// API Configuration
///
/// วิธีใช้งาน:
/// 1. Development (Local): ใช้ localhost หรือ 192.168.100.67
/// 2. Production (Public IP): ใช้ IP Public ของบ้าน
/// 3. Cloud Deploy: ใช้ Ngrok/Railway/Render URL
class ApiConfig {
  // ⚙️ เปลี่ยน URL ตรงนี้เท่านั้น
  // Node.js Backend (port 4000)
  static const String _baseUrl = 'http://localhost:4000';

  // Flask ML Server (port 5000)
  static const String _flaskUrl = 'http://localhost:5000';

  // 🔹 สำหรับ Development (ในบ้าน):
  //    - Physical Device (มือถือจริง):
  //      Node.js: 'http://10.13.2.102:4000'
  //      Flask: 'http://10.13.2.102:5000'
  //10.13.2.112
  //    - Android Emulator:
  //      Node.js: 'http://10.0.2.2:4000'
  //      Flask: 'http://10.0.2.2:5000'
  //    - iOS Simulator:
  //      Node.js: 'http://localhost:4000'
  //      Flask: 'http://localhost:5000'
  //    - Web Browser:
  //      Node.js: 'http://localhost:4000'
  //      Flask: 'http://localhost:5000'

  // ========================================
  // Node.js Backend API Endpoints (port 4000)
  // ========================================
  static String get baseUrl => _baseUrl;
  static String get authUrl => '$_baseUrl/api/auth';
  static String get profileUrl => '$_baseUrl/api/profile';
  static String get dailyUrl => '$_baseUrl/api/daily';
  static String get uploadsUrl => '$_baseUrl/uploads';

  // ========================================
  // Flask ML Server API Endpoints (port 5000)
  // ========================================
  static String get flaskUrl => _flaskUrl;
  static String get predictUrl => '$_flaskUrl/api/predict-food';
  static String get saveMealUrl => '$_flaskUrl/api/save-meal';
  static String get foodRecommendUrl => '$_flaskUrl/api/food-recommend';
  static String get sportRecommendUrl => '$_flaskUrl/api/sport-recommend';

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
