import 'package:flutter/material.dart';

class UpdateEmergencyPage extends StatelessWidget {
  final String emergencyId;
  final String title;

  const UpdateEmergencyPage({
    Key? key,
    required this.emergencyId,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController descriptionController = TextEditingController();
    final TextEditingController detailedAddressController =
        TextEditingController();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(title),
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
            // Description Field
            const Text(
              'Description',
              style: TextStyle(color: Colors.tealAccent, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter description',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black87,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Detailed Address Field
            const Text(
              'Detailed Address (Optional)',
              style: TextStyle(color: Colors.tealAccent, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: detailedAddressController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter Level/Unit details',
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black87,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Supporting Media Field
            const Text(
              'Supporting Media (Optional)',
              style: TextStyle(color: Colors.tealAccent, fontSize: 16),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: () {
                // Handle media upload
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Media upload feature coming soon')),
                );
              },
              icon: const Icon(Icons.upload_file, color: Colors.black),
              label: const Text(
                'Upload Media',
                style: TextStyle(color: Colors.black),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.tealAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Handle submit action
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Emergency updated successfully')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Update',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
