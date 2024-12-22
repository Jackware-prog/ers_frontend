import 'package:flutter/material.dart';
import 'list_emergency_page.dart';
import 'map_page.dart';
import 'report_history_page.dart';
import 'my_profile_page.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;

  const BottomNavigation({Key? key, required this.currentIndex})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        BottomNavigationBar(
          currentIndex: currentIndex,
          selectedItemColor: Colors.red,
          unselectedItemColor: Colors.black,
          backgroundColor: Colors.blueGrey,
          onTap: (index) {
            switch (index) {
              case 0: // List of Emergencies
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ListEmergencyPage()),
                );
                break;
              case 1: // Map Page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MapPage()),
                );
                break;
              case 2: // Report History
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReportHistoryPage()),
                );
                break;
              case 3: // Profile Page
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyProfilePage()),
                );
                break;
              default:
                break;
            }
          },
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.warning), label: 'Emergencies'),
            BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
            BottomNavigationBarItem(
                icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ],
    );
  }
}
