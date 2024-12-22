import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../utils/emergency_config.dart';
import 'dart:ui' as ui; // For custom marker rendering
import 'dart:async';
import 'package:intl/intl.dart'; // For date formatting

class ViewDetailsPage extends StatefulWidget {
  final String emergencyId;

  const ViewDetailsPage({Key? key, required this.emergencyId})
      : super(key: key);

  @override
  _ViewDetailsPageState createState() => _ViewDetailsPageState();
}

class _ViewDetailsPageState extends State<ViewDetailsPage> {
  // Simulated data for emergencies
  final List<Map<String, dynamic>> emergencies = [
    {
      'id': '1',
      'type': 'Fire',
      'state': 'Kuala Lumpur',
      'location': LatLng(3.1390, 101.6869),
      'address': '123 Main St, Kuala Lumpur',
      'time': '10:30 AM, 19 Dec 2024',
      'status': 'active',
      'closeDateTime': null, // Case not closed
    },
    {
      'id': '2',
      'type': 'Flood',
      'state': 'Johor Bahru',
      'location': LatLng(1.4927, 103.7414),
      'address': '45 Jalan ABC, Johor Bahru',
      'time': '08:15 PM, 18 Dec 2024',
      'status': 'closed',
      'closeDateTime': '11:15 PM, 18 Dec 2024',
    },
    {
      'id': '3',
      'type': 'Road Accident',
      'state': 'Penang',
      'location': LatLng(5.4164, 100.3327),
      'address': '67 XYZ Street, Penang',
      'time': '05:50 PM, 18 Dec 2024',
      'status': 'closed',
      'closeDateTime': '06:30 PM, 18 Dec 2024',
    },
  ];

  Marker? customMarker;
  LatLng? center;

  @override
  void initState() {
    super.initState();
    _setupMarker();
  }

  Future<void> _setupMarker() async {
    // Find the selected emergency
    final emergency = emergencies.firstWhere(
      (e) => e['id'] == widget.emergencyId,
      orElse: () => {
        'type': 'Unknown',
        'state': 'Unknown',
        'location': LatLng(0.0, 0.0),
        'address': 'Unknown',
        'time': 'Unknown',
        'status': 'Unknown',
        'closeDateTime': null,
      },
    );

    // Extract type and location
    final LatLng location = emergency['location'];

    // Create custom marker
    final markerIcon = await _createCustomMarker(emergency);
    setState(() {
      customMarker = Marker(
        markerId: MarkerId(widget.emergencyId),
        position: location,
        icon: markerIcon,
      );
      center = location;
    });
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
    const size = Size(100, 100);

    // Draw circle background
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
          fontSize: 40,
          fontFamily: icon.fontFamily,
          package: 'font_awesome_flutter',
          color: Colors.white,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
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
    final emergency = emergencies.firstWhere(
      (e) => e['id'] == widget.emergencyId,
      orElse: () => {
        'type': 'Unknown',
        'state': 'Unknown',
        'location': LatLng(0.0, 0.0),
        'address': 'Unknown',
        'time': 'Unknown',
        'status': 'Unknown',
        'closeDateTime': null,
      },
    );

    String closeInfo = '';
    if (emergency['status'] == 'closed' && emergency['closeDateTime'] != null) {
      DateTime startTime =
          DateFormat('hh:mm a, dd MMM yyyy').parse(emergency['time']);
      DateTime closeTime =
          DateFormat('hh:mm a, dd MMM yyyy').parse(emergency['closeDateTime']);
      Duration duration = closeTime.difference(startTime);
      closeInfo =
          '${emergency['closeDateTime']} (${duration.inMinutes} minutes)';
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Details of ${emergency['type']}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Type
            Text(
              emergency['type'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.tealAccent,
              ),
            ),
            const SizedBox(height: 10),

            // Google Map
            if (customMarker != null && center != null)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.tealAccent, width: 2),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: center!,
                      zoom: 14,
                    ),
                    markers: {customMarker!},
                    mapType: MapType.normal,
                    myLocationEnabled: false,
                    zoomControlsEnabled: true,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // State
            Text(
              'State: ${emergency['state']}',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 10),

            // Address
            Text(
              'Address: ${emergency['address']}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 10),

            // Reported Date & Time
            Text(
              'Reported Date & Time: ${emergency['time']}',
              style: const TextStyle(fontSize: 16, color: Colors.white70),
            ),
            const SizedBox(height: 10),

            // Report Status
            Text(
              'Status: ${emergency['status'] == 'active' ? 'Active' : 'Closed'}',
              style: TextStyle(
                fontSize: 16,
                color: emergency['status'] == 'active'
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
            ),
            const SizedBox(height: 10),

            // Case Close Date & Time (if closed)
            if (emergency['status'] == 'closed')
              Text(
                'Closed Date & Time: $closeInfo',
                style: const TextStyle(fontSize: 16, color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}
