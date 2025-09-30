// Model สำหรับ Response จาก Register API
class AuthResponse {
  final bool success;
  final String message;
  final String? token;

  AuthResponse({
    required this.success,
    required this.message,
    this.token,
  });
}

// Model สำหรับ Response จาก Login API
class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final UserData? user;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
  });
}

// Model สำหรับข้อมูล User
class UserData {
  final int id;
  final String username;

  UserData({
    required this.id,
    required this.username,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      username: json['username'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
    };
  }
}