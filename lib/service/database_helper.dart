import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (Platform.isAndroid || Platform.isIOS) {

    }

    _database = await _initDB('fitness.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    // Ensure the directory exists
    return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE workouts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise TEXT,
        weight REAL,
        date TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE water (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount REAL,
        date TEXT
      )
    ''');
  }


  Future<void> logWater(double ml) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('water', {
      'amount': ml,
      'date': DateTime.now().toIso8601String(),
    });
    print("Hydration Logged: $ml ml");
  }

  Future<List<Map<String, dynamic>>> getWeeklyWater() async {
    final db = await instance.database;
    // This query gets the total water for each of the last 7 days
    return await db.rawQuery('''
    SELECT date(date) as day, SUM(amount) as total 
    FROM water 
    WHERE date >= date('now', '-7 days')
    GROUP BY day 
    ORDER BY day ASC
  ''');
  }

  Future<String> generateAuraInsight() async {
    final db = await instance.database;

    // 1. Get average water intake for the last 7 days
    final waterData = await db.rawQuery(
        "SELECT AVG(total) as avg_water FROM (SELECT SUM(amount) as total FROM water GROUP BY date(date) LIMIT 7)"
    );

    // 2. Get total gym sessions in the last 7 days
    final auraaita = await db.rawQuery(
        "SELECT COUNT(*) as session_count FROM gym_logs WHERE date >= date('now', '-7 days')"
    );

    double avgWater = (waterData.first['avg_water'] ?? 0.0) as double;
    int gymSessions = (auraaita.first['session_count'] ?? 0) as int;

    // 3. Simple Rule-Based AI Engine
    if (gymSessions >= 4 && avgWater >= 2000) {
      return "Peak Aura: Your hydration is fueling your consistency. You're in the top 1% of performance this week.";
    } else if (gymSessions >= 3 && avgWater < 1500) {
      return "Aura Warning: You're training hard, but your hydration is lagging. Bump it up to 2000ml to avoid fatigue.";
    } else if (gymSessions < 2 && avgWater > 2000) {
      return "Aura Insight: Your recovery is on point. Now is the perfect time for a high-intensity session!";
    } else {
      return "Aura Tip: Try logging one more glass of water today to improve your gym focus.";
    }
  }
}