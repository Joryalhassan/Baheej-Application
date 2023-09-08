import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:baheej/reusable_widget/reusable_widget.dart';
import 'package:baheej/screens/home-page.dart';
import 'package:baheej/utlis/utilas.dart';

class GSignUpScreen extends StatefulWidget {
  const GSignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<GSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _FnameTextController = TextEditingController();
  TextEditingController _LnameTextController = TextEditingController();
  TextEditingController _PhoneNumTextController = TextEditingController();
  String? selectedGender;

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
          gradient: LinearGradient(colors: [
            hexStringToColor("CB2B93"),
            hexStringToColor("9546C4"),
            hexStringToColor("5E61F4"),
          ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
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
                  TextFormField(
                    controller: _FnameTextController,
                    decoration: InputDecoration(
                      labelText: "Enter First Name",
                      icon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your first name';
                      }
                      return null;
                    },
                  ),



         const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _LnameTextController,
                    decoration: InputDecoration(
                      labelText: "Enter Last Name",
                      icon: Icon(Icons.person_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your last name';
                      }
                      return null;
                    },
                  ),
           

          const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _emailTextController,
                    decoration: InputDecoration(
                      labelText: "Enter Email Id",
                      icon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
               

            const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _PhoneNumTextController,
                    decoration: InputDecoration(
                      labelText: "Enter Phone Number",
                      icon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      final phoneRegex = RegExp(r'^[0-9]{10}$');
                      if (!phoneRegex.hasMatch(value)) {
                        return 'Please enter a valid 10-digit phone number';
                      }
                      return null;
                    },
                  ),
            

             const SizedBox(
                    height: 20,
                  ),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    items: ["Male", "Female", "Other"]
                        .map<DropdownMenuItem<String>>(
                          (String value) => DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          ),
                        )
                        .toList(),
                    decoration: InputDecoration(
                      labelText: "Select Gender",
                      icon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your gender';
                      }
                      return null;
                    },
                  ),
                





           const SizedBox(
                    height: 20,
                  ),
                  TextFormField(
                    controller: _passwordTextController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Enter Password",
                      icon: Icon(Icons.lock_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (!RegExp(r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*()_+|~-]).{8,}$').hasMatch(value)) {
                        return 'Password must include at least one uppercase letter, one lowercase letter, one digit, and one special character';
                      }
                      return null;
                    },
                  ),
               


           const SizedBox(
                    height: 20,
                  ),
                  firebaseUIButton(context, "Sign Up", () {
                    if (_formKey.currentState!.validate()) {
                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                              email: _emailTextController.text,
                              password: _passwordTextController.text)
                          .then((value) {
                        print("Created New Account");
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
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
