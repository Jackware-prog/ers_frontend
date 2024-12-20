import 'dart:async'; // For Completer
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:ui' as ui;
import 'bottom_nav_fab.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'view_details_page.dart'; // Import the ViewDetailsPage

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;

  // Default location: Kuala Lumpur, Malaysia
  final LatLng _initialLocation = const LatLng(3.1390, 101.6869);

  // List of Emergency Data
  final List<Map<String, dynamic>> emergencies = [
    {
      'id': '1',
      'type': 'Fire',
      'state': 'Kuala Lumpur',
      'location': LatLng(3.1390, 101.6869),
      'address': '123 Main St, Kuala Lumpur',
      'time': '10:30 AM, 19 Dec 2024',
      'status': 'active',
    },
    {
      'id': '2',
      'type': 'Flood',
      'state': 'Johor Bahru',
      'location': LatLng(1.4927, 103.7414),
      'address': '45 Jalan ABC, Johor Bahru',
      'time': '08:15 PM, 18 Dec 2024',
      'status': 'closed',
    },
    {
      'id': '3',
      'type': 'Road Accident',
      'state': 'Penang',
      'location': LatLng(5.4164, 100.3327),
      'address': '67 XYZ Street, Penang',
      'time': '05:50 PM, 18 Dec 2024',
      'status': 'closed',
    },
  ];

  // Configuration Map for Emergency Types
  final Map<String, Map<String, dynamic>> emergencyConfig = {
    'Fire': {'icon': FontAwesomeIcons.fire},
    'Flood': {'icon': FontAwesomeIcons.water},
    'Road Accident': {'icon': FontAwesomeIcons.carBurst},
    'Earthquake': {'icon': FontAwesomeIcons.houseCrack},
    'Tornado': {'icon': FontAwesomeIcons.tornado},
    'Default': {'icon': FontAwesomeIcons.fontAwesome},
  };

  // Set of Markers
  final Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _addEmergencyMarkers();
  }

  Future<void> _addEmergencyMarkers() async {
    for (var emergency in emergencies) {
      BitmapDescriptor markerIcon = await _createCustomMarker(emergency);
      _markers.add(
        Marker(
          markerId: MarkerId(emergency['address']),
          position: emergency['location'],
          infoWindow: InfoWindow(
            title: '${emergency['type']} (${emergency['time']})',
            snippet: '${emergency['address']}',
            onTap: () {
              // Navigate to ViewDetailsPage on InfoWindow tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ViewDetailsPage(emergencyId: emergency['id']),
                ),
              );
            },
          ),
          icon: markerIcon,
        ),
      );
    }
    setState(() {});
  }

  Future<BitmapDescriptor> _createCustomMarker(
      Map<String, dynamic> emergency) async {
    try {
      final type = emergency['type'];
      final status = emergency['status'];

      // Get the configuration for this type, or use the default
      final config = emergencyConfig[type] ?? emergencyConfig['Default'];
      final icon = config?['icon'] as IconData;
      final color = status == 'active' ? Colors.red : Colors.grey;

      return await _widgetToBitmapDescriptor(
        icon: icon,
        color: color,
      );
    } catch (e) {
      // Log the error and return a default marker
      print('Error creating custom marker: $e');
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
    }
  }

  Future<BitmapDescriptor> _widgetToBitmapDescriptor({
    required IconData icon,
    required Color color,
  }) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);
    const size = Size(80, 80); // Adjust the marker size

    // Draw background circle
    Paint paint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

    // Draw the icon
    TextPainter textPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: 40, // Adjust font size
          fontFamily: icon.fontFamily,
          package: 'font_awesome_flutter',
          color: Colors.black,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width - textPainter.width) / 2,
        (size.height - textPainter.height) / 2,
      ),
    );

    final picture = pictureRecorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

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
          // Google Map
          GoogleMap(
            onMapCreated: (controller) {
              _controller = controller;
            },
            initialCameraPosition: CameraPosition(
              target: _initialLocation,
              zoom: 6.5,
            ),
            markers: _markers,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
          ),
          // Floating Action Button
          Positioned(
            bottom: 60, // Adjust height to make it appear above the bottom bar
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.tealAccent,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report Case Pressed')),
                );
              },
              child: const Icon(Icons.add, color: Colors.black),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigationFAB(currentIndex: 1),
    );
  }
}
