import 'package:flutter/material.dart';
import 'screens/login_page.dart';

void main() => runApp(EmergencyResponseApp());

class EmergencyResponseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.red,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.blue),
      ),
      home: LoginPage(),
    );
  }
}
