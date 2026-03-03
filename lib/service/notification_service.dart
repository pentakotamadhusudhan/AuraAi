import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';


class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await _notifications.initialize(settings: settings);

    tz.initializeTimeZones();
    final TimezoneInfo timezone = await FlutterTimezone.getLocalTimezone();
    debugPrint("----------- time zone ${timezone.identifier}");
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
  }

  static Future<void> scheduleNotification({
    required int id,required String title,required String body,
    required tz.TZDateTime scheduleTime
}) async {
    await _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();

    await _notifications.zonedSchedule(
     id:  id,
      title:title,
      body: body,
      scheduledDate: scheduleTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminder_channel',
          'Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exact,
    );
  }


  static Future<void> scheduleDailyWakeUp(int id,DateTime wakeTime) async {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    print("time zone$now");
    // 1. Create the base time for TODAY
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      wakeTime.hour,
      wakeTime.minute,
    );

    // 2. Critical: If 4:00 AM has already passed today, schedule for tomorrow
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notifications.zonedSchedule(
     id:  id, // Unique ID for WakeUp
     title:  "WakeUp Call ☀️",
      body: "Wake up, it's time to boost yourself!",
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_wake_up',
          'Daily Alarms',
          importance: Importance.max,
          priority: Priority.high,
          ongoing: true, // Set to true if you want it to stay until dismissed
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,

      // 🔥 THIS IS THE PART THAT MAKES IT REPEAT EVERY DAY
      matchDateTimeComponents: DateTimeComponents.time,
    );
    List<PendingNotificationRequest> notifications=await  _notifications.pendingNotificationRequests();
    print("All notifications ${notifications}");
    notifications.map((e) => print(e.id)).toList();
  }


  // drinking water dehydration

  static Future<void> scheduleHydrationRoutine({
    required double totalGoalMl,
    required double cupSizeMl,
    required DateTime wakeTime,
    required DateTime sleepTime,
  }) async {
    // 1. Clear previous water reminders (IDs 200-300 range)
    // You can also use cancelAll() if you are re-scheduling everything
    for (int i = 100; i < 200; i++) {
      await _notifications.cancel(id: i);
    }

    // 2. Calculate the "Waking Window"
    final int totalWakingMinutes = sleepTime.difference(wakeTime).inMinutes;

    // 3. Calculate how many times they need to drink
    final int totalReminders = (totalGoalMl / cupSizeMl).ceil();

    // 4. Calculate the interval (minutes between drinks)
    final int intervalMinutes = (totalWakingMinutes / totalReminders).floor();

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    for (int i = 0; i < totalReminders; i++) {
      // Calculate the time for this specific reminder
      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        wakeTime.hour,
        wakeTime.minute,
      ).add(Duration(minutes: intervalMinutes * i));

      // Skip if the time has already passed for today
      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      // Don't schedule if it accidentally goes past sleep time
      if (scheduledDate.hour > sleepTime.hour ||
          (scheduledDate.hour == sleepTime.hour && scheduledDate.minute > sleepTime.minute)) {
        continue;
      }

      await _notifications.zonedSchedule(
        id: 100 + i, // Unique ID in the 200 range
        title: "Drink Water 💧",
        body:"Time for your ${cupSizeMl.toInt()}ml! Stay hydrated.",
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminders', 'Hydration',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        // uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Repeats daily
      );
    }
    print("Scheduled $totalReminders water reminders every $intervalMinutes minutes.");
    // Verify scheduling
    var pending = await _notifications.pendingNotificationRequests();
    pending.forEach((e) => print("Water Reminder ID: ${e.id} at ${e.payload}"));
  }

}