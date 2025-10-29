/// API Configuration
///
/// วิธีใช้งาน:
/// 1. Development (Local): ใช้ localhost หรือ 192.168.100.67
/// 2. Production (Public IP): ใช้ IP Public ของบ้าน
/// 3. Cloud Deploy: ใช้ Ngrok/Railway/Render URL
class ApiConfig {
  // ⚙️ เปลี่ยน URL ตรงนี้เท่าน
  static const String _baseUrl = 'http://localhost:4000';

  // 🔹 สำหรับ Development (ในบ้าน):
  //    - Physical Device (มือถือจริง): 'http://10.13.2.102:4000'
  //    - Android Emulator: 'http://10.0.2.2:4000'
  //    - iOS Simulator: 'http://localhost:4000'
  //    - Web Browser: 'http://localhost:4000'
  //
  // 🔹 สำหรับ Production (ใช้นอกบ้าน):
  //    - Public IP: 'http://203.158.130.254:4000' (ต้องเปิด Port Forwarding)
  //    - Ngrok: 'https://your-ngrok-url.ngrok-free.app'
  //    - Railway: 'https://your-app.up.railway.app'
  //    - Render: 'https://your-app.onrender.com'

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
