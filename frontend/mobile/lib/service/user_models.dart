// lib/models/user_model.dart

class UserProfile {
  final int userId;
  final String username;
  final String email;
  final String? imageProfile;
  final String? imageProfileUrl; // URL เต็มสำหรับแสดงรูป
  final String? phoneNumber;
  final int? age;
  final String? gender;
  final double? height;
  final double? weight;
  final String? goal;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  UserProfile({
    required this.userId,
    required this.username,
    required this.email,
    this.imageProfile,
    this.imageProfileUrl,
    this.phoneNumber,
    this.age,
    this.gender,
    this.height,
    this.weight,
    this.goal,
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  // สร้าง UserProfile จาก JSON
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id'],
      username: json['username'],
      email: json['email'],
      imageProfile: json['image_profile'],
      imageProfileUrl: json['image_profile_url'],
      phoneNumber: json['phone_number'],
      age: json['age'],
      gender: json['gender'],
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      goal: json['goal'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.parse(json['last_login_at'])
          : null,
    );
  }

  // แปลง UserProfile เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'username': username,
      'email': email,
      'image_profile': imageProfile,
      'image_profile_url': imageProfileUrl,
      'phone_number': phoneNumber,
      'age': age,
      'gender': gender,
      'height': height,
      'weight': weight,
      'goal': goal,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'last_login_at': lastLoginAt?.toIso8601String(),
    };
  }

  // Copy with method สำหรับอัปเดทข้อมูลบางส่วน
  UserProfile copyWith({
    int? userId,
    String? username,
    String? email,
    String? imageProfile,
    String? imageProfileUrl,
    String? phoneNumber,
    int? age,
    String? gender,
    double? height,
    double? weight,
    String? goal,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      email: email ?? this.email,
      imageProfile: imageProfile ?? this.imageProfile,
      imageProfileUrl: imageProfileUrl ?? this.imageProfileUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }
}

// Response Model สำหรับ API
class ProfileResponse {
  final bool success;
  final String message;
  final UserProfile? user;

  ProfileResponse({required this.success, required this.message, this.user});

  factory ProfileResponse.fromJson(Map<String, dynamic> json) {
    return ProfileResponse(
      success: json['success'] ?? true,
      message: json['message'] ?? '',
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
    );
  }
}
