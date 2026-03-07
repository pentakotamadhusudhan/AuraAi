import 'package:auraai/models/user_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

class HealthCalculator {
  // BMI = kg / m^2
  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0; // Prevent division by zero
    return weight / ((height / 100) * (height / 100));
  }

  static double calculateWaterGoal(double weight, String gender) {
    double base = weight * 35; // 35ml per kg
    if (gender.toLowerCase() == 'male') base += 500;
    return base;
  }

  // Changed to static and public so you can call it from your UI
  static Future<void> saveProfile({
    required double weight,
    required double height,
    required String gender,
  }) async {
    double bmi = calculateBMI(weight, height);
    double waterGoal = calculateWaterGoal(weight, gender);

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Use await for persistence safety
    await prefs.setDouble('water_goal', waterGoal);
    await prefs.setDouble('user_bmi', bmi);
    await prefs.setDouble('user_weight', weight); // Good to save for future reference
    await prefs.setString('user_gender', gender);

    // Initial trigger for the reminder cycle

  }
  // You can put this in a helper or calculate it inside your Dashboard State
  double calculateReadiness(int sessionsThisWeek) {
    // 50% based on water, 50% based on gym consistency (goal of 4 sessions)

    double waterScore = (UserProfile.drunkWater / UserProfile.waterGoal).clamp(0.0, 1.0) * 50;
    double gymScore = (sessionsThisWeek / 7).clamp(0.0, 1.0) * 50;
    print("gym score--------- $gymScore");
    return waterScore + gymScore;
  }

  static Future<void> loadAndResetIfNeeded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. Get the last date the user logged water
    String? lastDateString = prefs.getString('last_log_date'); // Format: "2026-03-02"
    String todayDateString = DateTime.now().toString().substring(0, 10);

    // 2. If the date has changed, reset the water count
    if (lastDateString != todayDateString) {
      UserProfile.waterGoal = 0;
      await prefs.setDouble('waterGoal', 0);

      // 3. Update the last_log_date to today
      await prefs.setString('last_log_date', todayDateString);
      print("✨ New day detected! Water intake reset to 0.");
    } else {
      // Load existing intake for today
      UserProfile.waterGoal = prefs.getDouble('waterGoal') ?? 0;
    }
  }
}