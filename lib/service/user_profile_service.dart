import 'package:auraai/service/notification_service.dart';

import '../models/user_models.dart';
import 'health_service.dart';

class UserProfileService {
  Future updateAnalysis({String? w, String? h}) async {
    double weight = double.parse(w!);
    double height = double.parse(h!);
    if (weight > 0 && height > 0) {
      // We calculate these live but don't save to Disk until the button is pressed
      UserProfile.waterGoal = HealthCalculator.calculateWaterGoal(
        weight,
        UserProfile.gender ?? 'Male',
      );
    }
  }

  void reminderSetService() {
    print("wake up time ${UserProfile.wakingHours}");
    // NotificationService.scheduleDailyWakeUp(1,UserProfile.wakeUpTime!);
    // NotificationService.scheduleDailyWakeUp(2,UserProfile.sleepTime!);

  }
}
