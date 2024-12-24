import 'package:flutter/material.dart';
import 'bottom_nav_bar.dart'; // Import the BottomNavigationFAB
import 'login_page.dart'; // Import the LoginPage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MyProfilePage extends StatefulWidget {
  const MyProfilePage({Key? key}) : super(key: key);

  @override
  _MyProfilePageState createState() => _MyProfilePageState();
}

class _MyProfilePageState extends State<MyProfilePage> {
  // Sample user data
  final Map<String, String> userProfile = {
    'name': 'John Doe',
    'email': 'johndoe@example.com',
    'phone': '+60123456789',
    'address': '123 Main St, Kuala Lumpur',
  };

  bool isEditable = false;

  // Controllers for text fields
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final _secureStorage = FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // Initialize controllers with user profile data
    nameController.text = userProfile['name']!;
    emailController.text = userProfile['email']!;
    phoneController.text = userProfile['phone']!;
    addressController.text = userProfile['address']!;
  }

  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void toggleEdit() {
    if (isEditable) {
      // Save profile changes
      setState(() {
        userProfile['name'] = nameController.text;
        userProfile['email'] = emailController.text;
        userProfile['phone'] = phoneController.text;
        userProfile['address'] = addressController.text;
        isEditable = false;
      });

      // Show confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      // Switch to edit mode
      setState(() {
        isEditable = true;
      });
    }
  }

  Future<void> logOut() async {
    await _secureStorage.delete(key: 'userId');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('My Profile',
            style: TextStyle(color: Colors.tealAccent)),
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name Field
            const Text(
              'Name',
              style: TextStyle(color: Colors.tealAccent, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nameController,
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

            // Email Field
            const Text(
              'Email',
              style: TextStyle(color: Colors.tealAccent, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
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

            // Phone Field
            const Text(
              'Phone',
              style: TextStyle(color: Colors.tealAccent, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: phoneController,
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

            // Address Field
            const Text(
              'Address',
              style: TextStyle(color: Colors.tealAccent, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: addressController,
              readOnly: !isEditable,
              style:
                  TextStyle(color: isEditable ? Colors.black45 : Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: isEditable ? Colors.white : Colors.black45,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Update/Save Button
            Center(
              child: ElevatedButton(
                onPressed: toggleEdit,
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
                child: Text(
                  isEditable ? 'Save' : 'Update',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
            const Spacer(),

            // Log Out Button
            Center(
              child: ElevatedButton(
                onPressed: logOut,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 100,
                    vertical: 13,
                  ),
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
      bottomNavigationBar:
          const BottomNavigation(currentIndex: 3), // Navigation FAB
    );
  }
}
