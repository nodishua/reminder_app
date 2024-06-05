import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'storage_helper.dart';
import 'models/reminder.dart';
import 'notification_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await setupDefaultReminders();
  runApp(MyApp());
}

Future<void> setupDefaultReminders() async {
  final reminders = await StorageHelper.loadReminders();
  final defaultReminders = [
    Reminder(id: reminders.length, title: 'Dzikir Pagi', time: '07:00'),
    Reminder(id: reminders.length + 1, title: 'Dzikir Petang', time: '17:00')
  ];

  for (var reminder in defaultReminders) {
    if (!reminders
        .any((r) => r.title == reminder.title && r.time == reminder.time)) {
      reminders.add(reminder);
      NotificationService().scheduleDailyNotification(
        reminder.id,
        reminder.title,
        'Reminder for ${reminder.title}',
        TimeOfDay(
                hour: int.parse(reminder.time.split(':')[0]),
                minute: int.parse(reminder.time.split(':')[1]))
            .toTime(),
      );
    }
  }

  await StorageHelper.saveReminders(reminders);
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reminder App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Reminder> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() async {
    final reminders = await StorageHelper.loadReminders();
    setState(() {
      _reminders = reminders;
    });
  }

  void _saveReminders() {
    StorageHelper.saveReminders(_reminders);
  }

  void _showAddReminderDialog({Reminder? reminderToUpdate}) {
    final TextEditingController titleController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();

    if (reminderToUpdate != null) {
      titleController.text = reminderToUpdate.title;
      selectedTime = TimeOfDay(
        hour: int.parse(reminderToUpdate.time.split(':')[0]),
        minute: int.parse(reminderToUpdate.time.split(':')[1]),
      );
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              reminderToUpdate != null ? 'Update Reminder' : 'Add Reminder'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                    builder: (BuildContext context, Widget? child) {
                      return MediaQuery(
                        data: MediaQuery.of(context)
                            .copyWith(alwaysUse24HourFormat: true),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null && picked != selectedTime) {
                    setState(() {
                      selectedTime = picked;
                    });
                  }
                },
                child: Text("Pick Time (24-hour)"),
              ),
              SizedBox(height: 10),
              Text("Selected Time: ${selectedTime.format(context)}"),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final String title = titleController.text;
                final String time = selectedTime.format(context);
                final Reminder newReminder = Reminder(
                  id: reminderToUpdate != null
                      ? reminderToUpdate.id
                      : _reminders.length,
                  title: title,
                  time: time,
                );

                if (reminderToUpdate != null) {
                  final index =
                      _reminders.indexWhere((r) => r.id == reminderToUpdate.id);
                  setState(() {
                    _reminders[index] = newReminder;
                  });
                } else {
                  setState(() {
                    _reminders.add(newReminder);
                  });
                }

                _saveReminders();
                NotificationService().scheduleDailyNotification(
                  newReminder.id,
                  title,
                  'Reminder for $title',
                  selectedTime.toTime(),
                );
                Navigator.of(context).pop();
              },
              child: Text(reminderToUpdate != null ? 'Update' : 'Add'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
      ),
      body: ListView.builder(
        itemCount: _reminders.length,
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return ListTile(
            title: Text(reminder.title),
            subtitle: Text(reminder.time),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Switch(
                  value: reminder.isEnabled,
                  onChanged: (bool value) async {
                    setState(() {
                      reminder.isEnabled = value;
                    });
                    _saveReminders();
                    if (value) {
                      NotificationService().scheduleDailyNotification(
                        reminder.id,
                        reminder.title,
                        'Reminder for ${reminder.title}',
                        TimeOfDay(
                          hour: int.parse(reminder.time.split(':')[0]),
                          minute: int.parse(reminder.time.split(':')[1]),
                        ).toTime(),
                      );
                    } else {
                      NotificationService().cancelNotification(reminder.id);
                    }
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteReminder(index);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showAddReminderDialog(reminderToUpdate: reminder);
                  },
                ),
              ],
            ),
            onLongPress: () async {
              _deleteReminder(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddReminderDialog,
        tooltip: 'Add Reminder',
        child: Icon(Icons.add),
      ),
    );
  }

  void _deleteReminder(int index) {
    final reminder = _reminders[index];
    setState(() {
      _reminders.removeAt(index);
    });
    _saveReminders();
    NotificationService().cancelNotification(reminder.id);
  }
}

extension TimeOfDayExtension on TimeOfDay {
  Time toTime() {
    return Time(this.hour, this.minute);
  }
}
