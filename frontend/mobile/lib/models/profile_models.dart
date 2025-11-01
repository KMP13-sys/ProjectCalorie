// Model ข้อมูล User Profile
class UserProfile {
  final String userId;
  final String username;
  final String email;
  final String? imageProfile;
  final String? imageProfileUrl;
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

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['user_id']?.toString() ??
              json['userId']?.toString() ??
              json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      imageProfile: json['image_profile'],
      imageProfileUrl: json['image_profile_url'],
      phoneNumber: json['phone_number'],
      age: json['age'] is int ? json['age'] : (json['age'] != null ? int.tryParse(json['age'].toString()) : null),
      gender: json['gender'],
      height: json['height'] != null
          ? double.tryParse(json['height'].toString())
          : null,
      weight: json['weight'] != null
          ? double.tryParse(json['weight'].toString())
          : null,
      goal: json['goal'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
      lastLoginAt: json['last_login_at'] != null
          ? DateTime.tryParse(json['last_login_at'].toString())
          : null,
    );
  }

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

  // สำหรับอัปเดทข้อมูลบางส่วน
  UserProfile copyWith({
    String? userId,
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

// Model สำหรับ Response การอัปเดทรูป Profile
class UpdateProfileImageResponse {
  final String message;
  final String? imageUrl;

  UpdateProfileImageResponse({
    required this.message,
    this.imageUrl,
  });

  factory UpdateProfileImageResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileImageResponse(
      message: json['message'] ?? 'Profile image updated successfully',
      imageUrl: json['image_url'],
    );
  }
}

// Model สำหรับ Response การอัปเดท Profile
class UpdateProfileResponse {
  final String message;
  final UserProfile? user;

  UpdateProfileResponse({
    required this.message,
    this.user,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      message: json['message'] ?? 'Profile updated successfully',
      user: json['user'] != null ? UserProfile.fromJson(json['user']) : null,
    );
  }
}