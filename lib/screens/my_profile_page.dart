import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'login_page.dart';
import 'bottom_nav_bar.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  final Map<String, String> userProfile = {};

  bool isEditable = false;

  // Controllers for editable text fields
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();

  // States List
  final List<String> _states = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Malacca',
    'Negeri Sembilan',
    'Pahang',
    'Penang',
    'Perak',
    'Perlis',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
  ];

  // Selected state
  String? selectedState;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // API Base URL (Update this to match your backend)
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';

  Future<void> _fetchUserProfile() async {
    final userId = await _secureStorage.read(key: 'userId');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to retrieve user ID.')),
      );
      return;
    }

    final url = '$backendUrl/api/user/$userId'; // Replace with your backend URL

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          userProfile['ic'] = data['ic'];
          userProfile['name'] = data['name'];
          userProfile['email'] = data['email'];
          userProfile['phone'] = data['phonenumber'];
          userProfile['address'] = data['address'];
          userProfile['state'] = data['state'];
          phoneController.text = data['phonenumber'];
          addressController.text = data['address'];
          selectedState = data['state'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch user data: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching user data: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void toggleEdit() async {
    if (isEditable) {
      // Validate phone number
      final phone = phoneController.text.trim();
      if (!RegExp(r'^\+60\d{9,10}$').hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Enter a valid Malaysian phone number (include "+60").')),
        );
        return; // Stop saving if validation fails
      }

      // Validate address
      final address = addressController.text.trim();
      if (address.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address is required.')),
        );
        return; // Stop saving if validation fails
      }

      // Prepare payload
      final userId = await _secureStorage.read(key: 'userId');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to retrieve user ID.')),
        );
        return;
      }

      final payload = {
        "phonenumber": phone,
        "address": address,
        "state": selectedState,
      };

      final url =
          '$backendUrl/api/user/$userId/update'; // Replace with your backend URL

      try {
        final response = await http.put(
          Uri.parse(url),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200) {
          setState(() {
            userProfile['phone'] = phone;
            userProfile['address'] = address;
            userProfile['state'] = selectedState!;
            isEditable = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated successfully!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update profile: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } else {
      setState(() {
        isEditable = true;
      });
    }
  }

  Future<void> logOut() async {
    final userId = await _secureStorage.read(key: 'userId');
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to retrieve user ID.')),
      );
      return;
    }

    final url =
        '$backendUrl/api/fcm/delete?userId=$userId'; // Replace with your backend URL

    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 204) {
        // Token deleted successfully
        await _secureStorage.delete(key: 'userId');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete token: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting token: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userProfile.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('My Profile',
            style: TextStyle(color: Colors.tealAccent)),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildDisplayField('IC', userProfile['ic']!),
            buildDisplayField('Name', userProfile['name']!),
            buildDisplayField('Email', userProfile['email']!),
            buildEditableField('Phone', phoneController),
            buildEditableField('Address  (Street No, Residential Area, City)',
                addressController),
            buildStateDropdown(),

            const SizedBox(height: 30),

            // Update/Save Button
            Center(
              child: ElevatedButton(
                onPressed: toggleEdit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.tealAccent,
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  isEditable ? 'Save' : 'Update',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),

            const SizedBox(height: 70),

            // Log Out Button
            Center(
              child: ElevatedButton(
                onPressed: logOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 100, vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Log Out',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavigation(currentIndex: 3),
    );
  }

  // Helper function for display-only fields
  Widget buildDisplayField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.tealAccent, fontSize: 12),
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            value,
            style: const TextStyle(
                color: Color.fromARGB(255, 206, 163, 163), fontSize: 16),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Helper function for editable fields
  Widget buildEditableField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.tealAccent, fontSize: 16),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          readOnly: !isEditable,
          style: TextStyle(color: isEditable ? Colors.black : Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: isEditable ? Colors.white : Colors.black45,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // Helper function for state dropdown
  Widget buildStateDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'State',
          style: TextStyle(color: Colors.tealAccent, fontSize: 16),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isEditable ? Colors.white : Colors.black45,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButton<String>(
            value: selectedState,
            isExpanded: true,
            dropdownColor: Colors.white,
            underline: Container(), // Remove default underline
            iconEnabledColor: Colors.tealAccent,
            onChanged: isEditable
                ? (String? newValue) {
                    setState(() {
                      selectedState = newValue;
                    });
                  }
                : null,
            items: _states.map((String state) {
              return DropdownMenuItem<String>(
                value: state,
                child: Text(
                  state,
                  style: TextStyle(
                    color: isEditable ? Colors.black : Colors.white,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
