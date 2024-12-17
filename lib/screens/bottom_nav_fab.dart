import 'package:flutter/material.dart';

class BottomNavigationFAB extends StatelessWidget {
  final int currentIndex;

  const BottomNavigationFAB({Key? key, required this.currentIndex})
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
            // Handle Navigation (Placeholder)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Navigate to index: $index')),
            );
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
