import 'package:flutter/material.dart';
import 'package:erc_frontend/screens/message_reporting_page.dart';

Future<void> showEmergencyOptions(BuildContext context) async {
  final themeColor = Colors.tealAccent;

  // First Pop-up for options
  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.black,
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
            Navigator.pop(context);
            // Double Confirmation for Call
            final confirm = await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.black,
                title: const Text(
                  'Confirm Call',
                  style: TextStyle(color: Colors.tealAccent),
                ),
                content: const Text(
                  'Are you sure you want to call emergency services?',
                  style: TextStyle(color: Colors.white70),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      'Cancel',
                      style: TextStyle(color: themeColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'Confirm',
                      style: TextStyle(color: themeColor),
                    ),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Calling emergency services...')),
              );
            }
          },
          child: Text(
            'Call',
            style: TextStyle(color: themeColor),
          ),
        ),
        TextButton(
          onPressed: () {
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
