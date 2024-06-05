import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/reminder.dart';

class StorageHelper {
  static Future<void> saveReminders(List<Reminder> reminders) async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(
      reminders.map((reminder) => reminder.toMap()).toList(),
    );
    await prefs.setString('reminders', encodedData);
  }

  static Future<List<Reminder>> loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? encodedData = prefs.getString('reminders');
    if (encodedData == null) return [];

    final List<dynamic> decodedData = json.decode(encodedData) as List;
    return decodedData.map((data) => Reminder.fromMap(data)).toList();
  }
}
