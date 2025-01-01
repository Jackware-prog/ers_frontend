import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'view_details_page.dart';
import 'bottom_nav_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:erc_frontend/utils/fab_popup_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:erc_frontend/utils/emergency_config.dart'; // Import the emergency config

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({Key? key}) : super(key: key);

  @override
  _ReportHistoryPageState createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late Future<List<Map<String, dynamic>>> _reportHistory;
  // Base URL for API
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';

  // Google Geocoding API Key
  final String googleApiKey =
      dotenv.env['GOOGLE_API_KEY'] ?? 'AIzaSyATwAelFU5r5A_oYCKM1h9NDItM1DDLXIE';

  Future<String?> _getUserIdFromStorage() async {
    return await _secureStorage.read(key: 'userId');
  }

  Future<Map<String, String>> fetchAddress(num latitude, num longitude) async {
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
          String? state;

          // Extract components
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
              state = component["long_name"];
            }
          }

          // Combine available components for street
          final streetComponents = [
            if (streetNumber != null) streetNumber,
            if (route != null) route,
            if (sublocality != null) sublocality,
            if (locality != null) locality,
          ];
          final street = streetComponents.join(", ");

          return {
            "street": street.isNotEmpty ? street : "Unknown street",
            "state": state ?? "Unknown state",
          };
        } else {
          return {"street": "No address found", "state": "No state found"};
        }
      } else {
        throw Exception("Failed to fetch address: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error fetching address: $e");
    }
  }

  Future<List<Map<String, dynamic>>> fetchReportHistory(String userId) async {
    final url = Uri.parse('$backendUrl/api/reports/report-history/$userId');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        List<Map<String, dynamic>> reportList = [];

        for (var report in data) {
          final num latitude = num.parse(report['latitude'].toString());
          final num longitude = num.parse(report['longitude'].toString());

          // Fetch address components
          final address = await fetchAddress(latitude, longitude);

          reportList.add({
            'id': report['reportid'].toString(),
            'type': report['emergencyType'] ?? 'Unknown',
            'state': address['state'] ?? 'Unknown',
            'location': address['street'] ?? 'Unknown',
            'time': report['timestamp'] ?? 'Unknown',
            'status': report['status'] ?? 'Unknown',
          });
        }

        return reportList;
      } else {
        throw Exception('Failed to fetch report history');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _reportHistory = _initializeReportHistory();
  }

  Future<List<Map<String, dynamic>>> _initializeReportHistory() async {
    final userId = await _getUserIdFromStorage();
    if (userId == null) {
      throw Exception('User ID not found in secure storage');
    }
    return fetchReportHistory(userId);
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
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _reportHistory,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No report history found.',
                  style: TextStyle(color: Colors.white70),
                ),
              );
            }

            final reportHistory = snapshot.data!;

            return ListView.separated(
              itemCount: reportHistory.length,
              separatorBuilder: (context, index) => const Divider(
                color: Colors.white24,
                height: 20,
              ),
              itemBuilder: (context, index) {
                final report = reportHistory[index];
                final emergencyType = report['type'];
                final iconData = emergencyConfig[emergencyType]?['icon'] ??
                    emergencyConfig['Default']!['icon'];

                return ListTile(
                  tileColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  leading: SizedBox(
                    width: 45,
                    child: Icon(
                      iconData,
                      color: report['status'] == 'active'
                          ? Colors.tealAccent
                          : Colors.grey,
                      size: 30,
                    ),
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
                    'Date & Time: ${reformatTimestamp(report['time'])}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewDetailsPage(
                            emergencyId: report['id'], fromHistory: true),
                      ),
                    );
                  },
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
