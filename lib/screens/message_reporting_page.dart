import 'package:erc_frontend/utils/map_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MessageReportingPage extends StatefulWidget {
  @override
  _MessageReportingPageState createState() => _MessageReportingPageState();
}

class _MessageReportingPageState extends State<MessageReportingPage> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedIncidentType;
  bool? _reportedToAgency;
  final TextEditingController _locationController = TextEditingController();
  LatLng? _selectedLatLng;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _levelUnitController = TextEditingController();
  final List<XFile> _mediaList = []; // List to store uploaded media
  final ImagePicker _picker = ImagePicker();

  // Dummy list of incident types
  final List<String> _incidentTypes = [
    "Fire Hazard",
    "Medical Emergency",
    "Road Accident",
    "Other",
  ];

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

  Future<String> _reverseGeocodeWithGoogle(LatLng location) async {
    const String apiKey =
        "AIzaSyATwAelFU5r5A_oYCKM1h9NDItM1DDLXIE"; // Replace with your API key
    final String url =
        "https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$apiKey&language=en";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["results"] != null && data["results"].isNotEmpty) {
        return data["results"][0]["formatted_address"];
      } else {
        throw Exception("No address found.");
      }
    } else {
      throw Exception("Failed to fetch address: ${response.statusCode}");
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

  void _submitReport() {
    if (_formKey.currentState!.validate()) {
      final reportData = {
        "incidentType": _selectedIncidentType,
        "reportedToAgency": _reportedToAgency,
        "location": _locationController.text,
        "latitude": _selectedLatLng?.latitude,
        "longitude": _selectedLatLng?.longitude,
        "description": _descriptionController.text,
        "levelUnit": _levelUnitController.text,
        // Add media processing logic here if needed
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear form after submission
      _formKey.currentState!.reset();
      setState(() {
        _selectedIncidentType = null;
        _reportedToAgency = null;
        _selectedLatLng = null;
        _mediaList.clear();
      });
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

              // Previously Reported to Other Agency
              const Text(
                "Previously reported to other agency",
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
                    groupValue: _reportedToAgency,
                    onChanged: (value) {
                      setState(() {
                        _reportedToAgency = value;
                      });
                    },
                  ),
                  const Text("Yes"),
                  Radio<bool>(
                    value: false,
                    groupValue: _reportedToAgency,
                    onChanged: (value) {
                      setState(() {
                        _reportedToAgency = value;
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
