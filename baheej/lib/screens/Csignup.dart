import 'package:baheej/screens/SignInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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

  UserCredential? resultaccount;
  Future<void> signUp() async {
    try {
      if (resultaccount == null) {
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
        'addres': _AddressTextController.text.trim(),
        'email': _emailTextController.text.trim(),
        'comReg': _ComRegTextController.text.trim(),
        'type': 'center',
        'phonenumber': _PhoneNumTextController.text.trim(),
        'Desc': _DescriptionTextController.text.trim()
      });

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SignInScreen()),
      );
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
    _showSnackBar('create account successfully!');
  }

  void _showSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),

      backgroundColor: Colors.green,

      duration:
          Duration(seconds: 3), // Duration for which the SnackBar is displayed
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  // Validation functions
  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Center Name is required';
    }

    if (value.length < 4 || value.length > 25) {
      return 'Center Name must be between 4 and 25 letters';
    }

    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value)) {
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

    // Check if there is at least one alphabetic character in the address
    if (!RegExp(r'[a-zA-Z]').hasMatch(value)) {
      return 'Address must contain at least one alphabetic\n character';
    }

    // Check if the address contains only letters, numbers, or spaces
    if (!RegExp(r'^[a-zA-Z0-9\s]+$').hasMatch(value)) {
      return 'Address must contain only letters, numbers,\n or spaces';
    }

    if (value.length < 5 || value.length > 35) {
      return 'Address must be between 5 and 35 characters';
    }

    return null;
  }

  String? _validateCommercialRegister(String? value) {
    if (value == null || value.isEmpty) {
      return 'Commercial Register Number is required';
    }

    // Check if the value consists of exactly 10 numbers
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Commercial Register Number must contain exactly 10 numbers';
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
      return 'Description shoumustld contain only letters, numbers,\n spaces, or special characters';
    }

    if (value.length < 10 || value.length > 100) {
      return 'Description must be between 10 and 100 characters';
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
    if (value.length < 8 || value.length > 20) {
      return 'Password must be between 8 and 20 characters long';
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
      body: Stack(
        children: [
          // Background image
          Image.asset(
            'assets/images/back3.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            //color: Colors.white,
          ),

          SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
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
                            "First Name",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                            "Address",
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextFormField(
                          controller: _AddressTextController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.home),
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
                          validator: _validateAddress,
                        ),
                      ],
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
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                                fontSize: 16, fontWeight: FontWeight.bold),
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
                          obscureText: true,
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
                        style:
                            TextStyle(fontSize: 18), // Increase the font size
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}