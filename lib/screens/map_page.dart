import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'bottom_nav_fab.dart';

class MapPage extends StatelessWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Consistent background
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Malaysia Region Map',
          style:
              TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map Content
          Column(
            children: [
              const SizedBox(height: 10),
              Expanded(
                child: InteractiveViewer(
                  boundaryMargin: const EdgeInsets.all(10),
                  minScale: 0.8,
                  maxScale: 2.5,
                  child: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    // child: Image.asset(
                    //   'assets/malaysia_map.png', // Malaysia map asset
                    //   fit: BoxFit.contain,
                    // ),
                  ),
                ),
              ),
            ],
          ),
          // Floating Action Button
          Positioned(
            bottom: 60, // Adjust height to make it appear above the bottom bar
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.tealAccent,
              onPressed: () {
                // Handle Report Case Action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report Case Pressed')),
                );
              },
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: const BottomNavigationFAB(currentIndex: 1),
    );
  }
}
