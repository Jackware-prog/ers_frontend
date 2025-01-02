import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UpdateEmergencyPage extends StatefulWidget {
  final String emergencyId;
  final String initialDescription;
  final String initialDetailedAddress;

  const UpdateEmergencyPage({
    Key? key,
    required this.emergencyId,
    this.initialDescription = '',
    this.initialDetailedAddress = '',
  }) : super(key: key);

  @override
  _UpdateEmergencyPageState createState() => _UpdateEmergencyPageState();
}

class _UpdateEmergencyPageState extends State<UpdateEmergencyPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _detailedAddressController =
      TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<XFile> _mediaList = []; // List to store uploaded media
  // Base URL for API
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';

  final int maxFileSizeInBytes = 10 * 1024 * 1024; // 10 MB Max single file size

  @override
  void initState() {
    super.initState();
    _descriptionController.text = widget.initialDescription;
    _detailedAddressController.text = widget.initialDetailedAddress;
  }

  void _pickMedia(ImageSource source) async {
    if (_mediaList.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum of 5 media files can be added.')),
      );
      return;
    }

    final XFile? file = await _picker.pickImage(source: source);
    if (file != null) {
      final File fileObject = File(file.path);
      final int fileSize = await fileObject.length();

      if (fileSize > maxFileSizeInBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                'File size exceeds the 10 MB limit. Please select a smaller file.'),
          ),
        );
        return;
      }

      setState(() {
        _mediaList.add(file);
      });
    }
  }

  void _showMediaPickerDialog() {
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
                label:
                    const Text('Camera', style: TextStyle(color: Colors.blue)),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  _pickMedia(ImageSource.gallery);
                },
                icon: const Icon(Icons.photo_library, color: Colors.blue),
                label:
                    const Text('Gallery', style: TextStyle(color: Colors.blue)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child:
                    const Text('Cancel', style: TextStyle(color: Colors.red)),
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
              child: const Text('No', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _mediaList.removeAt(index);
                });
                Navigator.pop(context);
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _submitUpdate() async {
    final String url = '$backendUrl/api/reports/update-reportlog';
    final String emergencyId = widget.emergencyId;
    final String description = _descriptionController.text;
    final String detailedAddress = _detailedAddressController.text;

    // Check if the description is empty
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Description is required before submitting.')),
      );
      return; // Stop submission
    }

    try {
      // Create a MultipartRequest to send media files and form data
      var request = http.MultipartRequest('POST', Uri.parse(url));
      request.fields['emergencyId'] = emergencyId;
      request.fields['description'] = description;
      request.fields['detailed_address'] = detailedAddress;

      // Attach media files
      for (var media in _mediaList) {
        request.files.add(await http.MultipartFile.fromPath(
          'mediaFiles',
          media.path,
        ));
      }

      // Send the request
      var response = await request.send();

      // Handle response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emergency updated successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: ${response.statusCode}')),
        );
      }
    } catch (e) {
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
          'Update Emergency',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter description',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Detailed Address (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _detailedAddressController,
              decoration: InputDecoration(
                hintText: 'Enter detailed address',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Supporting Media (Optional)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _showMediaPickerDialog,
              icon: const Icon(Icons.add_a_photo, color: Colors.blue),
              label: const Text('Upload Media',
                  style: TextStyle(color: Colors.blue)),
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
                : const Text('No media added yet.',
                    style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitUpdate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Update',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
