import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestPermissions(BuildContext context) async {
    bool locationGranted = await _requestLocationPermission(context);
    bool notificationGranted = await _requestNotificationPermission(context);
    return locationGranted && notificationGranted;
  }

  static Future<bool> _requestLocationPermission(BuildContext context) async {
    if (await Permission.location.isDenied) {
      PermissionStatus status = await Permission.location.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        await _showPermissionDialog(
          context,
          "Location Permission",
          "Location access is required for this app to function properly.",
        );
        return false;
      }
    }
    return true;
  }

  static Future<bool> _requestNotificationPermission(
      BuildContext context) async {
    if (await Permission.notification.isDenied) {
      PermissionStatus status = await Permission.notification.request();
      if (status.isDenied || status.isPermanentlyDenied) {
        await _showPermissionDialog(
          context,
          "Notification Permission",
          "Notification access is required to receive important updates.",
        );
        return false;
      }
    }
    return true;
  }

  static Future<void> _showPermissionDialog(
      BuildContext context, String title, String message) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings(); // Redirect user to app settings
            },
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }
}
