import 'package:flutter/material.dart';
import 'view_details_page.dart'; // Import the View Details Page
import 'bottom_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../utils/fab_popup_handler.dart';

class ListEmergencyPage extends StatelessWidget {
  const ListEmergencyPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample list of emergencies with IDs
    final List<Map<String, String>> emergencies = [
      {
        'id': '1',
        'type': 'Fire',
        'location': 'Kuala Lumpur',
        'address': '123 Main St, Kuala Lumpur',
        'time': '10:30 AM, 19 Dec 2024',
      },
      {
        'id': '2',
        'type': 'Flood',
        'location': 'Johor Bahru',
        'address': '45 Jalan ABC, Johor Bahru',
        'time': '08:15 PM, 18 Dec 2024',
      },
      {
        'id': '3',
        'type': 'Road Accident',
        'location': 'Penang',
        'address': '67 XYZ Street, Penang',
        'time': '05:50 PM, 18 Dec 2024',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'List of Emergencies',
          style: TextStyle(color: Colors.tealAccent),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label for "Recent 3 Days"
            const Padding(
              padding: EdgeInsets.only(bottom: 10.0),
              child: Text(
                'Recent 3 Days',
                style: TextStyle(
                  color: Colors.tealAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // List of emergencies
            Expanded(
              child: ListView.separated(
                itemCount: emergencies.length,
                separatorBuilder: (context, index) => const Divider(
                  color: Colors.white24,
                  height: 20,
                ),
                itemBuilder: (context, index) {
                  final emergency = emergencies[index];
                  return ListTile(
                    tileColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    title: Text(
                      emergency['type']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Location: ${emergency['location']}\n'
                      'Address: ${emergency['address']}\n'
                      'Date & Time: ${emergency['time']}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.tealAccent,
                    ),
                    onTap: () {
                      // Navigate to View Details Page with the selected emergency's ID
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ViewDetailsPage(emergencyId: emergency['id']!),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        onPressed: () => showEmergencyOptions(context),
        child: const Icon(FontAwesomeIcons.headset, color: Colors.black),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 0),
    );
  }
}
