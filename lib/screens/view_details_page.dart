import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart'; // For date formatting
import 'package:erc_frontend/utils/emergency_config.dart';
import 'package:erc_frontend/utils/full_screen_media_view.dart';
import 'dart:ui' as ui; // For custom marker rendering
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'update_emergency_page.dart';
import 'package:erc_frontend/utils/real_time_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:async';

class ViewDetailsPage extends StatefulWidget {
  final String emergencyId;
  final bool fromHistory;

  const ViewDetailsPage({
    Key? key,
    required this.emergencyId,
    this.fromHistory = false,
  }) : super(key: key);

  @override
  _ViewDetailsPageState createState() => _ViewDetailsPageState();
}

class _ViewDetailsPageState extends State<ViewDetailsPage> {
  Map<String, dynamic>? emergencyDetails;
  Marker? customMarker;
  LatLng? center;
  String? address;
  String? state;
  late StreamSubscription caseHandlingSubscription;
  late StreamSubscription caseLogSubscription;

  // Base URL for API
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';

  // Base URL for Media
  final String mediaBaseUrl =
      dotenv.env['BACKEND_URL_MEDIA'] ?? 'http://localhost:8080/uploads/';

  // Google Geocoding API Key
  final String googleApiKey =
      dotenv.env['GOOGLE_API_KEY'] ?? 'AIzaSyATwAelFU5r5A_oYCKM1h9NDItM1DDLXIE';

  @override
  void initState() {
    super.initState();
    _fetchEmergencyDetails();

    caseLogSubscription = RealTimeService().caseLogStream.listen((data) async {
      if (data['event'] == PostgresChangeEvent.insert) {
        _fetchEmergencyDetails();
      }
    });

    caseHandlingSubscription =
        RealTimeService().caseHandlingStream.listen((data) async {
      if (data['event'] == PostgresChangeEvent.insert) {
        if (data['emergencyid'].toString() == widget.emergencyId) {
          _fetchEmergencyDetails();
        }
      }
    });
  }

  Future<void> _fetchEmergencyDetails() async {
    final url = Uri.parse(
        '$backendUrl/api/reports/emergency-detail/${widget.emergencyId}');
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          emergencyDetails = data;
          center = LatLng(data['latitude'], data['longitude']);
        });

        // Fetch address from Google API
        await _fetchAddress(data['latitude'], data['longitude']);
        _setupMarker();
      } else {
        throw Exception('Failed to fetch emergency details');
      }
    } catch (e) {
      print('Error fetching details: $e');
    }
  }

  Future<void> _fetchAddress(num latitude, num longitude) async {
    final url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleApiKey&language=en";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["results"] != null && data["results"].isNotEmpty) {
          String? streetNumber;
          String? route;
          String? sublocality;
          String? locality;
          String? adminState;

          for (var component in data["results"][0]["address_components"]) {
            if (component["types"].contains("street_number")) {
              streetNumber = component["long_name"];
            }
            if (component["types"].contains("route")) {
              route = component["long_name"];
            }
            if (component["types"].contains("sublocality")) {
              sublocality = component["long_name"];
            }
            if (component["types"].contains("locality")) {
              locality = component["long_name"];
            }
            if (component["types"].contains("administrative_area_level_1")) {
              adminState = component["long_name"];
            }
          }

          final streetComponents = [
            if (streetNumber != null) streetNumber,
            if (route != null) route,
            if (sublocality != null) sublocality,
            if (locality != null) locality,
          ];
          setState(() {
            address = streetComponents.join(", ");
            state = adminState ?? "Unknown state";
          });
        }
      } else {
        throw Exception("Failed to fetch address: ${response.statusCode}");
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  Future<void> _setupMarker() async {
    if (emergencyDetails == null) return;

    final markerIcon = await _createCustomMarker(emergencyDetails!);
    setState(() {
      customMarker = Marker(
        markerId: MarkerId(widget.emergencyId),
        position: center!,
        icon: markerIcon,
      );
    });
  }

  Future<BitmapDescriptor> _createCustomMarker(
      Map<String, dynamic> emergency) async {
    try {
      final type = emergency['emergencyType'];
      final status = emergency['status'];

      final config = emergencyConfig[type] ?? emergencyConfig['Default'];
      final icon = config?['icon'] as IconData;
      final color = status == 'active' ? Colors.red : Colors.grey;

      return await _widgetToBitmapDescriptor(
        icon: icon,
        color: color,
      );
    } catch (e) {
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

    Paint paint = Paint()..color = color;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 2,
      paint,
    );

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
    if (emergencyDetails == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Details'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final emergency = emergencyDetails!;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('ERS ID - ${emergency['emergencyid']}',
            style: TextStyle(color: const Color.fromARGB(255, 70, 70, 70))),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.tealAccent),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.black,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency Type
            Text(
              emergency['emergencyType'],
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
                    myLocationEnabled: true,
                    zoomControlsEnabled: false,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Address and State
            const SizedBox(height: 20),

            // Address and State
            const Text(
              'Address:',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            Text(
              address ?? 'Unknown',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 10),

            const Text(
              'State:',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            Text(
              state ?? 'Unknown',
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            const SizedBox(height: 20),

            // Reported Date & Time
            const Text(
              'Date & Times:',
              style: TextStyle(fontSize: 13, color: Colors.white54),
            ),
            const SizedBox(height: 5),
            const Text(
              'Received:',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            Text(
              reformatTimestamp(emergency['timestamp']),
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),

            // Case Close Date & Time (if closed)
            if (emergency['status'] == 'closed') ...[
              const Text(
                'Closed:',
                style: TextStyle(fontSize: 12, color: Colors.white54),
              ),
              Text(
                '${reformatTimestamp(emergency['closeTimestamp'])} (${DateTime.parse(emergency['closeTimestamp']).difference(DateTime.parse(emergency['timestamp'])).inMinutes} Mins)',
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],

            const SizedBox(height: 10),

            // Report Status
            const Text(
              'Status:',
              style: TextStyle(fontSize: 12, color: Colors.white54),
            ),
            Text(
              emergency['status'] == 'active' ? 'Active' : 'Closed',
              style: TextStyle(
                fontSize: 16,
                color: emergency['status'] == 'active'
                    ? Colors.greenAccent
                    : Colors.redAccent,
              ),
            ),

            if (widget.fromHistory && emergency['reportLogs'] != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Divider(
                    color: Colors.grey,
                    thickness: 1,
                  ),
                  const Text(
                    'Emergency Logs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.tealAccent,
                    ),
                  ),
                  ...emergency['reportLogs']
                      .asMap()
                      .entries
                      .map<Widget>((entry) {
                    final index = entry.key; // Get the index
                    final log = entry.value; // Get the log object
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          "Log Detail ${index + 1}", // Use the index
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white54),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          log['description'],
                          style: const TextStyle(
                              fontSize: 14, color: Colors.white),
                        ),
                        const SizedBox(height: 10),
                        if (log['media'] != null && log['media'].length > 0)
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: log['media'].map<Widget>((media) {
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FullScreenMediaView(
                                        mediaUrl:
                                            '$mediaBaseUrl${media['mediaPath']}',
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  '$mediaBaseUrl${media['mediaPath']}',
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              );
                            }).toList(),
                          ),
                        Text(
                          reformatTimestamp(log['timestamp']),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white54),
                        ),
                      ],
                    );
                  }).toList(),
                  if (emergency['status'] == 'active')
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateEmergencyPage(
                                  emergencyId:
                                      emergency['emergencyid'].toString()),
                            ),
                          ).then((_) {
                            // Refresh data after returning from UpdateEmergencyPage
                            _fetchEmergencyDetails();
                          });
                          ;
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.tealAccent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        child: const Text('Update Info'),
                      ),
                    ),
                  // New section for handled information and caseLogs
                  if (emergency['isHandled'] == true) ...[
                    const SizedBox(height: 20),
                    Divider(color: Colors.grey, thickness: 1),
                    Text(
                      'Handled by: ${emergency['adminName']} on ${reformatTimestamp(emergency['caseTimestamp'])}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Action Taken:',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.tealAccent,
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (emergency['caseLogs'] != null &&
                        emergency['caseLogs'].isNotEmpty)
                      ...emergency['caseLogs'].map<Widget>((log) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log['actionTaken'] ?? 'No action specified',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              reformatTimestamp(log['timestamp']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white54,
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        );
                      }).toList()
                    else
                      const Text(
                        'No action taken',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.white70,
                        ),
                      ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }
}
