// Model สำหรับ Response จากการสมัครสมาชิก
class RegisterResponse {
  final String message;

  RegisterResponse({required this.message});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'] ?? 'Registration successful',
    );
  }
}

// Model สำหรับ Response จากการเข้าสู่ระบบ
class LoginResponse {
  final String message;
  final String role;
  final String? userId;
  final String accessToken;
  final String? refreshToken;
  final String expiresIn;

  LoginResponse({
    required this.message,
    required this.role,
    this.userId,
    required this.accessToken,
    this.refreshToken,
    required this.expiresIn,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'] ?? 'Login successful',
      role: json['role'] ?? 'user',
      userId: json['userId']?.toString(),
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'],
      expiresIn: json['expiresIn'] ?? '30m',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'role': role,
      'userId': userId,
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
    };
  }
}

// Model สำหรับ Response จากการรีเฟรช Token
class RefreshTokenResponse {
  final String accessToken;
  final String expiresIn;

  RefreshTokenResponse({required this.accessToken, required this.expiresIn});

  factory RefreshTokenResponse.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponse(
      accessToken: json['accessToken'] ?? '',
      expiresIn: json['expiresIn'] ?? '30m',
    );
  }
}

// Model ข้อมูลผู้ใช้
class User {
  final String userId;
  final String username;
  final String? email;
  final String? phoneNumber;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? goal;
  final String? imageProfile;

  User({
    required this.userId,
    required this.username,
    this.email,
    this.phoneNumber,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.goal,
    this.imageProfile,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'],
      phoneNumber: json['phone_number'],
      age: json['age'] is int
          ? json['age']
          : (json['age'] != null ? int.tryParse(json['age'].toString()) : null),
      gender: json['gender'],
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      goal: json['goal'],
      imageProfile: json['image_profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'phone_number': phoneNumber,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal': goal,
      'image_profile': imageProfile,
    };
  }
}

// Model สำหรับ Error Response
class ErrorResponse {
  final String message;
  final int? attemptsLeft;

  ErrorResponse({required this.message, this.attemptsLeft});

  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      message: json['message'] ?? 'An error occurred',
      attemptsLeft: json['attemptsLeft'],
    );
  }
}
