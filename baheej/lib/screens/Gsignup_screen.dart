import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:baheej/screens/Home-Page.dart';
import 'package:baheej/utlis/utilas.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
import 'dart:convert';

class GSignUpScreen extends StatefulWidget {
  const GSignUpScreen({Key? key}) : super(key: key);

  @override
  _GSignUpScreenState createState() => _GSignUpScreenState();
}

class _GSignUpScreenState extends State {
  GlobalKey<FormState> _formKey = GlobalKey();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _FnameTextController = TextEditingController();
  TextEditingController _LnameTextController = TextEditingController();
  TextEditingController _PhoneNumTextController = TextEditingController();
  String? selectedGender;
  String type = "guardian";

  void sendDataToFirebase() async {
    final url = Uri.https('baheejdatabase-default-rtdb.firebaseio.com',
        'Gurdian-users.json'); // Replace with your Firebase Realtime Database URL

    final response = await http.post(
      url,
      body: json.encode({
        'firstName': _FnameTextController.text,
        'lastName': _LnameTextController.text,
        'email': _emailTextController.text,
        'phoneNum': _PhoneNumTextController.text,
        'gender': selectedGender,
        'type': type
      }),
    );

    if (response.statusCode == 200) {
      print(
          'User data added to Firebase Realtime Database'); // Optionally, you can navigate to the next screen or show a success message.
    } else {
      print(
          'Error adding user data to Firebase Realtime Database: ${response.reasonPhrase}'); // Handle the error, show an error message, etc.
    }
  }

  @override
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
        decoration: BoxDecoration(
          color: Colors.white, // Set the background color to white
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  buildStyledTextField(
                    label: "Enter First Name",
                    controller: _FnameTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'First Name is required';
                      }
                      // Use a regular expression to check if the value contains only letters
                      if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                        return 'First Name can only contain letters';
                      }
                      return null;
                    },
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildStyledTextField(
                    label: "Enter Last Name",
                    controller: _LnameTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Last Name is required';
                      }
                      // Use a regular expression to check if the value contains only letters
                      if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                        return 'Last Name can only contain letters';
                      }
                      return null;
                    },
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildStyledTextField(
                    label: "Enter Email Id",
                    controller: _emailTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email is required';
                      }
                      final emailRegex = RegExp(
                        r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$',
                      );
                      if (!emailRegex.hasMatch(value)) {
                        return 'Invalid Email format';
                      }
                      return null;
                    },
                    icon: Icons.email,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildStyledTextField(
                    label: "Enter Phone Number",
                    controller: _PhoneNumTextController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Phone Number is required';
                      }
                      final phoneRegex = RegExp(r'^[0-9]{10}$');
                      if (!phoneRegex.hasMatch(value)) {
                        return 'Invalid phone number';
                      }
                      return null;
                    },
                    icon: Icons.phone,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildStyledDropdownButtonFormField(
                    label: "Select Gender",
                    value: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    items: ["Male", "Female"],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Gender is required';
                      }
                      return null;
                    },
                    icon: Icons.person,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  buildStyledTextField(
                    label: "Enter Password",
                    controller: _passwordTextController,
                    validator: (value) {
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
                    },
                    icon: Icons.lock_outlined,
                    obscureText: true,
                  ),

                  ElevatedButton(
                    onPressed: () {
                      // Button action
                      if (_formKey.currentState!.validate()) {
                        FirebaseAuth.instance
                            .createUserWithEmailAndPassword(
                          email: _emailTextController.text,
                          password: _passwordTextController.text,
                        )
                            .then((value) {
                          print("Created New Account");
                          sendDataToFirebase();
                          // Send user data to Firebase
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeScreen(),
                            ),
                          );
                        }).onError((error, stackTrace) {
                          print("Error ${error.toString()}");
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 111, 176, 234),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      minimumSize: Size(120, 50),
                    ),
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20.0),
                    ),
                  ),

                  ////////b
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

  Widget buildStyledDropdownButtonFormField({
    required String label,
    required String? value,
    required void Function(String?) onChanged,
    required List<String> items,
    required String? Function(String?) validator,
    required IconData icon,
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
            child: DropdownButtonFormField<String>(
              value: value,
              onChanged: onChanged,
              items: items
                  .map<DropdownMenuItem<String>>(
                    (String value) => DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              decoration: InputDecoration(
                labelText: '',
                icon: Icon(icon),
                border: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              ),
              validator: validator,
            ),
          ),
        ],
      ),
    );
  }
}
