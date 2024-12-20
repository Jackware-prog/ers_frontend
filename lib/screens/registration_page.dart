import 'package:flutter/material.dart';

class RegistrationPage extends StatelessWidget {
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
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black
                        .withOpacity(0.7), // Semi-transparent background
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
                      // Full Name
                      _buildTextField(label: 'Full Name'),
                      const SizedBox(height: 15),
                      // Gender
                      _buildDropdown(
                        label: 'Gender',
                        items: ['Male', 'Female'],
                      ),
                      const SizedBox(height: 15),
                      // Identification Type
                      _buildDropdown(
                        label: 'Identification Type',
                        items: ['IC', 'Passport'],
                      ),
                      const SizedBox(height: 15),
                      // Identification Number
                      _buildTextField(
                          label: 'Identification Number/Passport Number'),
                      const SizedBox(height: 15),
                      // Phone Number
                      _buildTextField(
                          label: 'Phone Number (+60)',
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 15),
                      // Address
                      _buildTextField(label: 'Address'),
                      const SizedBox(height: 15),
                      // State
                      _buildDropdown(
                        label: 'State',
                        items: ['State1', 'State2'],
                      ),
                      const SizedBox(height: 25),
                      // Register Button
                      Center(
                        child: ElevatedButton(
                          onPressed: () {
                            // Handle registration logic here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.tealAccent,
                            foregroundColor: Colors.black,
                            padding: EdgeInsets.symmetric(
                                horizontal: 50, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
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
        ],
      ),
    );
  }

  // Function to build TextField
  Widget _buildTextField({required String label, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 5),
        TextField(
          keyboardType: keyboardType,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter $label...',
            hintStyle: TextStyle(color: Colors.white54),
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

  // Function to build Dropdown
  Widget _buildDropdown({required String label, required List<String> items}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.white70),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
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
                    child: Text(item, style: TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: (value) {},
        ),
      ],
    );
  }
}
