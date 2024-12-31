import 'package:erc_frontend/utils/map_selection_screen.dart';
import 'package:erc_frontend/screens/report_history_page.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:erc_frontend/utils/emergency_config.dart'; // Import emergency_config.dart

class MessageReportingPage extends StatefulWidget {
  @override
  _MessageReportingPageState createState() => _MessageReportingPageState();
}

class _MessageReportingPageState extends State<MessageReportingPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedIncidentType;
  bool? _isVictim;
  final TextEditingController _locationController = TextEditingController();
  LatLng? _selectedLatLng;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _levelUnitController = TextEditingController();
  final List<XFile> _mediaList = []; // List to store uploaded media
  final ImagePicker _picker = ImagePicker();
  final List<String> _incidentTypes = emergencyConfig.keys
      .where((key) => key != 'Default') // Exclude the "Default" key
      .toList();

  // Base URL for API
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';

  Future<void> _openMapSelection() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapSelectionScreen(
          initialLocation: _selectedLatLng,
          initialAddress: _locationController.text.isEmpty
              ? null
              : _locationController.text,
        ),
      ),
    );

    if (result != null && result is Map) {
      setState(() {
        _selectedLatLng = result["location"];
        _locationController.text = result["address"];
      });
    }
  }

  void _pickMedia(ImageSource source) async {
    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      setState(() {
        _mediaList.add(file);
      });
    }
  }

  void _showMediaPickerDialog() {
    // Unfocus any currently active text fields
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Add photo or video',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.camera);
                },
                icon: const Icon(Icons.camera_alt, color: Colors.blue),
                label: const Text(
                  'Camera',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library, color: Colors.blue),
                label: const Text(
                  'Upload from Photo Library',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDeleteMedia(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Are you sure you wish to delete this item?',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _mediaList.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  final _storage = FlutterSecureStorage();

  void _submitReport() async {
    if (!_formKey.currentState!.validate()) {
      return; // If the form is invalid, do nothing
    }

    try {
      // Retrieve the userId from secure storage
      String? userId = await _storage.read(key: 'userId');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User not logged in!')),
        );
        return;
      }

      // Prepare the request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$backendUrl/api/reports/create'),
      );

      // Add headers (including userId)
      request.headers.addAll({
        'userId': userId, // Pass userId in the headers
      });

      // Add text fields
      request.fields.addAll({
        'emergencyType': _selectedIncidentType!,
        'isVictim': _isVictim == true ? 'true' : 'false',
        'latitude': _selectedLatLng!.latitude.toString(),
        'longitude': _selectedLatLng!.longitude.toString(),
        'description': _descriptionController.text,
        'detailed_address': _levelUnitController.text,
      });

      // Add media files
      for (var file in _mediaList) {
        request.files.add(await http.MultipartFile.fromPath(
          'mediaFiles',
          file.path,
        ));
      }

      // Send the request
      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report submitted successfully!')),
        );

        // Delay for 1 second before navigating
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ReportHistoryPage()),
        );
      } else {
        // Read response body for more detailed error messages
        String responseBody = await response.stream.bytesToString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit report: $responseBody')),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Message Reporting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Incident Type Dropdown
              const Text(
                "Type of Emergency",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                hint: const Text("Select"),
                value: _selectedIncidentType,
                onChanged: (value) {
                  setState(() {
                    _selectedIncidentType = value;
                  });
                },
                items: _incidentTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select an emergency type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Who is victim
              const Text(
                "Are you the victims?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _isVictim,
                    onChanged: (value) {
                      setState(() {
                        _isVictim = value;
                      });
                    },
                  ),
                  const Text("Yes"),
                  Radio<bool>(
                    value: false,
                    groupValue: _isVictim,
                    onChanged: (value) {
                      setState(() {
                        _isVictim = value;
                      });
                    },
                  ),
                  const Text("No"),
                ],
              ),
              const SizedBox(height: 20),

              // Location Field
              const Text(
                "Location",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                readOnly: true, // Makes the text field non-editable
                decoration: InputDecoration(
                  hintText: "Search address",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a location';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _openMapSelection,
                icon: const Icon(Icons.map, color: Colors.blue),
                label: const Text(
                  "Select location on map",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),

              // Description Field
              const Text(
                "Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Please share more here",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please provide a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Level/Unit Field
              const Text(
                "Level/Unit (optional)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _levelUnitController,
                decoration: InputDecoration(
                  hintText: "Please share more here",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Supporting Media Section
              const Text(
                "Supporting media (optional)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: _showMediaPickerDialog,
                icon: const Icon(Icons.add_a_photo, color: Colors.blue),
                label: const Text(
                  "Add media",
                  style: TextStyle(color: Colors.blue),
                ),
              ),
              const SizedBox(height: 10),
              _mediaList.isNotEmpty
                  ? ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _mediaList.length,
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: Image.file(
                              File(_mediaList[index].path),
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                            title: Text('Media ${index + 1}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _confirmDeleteMedia(index),
                            ),
                          ),
                        );
                      },
                    )
                  : const Text(
                      "No media added yet.",
                      style: TextStyle(color: Colors.grey),
                    ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Submit",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
