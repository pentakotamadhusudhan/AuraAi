import 'package:auraai/models/user_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InitialService {


  Future setValues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    UserProfile.name = "Madhu";
    UserProfile.height = 157;
    UserProfile.weight = 66;
    UserProfile.waterGoal = 5000;
    UserProfile.drunkWater =prefs.getDouble('drunk_water') ?? 0.0;
    UserProfile.age = 29;
    // UserProfile.saveToDisk();

  }
}
