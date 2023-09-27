import 'package:baheej/screens/SignInScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GSignUpScreen extends StatefulWidget {
  const GSignUpScreen({Key? key}) : super(key: key);

  @override
  _GSignUpScreenState createState() => _GSignUpScreenState();
}

class _GSignUpScreenState extends State<GSignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordTextController = TextEditingController();
  final TextEditingController _emailTextController = TextEditingController();
  final TextEditingController _FnameTextController = TextEditingController();
  final TextEditingController _LnameTextController = TextEditingController();
  final TextEditingController _PhoneNumTextController = TextEditingController();
  String? selectedGender;
  String type = "guardian";

  UserCredential? resultaccount;

  Future<void> signspup() async {
    try {
      if (resultaccount == null) {
        resultaccount =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailTextController.text,
          password: _passwordTextController.text,
        );
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(resultaccount!.user!.uid)
          .set({
        'fname': _FnameTextController.text.trim(),
        'lname': _LnameTextController.text.trim(),
        'email': _emailTextController.text.trim(),
        'type': 'guardian',
        'phonenumber': _PhoneNumTextController.text.trim(),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sign Up As Guardian",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Stack(children: [
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
                        controller: _FnameTextController,
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'First Name is required';
                          }
                          if (value.length < 2 || value.length > 12) {
                            return 'First Name must be between 2 and 12 letters';
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'First Name can only contain letters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Last Name",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      TextFormField(
                        controller: _LnameTextController,
                        decoration: InputDecoration(
                          // labelText: "Enter Last Name",
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Last Name is required';
                          }
                          if (value.length < 2 || value.length > 12) {
                            return 'Last Name must be between 2 and 12 letters';
                          }
                          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
                            return 'Last Name can only contain letters';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
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
                          //   labelText: "Enter Email Id",
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Email is required';
                          }
                          final emailRegex = RegExp(
                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                          if (!emailRegex.hasMatch(value)) {
                            return 'Invalid Email format';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
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
                          // labelText: "Enter Phone Number",
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Phone Number is required';
                          }
                          final phoneRegex = RegExp(r'^05[0-9]{8}$');
                          if (!phoneRegex.hasMatch(value)) {
                            return 'Invalid Phone Number';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 20,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Select Gender",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      DropdownButtonFormField<String>(
                        value: selectedGender,
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                        items: ["Male", "Female"]
                            .map<DropdownMenuItem<String>>(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                        decoration: InputDecoration(
                          // labelText: "Select Gender",
                          prefixIcon: Icon(Icons.person),
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
                          if (value == null || value.isEmpty) {
                            return 'Gender is required';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
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
                        obscureText: true,
                        decoration: InputDecoration(
                          // labelText: "Enter Password",
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password is required';
                          }
                          if (!RegExp(r'^(?=.*[A-Z])').hasMatch(value)) {
                            return 'Password must include at least one uppercase letter';
                          }
                          if (!RegExp(r'^(?=.*[a-z])').hasMatch(value)) {
                            return 'Password must include at least one lowercase letter';
                          }
                          if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
                            return 'Password must contain at least one digit';
                          }
                          if (value.length < 8 || value.length > 20) {
                            return 'Password must be between 8 and 20 characters long';
                          }
                          return null;
                        },
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
                        signspup();
                      }
                    },
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 20), // Increase the font size
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

  Color hexStringToColor(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.isNotEmpty && hexColor.length == 6) {
      buffer.write('ff');
    }
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}