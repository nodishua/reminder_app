import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:reminder_app/controllers/notification_permission_controller.dart';
import 'package:reminder_app/main.dart';

class PermissionRequestWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<NotificationPermissionController>(
      builder: (context, permissionController, _) {
        if (permissionController.permissionStatus == PermissionStatus.granted) {
          return MyHomePage();
        } else if (permissionController.permissionStatus ==
            PermissionStatus.denied) {
          return Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  permissionController.requestPermission();
                },
                child: Text('Request Permission'),
              ),
            ),
          );
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
