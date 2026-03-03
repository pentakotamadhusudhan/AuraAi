import 'package:shared_preferences/shared_preferences.dart';

class UserProfile {
  // Personal Info
  static String? name;
  static int? age;
  static String? gender;

  // Physical Metrics
  static double? weight;
  static double? height;

  // Hydration Data
  static double waterGoal = 0.0;
  static double drunkWater = 0.0;

  // Schedule Data
  static DateTime? wakeUpTime;
  static DateTime? sleepTime;

  // --- SAFETY GETTERS ---

  static double get bmi {
    if (weight == null || height == null || height == 0) return 0.0;
    return weight! / ((height! / 100) * (height! / 100));
  }

  static double get progress {
    if (waterGoal <= 0) return 0.0;
    return (drunkWater / waterGoal).clamp(0.0, 1.0);
  }

  /// Calculates how many hours the user is awake.
  /// Useful for spacing out notifications.
  static int get wakingHours {
    if (wakeUpTime == null || sleepTime == null) return 16; // Default to 16
    return sleepTime!.difference(wakeUpTime!).inHours;
  }

  // --- PERSISTENCE ---

  static Future<void> saveToDisk() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (name != null) await prefs.setString('user_name', name!);
    if (age != null) await prefs.setInt('user_age', age!);
    if (gender != null) await prefs.setString('user_gender', gender!);
    if (weight != null) await prefs.setDouble('user_weight', weight!);
    if (height != null) await prefs.setDouble('user_height', height!);

    await prefs.setDouble('water_goal', waterGoal);
    await prefs.setDouble('drunk_water', drunkWater);

    // Save DateTime as ISO8601 Strings
    if (wakeUpTime != null) {
      await prefs.setString('wake_up_time', wakeUpTime!.toIso8601String());
    }
    if (sleepTime != null) {
      await prefs.setString('sleep_time', sleepTime!.toIso8601String());
    }
  }

  static Future<void> loadFromDisk() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    name = prefs.getString('user_name');
    age = prefs.getInt('user_age');
    gender = prefs.getString('user_gender');
    weight = prefs.getDouble('user_weight');
    height = prefs.getDouble('user_height');

    // Use ?? to provide safe defaults during load
    waterGoal = prefs.getDouble('water_goal') ?? 0.0;
    drunkWater = prefs.getDouble('drunk_water') ?? 0.0;

    // Parse Strings back to DateTime
    String? wakeStr = prefs.getString('wake_up_time');
    String? sleepStr = prefs.getString('sleep_time');

    if (wakeStr != null) wakeUpTime = DateTime.tryParse(wakeStr);
    if (sleepStr != null) sleepTime = DateTime.tryParse(sleepStr);
  }

  /// Reset daily progress (call this at midnight or via a button)
  static void resetProgress() {
    drunkWater = 0.0;
    saveToDisk();
  }
}