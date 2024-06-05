import 'dart:convert';

class Reminder {
  int id;
  String title;
  String time;
  bool isEnabled;

  Reminder(
      {required this.id,
      required this.title,
      required this.time,
      this.isEnabled = true});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'time': time,
      'isEnabled': isEnabled,
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      title: map['title'],
      time: map['time'],
      isEnabled: map['isEnabled'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Reminder.fromJson(String source) =>
      Reminder.fromMap(json.decode(source));
}
