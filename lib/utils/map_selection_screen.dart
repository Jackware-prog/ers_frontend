import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MapSelectionScreen extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const MapSelectionScreen({this.initialLocation, this.initialAddress});

  @override
  _MapSelectionScreenState createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  LatLng? _currentLocation;
  LatLng _selectedLocation;
  bool _isLoading = true;
  String? _address;

  // Google Geocoding API Key
  final String googleApiKey =
      dotenv.env['GOOGLE_API_KEY'] ?? 'AIzaSyATwAelFU5r5A_oYCKM1h9NDItM1DDLXIE';

  _MapSelectionScreenState()
      : _selectedLocation = LatLng(3.1390, 101.6869); // Default to Kuala Lumpur

  @override
  void initState() {
    super.initState();

    if (widget.initialLocation != null) {
      // Use the provided location and address if available
      _selectedLocation = widget.initialLocation!;
      _address = widget.initialAddress;
      _isLoading = false;
    } else {
      // Fetch the user's current location if no initial location is provided
      _fetchCurrentLocation();
    }
  }

  Future<void> _fetchCurrentLocation() async {
    final location = Location();

    // Check if location services are enabled
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Check location permissions
    PermissionStatus permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    // Get the user's current location
    final userLocation = await location.getLocation();
    setState(() {
      _currentLocation =
          LatLng(userLocation.latitude!, userLocation.longitude!);
      _selectedLocation = _currentLocation!;
      _isLoading = false;
    });

    // Reverse geocode the initial location
    await _reverseGeocodeWithGoogle(_selectedLocation);
  }

  void _onMapTap(LatLng position) {
    setState(() {
      _selectedLocation = position;
    });

    // Reverse geocode the selected location
    _reverseGeocodeWithGoogle(position);
  }

  Future<void> _reverseGeocodeWithGoogle(LatLng location) async {
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$googleApiKey&language=en";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data["results"] != null && data["results"].isNotEmpty) {
          setState(() {
            _address = data["results"][0]["formatted_address"];
          });
        } else {
          setState(() {
            _address = "No address found for this location.";
          });
        }
      } else {
        throw Exception("Failed to fetch address: ${response.statusCode}");
      }
    } catch (e) {
      setState(() {
        _address = "Error fetching address.";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error fetching address: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Location",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _selectedLocation,
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: false,
                  onTap: _onMapTap,
                  markers: {
                    Marker(
                      markerId: const MarkerId("selectedLocation"),
                      position: _selectedLocation,
                    ),
                  },
                ),
                if (_address != null)
                  Positioned(
                    bottom: 90,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _address!,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        "location": _selectedLocation,
                        "address": _address,
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text("Confirm Location"),
                  ),
                ),
              ],
            ),
    );
  }
}
