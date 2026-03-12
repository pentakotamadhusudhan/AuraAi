import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin notifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotification() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settingsNotification = InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(settings: settingsNotification);
    // Initialize timezone database
    tz.initializeTimeZones();

    // Get device timezone
    final TimezoneInfo timezone = await FlutterTimezone.getLocalTimezone();

    // Set timezone
    tz.setLocalLocation(tz.getLocation(timezone.identifier));
  }

  Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'basic_channel',
          'Basic Notifications',
          importance: Importance.max,
          priority: Priority.high,
        );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await notifications.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
    );
  }

  Future<void> zonedScheduleNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduleTime,
  }) async {
    Map<String,String> pay_load = {
      "time":"${scheduleTime.hour}:${scheduleTime.minute}:${scheduleTime.second}"
    };
    await FlutterLocalNotificationsPlugin().zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduleTime,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'your channel id',
          'your channel name',
          channelDescription: 'your channel description',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: "${scheduleTime.hour}:${scheduleTime.minute}:${scheduleTime.second}",
    );
  }

  Future<void> zonedScheduleAlarmClockNotification() async {
    await notifications.zonedSchedule(
      id: 123,
      title: 'scheduled alarm clock title',
      body: 'scheduled alarm clock body',
      scheduledDate: tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 5)),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'alarm_clock_channel',
          'Alarm Clock Channel',
          channelDescription: 'Alarm Clock Notification',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
    );
  }

  Future<void> scheduleHydrationRoutine({
    required double totalGoalMl,
    required double cupSizeMl,
    required DateTime wakeTime,
    required DateTime sleepTime,
  }) async {
    // 1. Clear previous water reminders (IDs 200-300 range)
    // You can also use cancelAll() if you are re-scheduling everything
    for (int i = 100; i < 200; i++) {
      await notifications.cancel(id: i);
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
          (scheduledDate.hour == sleepTime.hour &&
              scheduledDate.minute > sleepTime.minute)) {
        continue;
      }

      await zonedScheduleNotification(
        id: 100 + i, // Unique ID in the 200 range
        title: "Drink Water 💧",
        body: "Time for your ${cupSizeMl.toInt()}ml! Stay hydrated.",
        scheduleTime: scheduledDate,
      );
    }
    print(
      "Scheduled $totalReminders water reminders every $intervalMinutes minutes.",
    );
    // Verify scheduling
    var pending = await notifications.pendingNotificationRequests();
    pending.forEach((e) => print("Water Reminder ID: ${e.id} at ${e.payload}"));
  }
}
