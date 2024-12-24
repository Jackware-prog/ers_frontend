import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  // Selected state
  String? _selectedState;

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

  // API Base URL (Update this to match your backend)
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:8080';

  // Method to register user
  Future<void> _registerUser() async {
    // Prepare the payload
    final payload = {
      "ic": _idController.text,
      "name": _nameController.text,
      "password": _passwordController.text,
      "email": _emailController.text,
      "phonenumber": _phoneController.text,
      "address": _addressController.text,
      "state": _selectedState,
    };

    try {
      // Make the POST request
      final response = await http.post(
        Uri.parse("$backendUrl/api/user/auth/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      // Handle response
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Registration Successful',
              style: TextStyle(color: Colors.white), // Text color
            ),
            backgroundColor: Colors.green, // SnackBar background color
            duration:
                const Duration(seconds: 1), // Show the SnackBar for 1 second
          ),
        );

        // Wait for 1.5 seconds before navigating back
        await Future.delayed(const Duration(milliseconds: 1500));

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration Failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image/GIF
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/background.gif'), // Replace with your path
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Registration Form
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Form(
                  key: _formKey,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Center(
                          child: Text(
                            'Register',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Identification Number
                        _buildTextField(
                          label: 'Identification Number',
                          controller: _idController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Identification Number is required';
                            }
                            if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                              return 'Must be 12 digits and contain only numbers';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Full Name
                        _buildTextField(
                          label: 'Full Name',
                          controller: _nameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Full Name is required';
                            }
                            if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
                              return 'Name must contain only alphabets';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Password
                        _buildTextField(
                          label: 'Password',
                          controller: _passwordController,
                          isObscured: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password is required';
                            }
                            if (value.length < 8) {
                              return 'Password must be at least 8 characters';
                            }
                            if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).{8,}$')
                                .hasMatch(value)) {
                              return 'Password must contain letters and numbers';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 15),

                        // Email
                        _buildTextField(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email is required';
                            }
                            if (!RegExp(
                                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Phone Number
                        _buildTextField(
                          label: 'Phone Number (+60)',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Phone Number is required';
                            }
                            if (!RegExp(r'^\+60\d{9,10}$').hasMatch(value)) {
                              return 'Enter a valid Malaysian phone number include \n "+60"';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // Address (Street, Residential Area, City)
                        _buildTextField(
                          label: 'Address (Street No, Residential Area, City)',
                          controller: _addressController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Street is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // State Dropdown
                        _buildDropdown(
                          label: 'State',
                          items: _states,
                          value: _selectedState,
                          onChanged: (value) {
                            setState(() {
                              _selectedState = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'State is required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),

                        // Register Button
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _registerUser(); // Call the registration API
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.tealAccent,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Register',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TextField Widget with Validation
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    bool isObscured = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isObscured,
          validator: validator,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter $label...',
            hintStyle: const TextStyle(color: Colors.white54),
            filled: true,
            fillColor: Colors.black54,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  // Dropdown Widget with Validation
  Widget _buildDropdown({
    required String label,
    required List<String> items,
    required String? value,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black54,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
          dropdownColor: Colors.black87,
          items: items
              .map((item) => DropdownMenuItem(
                    value: item,
                    child:
                        Text(item, style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
