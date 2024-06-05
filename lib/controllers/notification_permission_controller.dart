import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionController extends ChangeNotifier {
  PermissionStatus _permissionStatus = PermissionStatus.denied;

  PermissionStatus get permissionStatus => _permissionStatus;

  NotificationPermissionController() {
    checkPermission();
  }

  Future<void> requestPermission() async {
    final status = await Permission.notification.request();
    _updatePermissionStatus(status);
  }

  void _updatePermissionStatus(PermissionStatus status) {
    _permissionStatus = status;
    notifyListeners();
  }

  Future<void> checkPermission() async {
    final status = await Permission.notification.status;
    _updatePermissionStatus(status);
  }
}
