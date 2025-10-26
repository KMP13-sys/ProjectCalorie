/// Model สำหรับอาหารแต่ละรายการ
class MealItem {
  final String foodName;
  final int calories;

  MealItem({
    required this.foodName,
    required this.calories,
  });

  factory MealItem.fromJson(Map<String, dynamic> json) {
    // แปลง calories จาก String/double/int → int
    int parsedCalories = 0;

    if (json['calories'] is String) {
      // ถ้าเป็น String เช่น "34.00"
      final doubleValue = double.tryParse(json['calories']);
      parsedCalories = doubleValue?.round() ?? 0;
    } else if (json['calories'] is double) {
      parsedCalories = (json['calories'] as double).round();
    } else if (json['calories'] is int) {
      parsedCalories = json['calories'];
    }

    return MealItem(
      foodName: json['food_name'] ?? '',
      calories: parsedCalories,
    );
  }
}

/// Model สำหรับกิจกรรมแต่ละรายการ
class ActivityItem {
  final String sportName;
  final int time;
  final int caloriesBurned;

  ActivityItem({
    required this.sportName,
    required this.time,
    required this.caloriesBurned,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    // Helper function สำหรับแปลงค่าเป็น int
    int parseToInt(dynamic value) {
      if (value is String) {
        final doubleValue = double.tryParse(value);
        return doubleValue?.round() ?? 0;
      } else if (value is double) {
        return value.round();
      } else if (value is int) {
        return value;
      }
      return 0;
    }

    return ActivityItem(
      sportName: json['sport_name'] ?? '',
      time: parseToInt(json['time']),
      caloriesBurned: parseToInt(json['calories_burned']),
    );
  }
}