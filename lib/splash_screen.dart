import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/login_page.dart'; // Replace with the actual login page
import 'screens/map_page.dart'; // Replace with the actual main page
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'utils/permission_utils.dart';
import '/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _secureStorage = FlutterSecureStorage(); // Secure storage instance
  late FirebaseMessaging _messaging;
  bool _permissionsGranted = false; // State to track permission status

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndNavigate(); // Check permissions and navigate
    initializeFCMListeners(); // Initialize FCM listeners
  }

  // Check permissions and navigate
  Future<void> _checkPermissionsAndNavigate() async {
    bool permissionsGranted = await PermissionUtils.requestPermissions(context);
    setState(() {
      _permissionsGranted = permissionsGranted;
    });

    if (permissionsGranted) {
      _checkLoginStatus(); // Proceed to check login status if permissions are granted
    }
  }

  // Firebase Cloud Messaging Initialization
  void initializeFCMListeners() {
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification received: ${message.notification?.title}");

      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel', // Channel ID
              'High Importance Notifications', // Channel Name
              channelDescription:
                  'This channel is used for important notifications.',
              importance: Importance.high,
              priority: Priority.high,
              styleInformation: BigTextStyleInformation(
                notification.body ?? '', // Expanded text
                htmlFormatBigText: true,
                contentTitle:
                    notification.title ?? '', // Title for expanded view
                htmlFormatContentTitle: true,
              ),
              icon: '@mipmap/launcher_icon',
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked: ${message.notification?.title}");
      // Handle click to navigate to a specific screen
    });
  }

  // Check login status and navigate
  Future<void> _checkLoginStatus() async {
    // Simulate splash screen delay
    await Future.delayed(const Duration(seconds: 3));

    // Check if the user ID exists in secure storage
    final userId = await _secureStorage.read(key: 'userId');

    if (userId != null) {
      // User is logged in, navigate to the main page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MapPage()),
      );
    } else {
      // User is not logged in, navigate to the login page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Background color
      body: Center(
        child: Image.asset(
          'assets/logowithword.png',
          width: 500, // Adjust size as needed
        ),
      ),
    );
  }
}
