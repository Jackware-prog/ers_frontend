import 'package:flutter/material.dart';
import 'package:erc_frontend/screens/message_reporting_page.dart';

Future<void> showEmergencyOptions(BuildContext context) async {
  final themeColor = Colors.tealAccent;

  // First Pop-up for options
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: const Color.fromARGB(255, 37, 37, 37),
      title: const Text(
        'Report Emergency',
        style: TextStyle(color: Colors.tealAccent),
      ),
      content: const Text(
        'Would you like to call or send a message?',
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () async {
            Navigator.pop(context, false);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Coming Soon...')),
            );
          },
          child: Text(
            'Call',
            style: TextStyle(color: themeColor),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, false);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MessageReportingPage()),
            );
          },
          child: Text(
            'Message',
            style: TextStyle(color: themeColor),
          ),
        ),
      ],
    ),
  );
}
