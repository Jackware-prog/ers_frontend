import 'dart:async'; // For Completer
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:ui' as ui;
import 'bottom_nav_bar.dart';
import 'view_details_page.dart'; // Import the ViewDetailsPage
import 'package:erc_frontend/utils/emergency_config.dart';
import 'package:erc_frontend/utils/fab_popup_handler.dart';
import 'package:location/location.dart'; // Import location package
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http; // Import HTTP package
import 'package:intl/intl.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _controller;
  LatLng _initialLocation =
      const LatLng(3.1390, 101.6869); // Default to Kuala Lumpur
  final Set<Marker> _markers = {};
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';
  final String googleApiKey =
      dotenv.env['GOOGLE_API_KEY'] ?? 'AIzaSyATwAelFU5r5A_oYCKM1h9NDItM1DDLXIE';

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Fetch user's current location
    _fetchEmergencies(); // Fetch recent emergencies
  }

  Future<void> _getUserLocation() async {
    Location location = Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    LocationData currentLocation = await location.getLocation();

    if (mounted) {
      // Check if the widget is still active in the widget tree
      setState(() {
        _initialLocation = LatLng(
          currentLocation.latitude ?? _initialLocation.latitude,
          currentLocation.longitude ?? _initialLocation.longitude,
        );
      });

      // Animate the camera to the user's current location
      if (_controller != null) {
        _controller!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: _initialLocation,
              zoom: 15,
            ),
          ),
        );
      }
    }
  }

  Future<void> _fetchEmergencies() async {
    try {
      final url = Uri.parse('$backendUrl/api/reports/recent-report');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> emergencies = json.decode(response.body);
        for (var emergency in emergencies) {
          final stateAndAddress = await _fetchAddress(
            emergency['latitude'],
            emergency['longitude'],
          );

          _markers.add(
            Marker(
              markerId: MarkerId(emergency['reportid'].toString()),
              position: LatLng(emergency['latitude'], emergency['longitude']),
              infoWindow: InfoWindow(
                title: '${emergency['emergencyType']} (${reformatTimestamp(emergency['timestamp'])})',
                snippet: stateAndAddress['address'],
                onTap: () {
                  // Navigate to ViewDetailsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViewDetailsPage(
                        emergencyId: emergency['reportid'].toString(),
                      ),
                    ),
                  );
                },
              ),
              icon: await _createCustomMarker({
                'type': emergency['emergencyType'],
                'status': emergency['status'],
              }),
            ),
          );
        }
        setState(() {});
      } else {
        throw Exception('Failed to fetch emergencies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching emergencies: $e');
    }
  }

  Future<Map<String, String>> _fetchAddress(num latitude, num longitude) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleApiKey&language=en";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["results"] != null && data["results"].isNotEmpty) {
          String? state;
          String? address;

          for (var component in data["results"][0]["address_components"]) {
            if (component["types"].contains("administrative_area_level_1")) {
              state = component["long_name"];
            }
          }
          address = data["results"][0]["formatted_address"];

          return {
            "state": state ?? "Unknown state",
            "address": address ?? "Unknown address",
          };
        }
      }
    } catch (e) {
      print('Error fetching address: $e');
    }

    return {"state": "Unknown state", "address": "Unknown address"};
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

  String reformatTimestamp(String? timestamp) {
    try {
      if (timestamp == null) return "Invalid timestamp";
      DateTime dateTime = DateTime.parse(timestamp);
      DateFormat formatter = DateFormat('yyyy MMM dd, hh:mm a');
      return formatter.format(dateTime);
    } catch (e) {
      return "Error formatting timestamp";
    }
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
              zoom: 15,
            ),
            markers: _markers,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomControlsEnabled: false,
          ),
          // Floating Action Button
          Positioned(
            bottom: 60, // Adjust height to make it appear above the bottom bar
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.tealAccent,
              onPressed: () => showEmergencyOptions(context),
              child: const Icon(FontAwesomeIcons.headset, color: Colors.black),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 1),
    );
  }
}
