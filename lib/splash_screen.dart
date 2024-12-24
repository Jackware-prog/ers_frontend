import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'screens/login_page.dart'; // Replace with the actual login page
import 'screens/map_page.dart'; // Replace with the actual main page
import 'package:firebase_messaging/firebase_messaging.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _secureStorage = FlutterSecureStorage(); // Secure storage instance
  late FirebaseMessaging _messaging;

  @override
  void initState() {
    super.initState();
    initializeFCMListeners(); // Initialize FCM listeners
    _checkLoginStatus(); // Check login status
  }

  // Firebase Cloud Messaging Initialization
  void initializeFCMListeners() {
    _messaging = FirebaseMessaging.instance;

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Foreground notification received: ${message.notification?.title}");
      // Optionally, show a dialog or notification
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("Notification clicked: ${message.notification?.title}");
      // Optionally, navigate to a specific screen
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
