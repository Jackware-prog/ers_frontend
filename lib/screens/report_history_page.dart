import 'package:flutter/material.dart';
import 'update_emergency_page.dart'; // Import the UpdateEmergencyPage
import 'view_details_page.dart';
import 'bottom_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/fab_popup_handler.dart';

class ReportHistoryPage extends StatelessWidget {
  const ReportHistoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample list of report history
    final List<Map<String, dynamic>> reportHistory = [
      {
        'id': '1',
        'type': 'Fire',
        'state': 'Kuala Lumpur',
        'location': '123 Main St, Kuala Lumpur',
        'time': '10:30 AM, 19 Dec 2024',
        'status': 'active',
      },
      {
        'id': '2',
        'type': 'Flood',
        'state': 'Johor Bahru',
        'location': '45 Jalan ABC, Johor Bahru',
        'time': '08:15 PM, 18 Dec 2024',
        'status': 'closed',
      },
      {
        'id': '3',
        'type': 'Road Accident',
        'state': 'Penang',
        'location': '67 XYZ Street, Penang',
        'time': '05:50 PM, 18 Dec 2024',
        'status': 'active',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Report History',
          style: TextStyle(color: Colors.tealAccent),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: ListView.separated(
          itemCount: reportHistory.length,
          separatorBuilder: (context, index) => const Divider(
            color: Colors.white24,
            height: 20,
          ),
          itemBuilder: (context, index) {
            final report = reportHistory[index];
            return ListTile(
              tileColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Text(
                report['type'],
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'State: ${report['state']}\n'
                'Location: ${report['location']}\n'
                'Date & Time: ${report['time']}',
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: report['status'] == 'active'
                  ? ElevatedButton(
                      onPressed: () {
                        // Navigate to Update Emergency Page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UpdateEmergencyPage(
                              emergencyId: report['id'],
                              title: report['type'],
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      child: const Text('Update'),
                    )
                  : null,
              onTap: () {
                // Navigate to ViewDetailsPage with the selected report ID
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewDetailsPage(emergencyId: report['id']),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        onPressed: () => showEmergencyOptions(context),
        child: const Icon(FontAwesomeIcons.headset, color: Colors.black),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 2),
    );
  }
}
