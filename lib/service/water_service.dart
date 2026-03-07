

import 'package:auraai/models/user_models.dart';

import 'database_helper.dart';
import 'notification_service.dart';

class WaterService {
  Future<void> checkHydrationAura(double currentTemp) async {
    final db = await DatabaseHelper.instance.database;
// formula $$\text{NeedWater} = (\text{TimeSinceLastDrink} > 2hrs) \lor (\text{Temp} > 28^\circ C \land \text{Time} > 1hr)$$
    // Get the most recent water log
    final List<Map<String, dynamic>> logs = await db.query(
        'water', orderBy: 'date DESC', limit: 1
    );

    if (logs.isEmpty) return;

    DateTime lastDrink = DateTime.parse(logs.first['date']);
    Duration difference = DateTime.now().difference(lastDrink);

    if (difference.inHours >= 2 || (currentTemp > 28 && difference.inHours >= 1)) {

    }
  }

  Future<void> logWater(double ml) async {
    final db = await DatabaseHelper.instance.database;
    await db.insert('water', {
      'amount': ml,
      'date': DateTime.now().toIso8601String(),
    });
    print("Hydration Logged: $ml ml");
    UserProfile.drunkWater = ml+UserProfile.drunkWater;
    UserProfile.saveToDisk();
  }
}