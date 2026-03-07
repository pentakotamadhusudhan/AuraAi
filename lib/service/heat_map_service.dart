import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuraHistory {
  static const String _key = 'heat_map_history';

  // 1. Save Today's Final Progress
  static Future<void> saveDailyProgress(double amount, double goal) async {
    final prefs = await SharedPreferences.getInstance();
    String? rawData = prefs.getString(_key);
    Map<String, dynamic> history = rawData != null ? jsonDecode(rawData) : {};

    // Calculate intensity (1 to 10)
    int intensity = ((amount / goal) * 10).toInt().clamp(0, 10);

    // Format: "2026-03-07"
    String today = DateTime.now().toString().substring(0, 10);
    history[today] = intensity;

    await prefs.setString(_key, jsonEncode(history));
  }

  // 2. Load History for the Widget
  static Future<Map<DateTime, int>> getHeatMapData() async {
    final prefs = await SharedPreferences.getInstance();
    String? rawData = prefs.getString(_key);
    if (rawData == null) return {};

    Map<String, dynamic> jsonMap = jsonDecode(rawData);
    Map<DateTime, int> history = {};

    jsonMap.forEach((key, value) {
      history[DateTime.parse(key)] = value as int;
    });

    return history;
  }

  static Future<void> loadAndResetIfNeeded() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? lastDateString = prefs.getString('last_log_date');
    String todayDateString = DateTime.now().toString().substring(0, 10);

    if (lastDateString != null && lastDateString != todayDateString) {
      // 🔥 STEP 1: Save yesterday's data into the Heat Map history
      double lastAmount = prefs.getDouble('current_water_intake') ?? 0;
      double lastGoal = prefs.getDouble('user_water_goal') ?? 2500;

      await AuraHistory.saveDailyProgress(lastAmount, lastGoal);

      // STEP 2: Now reset for the new day
      await prefs.setDouble('current_water_intake', 0);
      await prefs.setString('last_log_date', todayDateString);
    }
  }
}