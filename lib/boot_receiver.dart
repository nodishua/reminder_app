import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'storage_helper.dart';
import 'models/reminder.dart';
import 'notification_service.dart';
import 'main.dart';

class BootReceiver extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  static Future<void> onReceive(BuildContext context) async {
    final reminders = await StorageHelper.loadReminders();
    for (var reminder in reminders) {
      if (reminder.isEnabled) {
        NotificationService().scheduleDailyNotification(
          reminder.id,
          reminder.title,
          'Reminder for ${reminder.title}',
          TimeOfDay(
            hour: int.parse(reminder.time.split(':')[0]),
            minute: int.parse(reminder.time.split(':')[1]),
          ).toTime(),
        );
      }
    }
  }
}
