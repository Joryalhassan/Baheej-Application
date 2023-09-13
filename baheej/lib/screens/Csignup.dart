import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:baheej/screens/Home-Page.dart';
import 'package:baheej/utlis/utilas.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
import 'dart:convert';

class CsignUpScreen extends StatefulWidget {
  const CsignUpScreen({Key? key}) : super(key: key);

  @override
  _CsignUpScreenState createState() => _CsignUpScreenState();
}

class _CsignUpScreenState extends State<CsignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _PhoneNumTextController = TextEditingController();
  TextEditingController _AddressTextController = TextEditingController();
  TextEditingController _ComRegTextController = TextEditingController();
  TextEditingController _DescriptionTextController = TextEditingController();
  String type = "center";

  // Validation functions
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Center Name is required';
    }
    if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
      return 'Center Name should only contain letters';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)+$').hasMatch(value)) {
      return 'Invalid Email format';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone Number is required';
    } else if (!RegExp(r'^05\d{8}$').hasMatch(value)) {
      return 'Invalid Phone Number';
    }
    return null;
  }

  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'Address is required';
    }
    return null;
  }

  String? _validateCommercialRegister(String? value) {
    if (value == null || value.isEmpty) {
      return 'Commercial Register is required';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    // Check for at least one uppercase letter
    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must include at least one uppercase letter';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
      return 'Password must include at least one lowercase letter';
    }

    // Check for at least one digit
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must contain at least one digit';
    }

    // Check for a minimum length of 6 characters
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    return null;
  }

  void sendDataToFirebase() async {
    final url = Uri.https(
        'baheejdatabase-default-rtdb.firebaseio.com', 'Center-users.json');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'centerName': _userNameTextController.text,
          'email': _emailTextController.text,
          'phoneNum': _PhoneNumTextController.text,
          'address': _AddressTextController.text,
          'commercialRegister': _ComRegTextController.text,
          'description': _DescriptionTextController.text,
          'type': type
        }),
      );

      if (response.statusCode == 200) {
        print('Center data added to Firebase Realtime Database');
        // Optionally, you can navigate to the next screen or show a success message.
      } else {
        print(
            'Error adding center data to Firebase Realtime Database: ${response.reasonPhrase}');
        // Handle the error, show an error message, etc.
      }
    } catch (e) {
      print('Error sending data to Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white, // Set the background color to white
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  buildStyledTextField(
                    label: "Enter Center Name",
                    controller: _userNameTextController,
                    validator: _validateName,
                    icon: Icons.person_outline,
                  ),
                  buildStyledTextField(
                    label: "Enter Email Id",
                    controller: _emailTextController,
                    validator: _validateEmail,
                    icon: Icons.email,
                  ),
                  buildStyledTextField(
                    label: "Enter Phone Number",
                    controller: _PhoneNumTextController,
                    validator: _validatePhoneNumber,
                    icon: Icons.phone,
                  ),
                  buildStyledTextField(
                    label: "Enter Address",
                    controller: _AddressTextController,
                    validator: _validateAddress,
                    icon: Icons.home,
                  ),
                  buildStyledTextField(
                    label: "Enter Commercial Register",
                    controller: _ComRegTextController,
                    validator: _validateCommercialRegister,
                    icon: Icons.format_list_numbered,
                  ),
                  buildStyledTextField(
                    label: "Enter Description",
                    controller: _DescriptionTextController,
                    validator: _validateDescription,
                    icon: Icons.description,
                  ),
                  buildStyledTextField(
                    label: "Enter Password",
                    controller: _passwordTextController,
                    validator: _validatePassword,
                    icon: Icons.lock_outlined,
                    obscureText: true,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        // Form is valid, proceed with registration
                        FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text,
                        )
                            .then((value) {
                          print("Created New Account");
                          sendDataToFirebase(); // Send center data to Firebase
                          // Optionally, navigate to the home screen or show a success message.
                        }).onError((error, stackTrace) {
                          print("Error ${error.toString()}");
                          // Handle the error, show an error message, etc.
                        });
                      }
                    },
                    child: Text("Sign Up"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildStyledTextField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.0),
              color: Colors.grey[300], // Set the background color to grey
            ),
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: '',
                icon: Icon(icon),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
              validator: validator,
              obscureText: obscureText,
            ),
          ),
        ],
      ),
    );
  }
}
