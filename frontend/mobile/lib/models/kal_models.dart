// Model สำหรับ Response การคำนวณแคลอรี่
class CalculateCaloriesResponse {
  final String message;
  final double activityLevel;
  final double bmr;
  final double tdee;
  final double targetCalories;
  final String goal;

  CalculateCaloriesResponse({
    required this.message,
    required this.activityLevel,
    required this.bmr,
    required this.tdee,
    required this.targetCalories,
    required this.goal,
  });

  factory CalculateCaloriesResponse.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return CalculateCaloriesResponse(
      message: json['message'] ?? '',
      activityLevel: parseValue(json['activity_level']),
      bmr: parseValue(json['bmr']),
      tdee: parseValue(json['tdee']),
      targetCalories: parseValue(json['target_calories']),
      goal: json['goal'] ?? '',
    );
  }
}

// Model สถานะแคลอรี่รายวัน
class CalorieStatus {
  final double activityLevel;
  final double targetCalories;
  final double consumedCalories;
  final double burnedCalories;
  final double netCalories;
  final double remainingCalories;

  CalorieStatus({
    required this.activityLevel,
    required this.targetCalories,
    required this.consumedCalories,
    required this.burnedCalories,
    required this.netCalories,
    required this.remainingCalories,
  });

  factory CalorieStatus.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return CalorieStatus(
      activityLevel: parseValue(json['activity_level']),
      targetCalories: parseValue(json['target_calories']),
      consumedCalories: parseValue(json['consumed_calories']),
      burnedCalories: parseValue(json['burned_calories']),
      netCalories: parseValue(json['net_calories']),
      remainingCalories: parseValue(json['remaining_calories']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activity_level': activityLevel,
      'target_calories': targetCalories,
      'consumed_calories': consumedCalories,
      'burned_calories': burnedCalories,
      'net_calories': netCalories,
      'remaining_calories': remainingCalories,
    };
  }
}

// Model สารอาหารรายวัน (Macros)
class DailyMacros {
  final String message;
  final double protein;
  final double fat;
  final double carbohydrate;

  DailyMacros({
    required this.message,
    required this.protein,
    required this.fat,
    required this.carbohydrate,
  });

  factory DailyMacros.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return DailyMacros(
      message: json['message'] ?? '',
      protein: parseValue(json['protein']),
      fat: parseValue(json['fat']),
      carbohydrate: parseValue(json['carbohydrate']),
    );
  }
}

// Model สำหรับ Response แคลอรี่รายสัปดาห์
class WeeklyCaloriesResponse {
  final String message;
  final List<DailyCalorieData> data;

  WeeklyCaloriesResponse({required this.message, required this.data});

  factory WeeklyCaloriesResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyCaloriesResponse(
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map((item) => DailyCalorieData.fromJson(item))
              .toList() ??
          [],
    );
  }
}

// Model ข้อมูลแคลอรี่รายวัน
class DailyCalorieData {
  final String date;
  final double netCalories;

  DailyCalorieData({required this.date, required this.netCalories});

  factory DailyCalorieData.fromJson(Map<String, dynamic> json) {
    double parseValue(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0.0;
      return 0.0;
    }

    return DailyCalorieData(
      date: json['date'] ?? '',
      netCalories: parseValue(json['net_calories']),
    );
  }
}
