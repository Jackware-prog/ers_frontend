import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'view_details_page.dart';
import 'bottom_nav_bar.dart';
import 'package:erc_frontend/utils/fab_popup_handler.dart';
import 'package:erc_frontend/utils/emergency_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

class ListEmergencyPage extends StatefulWidget {
  const ListEmergencyPage({Key? key}) : super(key: key);

  @override
  _ListEmergencyPageState createState() => _ListEmergencyPageState();
}

class _ListEmergencyPageState extends State<ListEmergencyPage> {
  List<Map<String, dynamic>> activeEmergencies = [];
  List<Map<String, dynamic>> recentEmergencies = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchEmergencies();
  }

  Future<void> _fetchEmergencies() async {
    final String backendUrl =
        dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';
    try {
      final response =
          await http.get(Uri.parse('$backendUrl/api/reports/recent-report'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        for (var emergency in data) {
          final address = await _fetchAddress(
            emergency['latitude'],
            emergency['longitude'],
          );
          emergency['fetchedAddress'] = address; // Add the fetched address
        }

        setState(() {
          activeEmergencies = data
              .where((e) => e['status'] == 'active')
              .map((e) => e as Map<String, dynamic>)
              .toList();
          recentEmergencies = data
              .where((e) => e['status'] == 'closed')
              .map((e) => e as Map<String, dynamic>)
              .toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to fetch emergencies: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching emergencies: $e');

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<String> _fetchAddress(double latitude, double longitude) async {
    final String googleApiKey = dotenv.env['GOOGLE_API_KEY'] ??
        'AIzaSyATwAelFU5r5A_oYCKM1h9NDItM1DDLXIE';
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longitude&key=$googleApiKey&language=en";

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'] != null && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'] ?? 'Unknown address';
        }
      }
    } catch (e) {
      print('Error fetching address: $e');
    }

    return 'Unknown address';
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

  Widget buildEmergencyItem(Map<String, dynamic> emergency) {
    final icon = emergencyConfig[emergency['emergencyType']]?['icon'] ??
        emergencyConfig['Default']!['icon'];

    return ListTile(
      leading: FaIcon(
        icon,
        color: Colors.tealAccent,
        size: 30,
      ),
      title: Text(
        emergency['emergencyType'],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        emergency['fetchedAddress'] ?? 'No address',
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: SizedBox(
        width: 75,
        child: Center(
          child: Text(
            reformatTimestamp(emergency['timestamp']),
            style: const TextStyle(
              color: Colors.tealAccent,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ViewDetailsPage(
                emergencyId: emergency['emergencyid'].toString()),
          ),
        );
      },
      tileColor: Colors.black87,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'ACTIVE',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${activeEmergencies.length} cases',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: activeEmergencies.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.white24,
                        height: 10,
                      ),
                      itemBuilder: (context, index) {
                        return buildEmergencyItem(activeEmergencies[index]);
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'RECENT',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${recentEmergencies.length} cases',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recentEmergencies.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.white24,
                        height: 10,
                      ),
                      itemBuilder: (context, index) {
                        return buildEmergencyItem(recentEmergencies[index]);
                      },
                    ),
                  ],
                ),
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
