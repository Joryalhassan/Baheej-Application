import 'package:baheej/screens/SignInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:baheej/utlis/utilas.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class CsignUpScreen extends StatefulWidget {
  const CsignUpScreen({Key? key}) : super(key: key);

  @override
  _CsignUpScreenState createState() => _CsignUpScreenState();
}

class _CsignUpScreenState extends State<CsignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _passwordConfirmTextController =
      TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  TextEditingController _PhoneNumTextController = TextEditingController();
  TextEditingController _ComRegTextController = TextEditingController();
  TextEditingController _DescriptionTextController = TextEditingController();
  String? _selectedDistrict;
  String type = "center";

  UserCredential? resultaccount;
  Future<void> signUp() async {
    try {
      if (resultaccount == null) {
        // Check if passwords match before creating the account
        if (_passwordTextController.text !=
            _passwordConfirmTextController.text) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              content: const Text("Passwords do not match."),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Container(
                    color: Colors.green,
                    padding: const EdgeInsets.all(14),
                    child: const Text("OK"),
                  ),
                ),
              ],
            ),
          );
          return;
        }

        resultaccount =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passwordTextController.text,
        );
      }

      await FirebaseFirestore.instance
          .collection('center')
          .doc(resultaccount!.user!.uid)
          .set({
        'username': _userNameTextController.text.trim(),
        'addres': _selectedDistrict,
        'email': _emailTextController.text.trim(),
        'comReg': _ComRegTextController.text.trim(),
        'type': 'center',
        'phonenumber': _PhoneNumTextController.text.trim(),
        'Desc': _DescriptionTextController.text.trim()
      });

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => SignInScreen(),
        ),
        (route) => false, // Remove all previous routes
      );
      // Show success dialog here
      _showSuccessDialog();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: const Text("The password provided is too weak."),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Container(
                  color: Colors.green,
                  padding: const EdgeInsets.all(14),
                  child: const Text("OK"),
                ),
              ),
            ],
          ),
        );
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            content: const Text("Email already exists"),
            actions: <Widget>[
              Center(
                child: Container(
                  width: 90, // Adjust the width as needed
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              20), // Adjust the radius as needed
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: const Text(
                        "OK",
                        style: TextStyle(fontSize: 14, color: Colors.black),
                      ), // Adjust the font size as needed
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Center signed in successfully!'),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  //district drop down menu
  List<String> riyadhDistricts = [
    'Ad Diriyah',
    'Al Batha',
    'Al Dhahraniyah',
    'Al Malaz',
    'Al Manar',
    'Al Maizilah',
    'Al Muruj',
    'Al Olaya',
    'Al Rawdah',
    'Al Sulimaniyah',
    'Al Wadi',
    'Al Wizarat',
    'Al Worood',
    'An Nakheel',
    'As Safarat',
    'Diplomatic Quarter',
    'King Abdullah Financial District',
    'King Fahd District',
    'King Faisal District',
    'King Salman District',
    'King Saud University',
    'Kingdom Centre',
    'Masjid an Nabawi',
    'Medinah District',
    'Murabba',
    'Nemar',
    'Olaya',
    'Qurtubah',
    'Sulaymaniyah',
    'Takhasusi',
    'Umm Al Hamam',
    'Yasmeen',
  ];

  // Validation functions
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Center Name is required';
    }
    if (value.length < 4 || value.length > 25) {
      return 'Center Name must be between 4 and 25 letters';
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value)) {
      return 'Center Name can only contain letters and spaces';
    }
    if (value.trimLeft() != value) {
      return 'Center Name cannot start with a space';
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
    }
    if (value.length != 10) {
      return 'Phone Number must be exactly 10 digits';
    }
    final phoneRegex = RegExp(r'^05[0-9]{8}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Invalid Phone Number';
    }
    return null;
  }

  String? _validateCommercialRegister(String? value) {
    if (value == null || value.isEmpty) {
      return 'Commercial Register Number is required';
    } else if (value.length != 10) {
      return 'Commercial Register Number must be\nexactly 10 digits';
    } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Invalid Commercial Register Number';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.isEmpty) {
      return 'Description is required';
    }

    // Check if there is at least one alphabetic character in the description
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Description must contain at least one alphabetic\n character';
    }

    // Check if the description contains only letters, numbers, spaces, and special characters
    if (!RegExp(r'^[a-zA-Z0-9\s!@#\$%^&*()_+{}\[\]:;<>,.?~\\/-]+$')
        .hasMatch(value)) {
      return 'Description should contain only letters, numbers,\n spaces, or special characters';
    }

    if (value.length < 10 || value.length > 225) {
      return 'Description must be between 10 and 225 characters';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    // Check for at least one uppercase letter
    if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must include at least one uppercase letter,\none lowercase letter, one digit and between 8 and\n20 characters long';
    }

    // Check for at least one lowercase letter
    if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
      return 'Password must include at least one uppercase letter,\none lowercase letter, one digit and between 8 and\n20 characters long';
    }

    // Check for at least one digit
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must include at least one uppercase letter,\none lowercase letter, one digit and between 8 and\n20 characters long';
    }

    // Check for a minimum length of 8 characters
    if (value.length < 8 || value.length > 20) {
      return 'Password must include at least one uppercase letter,\none lowercase letter, one digit and between 8 and\n20 characters long';
    }

    return null;
  }

  String? _validatePasswordConfirmation(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirm Password is required';
    }

    if (value != _passwordTextController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up As Center",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      resizeToAvoidBottomInset: false,
      body: Stack(children: [
        // Background image
        Image.asset(
          'assets/images/blueWaves.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
        // Transparent container
        Container(
          margin: EdgeInsets.only(top: kToolbarHeight + 80),
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color:
                Colors.white.withOpacity(0.8), // Adjust the opacity as needed
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  //1
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Center Name",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _userNameTextController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        validator: _validateName,
                        maxLength: 25, // Add maxLength property here
                      ),
                    ],
                  ),

                  //2
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Email Id",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _emailTextController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.email),
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        validator: _validateEmail,
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  //3
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Phone Number",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _PhoneNumTextController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.phone),
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        validator: _validatePhoneNumber,
                        maxLength: 10, // Maximum length set to 10
                        keyboardType:
                            TextInputType.number, // Allow numeric keyboard
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Allow only numeric input
                        ],
                      ),
                    ],
                  ),

                  //4
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "District",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: _selectedDistrict ??
                            '', // Set an initial value here
                        items: [
                          DropdownMenuItem<String>(
                            value: '', // Add an empty value as an option
                            child: Text('Select a District'),
                          ),
                          ...riyadhDistricts.map((district) {
                            return DropdownMenuItem<String>(
                              value: district,
                              child: Text(district),
                            );
                          }).toList(),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedDistrict =
                                newValue; // Update the selected district when the user makes a choice
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || value == '') {
                            return 'Please select a valid district';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  //5
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Commercial Register Number",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _ComRegTextController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.format_list_numbered),
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        validator: _validateCommercialRegister,
                        maxLength: 10, // Maximum length set to 10
                        keyboardType:
                            TextInputType.number, // Allow numeric keyboard
                        inputFormatters: [
                          FilteringTextInputFormatter
                              .digitsOnly, // Allow only numeric input
                        ],
                      ),
                    ],
                  ),
                  //6
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Description",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _DescriptionTextController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.description),
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        validator: _validateDescription,
                        maxLength: 225,
                      ),
                    ],
                  ),

                  //7
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _passwordTextController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outlined),
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        validator: _validatePassword,
                        maxLength: 20,
                        obscureText:
                            true, // Set this property to make it a password field
                      ),
                    ],
                  ),

                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                        children: [
                          TextSpan(
                            text: "Password must include:\n",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: "• at least one uppercase letter\n",
                          ),
                          TextSpan(
                            text: "• at least one lowercase letter\n",
                          ),
                          TextSpan(
                            text: "• at least one digit\n",
                          ),
                          TextSpan(
                            text: "• between 8 and 20 characters long.",
                          ),
                        ],
                      ),
                    ),
                  ),

                  //8
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Confirm Password",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextFormField(
                        controller: _passwordConfirmTextController,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outlined),
                          filled: true,
                          fillColor: Colors.grey[300],
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                            borderSide: BorderSide(color: Colors.transparent),
                          ),
                        ),
                        validator: _validatePasswordConfirmation,
                        obscureText:
                            true, // Set this property to make it a password field
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Color.fromARGB(255, 59, 138, 207),
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            33.0), // Increase the border radius
                      ),
                      minimumSize: Size(150, 54), // Increase the button size
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        signUp();
                      }
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 18), // Increase the font size
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ]),
    );
  }
}
